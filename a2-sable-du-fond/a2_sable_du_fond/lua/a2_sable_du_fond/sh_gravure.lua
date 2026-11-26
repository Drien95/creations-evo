-- Gravure d'usine : reconnaître le build d'une scène à ses marques dédiées (générées par outils/gravure.py).
-- Module sans état ni globale : local G = include("<addon>/sh_gravure.lua"), à charger des deux côtés (AddCSLuaFile).
-- Une marque est un petit prop posé à une position et un lacet RELATIFS au prop repère, avec une couleur improbable.
-- Elle compte si le modèle et la position collent (TOL u) ; lacet (modulo 90°, plaque carrée) et couleur sont vérifiés
-- à part et seulement rapportés (un collage ou PermaProps peut les arrondir).
local G = {}
G.TOL = 2                                        -- écart de position toléré (u)
G.TOL_LACET = 3                                  -- écart de lacet toléré (degrés, modulo 90)

local function reel(e) return IsValid(e) and e:EntIndex() > 0 end   -- exclut les modèles dessinés en script

local function ecartLacet(a, b)
  local d = math.abs((a - b) % 90)
  return math.min(d, 90 - d)
end

-- prop de la marque m autour du repère t, ou nil
function G.trouverMarque(t, m)
  local pos = t:LocalToWorld(m.pos)
  local tol2 = G.TOL * G.TOL
  for _, e in ipairs(ents.FindInSphere(pos, G.TOL + 8)) do
    if reel(e) and e ~= t and string.lower(e:GetModel() or "") == m.modele and e:GetPos():DistToSqr(pos) <= tol2 then
      return e
    end
  end
end

-- lecture de la gravure autour d'un repère candidat : nombre de marques trouvées, et détail par marque
function G.lire(t, marques)
  local n, detail = 0, {}
  for i, m in ipairs(marques) do
    local e = G.trouverMarque(t, m)
    if e then
      n = n + 1
      local c = e:GetColor()
      local lacet = e:GetAngles().y - t:GetAngles().y
      detail[i] = { ok = true, lacetOk = ecartLacet(lacet, m.lacet) <= G.TOL_LACET,
        couleurOk = c.r == m.couleur[1] and c.g == m.couleur[2] and c.b == m.couleur[3] }
    else
      detail[i] = { ok = false }
    end
  end
  return n, detail
end

-- tous les repères (modèle donné) qui portent au moins `min` marques ; triés du plus complet au moins complet
function G.chercher(modeleRepere, marques, min)
  local l = {}
  for _, e in ipairs(ents.FindByModel(modeleRepere)) do
    if reel(e) then
      local n = G.lire(e, marques)
      if n >= min then l[#l + 1] = { repere = e, n = n } end
    end
  end
  table.sort(l, function(a, b) return a.n > b.n end)
  return l
end

return G
