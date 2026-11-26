-- A2 « Le Sable du Fond » : a2_retirer, tapée deux fois en 10 s. La scène est remise à zéro pour tous et le serveur
-- retire les props du build dans la boîte de la scène, seulement ceux aux modèles du dupe. La boîte se cale sur le
-- prop de tête du build le plus proche, jamais sur des coordonnées de la map. Avec un prop protect (CPPI) : les props
-- du joueur qui retire, ou n'importe lesquels pour un admin.
local C = A2_SABLE
local MAX_RETIRES = 120                          -- le dupe en a 76
local MODELES = {
  ["models/hunter/plates/plate16x16.mdl"] = true,
  ["models/hunter/plates/plate1x1.mdl"] = true,
  ["models/hunter/plates/plate5x5.mdl"] = true,
  ["models/hunter/plates/plate5x8.mdl"] = true,
  ["models/hunter/triangles/025x025.mdl"] = true,
  ["models/hunter/tubes/circle2x2.mdl"] = true,
  ["models/hunter/tubes/circle4x4.mdl"] = true,
  ["models/hunter/tubes/tube4x4x16c.mdl"] = true,
  ["models/props_wasteland/rockgranite02a.mdl"] = true,
  ["models/props_wasteland/rockgranite03b.mdl"] = true,
}
local demande = setmetatable({}, { __mode = "k" })  -- confirmation par joueur (10 s) ; la console confirme aussi en 2 fois

local function proprioOk(e, ply)
  if not e.CPPIGetOwner or not IsValid(ply) then return true end   -- pas de prop protect, ou console du serveur
  return e:CPPIGetOwner() == ply or ply:IsAdmin()
end

local function retirer(ply, tete)
  local n = 0
  local mn = tete:LocalToWorld(Vector(-C.BX, -C.BX, C.BZ0) - C.TETE)
  local mx = tete:LocalToWorld(Vector(C.BX, C.BX, C.BZ1) - C.TETE)
  local a, b = Vector(math.min(mn.x, mx.x), math.min(mn.y, mx.y), math.min(mn.z, mx.z)),
    Vector(math.max(mn.x, mx.x), math.max(mn.y, mx.y), math.max(mn.z, mx.z))
  for _, e in ipairs(ents.FindInBox(a, b)) do
    if n >= MAX_RETIRES then break end
    if IsValid(e) and e:GetClass() == "prop_physics" and MODELES[string.lower(e:GetModel() or "")]
      and C.dansBoite(tete, e:GetPos()) and proprioOk(e, ply) then
      e:Remove(); n = n + 1
    end
  end
  return n
end

concommand.Add("a2_retirer", function(ply)
  if not C.autorise(ply) then return end
  local cle = IsValid(ply) and ply or game.GetWorld()
  local d = demande[cle]
  if not (d and d > CurTime()) then
    demande[cle] = CurTime() + 10
    C.dire(ply, "[A2] a2_retirer : retape-la dans les 10 s pour confirmer. Le build sera retiré pour tout le monde.")
    return
  end
  demande[cle] = nil
  local tete = C.teteProche(ply)
  if not IsValid(tete) then C.dire(ply, "[A2] build introuvable (prop de tête absent)") return end
  C.effacer()
  C.dire(ply, string.format("[A2] scène remise à zéro, %d props du build retirés", retirer(ply, tete)))
end)
