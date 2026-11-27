-- Effets « monde » des temps 1 et 2 : tout est une fonction pure de (état, heure), testable avec luajit.
local M = {}

M.H_BASSE, M.ONDE, M.FONDU = 0.15, 240, 0.6     -- hauteur endormie, vitesse de l'éveil (u/s), fondu au passage (s)
M.SOLEIL_VOILE, M.NUAGE = 0.35, 6                -- part du soleil sous le nuage, durée pour s'en dégager (s)
M.VOISIN_MIN = 250                               -- « bruit » : la touffe qui frémit est au moins à cette distance
M.FREMIT, M.FREMIT_HZ, M.FREMIT_DE, M.FREMIT_A = 0.35, 28, 4.0, 5.2
M.PELLES = { 0.4, 1.5, 2.6, 3.7 }                -- instants des pelletées (ceux de P2)
M.RETARD_MAX = 0.5                               -- un son ponctuel plus vieux que ça n'est pas rejoué
M.PAPILLONS = 40

local function borne(v, a, b) return v < a and a or (v > b and b or v) end

-- instant de départ du temps 1, ou -inf si un temps plus loin a été lancé sans lui
local function depart(S)
	if S.inst.lancer then return S.inst.lancer end
	if S.i >= 1 then return -math.huge end
	return nil
end

-- hauteur de l'herbe (0 à 1) à la distance d du centre
function M.herbe(S, d, t)
	local t0 = depart(S)
	if not t0 then return M.H_BASSE end
	return M.H_BASSE + (1 - M.H_BASSE) * borne((t - t0 - d / M.ONDE) / M.FONDU, 0, 1)
end

-- écart du nuage : 0 devant le soleil, 1 tout à fait de côté
function M.ecartNuage(S, t)
	local t0 = depart(S)
	if not t0 then return 0 end
	local k = borne((t - t0) / M.NUAGE, 0, 1)
	return k * k * (3 - 2 * k)
end
function M.soleil(S, t) return M.SOLEIL_VOILE + (1 - M.SOLEIL_VOILE) * M.ecartNuage(S, t) end

-- terrier non fouillé le plus proche de n, au-delà de la distance minimale
function M.voisin(terriers, fouilles, n)
	local o, mieux, d2mieux = terriers[n], nil, math.huge
	for i, h in ipairs(terriers) do
		local dx, dy = h.x - o.x, h.y - o.y
		local d2 = dx * dx + dy * dy
		if i ~= n and not fouilles[i] and d2 > M.VOISIN_MIN ^ 2 and d2 < d2mieux then mieux, d2mieux = i, d2 end
	end
	return mieux
end

-- cisaillement ajouté à la touffe, s secondes après la commande de fouille
function M.fremit(s)
	if s < M.FREMIT_DE or s > M.FREMIT_A then return 0 end
	local enveloppe = math.sin((s - M.FREMIT_DE) / (M.FREMIT_A - M.FREMIT_DE) * math.pi)
	return M.FREMIT * enveloppe * math.sin(s * M.FREMIT_HZ * 2 * math.pi)
end

-- le son daté « t0 + decalage » est-il à jouer entre les heures avant (exclue) et maintenant (incluse) ?
function M.echu(t0, decalage, avant, maintenant)
	local quand = t0 + decalage
	return quand > avant and quand <= maintenant and maintenant - quand <= M.RETARD_MAX
end

-- papillon i à l'heure t : orbite lente à 600-1 500 u de (cx, cy) ; rend aussi le cap et le battement d'ailes
function M.papillon(i, t, cx, cy)
	local g = (i * 0.6180339887) % 1
	local rayon = 650 + 800 * ((i * 0.3819660113) % 1)
	local sens = i % 2 == 0 and 1 or -1
	local a = g * 2 * math.pi + sens * t * (22 + 16 * g) / rayon
	local r = rayon + 45 * math.sin(t * (0.7 + g) + i)
	local z = 52 + 30 * math.sin(t * 1.1 + i * 1.7) + 12 * math.sin(t * 3.7 + i)
	local x, y = cx + r * math.cos(a), cy + r * math.sin(a)
	return x, y, z, a + sens * math.pi / 2, math.sin(t * (17 + 6 * g) + i)
end

return M
