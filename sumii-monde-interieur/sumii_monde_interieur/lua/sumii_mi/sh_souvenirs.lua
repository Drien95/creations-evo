-- Temps 6 (souvenirs) et ses trois flashs : calcul pur, fonction de (état, heure).
local V = {}

V.PLACE = 6                                      -- place des souvenirs dans la séquence (vérifiée par les tests)
local FLASH3 = V.PLACE + 3
V.MONTEE = 22                                    -- durée de la tombée du soleil et du rouge (s)
V.SOLEIL_FIN, V.SOMBRE = -3, 0.55                -- élévation finale (degrés) et lumière finale
V.VENT_MAX, V.GEMISSEMENT = 2.5, 0.6
V.DUREE_SOUVENIRS = 30
V.COUPURE = 1.0                                  -- silence net à chaque flash (s)
V.SILHOUETTE, V.TRAIT = 2.5, 1.8

local function borne(v, a, b) return v < a and a or (v > b and b or v) end

-- 0 à 1 ; 1 si le temps est dépassé sans avoir été lancé
function V.rouge(S, t)
	if S.i < V.PLACE then return 0 end
	local t0 = S.inst.souvenirs
	if not t0 then return 1 end
	return borne((t - t0) / V.MONTEE, 0, 1)
end
function V.elevation(S, t, depart) return depart + (V.SOLEIL_FIN - depart) * V.rouge(S, t) end
-- lumiereAvant : celle de la révélation, jamais remontée
function V.lumiere(S, t, lumiereAvant)
	local k = V.rouge(S, t)
	return math.min(lumiereAvant, lumiereAvant + (V.SOMBRE - lumiereAvant) * k)
end
function V.voileHalo(elevation) return borne((elevation + 1) / 4, 0, 1) end

-- voile rouge du ciel : il arrive par l'est (estX = composante est de la direction, -1 à 1)
function V.alphaCiel(k, estX)
	local est = (estX + 1) / 2
	return borne(2 * k - (1 - est), 0, 1)
end
-- hauteur 0 (horizon) à 1 (haut du ciel)
function V.couleurCiel(hauteur)
	local k = borne(hauteur / 0.6, 0, 1)
	return 176 + (58 - 176) * k, 28 + (5 - 28) * k, 16 + (8 - 16) * k
end

-- le vent forcit pendant les souvenirs et les flashs, puis se calme (les temps suivants le reprennent)
local function agite(S) return S.i >= V.PLACE and S.i <= FLASH3 end
function V.facteurVent(S, t) return agite(S) and 1 + (V.VENT_MAX - 1) * V.rouge(S, t) or 1 end
function V.gemissement(S, t) return agite(S) and V.GEMISSEMENT * V.rouge(S, t) or 0 end
function V.acouphene(S, t)
	local t0 = S.inst.souvenirs
	return S.i == V.PLACE and t0 ~= nil and t >= t0 and t - t0 < V.DUREE_SOUVENIRS
end

-- secondes depuis le flash n s'il a été lancé, sinon nil
local function depuis(S, t, n)
	local t0 = S.inst["flash" .. n]
	if t0 and t >= t0 then return t - t0 end
end
function V.coupure(S, t)
	for n = 1, 3 do
		local s = depuis(S, t, n)
		if s and s < V.COUPURE then return true end
	end
	return false
end
-- flash 1 : opacité de la silhouette géante
function V.silhouette(S, t)
	local s = depuis(S, t, 1)
	if not s or s >= V.SILHOUETTE or depuis(S, t, 2) then return 0 end   -- un souvenir chasse l'autre
	return borne(s / 0.15, 0, 1) * borne((V.SILHOUETTE - s) / 0.4, 0, 1)
end
-- flash 2 : opacité et longueur (0 à 1) du trait rouge, ou nil
function V.trait(S, t)
	local s = depuis(S, t, 2)
	if not s or s >= V.TRAIT then return nil end
	return borne((V.TRAIT - s) / 0.5, 0, 1), borne(s * 3, 0, 1)
end
-- flash 3 : opacité du blanc plein écran
function V.blanc(S, t)
	local s = depuis(S, t, 3)
	if not s then return 0 end
	return borne(math.min((s - 0.1) / 0.1, (0.75 - s) / 0.2), 0, 1)   -- monte en 0,1 s, tient, retombe
end

-- affichage d'une valeur qui redescend (retour du MJ) : au plus 1 par seconde, jamais de saut en arrière
function V.adoucir(affiche, voulu, dt)
	if voulu >= affiche then return voulu end
	return math.max(voulu, affiche - dt)
end

return V
