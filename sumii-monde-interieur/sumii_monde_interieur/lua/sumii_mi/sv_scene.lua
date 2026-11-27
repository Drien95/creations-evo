-- Serveur : état de la scène, commandes du MJ (console seulement), rattrapage, cible, gel du plaquage, effacement total.
local C, Q, N, K, T = SumiiMI.config, SumiiMI.sequence, SumiiMI.reseau, SumiiMI.cible, SumiiMI.terriers
local PLAN = include("sumii_mi/sv_plan.lua")
local A = SumiiAncre

for _, m in ipairs({ "sumii_mi_etat", "sumii_mi_demande", "sumii_mi_tout" }) do util.AddNetworkString(m) end
local acces = CreateConVar(C.CONVAR_ACCES, "0", FCVAR_ARCHIVE, "1 : tout le monde peut mener la scène (banc)", 0, 1)

local S = Q.neuf()
local jeu = { cible = nil, arrancar = nil, gele = nil, versions = {}, confirme = {} }

local function estMJ(p) return not IsValid(p) or acces:GetBool() or p:IsAdmin() or C.MJ[p:SteamID()] == true end
local function dire(p, texte)
	if IsValid(p) then p:PrintMessage(HUD_PRINTCONSOLE, "[sumii] " .. texte .. "\n") else print("[sumii] " .. texte) end
end
local function fiches(mj)
	local l = {}
	for _, p in ipairs(player.GetAll()) do
		l[#l + 1] = { p = p, nom = p:Nick(), sid = p:SteamID(), dedans = A.dedans(p:GetPos()), mj = p == mj or p:IsAdmin() or C.MJ[p:SteamID()] == true }
	end
	return l
end
local function fiche(l, p)
	for _, j in ipairs(l) do if j.p == p then return j end end
end
local function cibleActuelle(mj)
	if IsValid(jeu.cible) then return jeu.cible end
	local l = fiches(mj)
	local j, motif = K.defaut(l, fiche(l, jeu.arrancar))
	return j and j.p, motif
end

local function envoyer(p)
	net.Start("sumii_mi_etat")
	N.ecrire(net, Q, S)
	local c = cibleActuelle()
	net.WriteUInt(IsValid(c) and c:EntIndex() or 0, 16)
	net.WriteUInt(IsValid(jeu.arrancar) and jeu.arrancar:EntIndex() or 0, 16)
	net.WriteBool(estMJ(p))
	net.Send(p)
	jeu.versions[p] = S.v
end
local function relais()
	if not A.tete() then return end
	for _, p in ipairs(player.GetAll()) do
		if jeu.versions[p] ~= S.v and (A.dedans(p:GetPos()) or estMJ(p)) then envoyer(p) end
	end
end
local function reveiller()
	if not timer.Exists("sumii_mi_relais") then timer.Create("sumii_mi_relais", C.RELAIS, 0, relais) end
end

local function liberer()
	if IsValid(jeu.gele) then jeu.gele:Freeze(false) end
	jeu.gele = nil
	timer.Remove("sumii_mi_gel")
	hook.Remove("Think", "sumii_mi_gel")
end
local function geler(p, mj)
	liberer()
	jeu.gele = p
	p:Freeze(true)
	timer.Create("sumii_mi_gel", 1, Q.GEL - 1, function()
		local r = math.ceil(Q.gel(S, CurTime()))
		if r > 0 then dire(mj, "plaquage en cours, " .. r .. " s") end
	end)
	hook.Add("Think", "sumii_mi_gel", function()
		if Q.gel(S, CurTime()) <= 0 then liberer() dire(mj, "plaquage fini, cible libre") end
	end)
end

local function resume(p)
	local e, s = Q.SEQ[S.i], Q.SEQ[S.i + 1]
	local c, motif = cibleActuelle(p)
	dire(p, string.format("temps : %s · suivant : %s", e and e.cmd or "repos", s and s.cmd or "rien"))
	dire(p, string.format("cible : %s · Arrancar : %s", IsValid(c) and c:Nick() or motif, IsValid(jeu.arrancar) and jeu.arrancar:Nick() or "non désigné"))
end

local function lancer(p, cle, terrier)
	local c, motif = cibleActuelle(p)
	if not IsValid(c) then dire(p, "rien n'est lancé : " .. motif) return end
	local bon, refus = Q.lancer(S, cle, CurTime(), terrier)
	if not bon then dire(p, refus) return end
	if cle == "detresse" then                               -- gardé dans l'état : un arrivant voit le tas au même endroit
		local ou = A.versBuild(c:GetPos())
		S.lieu = { ou.x, ou.y, ou.z }
	end
	if cle == "plaquer" then geler(c, p) else liberer() end
	resume(p)
end

local function terrierVise(p)
	if not IsValid(p) or not A.tete() then return nil end
	local vise = A.versBuild(p:GetEyeTrace().HitPos)
	local meilleur, dist = nil, 300
	for n, t in ipairs(T) do
		local d = math.sqrt((vise.x - t.x) ^ 2 + (vise.y - t.y) ^ 2)
		if d < dist then meilleur, dist = n, d end
	end
	return meilleur
end

-- la plaque sous le point visé : des rochers sont posés dessus, le rayon les traverse et ne retient que les plaques
local function plaqueVisee(p)
	local depart = p:EyePos()
	return util.TraceLine({ start = depart, endpos = depart + p:GetAimVector() * 6000, ignoreworld = true,
		filter = function(e) return e:GetClass() == "prop_physics" and string.lower(e:GetModel() or "") == C.REPERE.modele end }).Entity
end
local function designer(p, texte, champ)
	-- texte brut : la console découpe aux deux-points, un SteamID recollé depuis les arguments ne correspondrait plus
	texte = string.Trim((string.gsub(texte or "", '"', "")))
	local j, motif
	if texte == "" then
		local vu = IsValid(p) and p:GetEyeTrace().Entity
		if IsValid(vu) and vu:IsPlayer() then j = { p = vu } else motif = "regarde le joueur, ou donne un bout de nom ou un SteamID" end
	else
		j, motif = K.parTexte(fiches(p), texte)
	end
	if not j then dire(p, motif) return end
	jeu[champ] = j.p
	local autre = champ == "arrancar" and "cible" or "arrancar"   -- un joueur ne tient qu'un rôle à la fois
	if jeu[autre] == j.p then jeu[autre] = nil end
	S.v = S.v + 1
	resume(p)
end

local function retirerBuild()
	if not A.tete() then return 0, #PLAN end
	local restants, n = {}, 0
	for _, e in ipairs(ents.FindByClass("prop_physics")) do restants[#restants + 1] = e end
	local aRetirer = {}
	for _, ligne in ipairs(PLAN) do                          -- chaque prop pris une fois, à sa place du plan
		for k, e in ipairs(restants) do
			if e and string.lower(e:GetModel() or "") == ligne[1] and A.versBuild(e:GetPos()):Distance(Vector(ligne[2], ligne[3], ligne[4])) < 4 then
				aRetirer[#aRetirer + 1], restants[k] = e, false
				break
			end
		end
	end
	for _, e in ipairs(aRetirer) do e:Remove() n = n + 1 end   -- après la recherche : le repère sert jusqu'au bout
	return n, #PLAN
end

local COMMANDES = {
	sumii_suite = function(p)
		local cle = Q.suivant(S)
		if not cle then dire(p, "dernier temps atteint") return end
		lancer(p, cle)
	end,
	sumii_retour = function(p)
		local cle = Q.retour(S)
		if not cle then dire(p, "rien à annuler") return end
		if cle == "plaquer" then liberer() end
		resume(p)
	end,
	sumii_flash = function(p, args)
		local n = tonumber(args[1] or "")
		if not Q.index["flash" .. tostring(n)] then dire(p, "sumii_flash 1, 2 ou 3") return end
		lancer(p, "flash" .. n)
	end,
	sumii_reveler = function(p, args) lancer(p, "reveler", tonumber(args[1] or "") or terrierVise(p)) end,
	sumii_fouiller = function(p, args)
		local n, resultat = tonumber(args[1] or ""), args[2]
		if not n then n, resultat = terrierVise(p), args[1] end
		local bon, refus = Q.fouiller(S, n, resultat, CurTime())
		dire(p, bon and ("terrier " .. n .. " fouillé : " .. S.terriers[n].mode) or refus)
	end,
	sumii_ici = function(p)
		local n = terrierVise(p)
		dire(p, n and ("terrier visé : " .. n) or "aucun terrier près du point visé")
	end,
	sumii_reconstruire = function(p) liberer() Q.reconstruire(S, CurTime()) resume(p) end,
	-- secours si le motif n'est pas reconnu : vise la plaque centrale ; sans rien viser, on revient à la détection
	sumii_ancre = function(p)
		local vu = IsValid(p) and plaqueVisee(p)
		local bonne = IsValid(vu)
		SetGlobalEntity("sumii_mi_ancre", bonne and vu or NULL)
		A.oublier()
		S.v = S.v + 1
		if bonne then dire(p, "repère désigné à la main")
		else dire(p, "désignation retirée : " .. (A.tete() and "build reconnu à sa disposition" or "aucun build reconnu")) end
	end,
	sumii_etat = function(p)
		A.oublier()
		dire(p, A.tete() and (A.designee() and "repère désigné à la main" or "build reconnu à sa disposition") or "aucun build reconnu (voir sumii_ancre)")
		if IsValid(p) then envoyer(p) end
		resume(p)
		for n = 1, Q.NB_TERRIERS do if S.terriers[n] then dire(p, "terrier " .. n .. " : " .. S.terriers[n].mode) end end
	end,
	sumii_cible = function(p, _, brut) designer(p, brut, "cible") end,
	sumii_arrancar = function(p, _, brut) designer(p, brut, "arrancar") end,
	sumii_points = function(p)
		if not A.tete() then dire(p, "aucun build trouvé") return end
		for _, nom in ipairs({ "ARRIVEE", "SORTIE" }) do
			local w = A.versMonde(Vector(C[nom][1], C[nom][2], C[nom][3]))
			dire(p, string.format("%s : setpos %.0f %.0f %.0f", string.lower(nom), w.x, w.y, w.z))
		end
	end,
	sumii_tout_effacer = function(p)
		local qui = IsValid(p) and p:SteamID() or "console"
		if (jeu.confirme[qui] or 0) < CurTime() then
			jeu.confirme[qui] = CurTime() + 10
			dire(p, "retire le build et éteint tout : retape sumii_tout_effacer dans les 10 s")
			return
		end
		jeu.confirme[qui] = nil
		liberer()
		local n, total = retirerBuild()
		timer.Remove("sumii_mi_relais")
		S, jeu.cible, jeu.arrancar, jeu.versions = Q.neuf(S.v + 1), nil, nil, {}
		SetGlobalEntity("sumii_mi_ancre", NULL)
		A.oublier()
		net.Start("sumii_mi_tout")
		net.Broadcast()
		dire(p, string.format("tout effacé : %d props retirés sur %d au plan", n, total))
	end,
}
for _, cle in ipairs({ "lancer", "detresse", "voix", "nom", "souvenirs", "devore", "regard", "course", "plaquer", "fumee", "perte", "effondrement" }) do
	COMMANDES["sumii_" .. cle] = function(p) lancer(p, cle) end
end

for nom, fn in pairs(COMMANDES) do
	concommand.Add(nom, function(p, _, args, brut)
		if not estMJ(p) then dire(p, "réservé au MJ") return end
		-- pas de relais après l'effacement : Remove() est différé, le repère se trouve encore et l'état rallumerait les clients
		if nom == "sumii_tout_effacer" then return fn(p, args) end
		reveiller()
		fn(p, args, brut)
		relais()
	end)
end

local dernierDemande = {}
net.Receive("sumii_mi_demande", function(_, p)            -- requête d'un client : limitée à une par seconde
	if (dernierDemande[p] or 0) > CurTime() then return end
	dernierDemande[p] = CurTime() + 1
	jeu.versions[p] = nil
	if A.tete() then reveiller() end
end)
hook.Add("PlayerDisconnected", "sumii_mi_depart", function(p)
	if jeu.gele == p then liberer() end
	jeu.versions[p], dernierDemande[p] = nil, nil
end)
hook.Add("ShutDown", "sumii_mi_fin", liberer)
