-- GÉNÉRÉ par addon/construire.py depuis terriers/banc/cl_sumii_p2.lua : ne pas modifier ici.
-- Sumii, monde intérieur · P2 « Terriers » (banc, 27/11/2026, v15). Client seulement. FICHIER GÉNÉRÉ par build.py.
-- Pour le joueur dont la caméra est dans la boîte : le noir de chaque terrier héros (cône qui ne reçoit aucune lumière)
-- et 3 racines en arche autour de l'entrée. Les 3 props de chaque héros sont rééclairés par P1 (or), comme tous les props de la boîte.
-- Repère : celui de P1 (plaque centrale, modèle + teinte). Console (aucune touche en dur) : sumii_p2 <0|1>, sumii_p2_mesure.

local P = {
	MODELE_TETE = "models/hunter/plates/plate32x32.mdl", TEINTE_TETE = { 88, 124, 56 }, TETE = Vector(0, 0, -1.5),
	BX = 2400, BZ0 = -200, BZ1 = 1400,
	SOLEIL_AZ = 208, SOLEIL_EL = 6,                -- comme P1
	SEG_TROU = 24, BOUCHE_HAUT = 0.36, BOUCHE_PIED = 6, BOUCHE_RECUL = 12, BOUCHE_LARG = 1.0, COEUR = 0.42,
	SEUIL = 20, BOYAU_N = 12, BOYAU_LONG = 78, BOYAU_PROF = 46, BOYAU_VIRAGE = 22,
	TERRE = { 122, 84, 52 }, FOND = { 12, 7, 4, 255 }, LEVRE = { 112, 78, 50 }, LEVRE_R = 4.2,
	ARCHE_K = { 1.14, 1.30 },
	RACINE_SEG = 18, RACINE_COTES = 6,
	RACINE = { 92, 66, 44 }, AMB = 0.42, SOL = 0.75,
}
local HEROS = {
	{n = 1, c = {-157.76, -149.14, 12.81}, F = {0.754, 0.6569}, R = {-0.6569, 0.754}, w = 65.8, h = 34.9, racines = {{r = 2.57, p = {{-152.84, -176.76, 1.6}, {-153.31, -163.47, 20.04}, {-161.21, -152.51, 22.26}, {-171.57, -143.06, 18.92}, {-182.18, -140.65, 1.6}}}, {r = 2.08, p = {{-154.19, -171.55, 1.6}, {-153.43, -159.53, 16.43}, {-160.61, -149.53, 18.25}, {-165.96, -145.83, 15.52}, {-179.22, -140.38, 1.6}}}, {r = 1.6, p = {{-170.44, -151.68, 9.62}, {-166.35, -141.73, 3.21}, {-161.46, -132.68, 1}, {-160.16, -119.32, 0.5}}}}},
	{n = 2, c = {262.42, -155.47, 12.98}, F = {-0.8768, 0.4809}, R = {-0.4809, -0.8768}, w = 63.9, h = 32.7, racines = {{r = 2.65, p = {{287.48, -140.84, 1.66}, {274.4, -147.68, 20.88}, {266.53, -158.34, 23.2}, {262.96, -168.3, 19.72}, {262.58, -182.78, 1.66}}}, {r = 2.16, p = {{282.91, -144.0, 1.66}, {270.45, -150.72, 17.15}, {265.58, -154.89, 19.06}, {261.74, -165.34, 16.2}, {262.94, -176.95, 1.66}}}, {r = 1.66, p = {{269.41, -166.88, 9.95}, {258.29, -166.46, 3.32}, {246.25, -167.71, 1}, {236.79, -169.8, 0.5}}}}},
	{n = 3, c = {76.52, -322.23, 14.87}, F = {-0.4076, 0.9132}, R = {-0.9132, -0.4076}, w = 64.8, h = 32.7, racines = {{r = 3.67, p = {{116.31, -327.05, 2.29}, {96.98, -322.21, 30.55}, {77.82, -329.17, 33.95}, {63.79, -337.94, 28.85}, {52.9, -352.84, 2.29}}}, {r = 2.98, p = {{108.63, -326.71, 2.29}, {92.67, -322.18, 25.4}, {78.29, -325.2, 28.22}, {68.59, -332.04, 23.99}, {58.78, -346.45, 2.29}}}, {r = 2.29, p = {{74.69, -340.6, 13.75}, {62.81, -330.85, 4.58}, {50.99, -321.08, 1}, {34.85, -313.16, 0.5}}}}},
	{n = 4, c = {-312.69, 289.73, 15.21}, F = {0.5261, -0.8504}, R = {0.8504, 0.5261}, w = 63.3, h = 33.6, racines = {{r = 3.85, p = {{-354.73, 289.16, 2.4}, {-332.45, 289.19, 32.27}, {-318.84, 294.4, 35.86}, {-301.49, 307.96, 30.48}, {-294.58, 323.54, 2.4}}}, {r = 3.12, p = {{-346.7, 289.88, 2.4}, {-328.28, 287.28, 26.87}, {-315.84, 292.02, 29.85}, {-304.65, 301.77, 25.37}, {-294.5, 319.35, 2.4}}}, {r = 2.4, p = {{-313.37, 309.09, 14.42}, {-299.65, 300.62, 4.81}, {-288.35, 290.65, 1}, {-268.13, 286.23, 0.5}}}}},
	{n = 5, c = {230.72, 266.92, 13.7}, F = {-0.3448, -0.9387}, R = {0.9387, -0.3448}, w = 65.6, h = 32.3, racines = {{r = 3.04, p = {{209.85, 292.82, 1.9}, {218.35, 279.94, 24.59}, {232.04, 272.51, 27.33}, {244.59, 269.93, 23.23}, {261.15, 271.95, 1.9}}}, {r = 2.47, p = {{214.22, 288.17, 1.9}, {221.08, 274.77, 20.32}, {231.38, 269.71, 22.57}, {240.96, 268.22, 19.19}, {256.27, 270.7, 1.9}}}, {r = 1.9, p = {{242.45, 276.79, 11.41}, {243.87, 264.11, 3.8}, {247.48, 250.63, 1}, {250.22, 237.27, 0.5}}}}},
	{n = 6, c = {-483.84, -130.03, 14.07}, F = {0.9724, 0.2333}, R = {-0.2333, 0.9724}, w = 62.4, h = 33.6, racines = {{r = 3.24, p = {{-494.47, -163.79, 2.02}, {-488.82, -145.54, 26.46}, {-489.71, -131.61, 29.39}, {-494.79, -119.06, 24.99}, {-507.03, -102.74, 2.02}}}, {r = 2.63, p = {{-492.93, -157.18, 2.02}, {-485.54, -143.31, 21.9}, {-486.8, -130.73, 24.34}, {-491.61, -119.32, 20.69}, {-502.11, -110.23, 2.02}}}, {r = 2.02, p = {{-499.5, -125.47, 12.14}, {-489.11, -116.73, 4.05}, {-478.81, -107.65, 1}, {-472.83, -96.18, 0.5}}}}},
	{n = 7, c = {-348.85, 49.18, 13.25}, F = {0.903, -0.4295}, R = {0.4295, 0.903}, w = 62.4, h = 34.2, racines = {{r = 2.8, p = {{-374.33, 32.25, 1.75}, {-361.09, 39.96, 22.25}, {-352.98, 52.72, 24.72}, {-348.88, 65.42, 21.01}, {-349.52, 80.33, 1.75}}}, {r = 2.27, p = {{-369.71, 35.86, 1.75}, {-356.89, 41.85, 18.32}, {-350.36, 52.12, 20.35}, {-349.07, 58.89, 17.3}, {-349.35, 74.6, 1.75}}}, {r = 1.75, p = {{-356.9, 60.75, 10.49}, {-345.18, 60.98, 3.5}, {-333.94, 60.18, 1}, {-320.24, 64.61, 0.5}}}}},
	{n = 8, c = {359.52, -501.4, 14.3}, F = {-0.5667, 0.8239}, R = {-0.8239, -0.5667}, w = 61.8, h = 32.7, racines = {{r = 3.36, p = {{396.19, -499.12, 2.1}, {376.86, -499.65, 27.63}, {362.55, -506.96, 30.7}, {352.86, -516.18, 26.1}, {344.53, -532.1, 2.1}}}, {r = 2.73, p = {{389.21, -500.09, 2.1}, {372.33, -498.81, 22.91}, {359.51, -505.24, 25.45}, {352.03, -512.92, 21.64}, {347.96, -525.93, 2.1}}}, {r = 2.1, p = {{360.93, -518.27, 12.6}, {348.6, -511.46, 4.2}, {335.05, -505.49, 1}, {320.52, -500.28, 0.5}}}}},
	{n = 9, c = {-102.26, 652.16, 14.62}, F = {-0.0505, -0.9987}, R = {0.9987, -0.0505}, w = 65.9, h = 35.5, racines = {{r = 3.53, p = {{-134.3, 673.66, 2.21}, {-116.09, 662.0, 29.25}, {-104.05, 658.88, 32.5}, {-84.64, 660.11, 27.62}, {-70.79, 668.24, 2.21}}}, {r = 2.87, p = {{-127.86, 670.02, 2.21}, {-117.2, 657.69, 24.29}, {-101.59, 655.44, 26.98}, {-86.81, 656.9, 22.94}, {-72.91, 665.03, 2.21}}}, {r = 2.21, p = {{-92.67, 667.14, 13.23}, {-86.73, 653.59, 4.41}, {-82.63, 640.13, 1}, {-70.4, 627.03, 0.5}}}}},
	{n = 10, c = {-246.79, -698.96, 15.48}, F = {0.5101, 0.8601}, R = {-0.8601, 0.5101}, w = 63.1, h = 32.2, racines = {{r = 3.99, p = {{-226.07, -737.35, 2.49}, {-235.66, -717.85, 33.66}, {-252.61, -704.2, 37.4}, {-268.24, -697.83, 31.79}, {-289.87, -696.61, 2.49}}}, {r = 3.24, p = {{-230.59, -730.31, 2.49}, {-238.84, -711.48, 28.05}, {-250.0, -701.4, 31.16}, {-263.24, -696.45, 26.49}, {-280.08, -698.06, 2.49}}}, {r = 2.49, p = {{-264.28, -708.88, 14.96}, {-263.08, -692.2, 4.99}, {-260.18, -676.52, 1}, {-265.43, -657.06, 0.5}}}}},
	{n = 11, c = {790.72, 394.87, 14.82}, F = {-0.9671, -0.2545}, R = {0.2545, -0.9671}, w = 63.5, h = 33.2, racines = {{r = 3.63, p = {{801.82, 433.03, 2.27}, {794.6, 415.05, 30.26}, {797.68, 395.2, 33.62}, {803.48, 382.07, 28.58}, {816.67, 367.68, 2.27}}}, {r = 2.95, p = {{800.26, 425.57, 2.27}, {792.42, 407.5, 25.15}, {794.23, 394.93, 27.94}, {800.08, 381.63, 23.75}, {811.88, 372.47, 2.27}}}, {r = 2.27, p = {{808.41, 390.13, 13.63}, {796.96, 380.07, 4.54}, {786.22, 367.33, 1}, {778.9, 356.52, 0.5}}}}},
	{n = 12, c = {-877.97, -97.65, 13.41}, F = {0.9183, 0.3958}, R = {-0.3958, 0.9183}, w = 65.2, h = 32.3, racines = {{r = 2.89, p = {{-882.17, -128.92, 1.8}, {-878.86, -115.06, 23.09}, {-882.38, -101.1, 25.66}, {-890.72, -86.3, 21.81}, {-901.85, -78.7, 1.8}}}, {r = 2.34, p = {{-881.83, -122.88, 1.8}, {-877.84, -108.67, 19.04}, {-881.33, -96.69, 21.15}, {-886.52, -89.22, 17.98}, {-896.64, -83.95, 1.8}}}, {r = 1.8, p = {{-892.42, -96.03, 10.82}, {-884.62, -86.77, 3.61}, {-877.45, -76.08, 1}, {-870.83, -65.12, 0.5}}}}}
}

local ET, DEC, bouche_fermee
local etat = { allume = true, tete = nil, prochaine = 0, erreurs = {}, n = 0, total = 0, pic = 0, sn = 0, stotal = 0, spic = 0, essai = 3, posT = nil, angT = nil }
local G = { maillages = {}, bouches = {} }

local function chercherTete() return SumiiAncre.tete() end
local function majTete()
	if CurTime() >= etat.prochaine then
		etat.prochaine = CurTime() + 1
		if not IsValid(etat.tete) then etat.tete = chercherTete() end
	end
	return IsValid(etat.tete)
end
local function versMonde(v) return etat.tete:LocalToWorld(v - P.TETE) end
local function versBuild(p) return etat.tete:WorldToLocal(p) + P.TETE end
local function dedans()
	if not etat.allume or not majTete() then return false end
	local p = versBuild(EyePos())
	return p.x * p.x + p.y * p.y <= P.BX * P.BX and p.z >= P.BZ0 and p.z <= P.BZ1
end

local SOLEIL = Vector(math.cos(math.rad(P.SOLEIL_AZ)) * math.cos(math.rad(P.SOLEIL_EL)),
	math.sin(math.rad(P.SOLEIL_AZ)) * math.cos(math.rad(P.SOLEIL_EL)), math.sin(math.rad(P.SOLEIL_EL)))

local function detruire()
	for _, m in ipairs(G.maillages) do if IsValid(m) then m:Destroy() end end
	G.maillages = {}
	for _, b in ipairs(G.bouches) do
		if IsValid(b.decoupe) then b.decoupe:Destroy() end
		if IsValid(b.boyau) then b.boyau:Destroy() end
		if IsValid(b.temoin) then b.temoin:Destroy() end
	end
	G.bouches = {}
	if ET then ET.detruire() end
	if DEC then DEC.detruire() end
end

-- ---------- construction (une fois par position du repère, en coordonnées monde) ----------
local function catmull(p0, p1, p2, p3, t)
	local t2, t3 = t * t, t * t * t
	return 0.5 * ((2 * p1) + (p2 - p0) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (3 * p1 - p0 - 3 * p2 + p3) * t3)
end
local function courbe(pts, n)
	local out, k = {}, #pts
	for i = 1, k - 1 do
		local p0, p1, p2, p3 = pts[math.max(i - 1, 1)], pts[i], pts[i + 1], pts[math.min(i + 2, k)]
		local m = math.max(2, math.floor(n / (k - 1)))
		for j = 0, m - 1 do out[#out + 1] = catmull(p0, p1, p2, p3, j / m) end
	end
	out[#out + 1] = pts[k]
	return out
end

-- ---------- états des terriers héros : intact, fouillé, effondré (conception-etats.md, maquette validée 27/11 17 h 53) ----------
-- Injecté par build.py dans le modèle. Maillages construits une fois ; à chaque image on choisit, sans créer de Vector
-- (sauf à l'émission de la poussière). Les props ne sont tassés qu'à l'affichage (RenderMultiply), P1 les rééclaire toujours.
local E = {
	PELLES = { 0.4, 1.5, 2.6, 3.7 }, VOL = 0.6, CROIT = 0.3, FIN_FOUILLE = 5, FIN_CHUTE = 2.6,
	FRAIS = { 84, 50, 29 }, FRAIS_BORD = { 104, 66, 40 }, MOTTE = { { 58, 35, 21 }, { 108, 70, 43 }, { 78, 48, 28 } },
	PIERRE = { 138, 114, 90 }, TERRE = { 104, 74, 48 }, RACINE = { 92, 66, 44 }, CASSURE = { 150, 118, 84 },
	POUSSIERE = { 120, 92, 64 }, PAS_EVENTAIL = 16, PAS_CHUTE = 9, PAS_EBOULIS = 12, G = 600,
	ROCHES = { ["models/props_wasteland/rockgranite02a.mdl"] = "bras", ["models/props_wasteland/rockgranite02c.mdl"] = "dos" },
}
ET = { heros = {}, etats = {} }
-- zones d'herbe à masquer après une fouille (lues par P1 à sa construction) : même contour que l'éventail
SumiiHerbe = { zones = {}, masque = {} }
for _, h in ipairs(HEROS) do
	local avance = P.BOUCHE_PIED + P.SEUIL + 4
	SumiiHerbe.zones[h.n] = { x = h.c[1] + h.F[1] * avance, y = h.c[2] + h.F[2] * avance, fx = h.F[1], fy = h.F[2],
		rx = h.R[1], ry = h.R[2], lat = h.w * P.BOUCHE_LARG * 0.28 + 5, long = math.Clamp(h.w * 1.1, 66, 90) + 8 }
end
local HAUT = Vector(0, 0, 1)

local function alea(graine)                      -- tirage déterministe : identique chez tous les joueurs
	local s = graine % 2147483647
	if s <= 0 then s = s + 2147483646 end
	return function() s = (s * 16807) % 2147483647 return (s - 1) / 2147483646 end
end
local function etape(t, debut, duree) return math.Clamp((t - debut) / duree, 0, 1) end
local function maille(t)                         -- t = liste plate de sommets { pos build, couleur }
	if #t == 0 then return nil end
	local m = Mesh()
	mesh.Begin(m, MATERIAL_TRIANGLES, #t / 3)
	for _, v in ipairs(t) do
		local c = v[2]
		mesh.Position(versMonde(v[1]))
		mesh.Color(math.Clamp(c[1], 0, 255), math.Clamp(c[2], 0, 255), math.Clamp(c[3], 0, 255), 255)
		mesh.AdvanceVertex()
	end
	mesh.End()
	return m
end
local function facette(out, a, b, c, col, centre)    -- facette plate éclairée par sa normale, visible des deux côtés
	local n = (b - a):Cross(c - a)
	n:Normalize()
	if n:Dot((a + b + c) / 3 - centre) < 0 then n = -n end
	local l = 0.74 + 0.42 * math.max(n:Dot(SOLEIL), 0) + 0.16 * n.z
	local k = { col[1] * l, col[2] * l, col[3] * l }
	for _, p in ipairs({ a, b, c, a, c, b }) do out[#out + 1] = { p, k } end
end

local PHI = (1 + math.sqrt(5)) / 2
local ICO_S = { { -1, PHI, 0 }, { 1, PHI, 0 }, { -1, -PHI, 0 }, { 1, -PHI, 0 }, { 0, -1, PHI }, { 0, 1, PHI }, { 0, -1, -PHI },
	{ 0, 1, -PHI }, { PHI, 0, -1 }, { PHI, 0, 1 }, { -PHI, 0, -1 }, { -PHI, 0, 1 } }
local ICO_F = { { 1, 12, 6 }, { 1, 6, 2 }, { 1, 2, 8 }, { 1, 8, 11 }, { 1, 11, 12 }, { 2, 6, 10 }, { 6, 12, 5 }, { 12, 11, 3 },
	{ 11, 8, 7 }, { 8, 2, 9 }, { 4, 10, 5 }, { 4, 5, 3 }, { 4, 3, 7 }, { 4, 7, 9 }, { 4, 9, 10 }, { 5, 10, 6 }, { 3, 5, 12 },
	{ 7, 3, 11 }, { 9, 7, 8 }, { 10, 9, 2 } }
-- bloc cabossé : demi-axes ax (largeur, sur R), ay (profondeur, sur F), az (hauteur)
local function bloc(out, centre, R, F, ax, ay, az, col, r)
	local p, tour = {}, r() * math.pi * 2
	for i, s in ipairs(ICO_S) do
		local x, y, z = s[1] / 1.902, s[2] / 1.902, s[3] / 1.902
		local x2, y2 = x * math.cos(tour) - y * math.sin(tour), x * math.sin(tour) + y * math.cos(tour)
		local k = 0.78 + r() * 0.44
		p[i] = centre + R * (x2 * ax * k) + F * (y2 * ay * k) + HAUT * (z * az * k)
	end
	for _, f in ipairs(ICO_F) do
		local grain = 0.90 + r() * 0.2
		facette(out, p[f[1]], p[f[2]], p[f[3]], { col[1] * grain, col[2] * grain, col[3] * grain }, centre)
	end
end

local function matriceAutour(pivot, echelle, angle, leve)
	local m = Matrix()
	m:Translate(leve and (pivot + leve) or pivot)
	if angle then m:Rotate(angle) end
	if echelle then m:Scale(Vector(echelle, echelle, echelle)) end
	m:Translate(-pivot)
	return m
end

-- fouillé : éventail de terre fraîche (110°, dès 4 u après le seuil, bombé) et mottes posées, en 4 lots d'arrivée
local function construireFouille(g, h, geo)
	local r = alea(4100 + h.n * 37)
	local F, R = geo.F, geo.R
	local sommet = geo.pied + F * (P.SEUIL + 4)
	sommet.z = 0
	local longueur = math.Clamp(h.w * 1.1, 66, 90)
	local N, K, grille = 18, 7, {}
	for k = 0, K do
		grille[k] = {}
		for i = 0, N do
			local a, f = (i / N - 0.5) * math.rad(110), k / K
			local long = longueur * (1 + 0.07 * math.sin(i * 0.8 + h.n) + 0.04 * math.sin(i * 1.9)) * (0.82 + 0.18 * math.cos(a * 1.6))
			local bord = k == K or i == 0 or i == N
			local d = f * long + ((k == 0 or bord) and 0 or (r() - 0.5) * 7)
			local z = 1 + 6 * math.sin(math.pi * math.min(f * 0.8 + 0.14, 1)) * math.cos(a * 1.3) * (0.7 + r() * 0.6)
			if bord then z = 0.5 end
			local large = (i / N - 0.5) * geo.demi * 1.1 * (1 - f)      -- départ large comme la bouche, pas en pointe
			grille[k][i] = sommet + R * (math.sin(a) * d + large) + F * (math.cos(a) * d - 3) + HAUT * z
		end
	end
	local tris = {}
	for k = 0, K - 1 do
		for i = 0, N - 1 do
			local f = (k + 0.5) / K
			local function motif()                   -- grain par triangle : terre remuée, sans bandes rayonnantes
				local grain, col = 0.78 + r() * 0.44, {}
				for j = 1, 3 do col[j] = (E.FRAIS[j] + (E.FRAIS_BORD[j] - E.FRAIS[j]) * f) * grain end
				return col
			end
			local a, b, c, d = grille[k][i], grille[k][i + 1], grille[k + 1][i], grille[k + 1][i + 1]
			facette(tris, a, c, b, motif(), a - HAUT * 20)
			facette(tris, c, d, b, motif(), c - HAUT * 20)
		end
	end
	g.eventail = maille(tris)
	g.croissance = {}
	for k = 1, E.PAS_EVENTAIL do g.croissance[k] = matriceAutour(versMonde(sommet), k / E.PAS_EVENTAIL) end
	g.posees = {}
	for lot = 1, 4 do
		local t = {}
		for i = 1, 15 do
			local grosse, miette = i <= 3, i > 11
			local a = (r() - 0.5) * math.rad(miette and 118 or 96)
			local d = miette and longueur * (0.82 + r() * 0.24) or 9 + r() * (longueur - 18)
			local taille = grosse and 3.6 + r() * 1.4 or (miette and 1.2 + r() * 1 or 2 + r() * 1.4)
			local sol = miette and 1 or 1 + 6 * math.sin(math.pi * math.min(d / longueur * 0.8 + 0.14, 1)) * math.cos(a * 1.3)
			local c = sommet + R * (math.sin(a) * d) + F * (math.cos(a) * d - 3) + HAUT * (sol + taille * (grosse and 0.45 or 0.3))
			bloc(t, c, R, F, taille, taille * (0.8 + r() * 0.4), taille * 0.75, E.MOTTE[1 + math.floor(r() * 3)], r)
		end
		g.posees[lot] = maille(t)
	end
end

-- effondré : bouchon d'éboulis dans l'arche et langue bombée vers l'avant (jamais creuse : pas de cratère)
local function coulee(tris, base, R, F, demi, haut, r)
	local N, K, grille = 10, 8, {}
	local function dessus(u, f) return math.max(haut * 0.92 * (1 - f) ^ 1.25 * (1 - 0.55 * u * u), 0.6) end
	for k = 0, K do
		grille[k] = {}
		for i = 0, N do
			local u, f = (i / N - 0.5) * 2, k / K
			local bord = i == 0 or i == N or k == K
			local large = demi * (1.02 - 0.25 * f + 0.10 * math.sin(k * 1.9 + i))
			local z = bord and 0.4 or dessus(u, f) * (0.82 + r() * 0.36)
			grille[k][i] = base + R * (u * large) + F * (-8 + f * 50 + (bord and 0 or (r() - 0.5) * 5)) + HAUT * z
		end
	end
	for k = 0, K - 1 do
		for i = 0, N - 1 do
			local a, b, c, d = grille[k][i], grille[k][i + 1], grille[k + 1][i], grille[k + 1][i + 1]
			for _, t in ipairs({ { a, c, b }, { c, d, b } }) do
				local grain = 0.8 + r() * 0.4
				facette(tris, t[1], t[2], t[3], { E.TERRE[1] * grain, E.TERRE[2] * grain, E.TERRE[3] * grain }, t[1] - HAUT * 30)
			end
		end
	end
	return function(u, y) return dessus(u, math.Clamp((y + 8) / 50, 0, 1)) end
end
local function construireEboulis(g, h, geo)
	local r = alea(7300 + h.n * 53)
	local F, R = geo.F, geo.R
	local base = Vector(geo.pied.x, geo.pied.y, 0)
	local demi, haut = geo.demi, geo.haut
	local tris = {}
	bloc(tris, base - F * 6 + HAUT * 2, R, F, demi, 13, haut * 0.66, E.TERRE, r)          -- fond de terre qui ferme la bouche
	local sol = coulee(tris, base, R, F, demi, haut, r)
	local function pierre(u, y, ax, ay, az, enfonce, col)
		local grain = 0.76 + r() * 0.46
		local c = base + R * (u * demi) + F * y + HAUT * (sol(u, y) + az * (1 - 2 * enfonce))
		bloc(tris, c, R, F, ax, ay, az, { col[1] * grain, col[2] * grain, col[3] * grain }, r)
	end
	pierre(-0.42, 4 + r() * 4, 14 + r() * 3, 10, 6.5, 0.45, E.PIERRE)                      -- 3 gros blocs anguleux, aplatis
	pierre(0.38, -1 + r() * 3, 12 + r() * 3, 9, 6, 0.40, E.PIERRE)
	pierre(0.06, 19 + r() * 5, 10 + r() * 2, 8, 4.5, 0.50, E.PIERRE)
	for i = 1, 7 do                                                                         -- moyens
		local t = 4.4 + r() * 2.4
		pierre((r() - 0.5) * 1.6, -3 + r() * 30, t * 1.15, t, t * 0.8, 0.40, i <= 5 and E.PIERRE or E.TERRE)
	end
	for i = 1, 22 do                                                                        -- graviers
		local t = 1.5 + r() * 1.7
		pierre((r() - 0.5) * 1.9, -4 + r() * 46, t, t, t * 0.8, 0.25, i % 3 == 0 and E.TERRE or E.PIERRE)
	end
	g.eboulis = maille(tris)
	g.sortie = {}
	for k = 1, E.PAS_EBOULIS do g.sortie[k] = matriceAutour(versMonde(base), 0.2 + 0.8 * k / E.PAS_EBOULIS) end
end

-- racines en arche cassées : moignon à 3 échardes, partie haute qui tombe vers l'avant sur les éboulis
local function construireCassure(g, h, geo, tubeTris)
	g.moignons, g.chutes = {}, {}
	local F, R = geo.F, geo.R
	local axeR = versMonde(geo.pied + R) - versMonde(geo.pied)
	local avant = versMonde(geo.pied + F) - versMonde(geo.pied)
	local essai = Vector(0, 0, 1)
	local test = Angle(0, 0, 0)
	test:RotateAroundAxis(axeR, 30)
	essai:Rotate(test)
	local sens = essai:Dot(avant) >= 0 and 1 or -1
	for k, rac in ipairs(geo.arches) do
		local axe = geo.courbe(rac)
		local n = math.max(3, math.floor(#axe * (0.22 + 0.08 * k)))
		local bas, hautP = {}, {}
		for i = 1, n do bas[#bas + 1] = axe[i] end
		for i = n + 2, #axe do hautP[#hautP + 1] = axe[i] end
		local tm = {}
		tubeTris(tm, bas, rac.r, E.RACINE, 0.15)
		local dir = (axe[n] - axe[n - 1]):GetNormalized()
		for e = -1, 1 do
			local pointe = axe[n] + dir * (3 + (e + 1) * 0.9) + R * (e * 1.8) + HAUT * (e * 0.8)
			tubeTris(tm, { axe[n] + R * (e * rac.r * 0.5), pointe }, rac.r * 0.45, E.CASSURE, 1)
		end
		g.moignons[k] = maille(tm)
		local th = {}
		tubeTris(th, hautP, rac.r * 0.85, E.RACINE, 0.35)
		local pivot, matrices = versMonde(axe[#axe]), {}
		for j = 0, E.PAS_CHUTE do
			local f = (j / E.PAS_CHUTE) ^ 2
			local ang = Angle(0, 0, 0)
			ang:RotateAroundAxis(axeR, sens * (74 - k * 9) * f)
			matrices[j] = matriceAutour(pivot, nil, ang, Vector(0, 0, 3 * f))
		end
		g.chutes[k] = { m = maille(th), matrices = matrices }
	end
end

-- mottes en vol : seules des valeurs numériques sont stockées ; la position se calcule depuis le temps
local function volee(geo, graine, nb, hMin, hMax, vMin, vMax, ouverture, depart)
	local r, out = alea(graine), {}
	local o = versMonde(geo.pied + geo.F * 6 + HAUT * (depart or 9))
	local f = versMonde(geo.pied + geo.F) - versMonde(geo.pied)
	local d = versMonde(geo.pied + geo.R) - versMonde(geo.pied)
	for i = 1, nb do
		local a, vh = (r() - 0.5) * ouverture, hMin + r() * (hMax - hMin)
		local col = E.MOTTE[1 + math.floor(r() * 3)]
		local s = 2.4 + r() * 2.6
		out[i] = { x = o.x, y = o.y, z = o.z, vx = (f.x * math.cos(a) + d.x * math.sin(a)) * vh,
			vy = (f.y * math.cos(a) + d.y * math.sin(a)) * vh, vz = vMin + r() * (vMax - vMin),
			s = s, c = col, tour = 4 + r() * 6, sol = o.z - (depart or 9) - 2 }
	end
	return out
end

local tmp = Vector()
local function sommetVol(x, y, z, c, l)
	tmp:SetUnpacked(x, y, z)
	mesh.Position(tmp)
	mesh.Color(c[1] * l, c[2] * l, c[3] * l, 255)
	mesh.AdvanceVertex()
end
local TETRA = { { 1, 1, 1 }, { -1, -1, 1 }, { -1, 1, -1 }, { 1, -1, -1 } }
local TETRA_F = { { 1, 2, 3, 1.15 }, { 1, 4, 2, 0.8 }, { 1, 3, 4, 1.0 }, { 2, 4, 3, 0.65 } }
local PX, PY, PZ = { 0, 0, 0, 0 }, { 0, 0, 0, 0 }, { 0, 0, 0, 0 }
local function motteVol(m, dt)
	local z = m.z + m.vz * dt - E.G * 0.5 * dt * dt
	if dt <= 0 or z < m.sol then return end
	local x, y = m.x + m.vx * dt, m.y + m.vy * dt
	local co, si = math.cos(dt * m.tour), math.sin(dt * m.tour)
	for i = 1, 4 do
		local t = TETRA[i]
		local ax, az = t[1] * co - t[3] * si, t[1] * si + t[3] * co
		PX[i], PY[i], PZ[i] = x + ax * m.s * 0.7, y + t[2] * m.s * 0.7, z + az * m.s * 0.7
	end
	mesh.Begin(MATERIAL_TRIANGLES, 4)
	for _, f in ipairs(TETRA_F) do
		for j = 1, 3 do sommetVol(PX[f[j]], PY[f[j]], PZ[f[j]], m.c, f[4]) end
	end
	mesh.End()
end
local function volees(liste, dt) for i = 1, #liste do motteVol(liste[i], dt) end end

local function temps(v, mode)                    -- secondes depuis la commande ; nil si le terrier n'est pas dans ce mode
	local t0 = v and v[mode]
	if not t0 then return nil end
	return v.fige[mode] or (CurTime() - t0)
end
local MAT_POUSSIERE = CreateMaterial("sumii_p2_poussiere_v1", "UnlitGeneric", { ["$basetexture"] = "particle/smokesprites0001",
	["$translucent"] = "1", ["$vertexcolor"] = "1", ["$vertexalpha"] = "1" })
local teinte, lieu = Color(E.POUSSIERE[1], E.POUSSIERE[2], E.POUSSIERE[3], 255), Vector()
local NB_BOUFFEES = 10
local function poussiere(g, t)                   -- 10 bouffées au pied : pic tôt, puis dissipées en 2,3 s (choix 2b)
	local k = (t - 0.3) / 2.3
	local etale = 1 - (1 - k) ^ 3
	teinte.a = 215 * math.min(k * 9, 1) * (1 - k) ^ 1.2
	local o, f, c = g.bouffee, g.devant, g.cote
	for i = 1, NB_BOUFFEES do
		local a = (i / NB_BOUFFEES - 0.5) * math.pi * 1.5
		local loin = (14 + 46 * etale) * (0.7 + 0.3 * math.sin(i * 5.3))
		local av, lat = math.cos(a) * loin, math.sin(a) * loin
		lieu:SetUnpacked(o.x + f.x * av + c.x * lat, o.y + f.y * av + c.y * lat, o.z + 6 + (i % 3) * 8 + 18 * etale)
		local taille = 26 + 52 * etale + (i % 3) * 8
		render.DrawSprite(lieu, taille, taille, teinte)
	end
end
function ET.dessinerPoussiere()
	local pose = false
	for n, g in pairs(ET.heros) do
		local t = temps(ET.etats[n], "effondre")
		if t and t > 0.3 and t < 2.6 then
			if not pose then
				render.SetMaterial(MAT_POUSSIERE)
				pose = true
			end
			poussiere(g, t)
		end
	end
end

-- ---------- props : tassement à l'affichage seulement ----------
local function chercherRoches(g)
	g.roches = {}
	-- liste complète : à 2 places, les recherches par zone du moteur ne rendaient aucun prop côté joueur (banc du 27/11)
	for _, e in ipairs(ents.FindByClass("prop_physics")) do
		local sorte = IsValid(e) and E.ROCHES[string.lower(e:GetModel() or "")]
		if sorte and e:GetPos():Distance2DSqr(g.centre) < 70 * 70 then
			g.roches[#g.roches + 1] = { e = e, sorte = sorte, m = Matrix() }
		end
	end
end
local echelle, secousse = Vector(1, 1, 1), Vector()
local function tasser(g, bras, dos, large, dx)
	if not g.roches or #g.roches == 0 then chercherRoches(g) end
	for _, ro in ipairs(g.roches) do
		if IsValid(ro.e) then
			local k = ro.sorte == "bras" and bras or dos
			echelle:SetUnpacked(large, large, k)
			secousse:SetUnpacked(dx, 0, 0)
			ro.m:Identity()
			ro.m:Translate(secousse)
			ro.m:Scale(echelle)
			ro.e:EnableMatrix("RenderMultiply", ro.m)
		end
	end
end
local function redresser(g)
	for _, ro in ipairs(g.roches or {}) do if IsValid(ro.e) then ro.e:DisableMatrix("RenderMultiply") end end
	g.roches = nil
end

-- ---------- état et temps ----------
local function part(tf)                          -- part de l'éventail déjà tombée (0 à 1)
	local s = 0
	for i = 1, 4 do s = s + etape(tf, E.PELLES[i] + E.VOL, E.CROIT) end
	return s / 4
end
function bouche_fermee(n)                  -- le pochoir n'est plus dessiné une fois les éboulis sortis
	local t = temps(ET.etats[n], "effondre")
	return t ~= nil and t >= 0.85
end

local function animerProps(g, v)
	local tf, te = temps(v, "fouille"), temps(v, "effondre")
	local p = tf and part(tf) or 0
	local bras, dos, large, dx = 1 - 0.15 * p, 1 - 0.20 * p, 1 + 0.04 * p, 0
	if te and te > 0 then
		local tas = etape(te, 0.25, 0.5)
		local rebond = te > 0.75 and 0.04 * math.sin(etape(te, 0.75, 0.3) * math.pi) or 0
		bras = bras + (0.60 - bras) * tas + rebond
		dos = dos + (0.60 - dos) * tas + rebond
		large = large + (1.10 - large) * tas
		if te < 0.25 then dx = math.sin(te * 90) end
	end
	if p > 0 or (te and te > 0) then tasser(g, bras, dos, large, dx) elseif g.roches then redresser(g) end
end

function ET.dessiner()
	for n, g in pairs(ET.heros) do
		local v = ET.etats[n]
		local te = temps(v, "effondre")
		if not te or te < 0.2 then g.arches:Draw() end
		local fouillee = temps(v, "fouille")
		SumiiHerbe.masque[n] = fouillee ~= nil and part(fouillee) >= 0.5
		if v then
			animerProps(g, v)
			local tf = temps(v, "fouille")
			if tf then
				local p = part(tf)
				local k = math.floor(p * E.PAS_EVENTAIL + 0.5)
				if k > 0 then
					cam.PushModelMatrix(g.croissance[k], true)
					g.eventail:Draw()
					cam.PopModelMatrix()
				end
				for lot = 1, 4 do
					if tf >= E.PELLES[lot] + E.VOL + E.CROIT then g.posees[lot]:Draw() end
					if tf > E.PELLES[lot] and tf < E.PELLES[lot] + 1 then volees(g.pelles[lot], tf - E.PELLES[lot]) end
				end
			end
			if te and te >= 0.2 then
				local j = math.floor(etape(te, 0.2, 0.45) * E.PAS_CHUTE + 0.5)
				for k = 1, 2 do
					g.moignons[k]:Draw()
					cam.PushModelMatrix(g.chutes[k].matrices[j], true)
					g.chutes[k].m:Draw()
					cam.PopModelMatrix()
				end
				local s = math.ceil(etape(te, 0.3, 0.6) * E.PAS_EBOULIS)
				if s > 0 then
					cam.PushModelMatrix(g.sortie[s], true)
					g.eboulis:Draw()
					cam.PopModelMatrix()
				end
				if te < E.FIN_CHUTE then volees(g.grande, te - 0.3) end
			end
		end
	end
end

function ET.detruire()
	for _, g in pairs(ET.heros) do
		redresser(g)
		local liste = { g.arches, g.eventail, g.eboulis }
		for _, m in pairs(g.posees or {}) do liste[#liste + 1] = m end
		for _, m in pairs(g.moignons or {}) do liste[#liste + 1] = m end
		for _, c in pairs(g.chutes or {}) do liste[#liste + 1] = c.m end
		for _, m in pairs(liste) do if IsValid(m) then m:Destroy() end end
	end
	ET.heros = {}
end
function ET.redresserTout() for _, g in pairs(ET.heros) do if g.roches then redresser(g) end end end

-- geo : pied, F, R, demi, haut, arches (définitions des 2 racines), courbe(rac) ; arches : sommets des racines intactes
function ET.construire(h, geo, sommets, tubeTris)
	local g = { centre = versMonde(Vector(h.c[1], h.c[2], 8)), arches = maille(sommets) }
	construireFouille(g, h, geo)
	construireEboulis(g, h, geo)
	construireCassure(g, h, geo, tubeTris)
	g.pelles = {}
	for i = 1, 4 do g.pelles[i] = volee(geo, 900 + h.n * 11 + i, 9, 90, 160, 140, 200, math.rad(90)) end
	g.grande = volee(geo, 5200 + h.n * 13, 30, 30, 120, 90, 240, math.pi * 1.4, geo.haut + 4)
	g.bouffee = versMonde(geo.pied + geo.F * 8)
	g.devant = versMonde(geo.pied + geo.F * 9) - g.bouffee
	g.cote = versMonde(geo.pied + geo.F * 8 + geo.R) - g.bouffee
	ET.heros[h.n] = g
end

-- ---------- commandes d'essai (banc) ; le message réseau du MJ viendra avec le script de la scène ----------
function ET.tempsOnde()
	local o = ET.onde
	if not o then return nil end
	return o.fige or (CurTime() - o.t0)
end
local function numeros(arg)
	if arg == "tous" then
		local t = {}
		for _, h in ipairs(HEROS) do t[#t + 1] = h.n end
		return t
	end
	local n = math.floor(tonumber(arg or "") or 0)
	for _, h in ipairs(HEROS) do if h.n == n then return { n } end end
	return {}
end
local function regler(n, mode, fige, retard)
	if mode == "intact" then
		ET.etats[n], SumiiHerbe.masque[n] = nil, nil
		if ET.heros[n] then redresser(ET.heros[n]) end
		return
	end
	local v = ET.etats[n] or { fige = {} }
	if mode == "fouille" then v.effondre = nil end
	if mode == "effondre" and v.fouille then v.fige.fouille = E.FIN_FOUILLE end   -- fouille finie avant l'effondrement
	v[mode] = CurTime() + (retard or 0)
	v.fige[mode] = fige
	ET.etats[n] = v
end
-- état venu du serveur : fouilles datées de leur heure réelle (un arrivant voit le bon instant) ; absent = intact
-- temps 7 : effondrement en chaîne daté par le serveur ; t0 nil = les terriers se relèvent
local function chaine(t0, retards)
	if not ET then return end
	if t0 == -math.huge then t0 = -600 end       -- temps sauté : tout est déjà tombé (heure fixe, loin dans le passé)
	if t0 then
		if not (ET.onde and ET.onde.t0 == t0) then ET.onde = { t0 = t0 } end
		for _, h in ipairs(HEROS) do
			local v, voulu = ET.etats[h.n], t0 + retards[h.n]
			if not (v and v.effondre and math.abs(v.effondre - voulu) < 0.05) then regler(h.n, "effondre", nil, voulu - CurTime()) end
		end
		return
	end
	if not ET.onde then return end
	ET.onde = nil
	for _, h in ipairs(HEROS) do
		local v = ET.etats[h.n]
		if v and v.effondre then
			v.effondre = nil
			if not v.fouille then regler(h.n, "intact") elseif ET.heros[h.n] then redresser(ET.heros[h.n]) end
		end
	end
end
SumiiP2 = { chaine = chaine, bouche = function(n)
	for _, b in ipairs(G.bouches or {}) do if b.n == n then return b end end
end, appliquer = function(fouilles)
	if not ET then return end
	for _, h in ipairs(HEROS) do
		local f, v = fouilles[h.n], ET.etats[h.n]
		if f then
			if not (v and v.fouille and math.abs(v.fouille - f.t0) < 0.05) then regler(h.n, "fouille", nil, f.t0 - CurTime()) end
		elseif v and v.fouille and not v.effondre then regler(h.n, "intact") end
	end
end }
-- sumii_p2_etat <n|tous> <intact|fouille|effondre> [secondes figées]
SumiiNoyau.banc("sumii_p2_etat", function(_, _, args)
	local liste, mode = numeros(args[1]), args[2]
	if #liste == 0 or (mode ~= "intact" and mode ~= "fouille" and mode ~= "effondre") then
		print("[sumii_p2] usage : sumii_p2_etat <1-12|tous> <intact|fouille|effondre> [secondes]")
		return
	end
	for _, n in ipairs(liste) do regler(n, mode, tonumber(args[3] or "")) end
	if args[1] == "tous" then
		ET.onde = mode == "effondre" and { t0 = CurTime(), fige = tonumber(args[3] or "") and 20 or nil } or nil
	end
	print("[sumii_p2] " .. mode .. " : " .. table.concat(liste, ",") .. (args[3] and (" figé à " .. args[3] .. " s") or ""))
end)
-- sumii_p2_chaine [secondes figées] : effondrement en chaîne depuis le centre (temps 7)
SumiiNoyau.banc("sumii_p2_chaine", function(_, _, args)
	local fige = tonumber(args[1] or "")
	ET.onde = { t0 = CurTime(), fige = fige }
	local ordre = {}
	for _, h in ipairs(HEROS) do ordre[#ordre + 1] = h end
	table.sort(ordre, function(a, b) return a.c[1] ^ 2 + a.c[2] ^ 2 < b.c[1] ^ 2 + b.c[2] ^ 2 end)
	for rang, h in ipairs(ordre) do
		local depart = 2 + (rang - 1) * 0.55 + (h.n % 3 - 1) * 0.15
		regler(h.n, "effondre", fige and (fige - depart), depart)
	end
	print("[sumii_p2] effondrement en chaîne : " .. #ordre .. " terriers")
end)


-- ---------- ~300 petits terriers de décor (script seul, 0 posé). Placement : decor.py ; injecté par build.py. ----------
-- Un croissant de terre ouvert, un surplomb, une paroi en retrait et un sol qui s'assombrit : ni aplat noir, ni racine.
-- Maillages par bande de distance au centre ; au temps 7 chaque bande s'aplatit au passage de l'onde.
local D = {
	SEG = 10, ARC = math.rad(135), BANDES = 8, R_MIN = 150, R_MAX = 1500, PAS = 8, APLATI = 0.16, DUREE = 0.5,
	ONDE_T0 = 2.0, ONDE_R0 = 210, ONDE_DUREE = 6.05, ONDE_PORTEE = 670, LOT = 27000,
	TERRE = { 110, 76, 48 }, LEVRE = { 74, 50, 31 }, PAROI = { 36, 23, 14 }, FOND = { 28, 18, 11 }, SEUIL = { 92, 63, 41 },
}
local DECOR = {
	{1115.9, -50.0, 34.0, 14.8, 3.848},
	{1143.6, -200.4, 38.3, 17.6, 1.903},
	{990.4, 81.3, 21.4, 10.0, -3.176},
	{1202.8, 108.0, 26.9, 14.3, -1.848},
	{1022.6, 0.5, 34.8, 16.4, -4.289},
	{572.1, -514.0, 36.0, 16.7, 2.366},
	{553.2, -590.7, 29.7, 15.3, 3.384},
	{571.5, -739.9, 38.9, 15.8, 3.077},
	{669.6, -589.8, 33.2, 13.3, 1.376},
	{-670.6, -925.1, 30.8, 13.6, 2.209},
	{-676.2, -858.3, 25.3, 12.4, -0.303},
	{-736.1, -661.0, 48.7, 18.0, 1.072},
	{-488.5, -846.1, 24.0, 10.2, 0.649},
	{-572.4, -904.1, 31.3, 15.8, 0.267},
	{-1313.0, -197.7, 26.4, 12.0, -0.465},
	{-1384.8, -206.0, 36.4, 18.0, 0.784},
	{-1256.4, -288.6, 30.5, 16.3, 1.056},
	{-1376.3, -318.9, 26.9, 12.6, 0.592},
	{227.2, 1353.9, 31.1, 15.8, -0.352},
	{290.1, 1380.2, 25.1, 10.5, -2.778},
	{254.9, 1269.5, 43.1, 18.0, -2.060},
	{250.9, 1471.6, 28.2, 12.5, -3.058},
	{306.7, 1122.8, 25.6, 13.5, -1.090},
	{459.8, 1244.2, 33.9, 16.6, -0.914},
	{408.6, 1424.4, 38.0, 18.0, -1.451},
	{186.7, 1197.1, 31.5, 15.2, -1.542},
	{659.1, -433.7, 38.8, 17.7, 3.150},
	{809.2, -411.3, 28.8, 13.6, 1.351},
	{739.8, -358.5, 20.2, 10.0, 2.100},
	{704.1, -276.1, 35.0, 16.3, 3.391},
	{791.1, -273.0, 20.9, 10.8, 3.915},
	{644.0, -231.6, 44.1, 18.0, 3.390},
	{874.5, -510.8, 30.0, 14.2, 1.352},
	{855.9, -160.9, 20.7, 10.0, 1.793},
	{1050.4, -326.1, 20.4, 10.0, 2.055},
	{916.0, -324.3, 31.7, 15.2, 1.887},
	{-570.3, 94.2, 37.4, 18.0, -1.269},
	{-524.2, 144.2, 21.0, 10.0, -0.955},
	{-561.3, 217.9, 27.8, 13.1, 0.069},
	{-569.8, 308.0, 40.6, 18.0, -1.855},
	{-510.8, 291.3, 28.7, 11.8, 0.302},
	{102.7, -577.0, 38.1, 18.0, 1.025},
	{167.0, -562.3, 37.2, 18.0, 1.452},
	{245.7, -647.6, 37.3, 18.0, 1.348},
	{181.5, -626.1, 48.9, 18.0, 1.003},
	{-39.9, -530.1, 42.0, 18.0, 1.811},
	{-30.4, 333.7, 25.2, 10.7, -0.849},
	{-42.5, 237.1, 40.2, 17.4, -2.297},
	{-3.7, 396.2, 26.4, 14.2, -1.031},
	{-71.2, 183.3, 39.2, 18.0, -1.493},
	{67.4, 377.2, 20.8, 10.0, -2.153},
	{-106.9, 352.9, 37.5, 15.3, -0.315},
	{-820.9, 990.9, 27.5, 13.8, -1.663},
	{-844.4, 842.4, 32.0, 15.0, -1.715},
	{-964.8, 967.6, 34.8, 14.3, -1.137},
	{-910.7, 892.4, 35.0, 16.9, -1.987},
	{-926.0, 759.4, 20.1, 10.0, -1.080},
	{-897.7, 1061.2, 45.5, 18.0, -0.974},
	{-745.4, 903.2, 33.7, 14.1, -1.779},
	{-896.4, 981.4, 30.3, 13.3, -1.008},
	{-993.9, 860.6, 40.1, 18.0, -0.947},
	{-821.3, 1088.6, 24.8, 11.4, -1.189},
	{-580.8, -564.7, 27.2, 12.4, -0.104},
	{-455.0, -752.2, 22.9, 10.5, 0.890},
	{-458.7, -664.0, 40.4, 18.0, 1.259},
	{-531.2, -642.3, 31.7, 14.7, 0.684},
	{-610.4, -617.3, 43.2, 18.0, -0.602},
	{1430.0, 248.5, 35.8, 18.0, -3.313},
	{1428.1, 183.5, 27.7, 13.9, -3.802},
	{1355.0, 220.1, 26.6, 14.2, -3.380},
	{1356.9, 323.0, 32.1, 15.4, -2.436},
	{1284.7, 258.1, 28.1, 13.9, -1.755},
	{1422.6, 356.8, 32.7, 15.1, -2.548},
	{1488.4, 139.1, 31.5, 15.5, -2.548},
	{77.9, -932.0, 38.7, 16.6, 2.695},
	{-101.2, -826.6, 39.7, 15.9, 2.663},
	{-83.4, -954.5, 28.7, 11.8, 0.224},
	{-36.8, -909.5, 27.5, 13.1, 1.856},
	{-143.0, -972.1, 21.6, 11.7, 0.829},
	{1.9, -1020.0, 30.6, 14.7, 1.503},
	{-146.3, 412.7, 20.3, 10.0, -1.361},
	{-324.5, 514.4, 48.2, 18.0, -2.151},
	{462.1, -37.4, 27.6, 11.6, 4.223},
	{485.2, -171.3, 46.2, 18.0, 4.116},
	{444.7, -121.4, 25.5, 12.6, 2.196},
	{340.8, 2.2, 29.0, 11.7, -3.814},
	{399.4, -30.6, 25.7, 13.6, 2.444},
	{420.6, 1081.4, 24.6, 13.3, -2.627},
	{373.7, 1163.8, 24.3, 11.6, -3.074},
	{281.5, 885.5, 29.7, 12.0, -1.796},
	{528.4, 1177.3, 33.8, 15.5, -1.683},
	{519.0, 1276.0, 35.1, 16.5, -2.132},
	{481.7, 1054.4, 33.4, 17.3, -1.797},
	{472.1, 1128.2, 39.7, 17.4, -1.980},
	{539.3, 1082.2, 44.0, 18.0, -1.289},
	{429.4, 1187.2, 22.0, 10.3, -0.631},
	{381.0, 1229.6, 22.2, 10.6, -2.706},
	{634.4, 1210.2, 25.1, 10.8, -1.997},
	{359.5, 1009.2, 33.3, 17.8, -3.225},
	{135.5, -673.2, 26.5, 11.1, 2.545},
	{-0.3, -799.0, 25.9, 11.8, 1.313},
	{276.9, -814.6, 32.3, 13.5, 2.223},
	{226.6, -744.5, 37.6, 18.0, 1.685},
	{129.2, -741.4, 24.2, 10.0, 2.085},
	{27.5, -693.0, 37.3, 18.0, 0.475},
	{-388.3, 479.7, 48.7, 18.0, -2.210},
	{-468.4, 473.1, 22.1, 11.5, -1.723},
	{-495.7, 382.7, 20.7, 10.1, -1.867},
	{-438.3, 564.9, 21.7, 11.2, -0.819},
	{-369.0, 608.7, 31.3, 12.9, -1.615},
	{-505.6, 538.3, 21.7, 10.0, -2.014},
	{-495.3, 648.3, 35.0, 16.1, -1.144},
	{-791.8, 734.1, 21.7, 10.9, 0.102},
	{-844.5, 768.1, 26.3, 13.1, -0.822},
	{-743.7, 800.9, 24.2, 10.0, -0.220},
	{-911.6, 650.2, 29.4, 11.8, -0.609},
	{-666.7, 716.2, 33.4, 17.3, 0.048},
	{609.5, 47.8, 21.0, 10.0, -1.996},
	{413.2, 111.5, 23.0, 11.0, -4.192},
	{754.4, 26.7, 33.4, 17.0, -2.806},
	{577.0, 190.7, 29.2, 13.3, -1.439},
	{634.6, 122.0, 36.8, 17.8, -3.564},
	{738.1, 135.0, 29.7, 15.1, -2.157},
	{653.4, 193.6, 24.7, 11.5, -2.735},
	{440.3, 247.8, 29.5, 14.0, -3.008},
	{493.9, 192.8, 26.8, 11.9, -1.961},
	{450.5, 64.1, 26.3, 13.4, -2.596},
	{-802.7, -631.9, 29.0, 15.3, 0.931},
	{-658.9, -571.4, 44.4, 18.0, 0.760},
	{-822.4, -526.3, 27.7, 12.8, 0.192},
	{-675.8, -639.6, 31.1, 14.6, -0.440},
	{755.8, -187.7, 30.5, 14.9, 2.942},
	{922.3, -219.1, 42.2, 17.6, 3.897},
	{603.1, -277.0, 29.9, 13.9, 3.671},
	{540.4, -260.2, 21.2, 11.0, 3.589},
	{763.2, -127.1, 33.2, 14.7, 2.575},
	{-411.3, -1058.1, 34.3, 14.7, 0.832},
	{-620.5, -959.6, 21.0, 10.5, 0.710},
	{-514.4, -1051.1, 46.7, 18.0, 2.148},
	{-345.6, -1049.9, 28.5, 11.6, 2.567},
	{-643.8, -1031.0, 24.3, 10.7, 0.155},
	{-589.4, -1117.7, 39.4, 16.0, 1.425},
	{-359.9, -985.4, 21.7, 11.7, 1.011},
	{675.9, -491.6, 35.2, 16.4, 3.681},
	{594.1, -432.8, 25.8, 11.7, 3.115},
	{518.9, -358.0, 27.8, 11.8, 1.329},
	{631.4, -361.5, 27.9, 12.6, 2.902},
	{630.3, -540.9, 23.6, 11.3, 1.199},
	{733.1, -430.3, 27.4, 12.3, 3.206},
	{366.7, 57.3, 36.2, 18.0, -4.336},
	{479.0, -1093.8, 35.0, 18.0, 1.243},
	{506.5, -1217.2, 36.5, 17.0, 3.321},
	{427.3, -1176.3, 34.0, 15.4, 2.904},
	{478.8, -987.9, 34.9, 15.3, 1.987},
	{397.0, -1247.5, 22.2, 11.8, 2.037},
	{457.2, -1252.7, 25.8, 12.6, 2.119},
	{651.4, 604.2, 31.8, 16.1, -1.030},
	{832.1, 643.8, 24.5, 10.5, -1.229},
	{743.3, 640.8, 26.2, 12.0, -1.812},
	{779.5, 694.3, 28.9, 15.3, -1.034},
	{739.6, 841.2, 33.2, 15.5, -1.368},
	{726.7, 741.7, 33.0, 17.0, -2.283},
	{784.2, 587.9, 36.6, 15.8, -2.678},
	{674.8, 664.7, 23.8, 10.1, -2.928},
	{890.7, 679.3, 35.8, 16.0, -3.523},
	{587.7, 575.2, 49.9, 18.0, -1.715},
	{-100.9, -379.0, 24.4, 11.1, 0.865},
	{-185.3, -360.3, 41.0, 18.0, 0.358},
	{762.3, 1097.5, 39.7, 17.4, -1.810},
	{587.3, 958.0, 22.4, 11.0, -1.405},
	{708.9, 979.2, 38.7, 15.6, -3.005},
	{804.4, 1029.4, 21.0, 10.0, -1.461},
	{634.4, 1025.5, 44.5, 18.0, -1.771},
	{-322.1, 1235.4, 47.4, 18.0, -1.175},
	{-236.7, 1221.8, 23.6, 12.0, -2.659},
	{-235.2, 1318.3, 27.9, 11.5, -2.003},
	{-289.9, 1419.3, 21.3, 10.0, -2.292},
	{-372.4, 1140.6, 23.0, 10.0, -2.101},
	{-118.7, 121.8, 21.4, 11.5, -0.866},
	{-1041.0, 392.3, 39.7, 18.0, 0.435},
	{331.1, -1331.4, 39.0, 15.8, 2.272},
	{-1169.4, 114.3, 36.6, 18.0, -0.607},
	{-1292.4, 748.9, 22.6, 11.0, -1.379},
	{-296.0, -932.2, 33.4, 17.5, 0.779},
	{-124.9, -445.2, 37.1, 16.8, 1.904},
	{994.7, 832.0, 33.3, 15.2, -2.534},
	{-490.5, 984.3, 27.5, 13.4, -2.039},
	{498.0, 305.3, 31.0, 15.2, -3.539},
	{697.3, 1235.3, 31.8, 14.0, -2.504},
	{388.9, -814.8, 20.4, 10.6, 0.835},
	{1221.5, -8.1, 31.2, 13.7, 4.013},
	{-672.7, -213.7, 29.2, 12.4, 0.674},
	{212.4, 1002.3, 39.4, 18.0, -1.472},
	{-164.8, -1333.1, 21.9, 10.0, 1.061},
	{248.3, 789.5, 35.7, 18.0, -1.208},
	{122.2, -1139.8, 49.8, 18.0, 3.047},
	{446.3, 445.6, 35.4, 18.0, -2.007},
	{604.2, -1334.6, 26.0, 14.0, 2.494},
	{-519.9, 794.3, 38.3, 18.0, -0.490},
	{-1212.4, 371.3, 22.9, 10.4, 1.048},
	{-576.5, -483.5, 25.9, 12.4, 0.250},
	{1042.6, 245.3, 27.6, 13.6, -2.705},
	{-309.6, -461.1, 37.4, 18.0, 0.753},
	{1316.8, 444.2, 23.7, 10.7, -2.323},
	{-1050.3, -565.3, 33.6, 14.2, 0.299},
	{-675.2, 51.2, 33.9, 16.8, -0.602},
	{-905.0, -415.4, 24.9, 10.3, -0.455},
	{-188.2, -441.7, 33.8, 16.5, 2.179},
	{1299.9, 195.4, 23.9, 10.0, -2.585},
	{18.8, 282.6, 48.8, 18.0, -2.130},
	{-1261.9, 685.9, 43.2, 18.0, 0.621},
	{528.7, 753.6, 30.5, 12.7, -2.470},
	{-76.5, -1236.9, 43.4, 18.0, 2.415},
	{-625.2, 364.3, 25.1, 10.3, 0.430},
	{636.4, 825.5, 24.0, 12.7, -2.677},
	{-1361.0, 4.0, 21.0, 10.0, -0.928},
	{319.1, 782.8, 23.6, 11.9, -2.510},
	{1102.1, -374.7, 41.4, 17.4, 4.043},
	{-171.0, 1472.8, 27.5, 14.6, -1.410},
	{235.7, 937.9, 29.2, 14.6, -1.361},
	{-727.7, -1060.0, 24.4, 11.4, 1.292},
	{579.9, 506.8, 28.6, 15.0, -3.266},
	{536.8, -947.3, 32.2, 13.3, 2.143},
	{-459.8, -342.1, 42.3, 18.0, 1.570},
	{-678.2, -1233.3, 28.4, 14.7, 1.491},
	{-1208.0, -78.4, 31.7, 15.1, -1.143},
	{-606.8, -338.6, 34.5, 17.4, 1.125},
	{904.5, -457.4, 24.7, 12.7, 4.012},
	{-300.8, -396.8, 28.7, 11.6, 2.204},
	{-1243.3, 478.8, 28.0, 11.8, 0.627},
	{58.1, 814.5, 26.1, 12.1, -2.009},
	{699.5, -894.2, 29.8, 14.1, 1.059},
	{-522.9, -1356.7, 30.7, 12.4, 0.580},
	{-117.3, 931.0, 35.4, 16.9, -2.062},
	{1124.7, 561.3, 34.5, 17.8, -3.398},
	{-967.3, -433.7, 28.9, 15.3, 0.782},
	{-1197.7, -683.0, 22.7, 11.0, 0.986},
	{-819.5, -270.9, 21.3, 10.9, 0.506},
	{-120.3, -1175.7, 36.4, 17.8, 1.650},
	{-11.3, 150.1, 39.4, 17.6, -0.605},
	{976.9, -124.9, 31.6, 14.7, 1.912},
	{50.0, 466.5, 22.3, 11.4, -2.618},
	{-747.5, -249.0, 41.9, 17.3, 1.652},
	{236.4, -1081.0, 28.2, 12.0, 0.753},
	{738.7, -1218.9, 29.7, 12.5, 0.760},
	{-983.0, -736.5, 22.9, 10.1, 0.655},
	{-305.9, 643.7, 39.5, 17.1, -0.775},
	{122.5, 1024.0, 29.4, 12.7, -1.598},
	{1194.6, 628.9, 23.2, 12.1, -1.903},
	{-758.2, -348.3, 30.4, 12.8, 0.380},
	{304.4, -1112.2, 40.0, 18.0, 2.661},
	{-488.4, -409.6, 48.7, 18.0, 1.245},
	{1116.2, -959.3, 22.7, 10.0, 2.712},
	{1233.2, -323.1, 24.6, 12.3, 3.505},
	{-480.5, -587.8, 31.9, 12.8, 1.380},
	{-1076.1, -60.6, 29.5, 13.4, -0.236},
	{407.4, 387.4, 22.8, 11.0, -3.686},
	{-647.4, 597.3, 46.5, 18.0, -1.099},
	{-625.5, -276.6, 35.3, 17.9, 1.202},
	{667.4, -748.2, 41.6, 18.0, 2.113},
	{1227.2, -489.6, 22.9, 10.3, 3.045},
	{75.1, -802.1, 33.9, 16.7, 3.041},
	{1052.0, 396.8, 25.8, 13.6, -2.497},
	{79.1, 603.5, 27.3, 14.5, -0.748},
	{-233.4, -1424.0, 29.2, 14.8, 1.887},
	{-308.1, 874.7, 32.6, 16.2, -0.050},
	{1057.0, -659.8, 47.1, 18.0, 2.624},
	{-250.2, -1018.8, 31.8, 16.6, 0.687},
	{-895.9, -1033.5, 32.4, 13.3, -0.440},
	{-734.3, -432.3, 35.6, 17.3, 1.198},
	{-116.6, 1165.0, 21.4, 10.0, -2.771},
	{-1486.6, 94.0, 31.2, 15.4, 0.930},
	{-671.9, 1104.2, 20.4, 10.8, 0.287},
	{189.2, 1079.1, 31.4, 13.2, -2.820},
	{1397.4, -218.2, 29.1, 13.0, 3.061},
	{-739.5, -510.5, 33.1, 13.8, -0.632},
	{1190.1, -256.2, 22.4, 11.2, 3.001},
	{243.7, 658.0, 28.2, 11.6, -2.058},
	{1000.0, -202.8, 46.9, 18.0, 2.792},
	{-1112.5, -745.3, 33.7, 17.8, 1.759},
	{437.7, 697.4, 34.0, 16.6, -2.072},
	{151.9, 1132.0, 32.0, 14.5, -2.049},
	{-165.6, -1451.4, 20.9, 10.0, 1.091},
	{-913.2, 243.6, 20.2, 10.0, 0.736},
	{903.2, -884.0, 22.2, 11.4, 2.812},
	{-684.8, -301.3, 42.5, 18.0, 0.409},
	{852.0, -642.1, 37.2, 18.0, 2.576},
	{1232.3, -633.4, 20.7, 10.9, 3.159},
	{592.4, -637.0, 32.0, 16.5, 2.440},
	{1097.6, -456.0, 21.0, 10.0, 2.266},
	{357.8, 569.9, 21.9, 10.0, -2.324},
	{326.2, 936.4, 33.1, 17.0, -2.753},
	{1230.7, 449.7, 34.9, 17.0, -2.351},
	{-591.6, 530.6, 25.8, 12.2, -0.141},
	{-224.2, 1090.6, 23.8, 11.4, -0.954},
	{-303.8, -1399.4, 26.8, 12.9, -0.009},
	{1087.1, -586.2, 27.8, 13.8, 2.258},
	{-676.6, 244.5, 42.6, 18.0, 0.689},
	{150.8, -1027.1, 21.4, 10.0, 3.060},
	{-137.2, 1349.9, 37.1, 17.0, -2.184}
}
-- profil du dos, de l'extérieur à la lèvre : { rayon (x demi-largeur), hauteur (x h), couleur }
D.PROFIL = { { 1.00, 0.00 }, { 0.84, 0.72 }, { 0.62, 1.00 }, { 0.44, 0.90 } }
D.TERRES = { { 110, 76, 48 }, { 124, 80, 46 }, { 96, 70, 48 } }
D.DEBLAIS, D.DEBLAIS_BORD = { 86, 58, 36 }, { 102, 74, 46 }
D.NICHE, D.NOIR = { 50, 33, 20 }, { 9, 6, 4 }
D.TOMBE, D.TOMBE_BORD = { 104, 100, 44 }, { 108, 138, 40 }   -- terrier aplati : une terre qui retourne à l'herbe
D.BOUFFEE, D.POUSSIERE = 0.9, { 186, 154, 108 }
DEC = { bandes = {}, aplats = {} }

local function eclaire(col, a, b, c)             -- les deux premières bandes du profil prennent la lumière rasante
	local n = (b - a):Cross(c - a)
	n:Normalize()
	if n.z < 0 then n = -n end
	local l = 0.68 + 0.5 * math.max(n:Dot(SOLEIL), 0) + 0.22 * n.z
	return { col[1] * l, col[2] * l, col[3] * l }
end
local function triangle(out, a, ca, b, cb, c, cc)
	out[#out + 1] = { a, ca }
	out[#out + 1] = { b, cb }
	out[#out + 1] = { c, cc }
end

local function dos(out, x, y, demi, h, fx, fy, terre, graine)
	local anneaux = {}
	for i = 0, D.SEG do
		local th = (i / D.SEG - 0.5) * 2 * D.ARC
		local monte = 0.22 + 0.78 * math.max(math.cos(th * 2 / 3), 0) ^ 1.3
		local bosse = 1 + 0.11 * math.sin(i * 2.7 + graine) + 0.06 * math.sin(i * 5.3 + graine * 1.7)
		local dx = -fx * math.cos(th) - fy * math.sin(th)    -- th = 0 : le dos, à l'opposé de l'ouverture
		local dy = -fy * math.cos(th) + fx * math.sin(th)
		local an = {}
		for j, p in ipairs(D.PROFIL) do
			local r = p[1] * demi * bosse
			an[j] = Vector(x + dx * r, y + dy * r, 0.4 + p[2] * h * monte * bosse)
		end
		anneaux[i] = an
	end
	for i = 0, D.SEG - 1 do
		local A, B = anneaux[i], anneaux[i + 1]
		for j = 1, #D.PROFIL - 1 do
			local k = eclaire(terre, A[j], B[j], A[j + 1])
			triangle(out, A[j], k, B[j], k, B[j + 1], k)
			triangle(out, A[j], k, B[j + 1], k, A[j + 1], k)
		end
	end
	for _, an in ipairs({ anneaux[0], anneaux[D.SEG] }) do     -- bouts du croissant fermés
		for j = 2, #D.PROFIL - 1 do
			local k = eclaire(terre, an[1], an[j], an[j + 1])
			triangle(out, an[1], k, an[j], k, an[j + 1], k)
		end
	end
	return anneaux
end

-- bouche : de la lèvre vers un point reculé presque noir (un creux qui s'assombrit, pas un aplat) ; devant, des déblais
-- bas et mats d'un seul tenant avec le sol de la bouche (v14 : deux pointes qui se touchaient laissaient voir l'herbe)
local function bouche(out, anneaux, x, y, demi, h, fx, fy, graine)
	local fond = Vector(x - fx * demi * 0.30, y - fy * demi * 0.30, 0.4 + h * 0.28)
	local levre = #D.PROFIL
	for i = 0, D.SEG - 1 do
		triangle(out, anneaux[i][levre], D.NICHE, anneaux[i + 1][levre], D.NICHE, fond, D.NOIR)
	end
	local dedans, dehors = {}, {}
	for i = 0, 6 do
		local a = (i / 6 - 0.5) * math.rad(104)
		local dx, dy = fx * math.cos(a) - fy * math.sin(a), fy * math.cos(a) + fx * math.sin(a)
		local long = demi * (1.35 + 0.28 * math.sin(i * 2.9 + graine))
		dedans[i] = Vector(x + dx * demi * 0.50, y + dy * demi * 0.50, 1.8)
		dehors[i] = Vector(x + dx * long, y + dy * long, 0.7)
	end
	dedans[0], dedans[6] = anneaux[D.SEG][levre], anneaux[0][levre]
	if (dedans[0] - dehors[0]):Length2DSqr() > (dedans[0] - dehors[6]):Length2DSqr() then
		dedans[0], dedans[6] = dedans[6], dedans[0]
	end
	for i = 0, 5 do
		triangle(out, dedans[i], D.DEBLAIS, dedans[i + 1], D.DEBLAIS, fond, D.NOIR)          -- sol de la bouche
		triangle(out, dedans[i], D.DEBLAIS, dehors[i], D.DEBLAIS_BORD, dehors[i + 1], D.DEBLAIS_BORD)
		triangle(out, dedans[i], D.DEBLAIS, dehors[i + 1], D.DEBLAIS_BORD, dedans[i + 1], D.DEBLAIS)
	end
end

local function unTerrier(out, t, graine)
	local x, y, w, h, angle = t[1], t[2], t[3], t[4], t[5]
	local fx, fy, demi = math.cos(angle), math.sin(angle), w / 2
	local base, grain = D.TERRES[1 + graine % 3], 0.86 + 0.28 * math.abs(math.sin(graine * 12.9898))
	local anneaux = dos(out, x, y, demi, h, fx, fy, { base[1] * grain, base[2] * grain, base[3] * grain }, graine)
	bouche(out, anneaux, x, y, demi, h, fx, fy, graine)
end

local function tombe(out, t, graine)
	local x, y, demi = t[1], t[2], t[3] / 2
	local centre, prec, premier = Vector(x, y, 2.2), nil, nil
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2
		local r = demi * (0.85 + 0.3 * math.sin(i * 2.3 + graine))
		local q = Vector(x + math.cos(a) * r, y + math.sin(a) * r, 0.8)
		if prec then triangle(out, centre, D.TOMBE, prec, D.TOMBE_BORD, q, D.TOMBE_BORD) end
		prec, premier = q, premier or q
	end
	triangle(out, centre, D.TOMBE, prec, D.TOMBE_BORD, premier, D.TOMBE_BORD)
end

local function lotsDe(tris)
	local out, i = {}, 1
	while i <= #tris do
		local n = math.min(D.LOT, #tris - i + 1)
		local m = Mesh()
		mesh.Begin(m, MATERIAL_TRIANGLES, n / 3)
		for j = i, i + n - 1 do
			local v = tris[j]
			local c = v[2]
			mesh.Position(versMonde(v[1]))
			mesh.Color(math.min(c[1], 255), math.min(c[2], 255), math.min(c[3], 255), 255)
			mesh.AdvanceVertex()
		end
		mesh.End()
		out[#out + 1] = m
		i = i + n
	end
	return out
end

function DEC.detruire()
	for _, b in ipairs(DEC.bandes) do
		for _, liste in ipairs({ b.lots, b.tombes }) do for _, m in ipairs(liste) do if IsValid(m) then m:Destroy() end end end
	end
	DEC.bandes = {}
end

function DEC.construire()
	DEC.detruire()
	local t0 = SysTime()
	local parBande, aPlat, lieux, largeur = {}, {}, {}, (D.R_MAX - D.R_MIN) / D.BANDES
	for k = 1, D.BANDES do parBande[k], aPlat[k], lieux[k] = {}, {}, {} end
	for i, t in ipairs(DECOR) do
		local d = math.sqrt(t[1] * t[1] + t[2] * t[2])
		local k = math.Clamp(1 + math.floor((d - D.R_MIN) / largeur), 1, D.BANDES)
		unTerrier(parBande[k], t, i)
		tombe(aPlat[k], t, i)
		lieux[k][#lieux[k] + 1] = { p = versMonde(Vector(t[1], t[2], 8)), w = t[3] }
	end
	local sommets = 0
	for k = 1, D.BANDES do
		local milieu = D.R_MIN + (k - 0.5) * largeur
		DEC.bandes[k] = { lots = lotsDe(parBande[k]), tombes = lotsDe(aPlat[k]), lieux = lieux[k],
			passage = D.ONDE_T0 + D.ONDE_DUREE * math.max((milieu - D.ONDE_R0) / D.ONDE_PORTEE, 0) }
		sommets = sommets + #parBande[k]
	end
	local sol = versMonde(Vector(0, 0, 0))       -- aplatissement vers le sol (repère posé à plat)
	for k = 0, D.PAS do
		local m = Matrix()
		m:Translate(sol)
		m:Scale(Vector(1, 1, 1 - (1 - D.APLATI) * k / D.PAS))
		m:Translate(-sol)
		DEC.aplats[k] = m
	end
	print(string.format("[sumii_p2] décor : %d terriers, %d triangles, construit en %.0f ms", #DECOR, sommets / 3, (SysTime() - t0) * 1000))
end

-- tOnde : secondes depuis le début de l'effondrement en chaîne (nil : tout intact)
local function avancee(b, tOnde) return tOnde and math.Clamp((tOnde - b.passage) / D.DUREE, 0, 1) or 0 end
function DEC.dessiner(tOnde)
	render.CullMode(MATERIAL_CULLMODE_NONE)
	for _, b in ipairs(DEC.bandes) do
		local f = avancee(b, tOnde)
		local tombee = f >= 0.6                      -- le relief s'écrase, puis il ne reste qu'une terre dans l'herbe
		local k = tombee and 0 or math.floor(f / 0.6 * D.PAS + 0.5)
		if k > 0 then cam.PushModelMatrix(DEC.aplats[k], true) end
		for _, m in ipairs(tombee and b.tombes or b.lots) do m:Draw() end
		if k > 0 then cam.PopModelMatrix() end
	end
	render.CullMode(MATERIAL_CULLMODE_CCW)
end

-- front de l'onde : une bouffée de terre par petit terrier au passage de sa bande (aucune allocation par image)
local MAT_BOUFFEE = CreateMaterial("sumii_p2_poussiere_v1", "UnlitGeneric", { ["$basetexture"] = "particle/smokesprites0001",
	["$translucent"] = "1", ["$vertexcolor"] = "1", ["$vertexalpha"] = "1" })
local teinteBouffee, lieuBouffee = Color(D.POUSSIERE[1], D.POUSSIERE[2], D.POUSSIERE[3], 255), Vector()
function DEC.dessinerPoussiere(tOnde)
	if not tOnde then return end
	local pose = false
	for _, b in ipairs(DEC.bandes) do
		local k = (tOnde - b.passage) / D.BOUFFEE
		if k > 0 and k < 1 then
			if not pose then
				render.SetMaterial(MAT_BOUFFEE)
				pose = true
			end
			teinteBouffee.a = 255 * math.min(k * 8, 1) * (1 - k * k)
			for i = 1, #b.lieux do
				local l = b.lieux[i]
				lieuBouffee:SetUnpacked(l.p.x, l.p.y, l.p.z + 22 * k)
				local taille = l.w * (1.8 + 2.4 * k)
				render.DrawSprite(lieuBouffee, taille, taille, teinteBouffee)
			end
		end
	end
end


local function construire()
	detruire()
	local tris = {}                                      -- { pos, r, g, b }
	local U = Vector(0, 0, 1)
	for _, h in ipairs(HEROS) do
		local F, R = Vector(h.F[1], h.F[2], 0), Vector(h.R[1], h.R[2], 0)
		-- v4 : tunnel en trompe-l'œil au pochoir.
		-- La bouche (arche debout + demi-ellipse couchée sur le sol) découpe l'image ; dans la découpe, un boyau de terre
		-- s'enfonce vers l'arrière et sous le sol en s'assombrissant. Aucun aplat noir, parallaxe réelle.
		local c = Vector(h.c[1], h.c[2], 1.2)
		local haut = h.c[3] + h.h * P.BOUCHE_HAUT
		local demi = h.w * P.BOUCHE_LARG / 2
		local pied = c + F * P.BOUCHE_PIED
		local function contour(t, k, avant)          -- t de 0 à pi : arche ; de pi à 2 pi : bord au sol, vers l'avant
			local bosse = 1 + 0.09 * math.sin(3 * t + h.n * 1.7) + 0.06 * math.sin(7 * t + h.n * 2.9)
			local u, s = math.cos(t) * k * bosse, math.sin(t)
			local v, b = 0, 0
			if s > 0 then
				v = s ^ 0.8 * k * bosse
				b = -(P.BOUCHE_PIED + P.BOUCHE_RECUL) * math.min(v, 1.3)
			else
				b = -s * P.SEUIL * k * bosse
			end
			return pied + R * (u * demi) + U * (v * haut) + F * (b + (avant or 0))
		end
		local function terre(clair, grain)           -- couleur de terre : clair de 0 (fond) à 1 (entrée)
			local g = clair * (1 + grain)
			return { P.FOND[1] + (P.TERRE[1] - P.FOND[1]) * g, P.FOND[2] + (P.TERRE[2] - P.FOND[2]) * g,
				P.FOND[3] + (P.TERRE[3] - P.FOND[3]) * g, 255 }
		end
		local mt, boyau, bord = {}, {}, {}
		local function pousser(t, p, col) t[#t + 1] = { p, col } end
		for i = 0, P.SEG_TROU - 1 do bord[i] = contour(i / P.SEG_TROU * math.pi * 2, 1) end
		for i = 0, P.SEG_TROU - 1 do                 -- découpe : éventail depuis le milieu du seuil, dans les deux sens
			local q1, q2 = bord[i], bord[(i + 1) % P.SEG_TROU]
			pousser(mt, pied, P.FOND); pousser(mt, q1, P.FOND); pousser(mt, q2, P.FOND)
			pousser(mt, pied, P.FOND); pousser(mt, q2, P.FOND); pousser(mt, q1, P.FOND)
		end
		local cote = (h.n % 2 == 0) and 1 or -1      -- le boyau tourne à gauche ou à droite
		local function section(j)
			local an = {}
			local tau = j / P.BOYAU_N
			local axe = pied - F * (P.BOYAU_LONG * tau) - U * (P.BOYAU_PROF * tau * tau) + R * (cote * P.BOYAU_VIRAGE * tau * tau)
			local serre = 1 - 0.55 * tau
			for i = 0, P.SEG_TROU - 1 do
				local d = bord[i] - pied
				local rugueux = j == 0 and 1 or 1 + 0.16 * math.sin(i * 2.3 + j * 3.7 + h.n) * math.sin(i * 0.9 - j * 1.9)
				local plafond = math.Clamp(d.z / haut, 0, 1)
				local clair = math.max(1 - tau, 0) ^ 1.7 * (1 - 0.45 * plafond)
				local grain = 0.30 * math.sin(i * 7.9 + j * 4.3 + h.n * 2.2) * math.sin(i * 3.1 + j * 8.7)
				if j % 3 == 2 then clair = clair * 0.78 end   -- strates : repères de profondeur
				an[i] = { axe + d * (serre * rugueux), terre(clair, grain) }
			end
			return an
		end
		local precSec = section(0)
		for j = 1, P.BOYAU_N do
			local an = section(j)
			for i = 0, P.SEG_TROU - 1 do
				local i2 = (i + 1) % P.SEG_TROU
				local A1, A2, B1, B2 = precSec[i], precSec[i2], an[i], an[i2]
				for _, v in ipairs({ A1, B1, B2, A1, B2, B1, A1, B2, A2, A1, A2, B2 }) do pousser(boyau, v[1], v[2]) end
			end
			precSec = an
		end
		local fin = pied - F * (P.BOYAU_LONG + 6) - U * P.BOYAU_PROF + R * (cote * P.BOYAU_VIRAGE)
		for i = 0, P.SEG_TROU - 1 do                 -- bout du boyau : petit, loin et hors de l'axe du regard
			local A1, A2 = precSec[i], precSec[(i + 1) % P.SEG_TROU]
			for _, v in ipairs({ A1, A2, { fin, P.FOND }, A2, A1, { fin, P.FOND } }) do pousser(boyau, v[1], v[2]) end
		end
		local peintre = {}
		for i = #boyau - 2, 1, -3 do
			peintre[#peintre + 1] = boyau[i]; peintre[#peintre + 1] = boyau[i + 1]; peintre[#peintre + 1] = boyau[i + 2]
		end
		boyau = peintre
		local function maillage(t)
			local m = Mesh()
			mesh.Begin(m, MATERIAL_TRIANGLES, #t / 3)
			for _, v in ipairs(t) do
				local col = v[2]
				mesh.Position(versMonde(v[1]))
				mesh.Color(math.Clamp(col[1], 0, 255), math.Clamp(col[2], 0, 255), math.Clamp(col[3], 0, 255), 255)
				mesh.AdvanceVertex()
			end
			mesh.End()
			return m
		end
		local o = versMonde(pied)
		local mt2 = {}
		for i, v in ipairs(mt) do mt2[i] = { v[1], { 255, 0, 255 } } end
		G.bouches[#G.bouches + 1] = { n = h.n, temoin = maillage(mt2), decoupe = maillage(mt), boyau = maillage(boyau), o = o, f = versMonde(pied + F) - o,
			droite = versMonde(pied + R) - o, haut = haut - pied.z }
		-- lèvre de terre au bord irrégulier : épaisse au-dessus (surplomb), bourrelet bas au bord du sol
		local haute, basse = {}, {}
		for j = 0, 14 do
			local t = j / 14 * math.pi
			local q = contour(t, 1.04, 1.5)
			haute[#haute + 1] = { q.x, q.y, math.max(q.z, 1) }
			local q2 = contour(math.pi + t, 1.03)
			basse[#basse + 1] = { q2.x, q2.y, 0.6 }
		end
		local racines = { { r = P.LEVRE_R, p = haute, col = P.LEVRE, bosse = 0.35, effile = 0 },
			{ r = P.LEVRE_R * 0.5, p = basse, col = P.LEVRE, bosse = 0.45, effile = 0 } }
		-- les 2 racines en arche validées, DEVANT la bouche, pieds au sol ; la 3e court au sol
		for k = 1, 2 do
			local pts = {}
			for j = 0, 8 do
				local t = j / 8 * math.pi
				local q = contour(t, P.ARCHE_K[k] * (1 + 0.05 * math.sin(j * 2.3 + h.n + k * 4)), 6 - k)
				if j == 0 or j == 8 then q.z = -2 end
				pts[#pts + 1] = { q.x, q.y, q.z }
			end
			racines[#racines + 1] = { r = h.racines[k].r, p = pts, arche = true }
		end
		racines[#racines + 1] = h.racines[3]
		local U2 = U
		local function anneauxVers(out, axe, rayon, couleur, effile, bosse)
			local anneaux = {}
			for i, p in ipairs(axe) do
				local d = (axe[math.min(i + 1, #axe)] - axe[math.max(i - 1, 1)]):GetNormalized()
				local a1 = d:Cross(U2); if a1:LengthSqr() < 0.01 then a1 = d:Cross(F) end
				a1:Normalize(); local a2 = d:Cross(a1)
				local rr = rayon * (1 - effile * (i - 1) / math.max(#axe - 1, 1)) * (1 + bosse * math.sin(i * 2.9 + h.n) * math.sin(i * 1.3))
				local an = {}
				for k = 0, P.RACINE_COTES - 1 do
					local t = k / P.RACINE_COTES * math.pi * 2
					local n = a1 * math.cos(t) + a2 * math.sin(t)
					local l = P.AMB + P.SOL * math.max(n:Dot(SOLEIL), 0) + 0.15 * math.max(n.z, 0)
					an[#an + 1] = { p + n * rr, { couleur[1] * l, couleur[2] * l, couleur[3] * l } }
				end
				anneaux[#anneaux + 1] = an
			end
			for i = 1, #anneaux - 1 do
				local A, B = anneaux[i], anneaux[i + 1]
				for k = 1, P.RACINE_COTES do
					local k2 = k % P.RACINE_COTES + 1
					out[#out + 1] = A[k]; out[#out + 1] = B[k]; out[#out + 1] = B[k2]
					out[#out + 1] = A[k]; out[#out + 1] = B[k2]; out[#out + 1] = A[k2]
				end
			end
		end
		local function axeDe(rac)
			local pts = {}
			for _, p in ipairs(rac.p) do pts[#pts + 1] = Vector(p[1], p[2], p[3]) end
			return courbe(pts, P.RACINE_SEG)
		end
		local arches, sommetsArches = {}, {}
		for _, rac in ipairs(racines) do
			local out = tris
			if rac.arche then out = sommetsArches; arches[#arches + 1] = rac end
			anneauxVers(out, axeDe(rac), rac.r, rac.col or P.RACINE, rac.effile or 0.35, rac.bosse or 0)
		end
		ET.construire(h, { pied = pied, F = F, R = R, demi = demi, haut = haut, arches = arches, courbe = axeDe }, sommetsArches,
			function(out, axe, rayon, couleur, effile) anneauxVers(out, axe, rayon, couleur, effile, 0) end)
	end
	-- lots de 9 000 triangles au plus (limite d'indices)
	local i = 1
	while i <= #tris do
		local n = math.min(27000, #tris - i + 1)
		local m = Mesh()
		mesh.Begin(m, MATERIAL_TRIANGLES, n / 3)
		for j = i, i + n - 1 do
			local v = tris[j]
			mesh.Position(versMonde(v[1]))
			local col = v[2]
			mesh.Color(math.min(col[1], 255), math.min(col[2], 255), math.min(col[3], 255), 255)
			mesh.AdvanceVertex()
		end
		mesh.End()
		G.maillages[#G.maillages + 1] = m
		i = i + n
	end
	G.tris = #tris / 3
	DEC.construire()
end

-- ---------- hooks protégés ----------
local function ajouter(ev, nom, f)
	SumiiNoyau.hook(ev, "sumii_p2_" .. nom, function(...)
		if etat.erreurs[nom] then return end
		local ok, a, b = pcall(f, ...)
		if not ok then etat.erreurs[nom] = true; print("[sumii_p2] erreur " .. nom .. " : " .. tostring(a)) return end
		return a, b
	end)
end
ajouter("Think", "chantier", function()
	-- props redressés 3 s après la dernière vue dans la boîte (au banc, la caméra n'est pas le joueur)
	if ET and (not etat.allume or CurTime() - (etat.vuDedans or -10) > 3) then ET.redresserTout() end
	if not etat.allume or not majTete() then return end
	if CurTime() < (etat.controle or 0) then return end
	etat.controle = CurTime() + 1
	local p, a = etat.tete:GetPos(), etat.tete:GetAngles()
	if not etat.posT or p:DistToSqr(etat.posT) > 1 or a ~= etat.angT then
		etat.posT, etat.angT = p, a
		construire()
	end
end)
-- portail au pochoir, un par bouche vue de l'avant (après l'opaque : herbe et rochers de devant restent devant)
local function portail(b)
	if etat.essai == 1 then b.temoin:Draw() return end
	render.ClearStencil()
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(1)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	-- 1) marquer les pixels de la bouche qui passent le test de profondeur, sans rien écrire d'autre
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.OverrideColorWriteEnable(true, false)
	render.OverrideDepthEnable(true, false)
	b.decoupe:Draw()
	render.OverrideDepthEnable(false, false)
	render.OverrideColorWriteEnable(false, false)
	-- 2) dans ces pixels seulement : le boyau sans test de profondeur, du fond vers l'entrée.
	-- (v5 diagnostic : avec ClearBuffersObeyStencil rien ne s'affichait au banc ; on ne s'en sert plus.)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetColorMaterialIgnoreZ()
	cam.IgnoreZ(true)
	if etat.essai == 4 then b.temoin:Draw() else b.boyau:Draw() end   -- 4 : témoin du marquage
	if SumiiScene and SumiiScene.dansTrou then SumiiScene.dansTrou(b) end
	cam.IgnoreZ(false)
	render.SetColorMaterial()
end
local function tunnels()
	if #G.bouches == 0 then return end
	local t0 = SysTime()
	local e = EyePos()
	if etat.essai == 1 then render.SetColorMaterial() else render.SetStencilEnable(true) end
	local ok, err = pcall(function()
		for _, b in ipairs(G.bouches) do
			local o, f = b.o, b.f
			local dx, dy = e.x - o.x, e.y - o.y
			if not bouche_fermee(b.n) and dx * f.x + dy * f.y > 0 and dx * dx + dy * dy < 2600 * 2600 then portail(b) end
		end
	end)
	render.SetStencilEnable(false)                -- état de rendu remis, même après une erreur
	render.OverrideDepthEnable(false, false)
	render.OverrideColorWriteEnable(false, false)
	render.ClearStencil()
	if not ok then error(err) end
	local dt = (SysTime() - t0) * 1000
	etat.sn, etat.stotal, etat.spic = etat.sn + 1, etat.stotal + dt, math.max(etat.spic, dt)
end

ajouter("PostDrawOpaqueRenderables", "dessin", function(profondeur, ciel)
	if profondeur or ciel or #G.maillages == 0 or not dedans() then return end
	local t0 = SysTime()
	render.SetColorMaterial()
	render.OverrideDepthEnable(true, true)
	for _, m in ipairs(G.maillages) do m:Draw() end
	DEC.dessiner(ET.tempsOnde())
	etat.vuDedans = CurTime()
	ET.dessiner()
	render.OverrideDepthEnable(false, false)
	local dt = (SysTime() - t0) * 1000
	etat.n, etat.total, etat.pic = etat.n + 1, etat.total + dt, math.max(etat.pic, dt)
	if etat.essai < 3 then tunnels() end
end)
ajouter("PostDrawTranslucentRenderables", "tunnels_apres", function(profondeur, ciel)
	if profondeur or ciel or etat.essai < 3 or not dedans() then return end
	render.SetColorMaterial()
	tunnels()
end)
ajouter("PostDrawTranslucentRenderables", "poussiere", function(profondeur, ciel)
	if profondeur or ciel or not dedans() then return end
	DEC.dessinerPoussiere(ET.tempsOnde())
	ET.dessinerPoussiere()
end)
SumiiNoyau.banc("sumii_p2_essai", function(_, _, args)
	etat.essai = math.Clamp(math.floor(tonumber(args[1] or "") or 3), 0, 4)
	etat.erreurs = {}
	print("[sumii_p2] essai " .. etat.essai)
end)

SumiiNoyau.banc("sumii_p2", function(_, _, args)
	etat.allume = tonumber(args[1] or "") == 1
	etat.erreurs = {}
	print("[sumii_p2] " .. (etat.allume and "allumé" or "éteint"))
end)
SumiiNoyau.banc("sumii_p2_mesure", function()
	local moy = etat.n > 0 and etat.total / etat.n or 0
	local ligne = string.format("%s sumii_p2 v15 appels=%d moyenne_ms=%.4f pic_ms=%.4f triangles=%d", os.date("%H:%M:%S"), etat.n, moy, etat.pic, G.tris or 0)
	ligne = ligne .. string.format(" pochoirs_moyenne_ms=%.4f pochoirs_pic_ms=%.4f", etat.sn > 0 and etat.stotal / etat.sn or 0, etat.spic)
	print("[sumii_p2] " .. ligne)
	file.CreateDir("sumii_p2")
	file.Append("sumii_p2/mesure.txt", ligne .. "\n")
	etat.n, etat.total, etat.pic = 0, 0, 0
	etat.sn, etat.stotal, etat.spic = 0, 0, 0
end)
SumiiNoyau.hook("ShutDown", "sumii_p2_fin", detruire)
print("[sumii_p2] chargé v15")

SumiiNoyau.surExtinction(function() detruire() etat.posT, etat.angT, etat.controle = nil end)
