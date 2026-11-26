-- A2 « Le Sable du Fond » : l'ancre de la scène (serveur et clients, même règle des deux côtés).
-- L'ancre est le prop de tête du dupe (une plate5x5 du sol). Il y en a 9 pareilles dans le dupe et d'autres dans les
-- builds des joueurs : on la reconnaît à un MOTIF DE PROPS, sans couleur, matériau, propriétaire ni classe.
-- Une plate5x5 est l'ancre si le grand disque de la dalle et au moins un autre prop du motif sont à leur place attendue
-- par rapport à elle (dans son repère : le build peut être tourné). Plusieurs builds : le plus proche.
-- Le MJ peut aussi désigner l'ancre à la main (a2_ancre, sv_scene.lua) ; elle passe alors avant la recherche.
local C = A2_SABLE
C.MOTIF = {                                      -- positions relatives à la tête (coordonnées du build moins C.TETE)
  { modele = "models/hunter/tubes/circle4x4.mdl", pos = Vector(226, 226, 5.75), requis = true },   -- grand disque
  { modele = "models/hunter/tubes/circle2x2.mdl", pos = Vector(226, 226, 9.25) },                  -- petit disque
  { modele = "models/hunter/plates/plate1x1.mdl", pos = Vector(49.233, 436.662, 10.25) },          -- bloc de la place 1
}
C.MOTIF_TOL = 6                                  -- écart toléré (u)
C.MOTIF_MIN = 2                                  -- props du motif à retrouver, grand disque compris

local function reel(e) return IsValid(e) and e:EntIndex() > 0 end   -- exclut les modèles dessinés en script
C.reel = reel

local function present(modele, pos)
  local tol2 = C.MOTIF_TOL * C.MOTIF_TOL
  for _, e in ipairs(ents.FindInSphere(pos, C.MOTIF_TOL + 2)) do
    if reel(e) and string.lower(e:GetModel() or "") == modele and e:GetPos():DistToSqr(pos) <= tol2 then return true end
  end
  return false
end

function C.motifOk(t)
  if not reel(t) or string.lower(t:GetModel() or "") ~= C.MODELE_TETE then return false end
  local n = 0
  for _, m in ipairs(C.MOTIF) do
    if present(m.modele, t:LocalToWorld(m.pos)) then n = n + 1 elseif m.requis then return false end
  end
  return n >= C.MOTIF_MIN
end

function C.trouverTetes()                        -- une tête par build posé (bornée par le nombre de plate5x5)
  local l = {}
  for _, e in ipairs(ents.FindByModel(C.MODELE_TETE)) do
    if C.motifOk(e) then l[#l + 1] = e end
  end
  return l
end

function C.plusProche(liste, pos)
  local pres, meilleur = nil, math.huge
  for _, t in ipairs(liste) do
    local d = pos and t:GetPos():DistToSqr(pos) or 0
    if d < meilleur then pres, meilleur = t, d end
  end
  return pres
end

if SERVER then return end

-- ---------- client : une seule recherche partagée par les quatre scripts ----------
local cache, prochain, mode = NULL, 0, "aucune"
C.ancreIndex = 0                                 -- ancre désignée par le MJ (index d'entité reçu dans l'état), 0 = aucune
C.nbCandidats = 0

function C.tete()
  if C.ancreIndex > 0 then
    local e = Entity(C.ancreIndex)
    if reel(e) then mode = "désignée par le MJ" return e end
  end
  local now = CurTime()
  if now >= prochain then
    local l = C.trouverTetes()
    C.nbCandidats = #l
    local avant = cache
    cache = C.plusProche(l, EyePos()) or NULL
    prochain = now + (IsValid(cache) and 5 or 1)
    mode = IsValid(cache) and "motif" or "aucune"
    if cache ~= avant then
      print(IsValid(cache) and ("[A2] ancre trouvée (motif), " .. #l .. " build(s)") or "[A2] ancre perdue : build introuvable")
    end
  end
  return IsValid(cache) and cache or nil
end
function C.modeAncre() return mode end

hook.Add("OnEntityCreated", "a2_sable_ancre", function(e)   -- collage en cours : on recherche bientôt
  if IsValid(e) and not IsValid(cache) then prochain = math.min(prochain, CurTime() + 0.5) end
end)
