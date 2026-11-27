-- Temps 6 bis à 6 fin (dévore, regard, course, fumée) : calcul pur, fonction de (état, heure).
-- L'Arrancar est un vrai joueur : le script ne fait que l'accompagner.
local R = {}

R.SOUVENIRS, R.DEVORE, R.REGARD, R.COURSE, R.PLAQUER, R.FUMEE = 6, 10, 11, 12, 13, 14  -- places (vérifiées par les tests)
R.LAPIN = { 380, 330 }                           -- repère du build, comme l'aperçu validé
R.TACHE = 0.8
R.COEUR_LENT, R.COEUR_VITE, R.DUREE_COURSE = 1.4, 0.4, 11
R.CACHE_APRES = 1.2                              -- secondes après la fumée
R.VOLUTES, R.BRINS, R.VIE_BRIN = 60, 7, 0.7
local PERTE = R.FUMEE + 1

local function borne(v, a, b) return v < a and a or (v > b and b or v) end

function R.lapin(S) return S.i >= R.SOUVENIRS and S.i <= R.PLAQUER end

function R.tache(S, t)
	if S.i < R.DEVORE then return 0 end
	local t0 = S.inst.devore
	if not t0 then return R.TACHE end
	return R.TACHE * borne((t - t0 - 3) / 1, 0, 1)
end

function R.facteurVent(S) return (S.i == R.DEVORE or S.i == R.REGARD) and 0 or 1 end
function R.silence(S) return S.i >= R.DEVORE and S.i < PERTE end

-- un battement de cœur tombe-t-il entre les heures avant (exclue) et maintenant (incluse) ?
function R.battementEchu(S, avant, maintenant)
	local course = S.i == R.COURSE
	if S.i ~= R.REGARD and not course then return false end
	local t0 = course and S.inst.course or S.inst.regard
	if not t0 then return false end
	local b = t0
	for _ = 1, 400 do                               -- borne : quelques minutes de battements au plus
		if b > maintenant then return false end
		if b > avant and maintenant - b <= 0.5 then return true end
		local k = course and borne((b - t0) / R.DUREE_COURSE, 0, 1) or 0
		b = b + R.COEUR_LENT + (R.COEUR_VITE - R.COEUR_LENT) * k
	end
	return false
end

function R.cache(S, t)
	if S.i < R.FUMEE then return false end
	local t0 = S.inst.fumee
	return not t0 or t - t0 >= R.CACHE_APRES
end

-- volute de fumée noire i, s secondes après la commande : place autour de lui, taille, opacité (0 à 255)
function R.volute(i, s)
	local g, h = (i * 0.6180339887) % 1, (i * 0.3819660113) % 1
	local a = g * 2 * math.pi
	local etale = 8 + 30 * h * math.min(s, 3)
	local z = math.min(8 + 80 * h + 12 * s * g, 130)
	local taille = 22 + 26 * g + 9 * s
	local alpha = 165 * borne(s / 0.5, 0, 1) * borne((3.8 - s) / 2, 0, 1)
	return math.cos(a) * etale, math.sin(a) * etale, z, taille, alpha
end

-- brin d'herbe arraché i, s secondes après le pas : (x, y, z) autour du pied
function R.brin(i, s)
	local g, h = (i * 0.6180339887) % 1, (i * 0.7548776662) % 1
	local a = g * 2 * math.pi
	local k = borne(s / R.VIE_BRIN, 0, 1)
	local loin = (10 + 30 * h) * k
	return math.cos(a) * loin, math.sin(a) * loin, 4 + (18 + 24 * g) * 4 * k * (1 - k)
end

return R
