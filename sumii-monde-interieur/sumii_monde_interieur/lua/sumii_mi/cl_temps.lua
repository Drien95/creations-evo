-- Effets « monde » des temps 1 (arrivée) et 2 (fouille) : herbe, soleil et nuage, papillons ; sons de toute la scène.
-- Chaque image est une fonction de l'état reçu (SumiiScene.S) : un arrivant voit le bon instant.
local C, M, Q, T, P = SumiiMI.config, SumiiMI.monde, SumiiMI.sequence, SumiiMI.terriers, SumiiMI.apparition
local A, K, SC = SumiiAncre, SumiiNoyau, SumiiScene
local V, R, E = SumiiMI.souvenirs, SumiiMI.arrancar, SumiiMI.effondrement

-- ---------- crochets lus par P1 ----------
function SC.herbe(bloc, k, ky) return M.herbe(SC.S, math.sqrt(bloc.x * bloc.x + bloc.y * bloc.y), CurTime()), k, ky end
function SC.voileSoleil() return M.soleil(SC.S, CurTime()) end

-- « bruit » : la touffe devant un AUTRE terrier frémit (recalculé à chaque image par le Think)
local fremis = {}
function SC.fremit(n) return fremis[n] or 0 end

-- nuage devant le soleil, peint dans le ciel (repère du maillage de ciel : s = place du soleil)
local NUAGE = CreateMaterial("sumii_mi_nuage_v1", "UnlitGeneric", { ["$basetexture"] = "particle/smokesprites0001",
	["$translucent"] = "1", ["$vertexcolor"] = "1", ["$vertexalpha"] = "1" })
local BOUFFEES = { { 0, 0, 150 }, { -55, 8, 110 }, { 60, -6, 125 }, { 15, 28, 90 }, { -20, -22, 100 } }  -- côté, haut, taille
local couleurNuage = Color(176, 150, 168, 255)
function SC.cielPar(s)
	local k = M.ecartNuage(SC.S, CurTime())
	local cote = s:Angle():Right()
	couleurNuage.a = 235 - 110 * k
	render.SetMaterial(NUAGE)
	for _, b in ipairs(BOUFFEES) do
		local p = s * 0.97 + cote * (b[1] + 210 * k) + Vector(0, 0, b[2] + 18 * k)
		render.DrawSprite(p, b[3] * 1.25, b[3] * 0.7, couleurNuage)
	end
end

-- ---------- papillons : un seul maillage, deux ailes par papillon ----------
local TEINTES = { { 246, 226, 180 }, { 240, 164, 62 }, { 232, 204, 92 } }
-- les 4 coins de la grande aile puis de la petite : (avant, côté, part du battement)
local AILES = {
	{ { 1, 0, 0 }, { 8, 8, 1 }, { 4, 12, 1 }, { -1, 2, 0 } },
	{ { -1, 2, 0 }, { -2, 8, 0.8 }, { -7, 6, 0.7 }, { -4, 0, 0 } },
}
local point, repere, origine = Vector(0, 0, 0), Matrix(), Vector(0, 0, 0)
local function aile(cx, cy, cz, ax, ay, ox, oy, leve, c)
	for _, coins in ipairs(AILES) do
		for j = 1, 4 do
			local q = coins[j]
			point:SetUnpacked(cx + ax * q[1] + ox * q[2], cy + ay * q[1] + oy * q[2], cz + leve * q[3])
			mesh.Position(point)
			mesh.Color(c[1], c[2], c[3], 255)
			mesh.AdvanceVertex()
		end
	end
end
local function papillons(t)
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	repere:Identity()                                  -- sommets en coordonnées du build : aucune conversion par sommet
	repere:SetTranslation(A.versMonde(origine))
	repere:SetAngles(A.tete():GetAngles())
	cam.PushModelMatrix(repere)
	mesh.Begin(MATERIAL_QUADS, M.PAPILLONS * 4)
	for i = 1, M.PAPILLONS do
		local x, y, z, cap, bat = M.papillon(i, t, 0, 0)
		local ax, ay = math.cos(cap), math.sin(cap)
		local pli = 0.9 * bat                          -- angle des ailes
		local large, leve = math.cos(pli), 10 * math.sin(pli)
		local c = TEINTES[i % #TEINTES + 1]
		aile(x, y, z, ax, ay, -ay * large, ax * large, leve, c)
		aile(x, y, z, ax, ay, ay * large, -ax * large, leve, c)
	end
	mesh.End()
	cam.PopModelMatrix()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end
local function eveilles() return Q.fait(SC.S, "lancer") and not Q.fait(SC.S, "reveler") end   -- plus rien ne bouge à la révélation
K.hook("PostDrawOpaqueRenderables", "sumii_mi_papillons", function(profondeur, ciel)
	if profondeur or ciel or not eveilles() or not A.dedans(EyePos()) then return end
	papillons(CurTime())
end)

-- ---------- sons ----------
local vent, avant, prochainOiseau = nil, nil, 0
-- Plusieurs sons du jeu tournent en boucle : tout son long passe par ici, avec une durée et un arrêt certain.
local bornes = {}
local function arreter(cle)
	local s = bornes[cle]
	if not s then return end
	if s.son then s.son:Stop() end
	if IsValid(s.porteur) then s.porteur:Remove() end
	bornes[cle] = nil
end
-- position nil : sur le joueur lui-même
local function jouerBorne(cle, position, chemin, volume, hauteur, duree)
	arreter(cle)
	local porteur, cible = nil, LocalPlayer()
	if position then
		porteur = ClientsideModel("models/hunter/plates/plate.mdl")  -- porte le son à sa place ; jamais dessiné
		if not IsValid(porteur) then return end
		porteur:SetPos(position)
		porteur:SetNoDraw(true)
		cible = porteur
	end
	local son = CreateSound(cible, chemin)
	son:PlayEx(volume, hauteur)
	bornes[cle] = { son = son, porteur = porteur, fin = CurTime() + duree }
end
SC.jouerBorne = jouerBorne
local function echeances(maintenant)
	for cle, s in pairs(bornes) do
		if maintenant >= s.fin then arreter(cle) end
	end
end
local function taireVent()
	if vent then vent:FadeOut(0.3) vent = nil end
end
local function taire()
	taireVent()
	for cle in pairs(bornes) do arreter(cle) end
end
local function bouche(n) local h = T[n] return A.versMonde(Vector(h.x + h.fx * 26, h.y + h.fy * 26, 12)) end
SC.boucheMonde = bouche

local function ambiance(maintenant)
	local volume = P.volumeVent(SC.S)
	if V.coupure(SC.S, maintenant) then                        -- à chaque flash, le silence tombe d'un coup
		if vent then vent:Stop() vent = nil end
	elseif volume <= 0 or R.silence(SC.S) or E.silence(SC.S, maintenant) then taireVent()
	elseif not vent then
		vent = CreateSound(LocalPlayer(), C.SONS.VENT)
		vent:PlayEx(volume, 100)
	else vent:ChangeVolume(volume, 1) end
	if P.oiseaux(SC.S) and maintenant >= prochainOiseau then
		prochainOiseau = maintenant + math.Rand(4, 9)
		local a = math.Rand(0, math.pi * 2)
		sound.Play(C.SONS.OISEAUX[math.random(#C.SONS.OISEAUX)], EyePos() + Vector(math.cos(a) * 600, math.sin(a) * 600, 120), 70, 100, 0.5)
	end
end

local function fouilles(maintenant)
	table.Empty(fremis)
	for n, f in pairs(SC.S.terriers) do
		for _, d in ipairs(M.PELLES) do
			if M.echu(f.t0, d, avant, maintenant) then
				sound.Play(C.SONS.TERRE[math.random(#C.SONS.TERRE)], bouche(n), 70, math.random(90, 110), 1)
			end
		end
		if f.mode == "bruit" and maintenant - f.t0 <= M.FREMIT_A then
			local v = M.voisin(T, SC.S.terriers, n)
			if v then
				fremis[v] = M.fremit(maintenant - f.t0)
				if M.echu(f.t0, M.FREMIT_DE, avant, maintenant) then
					jouerBorne("raclement", bouche(v), C.SONS.RACLEMENT, 0.3, 65, M.FREMIT_A - M.FREMIT_DE)
				end
			end
		end
	end
end

K.hook("Think", "sumii_mi_temps", function()
	local maintenant = CurTime()
	if SumiiP2 then SumiiP2.appliquer(SC.S.terriers) end
	if not A.tete() or not A.dedans(EyePos()) then taire() avant = maintenant return end
	echeances(maintenant)
	ambiance(maintenant)
	if avant then fouilles(maintenant) end
	avant = maintenant
end)
K.surExtinction(function()
	taire()
	fremis, avant, prochainOiseau = {}, nil, 0
end)
