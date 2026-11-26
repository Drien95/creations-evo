-- A2 « Le Sable du Fond » : l'ancre de la scène (serveur et clients, même règle des deux côtés).
-- L'ancre est le prop de tête du dupe (une plate5x5 du sol). Il y en a 9 pareilles dans le dupe et d'autres dans les
-- builds des joueurs : on la reconnaît à un MOTIF DE PROPS, sans couleur, matériau, propriétaire ni classe.
-- Une plate5x5 est l'ancre si le grand disque de la dalle et au moins un autre prop du motif sont à leur place attendue
-- par rapport à elle (dans son repère : le build peut être tourné). Plusieurs builds : le plus proche.
-- Le MJ peut aussi désigner l'ancre à la main (a2_ancre, sv_scene.lua) ; elle passe alors avant la recherche.
local C = A2_SABLE
local G = include("a2_sable_du_fond/sh_gravure.lua")   -- gravure d'usine d'abord, motif ci-dessous en secours
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

function C.lireGravure(t) return (G.lire(t, C.GRAVURE)) end   -- nombre de marques trouvées autour de ce repère
function C.ancreValide(t) return reel(t) and (C.lireGravure(t) >= C.GRAVURE_MIN or C.motifOk(t)) end

function C.trouverTetes()                        -- une tête par build posé : par la gravure, sinon par le motif
  local l = {}
  for _, r in ipairs(G.chercher(C.MODELE_TETE, C.GRAVURE, C.GRAVURE_MIN)) do l[#l + 1] = r.repere end
  if #l > 0 then return l, "gravure" end
  for _, e in ipairs(ents.FindByModel(C.MODELE_TETE)) do
    if C.motifOk(e) then l[#l + 1] = e end
  end
  return l, #l > 0 and "motif" or nil
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

-- ---------- client : le repère envoyé par le serveur (seul autoritaire) ----------
-- Le serveur voit toutes les entités ; il envoie la position et l'angle de l'ancre dans l'état. Le client en fait un
-- repère (mêmes méthodes qu'une entité : LocalToWorld, WorldToLocal, GetUp...) sans rien chercher lui-même.
-- Recherche par motif côté client seulement en secours, tant qu'aucun état n'est reçu.
local Repere = {}
Repere.__index = Repere
function Repere:IsValid() return true end
function Repere:GetPos() return Vector(self.p) end
function Repere:GetAngles() return Angle(self.a) end
function Repere:LocalToWorld(v) return self.m * v end
function Repere:WorldToLocal(v) return self.mi * v end
function Repere:LocalToWorldAngles(a) local _, r = LocalToWorld(vector_origin, a, self.p, self.a) return r end
function Repere:GetUp() return self.a:Up() end
function Repere:GetForward() return self.a:Forward() end
function Repere:GetRight() return self.a:Right() end
local function nouveauRepere(p, a)
  local m = Matrix()
  m:SetTranslation(p); m:SetAngles(a)
  return setmetatable({ p = Vector(p), a = Angle(a), m = m, mi = m:GetInverseTR() }, Repere)
end

local cache, prochain, mode = NULL, 0, "aucune"
local repere = nil                               -- repère reçu du serveur (nil : aucun état reçu)
C.ancreIndex, C.ancreDesignee, C.nbCandidats = 0, false, 0

function C.recevoirAncre(index, pos, ang, designee)   -- appelé à chaque état reçu (cl_sequence.lua)
  C.rallumer()                                   -- éteinte par a2_tout_effacer : le build est revenu
  C.ancreIndex, C.ancreDesignee = index, designee
  if repere and repere.p:DistToSqr(pos) < 0.01 and repere.a == ang then return end   -- inchangé : caches gardés
  if not repere then print(string.format("[A2] ancre reçue du serveur : %.0f %.0f %.0f", pos.x, pos.y, pos.z)) end
  repere = nouveauRepere(pos, ang)
end

function C.perdreAncre()                         -- le serveur ne voit plus le build : plus rien n'est dessiné
  if repere then print("[A2] le serveur ne trouve plus le build : scène éteinte") end
  repere, C.ancreIndex, cache, prochain = nil, 0, NULL, CurTime() + 5
end

function C.tete()
  if C.eteint then return nil end
  if repere then mode = C.ancreDesignee and "serveur (désignée par le MJ)" or "serveur (gravure ou motif)" return repere end
  local now = CurTime()                          -- secours : aucun état reçu encore
  if now >= prochain then
    local l = C.trouverTetes()
    C.nbCandidats = #l
    local avant = cache
    cache = C.plusProche(l, EyePos()) or NULL
    prochain = now + (IsValid(cache) and 5 or 1)
    mode = IsValid(cache) and "recherche du client (secours)" or "aucune"
    if cache ~= avant and not IsValid(cache) then print("[A2] build introuvable côté client (en attente de l'état du serveur)") end
  end
  return IsValid(cache) and cache or nil
end
function C.modeAncre() return mode end
function C.repereServeur() return repere end

C.hook("OnEntityCreated", "a2_sable_ancre", function(e)   -- collage en cours : on recherche bientôt (secours)
  if IsValid(e) and not repere and not IsValid(cache) then prochain = math.min(prochain, CurTime() + 0.5) end
end)

C.surExtinction(function()                       -- a2_tout_effacer : repère et recherche oubliés
  repere, cache, prochain, mode = nil, NULL, 0, "aucune"
  C.ancreIndex, C.ancreDesignee, C.nbCandidats = 0, false, 0
end)
