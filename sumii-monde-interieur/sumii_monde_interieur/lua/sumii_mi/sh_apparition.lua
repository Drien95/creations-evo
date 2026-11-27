-- Temps 3, 4, 4 bis et 5 (détresse, révélation, voix, nom) : calcul pur, fonction de (état, heure).
local P = {}
local DETRESSE, REVELER, SOUVENIRS = 2, 3, 6    -- places dans la séquence (vérifiées par les tests)

P.VOLUME = 0.35                                  -- vent en boucle
P.FIGE = 9                                       -- herbe immobile après la révélation (s)
P.SOMBRE = 0.8                                   -- « la lumière baisse d'un cran »
P.POUSSEE, P.BANDE, P.VOIX = 0.5, 70, 3          -- herbe poussée par la voix, demi-largeur de l'anneau, durée
P.BOUFFEES, P.TERRIER_DEFAUT = 24, 7

local function borne(v, a, b) return v < a and a or (v > b and b or v) end

-- part (0 à 1) écoulée de la rampe [debut, debut + duree] après le temps « cle » ;
-- 1 si le temps est dépassé sans avoir été lancé, 0 s'il n'est pas atteint
local function rampe(S, cle, place, t, debut, duree)
	if S.i < place then return 0 end
	local t0 = S.inst[cle]
	if not t0 then return 1 end
	return borne((t - t0 - debut) / duree, 0, 1)
end

function P.vitesseVent(S, t)
	if S.i == DETRESSE then return 1 - 0.5 * rampe(S, "detresse", DETRESSE, t, 0, 1) end
	local t0 = S.inst.reveler
	if S.i >= REVELER and S.i < SOUVENIRS and t0 and t - t0 < P.FIGE then return 0 end
	return 1
end
function P.volumeVent(S)
	if S.i < 1 or (S.i >= REVELER and S.i < SOUVENIRS) then return 0 end
	return S.i == DETRESSE and P.VOLUME / 2 or P.VOLUME
end
function P.oiseaux(S) return S.i >= 1 and S.i < REVELER end

function P.lumiere(S, t) return 1 - (1 - P.SOMBRE) * rampe(S, "reveler", REVELER, t, 2, 3) end

local function presents(S) return S.i >= REVELER and S.i < SOUVENIRS end
function P.yeux(S, t) return presents(S) and rampe(S, "reveler", REVELER, t, 5, 2) or 0 end
function P.oreilles(S, t) return presents(S) and rampe(S, "reveler", REVELER, t, 8, 3) or 0 end
function P.lapinEndormi(S) return S.i < REVELER end
function P.terrier(S) return S.revele or P.TERRIER_DEFAUT end

-- secondes écoulées dans la réplique en cours, ou nil
local function enVoix(S, t)
	local t0 = S.inst.voix
	if t0 and t >= t0 and t - t0 <= P.VOIX then return t - t0 end
end
function P.rayonVoix(S, t)
	local s = enVoix(S, t)
	return s and 140 + 40 * s or nil
end
function P.pulsation(S, t)
	local s = enVoix(S, t)
	return s and 1 + 0.7 * math.abs(math.sin(s * 8)) or 1
end
-- cisaillement vers l'extérieur d'un bloc d'herbe à la distance d du terrier, s secondes après la réplique
function P.poussee(d, rayon, s)
	local ecart = math.abs(d - rayon)
	if ecart >= P.BANDE then return 0 end
	return P.POUSSEE * (1 - ecart / P.BANDE) * math.sin(borne(s / P.VOIX, 0, 1) * math.pi)
end

-- onde rouge du nom : rayon et opacité (0 à 1), ou nil
function P.anneauNom(S, t)
	local t0 = S.inst.nom
	if not t0 or t < t0 or t - t0 >= 4.5 then return nil end
	return 750 * (t - t0), borne((4.5 - (t - t0)) / 0.5, 0, 1)
end

-- bouffée de terre i, s secondes après la détresse : place autour d'elle, taille, opacité
function P.bouffee(i, s)
	local g, h = (i * 0.6180339887) % 1, (i * 0.3819660113) % 1
	local a, r = i / P.BOUFFEES * 2 * math.pi + g, 30 + 70 * h
	local monte = 1 - (1 - borne(s / 1.2, 0, 1)) ^ 2      -- pic tôt
	local z = (20 + 70 * g) * monte
	local taille = 26 + 34 * h + 6 * s
	local alpha = 200 * borne(s / 0.25, 0, 1) * borne((6 - s) / 4, 0, 1)
	return math.cos(a) * r, math.sin(a) * r, z, taille, alpha
end
-- taille (0 à 1) du tas à ses pieds
function P.tas(S, t) return rampe(S, "detresse", DETRESSE, t, 0, 1.5) end

return P
