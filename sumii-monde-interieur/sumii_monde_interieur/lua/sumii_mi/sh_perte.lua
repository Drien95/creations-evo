-- Temps 7 (perte de contrôle) et vertige : calcul pur, fonction de (état, heure).
local F = {}

F.PERTE, F.EFFONDREMENT = 15, 16                 -- places (vérifiées par les tests)
F.COUCHE = 1.1                                   -- cisaillement de l'herbe couchée
F.ROULIS, F.CHAMP, F.ROTATION = 7, 6, 7          -- degrés, degrés, degrés par seconde
F.BLANC_A = 15                                   -- la boîte blanchit 15 s après l'effondrement

local function borne(v, a, b) return v < a and a or (v > b and b or v) end

-- secondes depuis la perte (grand nombre si elle a été sautée), ou nil si elle n'est pas atteinte
local function depuis(S, t)
	if S.i < F.PERTE then return nil end
	local t0 = S.inst.perte
	return t0 and t - t0 or 1000
end

-- force du vent de la perte, 0 à 1 : monte en 3 s puis souffle par rafales
function F.rafale(S, t)
	local s = depuis(S, t)
	if not s then return 0 end
	local souffle = 0.68 + 0.32 * math.sin(s * 1.7) * math.sin(s * 0.53 + 1.1)
	return borne(s / 3, 0, 1) * borne(souffle, 0, 1)
end
-- cisaillement d'un bloc d'herbe : du vent d'avant (k) jusqu'à l'herbe à plat, avec un frémissement rapide
function F.herbe(S, t, k, phase)
	local s = depuis(S, t)
	if not s then return k end
	local monte = borne(s / 3, 0, 1)
	return k + (F.COUCHE - k) * monte + 0.2 * math.sin(s * 11 + phase) * monte
end

-- terriers du centre vers le bord
function F.ordre(terriers)
	local l = {}
	for n = 1, #terriers do l[n] = n end
	table.sort(l, function(a, b)
		local ta, tb = terriers[a], terriers[b]
		return ta.x * ta.x + ta.y * ta.y < tb.x * tb.x + tb.y * tb.y
	end)
	return l
end
-- retard de l'effondrement du terrier n, de rang donné (même rythme que l'essai prouvé de P2)
function F.depart(rang, n) return 2 + (rang - 1) * 0.55 + (n % 3 - 1) * 0.15 end
-- heure de départ de la chaîne : nil avant la perte, -inf si elle a été sautée
function F.chaine(S)
	if S.i < F.PERTE then return nil end
	return S.inst.perte or -math.huge
end

-- part de vertige, 0 à 1 : monte en 2 s, s'éteint quand la boîte devient blanche
function F.vertige(S, t)
	local s = depuis(S, t)
	if not s then return 0 end
	local part = borne(s / 2, 0, 1)
	if S.i >= F.EFFONDREMENT then
		local e = S.inst.effondrement
		if not e then return 0 end
		part = part * borne(F.BLANC_A - (t - e), 0, 1)
	end
	return part
end
function F.roulis(S, t) return F.ROULIS * F.vertige(S, t) * math.sin((depuis(S, t) or 0) * 0.9) end
function F.champ(S, t) return F.CHAMP * F.vertige(S, t) * math.sin((depuis(S, t) or 0) * 1.4) end
-- angle (degrés) du ciel qui tourne
function F.tourne(S, t)
	local s = depuis(S, t)
	if not s or s >= 1000 then return 0 end
	return F.ROTATION * math.max(0, s - 1)
end

return F
