-- Géométrie du cylindre de fermeture et de sa parallaxe. Calcul pur (testable avec luajit), repère du build.
local C = {}

C.RAYON, C.RAYON_HALO, C.DIST_MIN = 2400, 2390, 40
C.OEIL_REF = 64                                   -- hauteur d'œil debout : à cette hauteur au centre, image inchangée
C.PLANS = { 14000, 8000, 4800 }                   -- distance apparente des 3 plans lointains de P1, du fond vers l'avant
C.NUAGES = 20000

function C.dedans(x, y) return x * x + y * y < C.RAYON * C.RAYON end

-- Décalage de la caméra d'un plan peint à rayonMaillage et vu à la distance apparente D (nil : à l'infini).
function C.decalage(x, y, z, rayonMaillage, D)
	if not D then return 0, 0, 0 end
	local d = math.sqrt(x * x + y * y)
	local borne = d > C.RAYON and C.RAYON / d or 1
	local k = rayonMaillage / D
	return x * borne * k, y * borne * k, (z - C.OEIL_REF) * k
end

-- Distance, le long de la direction unitaire (dx, dy, dz), entre l'œil et le mur : le halo du soleil se pose là.
function C.distanceMur(x, y, dx, dy, dz)
	local a = dx * dx + dy * dy
	if a < 1e-6 then return C.RAYON_HALO end
	local b = x * dx + y * dy
	local c = x * x + y * y - C.RAYON_HALO * C.RAYON_HALO
	local delta = b * b - a * c
	if delta < 0 then return C.DIST_MIN end
	return math.max((math.sqrt(delta) - b) / a, C.DIST_MIN)
end

return C
