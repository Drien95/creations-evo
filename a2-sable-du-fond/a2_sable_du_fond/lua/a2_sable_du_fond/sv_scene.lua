-- A2 « Le Sable du Fond » : l'état de la scène, tenu par le serveur et partagé par tous (chargé par autorun).
-- Les commandes a2_* sont réservées à qui est listé dans sh_config.lua (et aux admins), et à la console du serveur.
-- Après chaque commande, l'état complet part aux seuls joueurs dans la boîte de la scène. Un joueur qui arrive
-- ou qui entre dans la boîte en cours de scène le reçoit à son tour : tout le monde voit la même chose.
local C = A2_SABLE
util.AddNetworkString(C.NET)
util.AddNetworkString(C.NET_PRET)
util.AddNetworkString(C.NET_TOUT)

local RES_INDEX = {}
for i, r in ipairs(C.RESULTATS) do RES_INDEX[r] = i end
local MAX_VAGUES = 3                             -- les vagues plus anciennes sont finies depuis longtemps

local etat = { n = 0, vagues = {}, places = {}, adler = NULL, ancre = NULL, version = 0 }
local function placeVide(i)
  local s = C.SIGS[(i - 1) % #C.SIGS + 1]
  return { on = false, res = "reussite", t0 = 0, joueur = NULL, sig = { s[1], s[2], s[3] } }
end
local function toutEffacer()
  etat.n, etat.vagues, etat.adler = 0, {}, NULL
  for i = 1, C.NB_PLACES do etat.places[i] = placeVide(i) end
end
toutEffacer()

-- ---------- droits et messages ----------
local function autorise(ply)                     -- joueur invalide = console du serveur
  if not IsValid(ply) then return true end
  return (C.ADMINS and ply:IsAdmin()) or C.AUTORISES[ply:SteamID()] == true or C.AUTORISES[ply:SteamID64()] == true
end
local function dire(ply, texte)
  if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, texte) end
  print(texte)
end

-- ---------- l'ancre : le serveur seul décide (il voit toutes les entités) ----------
-- Une seule ancre : celle désignée par a2_ancre, sinon le build reconnu par le motif (sh_ancre.lua). Sa position et son
-- angle partent dans l'état ; les clients bâtissent la boîte dessus sans chercher eux-mêmes.
local mjs = setmetatable({}, { __mode = "k" })   -- qui a mené la scène : prévenu en console quand l'ancre change
local ancre, prochainReleve, vue, trouvee, marques = NULL, 0, { pos = nil, ang = nil }, false, -1
local forcer = true                              -- recherche complète au prochain relevé (sinon : revalider l'ancre)
local function annoncer(texte)
  print(texte)
  for ply in pairs(mjs) do if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, texte) end end
end
local function fmt(v) return string.format("%.0f %.0f %.0f", v.x, v.y, v.z) end
local function releverAncre()
  if C.reel(etat.ancre) then return etat.ancre end
  local perdue = trouvee and not C.reel(ancre)    -- l'ancre vient d'être retirée : on cherche tout de suite
  if CurTime() < prochainReleve and not perdue then return ancre end
  prochainReleve = CurTime() + 5
  local avant, l = ancre, nil
  if C.reel(ancre) and not forcer and not C.ancreValide(ancre) then ancre = NULL end   -- revalider : quelques sondes autour d'elle
  if forcer or not C.reel(ancre) then           -- recherche complète : ancre perdue, ou un prop du repère vient d'être créé
    forcer = false
    l = C.trouverTetes()
    ancre = C.ancreValide(ancre) and ancre or (l[1] or NULL)   -- on garde l'ancre tant qu'elle reste valide
  end
  l = l or { ancre }
  local n = C.reel(ancre) and C.lireGravure(ancre) or -1
  if C.reel(ancre) ~= trouvee or (C.reel(ancre) and ancre ~= avant) then
    trouvee = C.reel(ancre)
    if C.reel(ancre) then
      annoncer(string.format("[A2] build repéré à %s (angle %.0f°), %s%s", fmt(ancre:GetPos()), ancre:GetAngles().y,
        n >= C.GRAVURE_MIN and ("gravure " .. n .. "/" .. #C.GRAVURE) or "par le motif (gravure absente)",
        #l > 1 and (" ; " .. #l .. " builds reconnus : a2_ancre en visant celui de la scène") or ""))
    else
      annoncer("[A2] build introuvable : vise-le et tape a2_ancre")
    end
  elseif C.reel(ancre) and n ~= marques then
    annoncer(n == #C.GRAVURE and ("[A2] gravure complète (" .. n .. "/" .. n .. ")")
      or string.format("[A2] gravure incomplète (%d/%d)", math.max(n, 0), #C.GRAVURE))
  end
  if C.reel(ancre) and n < #C.GRAVURE and avant ~= ancre and n > 0 then
    annoncer(string.format("[A2] gravure incomplète (%d/%d)", n, #C.GRAVURE))
  end
  marques = n
  return ancre
end
local MODELES_REPERE = { [C.MODELE_TETE] = true }   -- modèles qui peuvent faire apparaître un build : tête, gravure, motif
for _, m in ipairs(C.GRAVURE) do MODELES_REPERE[m.modele] = true end
for _, m in ipairs(C.MOTIF) do MODELES_REPERE[m.modele] = true end
local function surCreation(e)                    -- collage ou PermaProps : recherche complète au prochain relevé
  if not IsValid(e) or e:GetClass() ~= "prop_physics" then return end
  timer.Simple(0, function()                     -- le modèle n'est pas encore posé à la création
    if not IsValid(e) or not MODELES_REPERE[string.lower(e:GetModel() or "")] then return end
    forcer = true
    prochainReleve = math.min(prochainReleve, CurTime() + 1)   -- anti-rebond : un collage entier = un seul relevé
  end)
end
local function ancreActuelle() local a = releverAncre() return C.reel(a) and a or nil end
local function dansScene(ply, a) return C.dansBoite(a, ply:EyePos()) end
function C.teteProche() return ancreActuelle() end   -- a2_retirer : la même ancre unique

-- ---------- relais ----------
local recu = setmetatable({}, { __mode = "k" })  -- version de l'état déjà reçue par chaque joueur
local function envoyerSansAncre(ply)            -- le build a disparu : les clients éteignent la scène
  net.Start(C.NET)
  net.WriteBool(false)
  net.Send(ply)
  recu[ply] = -1
end
local function envoyer(ply, a)
  net.Start(C.NET)
  net.WriteBool(true)
  net.WriteUInt(etat.n, 8)
  net.WriteUInt(#etat.vagues, 2)
  for _, v in ipairs(etat.vagues) do net.WriteDouble(v.t0); net.WriteUInt(v.n, 8) end
  net.WriteUInt(#etat.places, 4)
  for _, p in ipairs(etat.places) do
    net.WriteBool(p.on); net.WriteUInt(RES_INDEX[p.res], 3); net.WriteDouble(p.t0)
    net.WriteUInt(p.sig[1], 8); net.WriteUInt(p.sig[2], 8); net.WriteUInt(p.sig[3], 8)
  end
  net.WriteEntity(IsValid(etat.adler) and etat.adler or NULL)
  net.WriteUInt(a:EntIndex(), 16)                -- pour a2_diag seulement
  net.WriteVector(a:GetPos())                    -- le repère de la scène, tel que le serveur le voit
  net.WriteAngle(a:GetAngles())
  net.WriteBool(C.reel(etat.ancre))              -- désignée par le MJ ?
  net.Send(ply)
  recu[ply] = etat.version
end
local function relayer()                         -- aux joueurs dans la boîte qui n'ont pas la dernière version
  local a = ancreActuelle()
  if not a then
    for ply, v in pairs(recu) do if IsValid(ply) and v ~= -1 then envoyerSansAncre(ply) end end
    vue.pos = nil
    return
  end
  local p, g = a:GetPos(), a:GetAngles()         -- le build a bougé (physgun, recollage) : nouvel envoi à tous
  if not (vue.pos and vue.pos:DistToSqr(p) < 0.25 and vue.ang == g) then
    vue.pos, vue.ang = p, g
    etat.version = etat.version + 1
  end
  for _, ply in ipairs(player.GetHumans()) do
    if recu[ply] ~= etat.version and dansScene(ply, a) then envoyer(ply, a) end
  end
end
local function changer(ply)
  etat.version = etat.version + 1
  relayer()
  if not ancreActuelle() then dire(ply, "[A2] build introuvable : l'état est gardé, personne ne le voit. Vise le build et tape a2_ancre") end
end

-- ---------- veille : a2_tout_effacer endort l'addon (aucun hook ni timer), une commande a2_* le réveille ----------
function C.reveiller()
  if timer.Exists("a2_sable_relais") then return end
  hook.Add("OnEntityCreated", "a2_sable_ancre", surCreation)
  timer.Create("a2_sable_relais", 0.5, 0, relayer)
  prochainReleve, forcer = 0, true
end
function C.endormir()
  hook.Remove("OnEntityCreated", "a2_sable_ancre")
  timer.Remove("a2_sable_relais")
  toutEffacer()
  etat.ancre, ancre, trouvee, marques, vue.pos, vue.ang = NULL, NULL, false, -1, nil, nil
  for ply in pairs(recu) do recu[ply] = nil end
  etat.version = etat.version + 1
end
function C.actifServeur()                        -- relais et hook A2 du serveur posés ? (a2_etat)
  return timer.Exists("a2_sable_relais"), (hook.GetTable().OnEntityCreated or {}).a2_sable_ancre ~= nil
end
C.reveiller()

-- un client prêt (chargement fini) redemande l'état ; une fois toutes les 5 s au plus
local demande = setmetatable({}, { __mode = "k" })
net.Receive(C.NET_PRET, function(_, ply)
  if not IsValid(ply) or (demande[ply] or 0) > CurTime() then return end
  demande[ply] = CurTime() + 5
  recu[ply] = nil
end)

-- ---------- cibles ----------
local function joueurDe(nom)
  nom = string.lower(nom or "")
  if nom == "" then return nil end
  for _, ply in ipairs(player.GetHumans()) do
    if string.find(string.lower(ply:Nick()), nom, 1, true) then return ply end
  end
end
local function placesDe(cible)                   -- « tous », un numéro de place, ou un nom de joueur (partiel)
  if cible == "tous" then local l = {} for i = 1, #etat.places do l[i] = i end return l end
  local n = tonumber(cible or "")
  if n then return etat.places[n] and { n } or {} end
  local nom = string.lower(cible or "")
  local l = {}
  if nom == "" then return l end
  for i, p in ipairs(etat.places) do
    if IsValid(p.joueur) and string.find(string.lower(p.joueur:Nick()), nom, 1, true) then l[#l + 1] = i end
  end
  return l
end

-- ---------- commandes ----------
local function vague(ply)
  etat.n = math.min(etat.n + 1, 255)
  table.insert(etat.vagues, { t0 = CurTime(), n = etat.n })
  if #etat.vagues > MAX_VAGUES then table.remove(etat.vagues, 1) end
  changer(ply)
  dire(ply, "[A2] vague " .. etat.n)
end

local COMMANDES = {}
local function ancreRequise(ply)                 -- pas de vague sans build repéré : personne ne la verrait
  if ancreActuelle() then return true end
  dire(ply, "[A2] build introuvable : vise-le et tape a2_ancre, puis relance")
  return false
end
COMMANDES.a2_lancer = function(ply)
  if not ancreRequise(ply) then return end
  etat.n, etat.vagues = 0, {}
  vague(ply)
end
COMMANDES.a2_suivante = function(ply) if ancreRequise(ply) then vague(ply) end end
COMMANDES.a2_effacer = function(ply)
  toutEffacer(); changer(ply)
  dire(ply, "[A2] scène remise à zéro pour tous")
end
COMMANDES.a2_place = function(ply, args)
  local cible, n = joueurDe(args[1]), math.floor(tonumber(args[2] or "") or 0)
  if not cible or not etat.places[n] then dire(ply, "[A2] usage : a2_place <joueur> <1-" .. #etat.places .. ">") return end
  for _, p in ipairs(etat.places) do if p.joueur == cible then p.joueur = NULL end end
  etat.places[n].joueur = cible
  dire(ply, "[A2] place " .. n .. " : " .. cible:Nick())
end
COMMANDES.a2_pierres = function(ply, args)
  local l, on = placesDe(args[1]), args[2]
  if #l == 0 or (on ~= "on" and on ~= "off") then dire(ply, "[A2] usage : a2_pierres <joueur|place|tous> <on|off>") return end
  for _, i in ipairs(l) do local p = etat.places[i]; p.on, p.res, p.t0 = on == "on", "reussite", CurTime() end
  changer(ply)
  dire(ply, "[A2] pierres " .. on .. " : places " .. table.concat(l, ", "))
end
COMMANDES.a2_resultat = function(ply, args)
  local l, res = placesDe(args[1]), args[2]
  if #l == 0 or not RES_INDEX[res or ""] then
    dire(ply, "[A2] usage : a2_resultat <joueur|place|tous> <" .. table.concat(C.RESULTATS, "|") .. ">") return
  end
  for _, i in ipairs(l) do local p = etat.places[i]; p.on, p.res, p.t0 = true, res, CurTime() end
  changer(ply)
  dire(ply, "[A2] résultat " .. res .. " : places " .. table.concat(l, ", "))
end
COMMANDES.a2_signature = function(ply, args)
  local l = placesDe(args[1])
  local r, g, b = tonumber(args[2] or ""), tonumber(args[3] or ""), tonumber(args[4] or "")
  if #l == 0 or not r or not g or not b then dire(ply, "[A2] usage : a2_signature <joueur|place|tous> <r> <g> <b>") return end
  local function c(x) return math.floor(math.Clamp(x, 0, 255)) end
  for _, i in ipairs(l) do etat.places[i].sig = { c(r), c(g), c(b) } end
  changer(ply)
  dire(ply, "[A2] signature : places " .. table.concat(l, ", "))
end
COMMANDES.a2_adler = function(ply, args)        -- le fil d'Injerto suit ce joueur ; sans nom : au centre de la dalle
  local cible = joueurDe(args[1])
  if args[1] and args[1] ~= "" and not cible then dire(ply, "[A2] usage : a2_adler [joueur]") return end
  etat.adler = cible or NULL
  changer(ply)
  dire(ply, "[A2] fil d'Injerto : " .. (cible and ("au-dessus de " .. cible:Nick()) or "au centre de la dalle"))
end
COMMANDES.a2_ancre = function(ply, args)       -- viser un prop du build ; « a2_ancre auto » rend la main à la recherche
  if args[1] == "auto" then
    etat.ancre, prochainReleve, ancre = NULL, 0, NULL
    changer(ply)
    dire(ply, "[A2] ancre : recherche automatique (" .. #C.trouverTetes() .. " build(s) reconnu(s))")
    return
  end
  if not IsValid(ply) then dire(ply, "[A2] a2_ancre se tape en jeu, en visant le build") return end
  local tr = ply:GetEyeTrace()
  local vise = tr.Entity
  if not C.reel(vise) then dire(ply, "[A2] a2_ancre : vise un prop du build (rien de touché)") return end
  local tete
  if C.ancreValide(vise) then tete = vise
  else
    local l = {}
    for _, t in ipairs(C.trouverTetes()) do if C.dansBoite(t, tr.HitPos) then l[#l + 1] = t end end
    tete = C.plusProche(l, tr.HitPos)
    if not tete and string.lower(vise:GetModel() or "") == C.MODELE_TETE then tete = vise end   -- motif absent : la plaque visée
  end
  if not tete then dire(ply, "[A2] a2_ancre : build non reconnu ; vise la plaque 5x5 du sol au coin du build (voir README)") return end
  etat.ancre = tete
  changer(ply)
  annoncer(string.format("[A2] build désigné par %s à %s (angle %.0f°)%s", ply:Nick(), fmt(tete:GetPos()), tete:GetAngles().y,
    C.ancreValide(tete) and (", gravure " .. C.lireGravure(tete) .. "/" .. #C.GRAVURE) or " : gravure et motif absents, plaque visée"))
end
COMMANDES.a2_etat = function(ply)
  dire(ply, string.format("[A2] vagues : %d ; fil : %s ; ancre : %s ; builds reconnus : %d", etat.n,
    IsValid(etat.adler) and etat.adler:Nick() or "centre", ancreActuelle() and ((C.reel(etat.ancre) and "désignée, " or "auto, ")
      .. fmt(ancreActuelle():GetPos()) .. ", gravure " .. C.lireGravure(ancreActuelle()) .. "/" .. #C.GRAVURE) or "aucune",
    #C.trouverTetes()))
  for i, p in ipairs(etat.places) do
    dire(ply, string.format("[A2] place %d : %s, pierres %s, %s", i, IsValid(p.joueur) and p.joueur:Nick() or "libre",
      p.on and "on" or "off", p.res))
  end
end

for nom, f in pairs(COMMANDES) do
  concommand.Add(nom, function(ply, _, args)
    if not autorise(ply) then return end
    if IsValid(ply) then mjs[ply] = true end
    C.reveiller()                                -- après a2_tout_effacer, la première commande rallume l'addon
    f(ply, args or {})
  end)
end

C.autorise, C.dire, C.effacer = autorise, dire, function() toutEffacer(); etat.version = etat.version + 1; relayer() end
C.ancreServeur = function() return etat.ancre end
