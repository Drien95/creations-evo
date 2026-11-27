-- Temps 8 (effondrement) puis boîte blanche : calcul pur, fonction de (état, heure).
local E = {}

E.PLACE = 16                                     -- place dans la séquence (vérifiée par les tests)
E.PROFONDEUR, E.ECLATS = 700, 90

local function borne(v, a, b) return v < a and a or (v > b and b or v) end
local function alea(i, k) return (math.sin(i * 127.1 + k * 311.7) * 43758.5453) % 1 end   -- identique chez tous

-- secondes depuis la commande ; grand nombre si le temps n'a pas d'heure ; nil s'il n'est pas atteint
function E.instant(S, t)
	if S.i < E.PLACE then return nil end
	local t0 = S.inst.effondrement
	return t0 and t - t0 or 1000
end

function E.blanc(S, t)
	local s = E.instant(S, t)
	return s and borne((s - 15) / 1.5, 0, 1) or 0
end
function E.silence(S, t) return E.blanc(S, t) >= 1 end
function E.masque(S, t)
	local s = E.instant(S, t)
	return s ~= nil and s >= 13
end

-- la lisière et les rochers s'enfoncent : lentement d'abord, puis vite
function E.enfoncement(S, t)
	local s = E.instant(S, t)
	if not s then return 0 end
	local k = borne((s - 3) / 10, 0, 1)
	return E.PROFONDEUR * k * k
end

-- part de hauteur qui reste à l'herbe, à la distance r du centre : le bord s'éteint d'abord
function E.herbe(S, t, r)
	local s = E.instant(S, t)
	if not s then return 1 end
	return 1 - borne((s - 2 - (1750 - borne(r, 0, 1750)) / 300) / 2, 0, 1)
end

-- éclat de ciel i à la seconde s : x, y, z, angle, taille ; nil s'il n'est pas en l'air
function E.eclat(i, s)
	local depart = 4 + alea(i, 1) * 7.5
	local age = s - depart
	if age < 0 or s >= 14 then return nil end
	local z = 700 + 600 * alea(i, 2) - 160 * age * age
	if z < -90 then return nil end
	local a = alea(i, 3) * math.pi * 2
	local r = 2215 + 70 * alea(i, 4)
	return math.cos(a) * r, math.sin(a) * r, z, age * (1.5 + 3 * alea(i, 5)) + a, 36 + 62 * alea(i, 6)
end

-- veines du ciel, à la façon des veines du Lac noir : tracés sinueux à points serrés, fourches puis brins,
-- largeur qui s'affine du départ à la pointe. Listes de points { azimut, élévation (degrés), largeur }.
E.PAS = 1.3                                      -- écart maximal entre deux points (degrés)
function E.fissures()
	local liste = {}
	local function veine(az, el, cap, nb, large, debut, duree, graine)
		large = math.max(large, 0.34)
		local pointe = borne(large * 0.45, 0.16, 0.22)
		local v = { debut = debut, fin = math.min(debut + duree, 8), { az, el, 0.16 } }
		local derive = 0
		for k = 1, nb do
			derive = derive * 0.72 + (alea(graine, k) - 0.5) * 0.55          -- courbure douce, qui garde son élan
			cap = cap + derive
			local casse = (alea(graine, k + 400) - 0.5) * 0.7                -- petite cassure : la pierre qui se fend
			local vers = el + math.sin(cap + casse) * E.PAS * 0.75
			if vers < 4 or vers > 80 then cap, casse = -cap, -casse end      -- elle reste dans le ciel
			az = az + math.cos(cap + casse) * E.PAS * 0.9
			el = borne(el + math.sin(cap + casse) * E.PAS * 0.4, 4, 80)
			local ouvre = math.min(1, k / 5)                                  -- la fente s'ouvre depuis une pointe
			local plein = large + (pointe - large) * (k / nb) ^ 0.8
			v[#v + 1] = { az, el, 0.16 + (plein - 0.16) * ouvre }
		end
		liste[#liste + 1] = v
		return v
	end
	-- des fourches partent d'une veine, au moment où son front les atteint
	local function fourches(mere, combien, nb, graine)
		local filles = {}
		for b = 1, combien do
			local place = borne(math.floor((#mere - 3) * (b / (combien + 1) + 0.12 * (alea(graine, b + 20) - 0.5))) + 1, 1, #mere - 2)
			local p, q = mere[place], mere[place + 1]
			local cote = b % 2 == 0 and 1 or -1
			local cap = math.atan2((q[2] - p[2]) * 2, q[1] - p[1]) + cote * (0.7 + 0.6 * alea(graine, b + 40))
			local depart = mere.debut + (mere.fin - mere.debut) * place / #mere
			filles[#filles + 1] = veine(p[1], p[2], cap, nb, p[3] * 0.62, math.min(depart, 7.4), 0.9, graine * 17 + b)
		end
		return filles
	end
	for i = 1, 8 do
		local debut = 1 + (i - 1) * 0.5
		local mere = veine(i * 45 + alea(i, 7) * 22, 12 + 36 * alea(i, 8), alea(i, 9) * math.pi * 2, 52, 2.7, debut, 2.6, i)
		for k, fille in ipairs(fourches(mere, 4, 20, i * 31)) do fourches(fille, 1, 9, i * 53 + k) end   -- puis les brins
	end
	return liste
end

return E
