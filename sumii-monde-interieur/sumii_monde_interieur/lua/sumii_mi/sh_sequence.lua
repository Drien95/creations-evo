-- Séquenceur des 7 temps : état pur, sans appel à GMod (testable avec luajit). L'heure est toujours passée en argument.
-- Le serveur tient l'état ; chaque rendu client est une fonction de (état, heure).
local Q = {}

Q.NB_TERRIERS, Q.REVELE_DEFAUT, Q.GEL = 12, 7, 6
local RESULTATS = { vide = true, bruit = true, rien = true }

Q.SEQ = {
	{ cle = "lancer", cmd = "sumii_lancer", dur = 20 },
	{ cle = "detresse", cmd = "sumii_detresse", dur = 6 },
	{ cle = "reveler", cmd = "sumii_reveler", dur = 12 },
	{ cle = "voix", cmd = "sumii_voix", dur = 3, repetable = true },
	{ cle = "nom", cmd = "sumii_nom", dur = 6 },
	{ cle = "souvenirs", cmd = "sumii_souvenirs", dur = 30 },
	{ cle = "flash1", cmd = "sumii_flash 1", dur = 4 },
	{ cle = "flash2", cmd = "sumii_flash 2", dur = 3 },
	{ cle = "flash3", cmd = "sumii_flash 3", dur = 3 },
	{ cle = "devore", cmd = "sumii_devore", dur = 10 },
	{ cle = "regard", cmd = "sumii_regard", dur = 8 },
	{ cle = "course", cmd = "sumii_course", dur = 11 },
	{ cle = "plaquer", cmd = "sumii_plaquer", dur = Q.GEL },
	{ cle = "fumee", cmd = "sumii_fumee", dur = 4 },
	{ cle = "perte", cmd = "sumii_perte", dur = 25 },
	{ cle = "effondrement", cmd = "sumii_effondrement", dur = 20 },
}
Q.index = {}
for i, e in ipairs(Q.SEQ) do Q.index[e.cle] = i end

-- v : version (le serveur renvoie l'état à qui est en retard) ; i : dernier temps atteint ; inst : heure de lancement
function Q.neuf(v)
	return { v = v or 1, i = 0, inst = {}, terriers = {}, revele = nil }
end

local function terrierValide(n)
	return type(n) == "number" and n % 1 == 0 and n >= 1 and n <= Q.NB_TERRIERS
end

function Q.suivant(S)
	local e = Q.SEQ[S.i + 1]
	return e and e.cle
end

-- un temps dépassé compte comme fait, même sauté par une commande directe (le ciel rouge reste tenu)
function Q.fait(S, cle)
	return S.i >= Q.index[cle]
end

-- rend true, ou false et le motif
function Q.lancer(S, cle, t, terrier)
	local i = Q.index[cle]
	if not i then return false, "temps inconnu : " .. tostring(cle) end
	if cle == "reveler" then
		terrier = terrier or Q.REVELE_DEFAUT
		if not terrierValide(terrier) then return false, "terrier attendu de 1 à " .. Q.NB_TERRIERS end
		S.revele = terrier
	end
	S.inst[cle] = t
	if not (Q.SEQ[i].repetable and S.i > i) then S.i = i end     -- rejouer la voix ne fait pas reculer
	S.v = S.v + 1
	return true
end

function Q.avancer(S, t)
	local cle = Q.suivant(S)
	if not cle then return nil end
	Q.lancer(S, cle, t)
	return cle
end

-- annule le temps courant : l'image revient à la fin du temps précédent. Les fouilles ne reculent jamais.
function Q.retour(S)
	local e = Q.SEQ[S.i]
	if not e then return nil end
	S.inst[e.cle] = nil
	if e.cle == "reveler" then S.revele = nil end
	if e.cle == "detresse" then S.lieu = nil end
	S.i, S.v = S.i - 1, S.v + 1
	return e.cle
end

function Q.fouiller(S, n, resultat, t)
	if not terrierValide(n) then return false, "terrier attendu de 1 à " .. Q.NB_TERRIERS end
	resultat = resultat or "vide"
	if not RESULTATS[resultat] then return false, "résultat attendu : vide, bruit ou rien" end
	S.terriers[n] = { mode = resultat, t0 = t }
	S.v = S.v + 1
	return true
end

function Q.reconstruire(S, t)
	S.i, S.inst, S.terriers, S.revele, S.lieu = 0, { reconstruire = t }, {}, nil, nil
	S.v = S.v + 1
end

-- secondes de gel restantes à l'heure t (0 : la cible est libre)
function Q.gel(S, t)
	local t0 = S.inst.plaquer
	if not t0 or S.i ~= Q.index.plaquer then return 0 end
	return math.max(0, t0 + Q.GEL - t)
end

return Q
