-- Lac noir de Nobleza : effacer le build (26/11/2026). lac_noir_effacer, tapée deux fois en 10 s : la scène s'arrête pour
-- tous et le serveur retire les props du build dans la boîte de la scène, seulement ceux aux modèles du dupe. La boîte se
-- cale sur le dupe posé (sa grande plaque 8x8, comme le script client), jamais sur des coordonnées de la map. Avec un prop protect (CPPI) : les props du joueur qui efface, ou n'importe lesquels pour un admin.
local REF, SOL = "models/hunter/plates/plate8x8.mdl", Vector(0, 2600, 1.0)   -- plaque repère du dupe et sa place dans le build
local BMIN, BMAX = Vector(-4100, -2700, -150), Vector(4100, 5700, 1900)      -- boîte de la scène (+ 50 u), relative au build
local MAX_RETIRES = 400
local MODELES = {
  ["models/hunter/blocks/cube05x05x025.mdl"] = true,
  ["models/hunter/blocks/cube05x2x05.mdl"] = true,
  ["models/hunter/blocks/cube1x1x025.mdl"] = true,
  ["models/hunter/blocks/cube1x2x025.mdl"] = true,
  ["models/hunter/blocks/cube1x2x1.mdl"] = true,
  ["models/hunter/blocks/cube1x8x1.mdl"] = true,
  ["models/hunter/blocks/cube2x2x025.mdl"] = true,
  ["models/hunter/blocks/cube2x2x1.mdl"] = true,
  ["models/hunter/blocks/cube2x2x2.mdl"] = true,
  ["models/hunter/blocks/cube2x4x025.mdl"] = true,
  ["models/hunter/blocks/cube2x8x1.mdl"] = true,
  ["models/hunter/blocks/cube3x4x025.mdl"] = true,
  ["models/hunter/blocks/cube4x4x05.mdl"] = true,
  ["models/hunter/blocks/cube4x4x2.mdl"] = true,
  ["models/hunter/blocks/cube4x4x4.mdl"] = true,
  ["models/hunter/blocks/cube6x6x05.mdl"] = true,
  ["models/hunter/blocks/cube8x8x05.mdl"] = true,
  ["models/hunter/blocks/cube8x8x2.mdl"] = true,
  ["models/hunter/misc/platehole4x4.mdl"] = true,
  ["models/hunter/misc/sphere1x1.mdl"] = true,
  ["models/hunter/plates/plate025x025.mdl"] = true,
  ["models/hunter/plates/plate025x05.mdl"] = true,
  ["models/hunter/plates/plate025x125.mdl"] = true,
  ["models/hunter/plates/plate025x16.mdl"] = true,
  ["models/hunter/plates/plate025x2.mdl"] = true,
  ["models/hunter/plates/plate025x3.mdl"] = true,
  ["models/hunter/plates/plate025x4.mdl"] = true,
  ["models/hunter/plates/plate025x6.mdl"] = true,
  ["models/hunter/plates/plate05x2.mdl"] = true,
  ["models/hunter/plates/plate1x2.mdl"] = true,
  ["models/hunter/plates/plate1x32.mdl"] = true,
  ["models/hunter/plates/plate2x4.mdl"] = true,
  ["models/hunter/plates/plate32x32.mdl"] = true,
  ["models/hunter/plates/plate8x8.mdl"] = true,
  ["models/hunter/tubes/circle2x2.mdl"] = true,
  ["models/hunter/tubes/tube1x1x8.mdl"] = true,
  ["models/hunter/tubes/tube2x2x025.mdl"] = true,
  ["models/hunter/tubes/tube4x4x05.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails162.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails170.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails171.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails172.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails173.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails185.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails197_1.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails197_18.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails197_2.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails208_1.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails25.mdl"] = true,
  ["models/propper/hueco_mundo_v1/huecomundosetails58.mdl"] = true,
  ["models/propper/hueco_mundo_v1/s_45_0.mdl"] = true,
  ["models/propper/rp_seireitei_v1/thewatcher_stuff_evo_2.mdl"] = true
}
local demande = setmetatable({}, { __mode = "k" })  -- confirmation par joueur (10 s) ; la console confirme aussi en 2 fois

local function proprio_ok(e, ply)
  if not e.CPPIGetOwner or not IsValid(ply) then return true end   -- pas de prop protect, ou console du serveur
  return e:CPPIGetOwner() == ply or ply:IsAdmin()
end

local function repere(ply)                         -- le build posé : la plaque repère la plus proche de qui efface
  local pres, meilleur = nil, math.huge
  local o = IsValid(ply) and ply:GetPos() or nil
  for _, e in ipairs(ents.FindByModel(REF)) do
    local d = o and e:GetPos():DistToSqr(o) or 0
    if d < meilleur then pres, meilleur = e, d end
  end
  return pres and (pres:GetPos() - SOL) or nil
end

local function retirer(ply, off)
  local n = 0
  for _, e in ipairs(ents.FindInBox(off + BMIN, off + BMAX)) do
    if n >= MAX_RETIRES then break end
    if IsValid(e) and e:GetClass() == "prop_physics" and MODELES[string.lower(e:GetModel() or "")] and proprio_ok(e, ply) then
      e:Remove(); n = n + 1
    end
  end
  return n
end

concommand.Add("lac_noir_effacer", function(ply)
  if not LAC_NOIR.autorise(ply) then return end
  local cle = IsValid(ply) and ply or game.GetWorld()
  local d = demande[cle]
  if not (d and d > CurTime()) then
    demande[cle] = CurTime() + 10
    LAC_NOIR.dire(ply, "[Lac noir] lac_noir_effacer : retape-la dans les 10 s pour confirmer. Le build sera retiré pour tout le monde.")
    return
  end
  demande[cle] = nil
  local off = repere(ply)
  if not off then LAC_NOIR.dire(ply, "[Lac noir] build introuvable (plaque repère absente)") return end
  LAC_NOIR.arreter()
  LAC_NOIR.dire(ply, string.format("[Lac noir] scène arrêtée, %d props du build retirés", retirer(ply, off)))
end)
