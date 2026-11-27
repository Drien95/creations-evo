-- Plaquage (6 s), d'après la maquette validée effets/apercu-plaquage.html. Calcul pur.
local L = {}

L.PLACE, L.DUREE = 13, 6

local function borne(v, a, b) return v < a and a or (v > b and b or v) end
local function passage(s, a, b)                    -- 0 avant a, 1 après b, adouci entre les deux
	local k = borne((s - a) / (b - a), 0, 1)
	return k * k * (3 - 2 * k)
end

-- secondes depuis le plaquage tant qu'il dure, sinon nil
function L.instant(S, maintenant)
	local t0 = S.inst.plaquer
	if S.i ~= L.PLACE or not t0 then return nil end
	local s = maintenant - t0
	if s >= -1e-6 and s <= L.DUREE then return math.max(s, 0) end
end

local function releve(s) return passage(s, 5.4, 6) end
-- vue de Sumii : hauteur de l'œil (u), tangage, écart de lacet, roulis (degrés)
function L.vue(s)
	local chute = passage(s, 0, 0.4) * (1 - releve(s))
	local secousse = s > 0.4 and borne(1 - (s - 0.4) / 1.1, 0, 1) or 0
	return 64 - 58 * chute,
		-65.9 * chute - 1.7 * math.sin(s * 47) * secousse,
		-20 * chute,
		20 * chute + 2.3 * math.cos(s * 53) * secousse
end
function L.couche(s) return passage(s, 0, 0.4) * (1 - releve(s)) end

function L.penche(s) return passage(s, 1.0, 2.5) end
function L.lame(s)
	if s < 2.5 or s > 3.6 then return nil end
	return passage(s, 2.5, 3.2)
end
function L.entailles(s) return passage(s, 3.4, 3.6) end
function L.noir(s) return passage(s, 4.2, 5.0) end

-- point (x, y) de la maquette, à la profondeur donnée devant la caméra, vers les pixels d'un écran W x H
local DEMI_CHAMP = math.tan(math.rad(37.5))
function L.ecran(x, y, profondeur, W, H)
	local unite = (H / 2) / (profondeur * DEMI_CHAMP)
	return W / 2 + x * unite, H / 2 - y * unite
end

-- silhouette de la maquette (épaules, cou, tête) en morceaux convexes, parcourus dans le sens horaire à l'écran
local tete = {}
for i = 0, 15 do
	local a = i / 16 * math.pi * 2
	tete[#tete + 1] = { 0.43 * math.cos(a), 0.83 - 0.43 * math.sin(a) }
end
L.SILHOUETTE = {
	{ { -1.6, -1 }, { -1.5, 0.1 }, { -1.05, 0.4 }, { -0.45, 0.5 }, { 0.45, 0.5 }, { 1.05, 0.4 }, { 1.5, 0.1 }, { 1.6, -1 } },
	{ { -0.34, 0.4 }, { -0.34, 0.7 }, { 0.34, 0.7 }, { 0.34, 0.4 } },
	tete,
}

return L
