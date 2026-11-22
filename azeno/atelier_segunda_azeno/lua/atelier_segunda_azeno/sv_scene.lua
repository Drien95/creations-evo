-- Atelier : serveur de la scène « atelier_segunda_azeno » : l'étape en cours, partagée par tous les joueurs, et le wipe du build.
local NOM = "atelier_segunda_azeno"
local N_SEQ, RAYON = 6, 5208
local CENTRE, TETE = Vector(0.00, 0.00, 1.50), Vector(-1895.00, -1895.00, 3.75)
local BOITE_MIN, BOITE_MAX = Vector(-3940.25, -3940.55, -148.50), Vector(3940.25, 3940.55, 2043.45)
local MODELES = {
  ["models/fallenlogic_environment/rocks/bigformation_05.mdl"] = true,
  ["models/hunter/blocks/cube1x1x1.mdl"] = true,
  ["models/hunter/blocks/cube1x2x1.mdl"] = true,
  ["models/hunter/blocks/cube1x4x1.mdl"] = true,
  ["models/hunter/blocks/cube1x6x1.mdl"] = true,
  ["models/hunter/blocks/cube2x8x1.mdl"] = true,
  ["models/hunter/plates/plate025x025.mdl"] = true,
  ["models/hunter/plates/plate025x16.mdl"] = true,
  ["models/hunter/plates/plate025x24.mdl"] = true,
  ["models/hunter/plates/plate025x32.mdl"] = true,
  ["models/hunter/plates/plate025x4.mdl"] = true,
  ["models/hunter/plates/plate025x5.mdl"] = true,
  ["models/hunter/plates/plate025x7.mdl"] = true,
  ["models/hunter/plates/plate025x8.mdl"] = true,
  ["models/hunter/plates/plate16x32.mdl"] = true,
  ["models/hunter/plates/plate32x32.mdl"] = true,
  ["models/hunter/tubes/circle2x2.mdl"] = true,
  ["models/hunter/tubes/circle4x4.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails128.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails129.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails160.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails170.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails173.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails176.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails197_2.mdl"] = true,
  ["models/props_mining/stalactite_static03.mdl"] = true,
  ["models/props_mining/stalactite_static04.mdl"] = true
}
local MAX_RETIRES = 2000
util.AddNetworkString(NOM)
util.AddNetworkString(NOM .. "_cl")
local etat                                    -- {k, t0} ou nil (pas de scène en cours)
local wipe_jusqua = 0
local attente = setmetatable({}, {__mode = "k"})    -- anti-répétition par joueur
local demande = setmetatable({}, {__mode = "k"})    -- confirmation du wipe par joueur (10 s)

local function config() return (ATELIER_SCENES and ATELIER_SCENES[NOM]) or {admins = true, steamid = {}} end
local function a_droit(ply)
  if not IsValid(ply) then return false end
  local c = config()
  if c.admins and ply:IsAdmin() then return true end
  local l = c.steamid or {}
  return l[ply:SteamID()] == true or l[ply:SteamID64()] == true
end
local function envoyer(quoi, k, t0, texte, a)  -- a : un joueur ; sinon tout le monde
  net.Start(NOM .. "_cl"); net.WriteString(quoi); net.WriteInt(k or -1, 8); net.WriteDouble(t0 or 0)
  net.WriteString(texte or "")
  if a then net.Send(a) else net.Broadcast() end
end
local function dire(ply, texte) envoyer("msg", nil, nil, texte, ply) end
local function aller(ply, k)
  if CurTime() < wipe_jusqua then return dire(ply, "wipe en cours") end
  k = math.max(0, math.min(N_SEQ, math.floor(k)))
  etat = {k = k, t0 = CurTime()}
  envoyer("etape", k, etat.t0)
end
local function confirme(ply, quoi)
  local d = demande[ply]
  if d and d.quoi == quoi and d.fin > CurTime() then demande[ply] = nil return true end
  demande[ply] = {quoi = quoi, fin = CurTime() + 10}
  dire(ply, quoi .. " : retape-la dans les 10 s pour confirmer. Le build sera retiré pour tout le monde.")
  return false
end
local function proprio_ok(e, ply)              -- avec un prop protect (CPPI) : tes props, ou n'importe lequel pour un admin
  if not e.CPPIGetOwner then return true end
  return e:CPPIGetOwner() == ply or ply:IsAdmin()
end
local function retirer(ply, c)                 -- les props du build dans sa boîte, retrouvée depuis son centre
  local o = c - (CENTRE - TETE)                -- le prop de tête
  local a, b = o - TETE + BOITE_MIN, o - TETE + BOITE_MAX
  local n = 0
  for _, e in ipairs(ents.FindInBox(a, b)) do
    if n >= MAX_RETIRES then break end
    if IsValid(e) and string.sub(e:GetClass(), 1, 5) == "prop_" and MODELES[string.lower(e:GetModel() or "")] and proprio_ok(e, ply) then
      e:Remove(); n = n + 1
    end
  end
  if IsValid(ply) then dire(ply, ("wipe : %d props du build retirés"):format(n)) end
end
local function centre_ok(ply, c)
  if not c then dire(ply, "wipe : build pas retrouvé chez toi, approche-toi de la salle") return false end
  if c:Distance(ply:GetPos()) > RAYON * 3 then dire(ply, "wipe : build trop loin de toi") return false end
  return true
end
local ACTIONS = {
  suivant = function(ply) aller(ply, etat and etat.k + 1 or 1) end,
  precedent = function(ply) if etat then aller(ply, etat.k - 1) end end,
  etape = function(ply, k)
    if k < 0 or k > N_SEQ then return dire(ply, "atelier_etape k (0 à " .. N_SEQ .. ")") end
    aller(ply, k)
  end,
  stop = function() etat = nil; envoyer("stop") end,
  wipe = function(ply, _, c)
    if CurTime() < wipe_jusqua or not centre_ok(ply, c) or not confirme(ply, "atelier_wipe") then return end
    local fin = (RAYON + 200) / (RAYON / 2.5) + 1.5   -- la durée de l'aspiration chez les joueurs
    etat = nil; wipe_jusqua = CurTime() + fin + 1
    envoyer("wipe")
    timer.Simple(fin, function() retirer(ply, c) end)
  end,
  wipe_sec = function(ply, _, c)
    if CurTime() < wipe_jusqua or not centre_ok(ply, c) or not confirme(ply, "atelier_wipe_sec") then return end
    etat = nil; envoyer("wipe_sec"); retirer(ply, c)
  end,
}
net.Receive(NOM, function(_, ply)
  local quoi, k = net.ReadString(), net.ReadInt(8)
  local c = net.ReadBool() and net.ReadVector() or nil
  if quoi == "bonjour" then                     -- un joueur vient de charger le script : ses droits et l'étape en cours
    envoyer("droit", a_droit(ply) and 1 or 0, nil, nil, ply)
    if etat then envoyer("etape", etat.k, etat.t0, nil, ply) end
    return
  end
  local f = ACTIONS[quoi]
  if not f then return end
  if (attente[ply] or 0) > CurTime() then return end   -- anti-répétition : une demande par joueur tous les 0,1 s
  attente[ply] = CurTime() + 0.1
  if not a_droit(ply) then return dire(ply, "la scène « " .. NOM .. " » est réservée aux joueurs autorisés") end
  f(ply, k, c)
end)
print("[Atelier] scène « " .. NOM .. " » chargée côté serveur")
