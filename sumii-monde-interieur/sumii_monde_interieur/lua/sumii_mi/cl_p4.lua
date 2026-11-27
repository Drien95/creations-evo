-- GÉNÉRÉ par addon/construire.py depuis lisiere/banc/cl_sumii_p4.lua : ne pas modifier ici.
-- Sumii, monde intérieur · P4 « Lisière et rochers » (banc, 27/11/2026). Client seulement, 0 posé.
-- Mousse sur le dessus des rochers (calculée en jeu) et buissons bas au pied de la lisière de P1 :
-- masses aplaties cabossées, feuilles collées à la surface (jamais en pics). La lisière de P1 n'est pas touchée.
-- Trois lots de maillages statiques, construits en coroutine (6 ms par image) ; aucune allocation par image.
-- Console (aucune touche en dur) : sumii_p4 <0|1>, sumii_p4_mesure. Les données générées sont en bas de la table P4.

local P4 = {
	MODELE_TETE = "models/hunter/plates/plate32x32.mdl", TEINTE_TETE = { 88, 124, 56 }, TETE = Vector(0, 0, -1.5),
	BX = 2400, BZ0 = -200, BZ1 = 1400,
	SOLEIL = Vector(math.cos(math.rad(208)), math.sin(math.rad(208)), 0.105):GetNormalized(),
	DESSOUS = { 30, 60, 32 }, MILIEU = { 62, 108, 48 }, DESSUS = { 112, 160, 66 }, OR = { 232, 184, 96 },
	FLEURS = { { 236, 168, 184 }, { 232, 228, 210 } },
	MERIDIENS = 10, PARALLELES = 4, LOT = 3000, MS_PAR_IMAGE = 6,
	ROCHERS = {
{"models/props_wasteland/rockgranite02a.mdl",-420,180,8},
{"models/props_wasteland/rockgranite02a.mdl",380,-300,8},
{"models/models/props_swamp/rock001_swamp.mdl",-1189.0,1071.0,-30},
{"models/propper/instance_onepiece/rock9.mdl",-969.0,1197.0,-30},
{"models/propper/instance_onepiece/rock9.mdl",-1272.9,885.2,-30},
{"models/props_wasteland/rockgranite02a.mdl",-1030.0,1010.0,-8},
{"models/props_wasteland/rockgranite02c.mdl",-1180.0,900.0,-8},
{"models/models/props_swamp/rock001_swamp.mdl",-1074.5,1054.9,-190},
{"models/models/props_swamp/rock001_swamp.mdl",-1150.0,935.0,-205},
{"models/models/props_swamp/rock001_swamp.mdl",-1080.0,975.0,-165},
{"models/propper/instance_onepiece/rock9.mdl",-708.0,-1390.0,-28},
{"models/props_wasteland/rockgranite02a.mdl",-650.0,-1290.0,-8},
{"models/props_wasteland/rockgranite02c.mdl",-790.0,-1300.0,-8},
{"models/propper/instance_onepiece/rock9.mdl",-1506.0,320.0,-32},
{"models/props_wasteland/rockgranite02a.mdl",-1390.0,300.0,-8},
{"models/props_wasteland/rockgranite02c.mdl",-1420.0,430.0,-8},
{"models/propper/instance_onepiece/rock9.mdl",-154.0,1534.0,-30},
{"models/props_wasteland/rockgranite02a.mdl",-60.0,1420.0,-8},
{"models/propper/instance_onepiece/rock9.mdl",772.3,-1332.5,-26},
{"models/props_wasteland/rockgranite02a.mdl",680.0,-1250.0,-8},
{"models/props_wasteland/rockgranite02c.mdl",860.0,-1250.0,-8},
{"models/models/props_swamp/rock001_swamp.mdl",1585.0,333.0,-40},
{"models/props_wasteland/rockgranite02a.mdl",1450.0,430.0,-8},
{"models/props_wasteland/rockgranite02c.mdl",-470.0,215.0,-8},
{"models/props_wasteland/rockgranite02a.mdl",432.0,-270.0,-8}
	},
	CREUX = { 56, 82, 40 }, VERT = { 118, 150, 62 }, ATTENTE_ROCHERS = 10,
	BUISSONS = {
{1721,42,52,56},
{1756,-56,81,92},
{1772,-60,43,55},
{1761,242,83,106},
{1741,205,78,91},
{1791,216,47,65},
{1728,258,66,79},
{1765,282,33,38},
{1701,417,50,58},
{1728,447,47,58},
{1692,461,64,69},
{1780,471,49,70},
{1629,643,49,58},
{1609,663,35,41},
{1678,674,71,83},
{1627,699,55,73},
{1421,854,37,39},
{1557,827,52,73},
{1547,938,61,85},
{1581,883,46,55},
{1530,827,84,93},
{1498,1071,77,86},
{1575,1098,64,76},
{1486,1144,83,108},
{1500,1144,79,108},
{1316,1172,36,47},
{1364,1213,39,46},
{1337,1247,38,42},
{1376,1241,79,102},
{1029,1350,36,45},
{1097,1385,38,51},
{1187,1379,69,86},
{925,1492,72,85},
{966,1483,59,83},
{956,1540,60,75},
{707,1630,75,103},
{798,1594,50,53},
{689,1664,45,59},
{510,1738,35,38},
{592,1778,85,108},
{455,1728,49,64},
{565,1784,52,69},
{296,1760,75,108},
{327,1726,71,79},
{338,1800,81,108},
{90,1828,39,49},
{75,1849,36,48},
{86,1764,41,57},
{47,1802,58,79},
{-238,1769,50,61},
{-226,1729,81,102},
{-174,1677,31,38},
{-221,1752,75,84},
{-225,1732,61,72},
{-389,1656,33,37},
{-397,1680,32,44},
{-414,1670,85,108},
{-452,1657,58,80},
{-527,1712,59,83},
{-643,1505,38,41},
{-750,1634,34,45},
{-700,1565,39,52},
{-681,1671,79,108},
{-861,1481,77,85},
{-902,1475,41,48},
{-837,1551,61,75},
{-877,1611,65,81},
{-844,1539,74,107},
{-1133,1435,72,100},
{-1084,1448,53,67},
{-1094,1397,48,56},
{-1002,1451,80,93},
{-1218,1291,34,47},
{-1199,1337,82,95},
{-1167,1295,43,47},
{-1311,1103,60,68},
{-1275,1142,75,108},
{-1335,1111,58,84},
{-1382,1125,55,72},
{-1488,989,47,54},
{-1617,944,71,78},
{-1581,983,77,81},
{-1537,949,54,58},
{-1561,975,58,84},
{-1647,737,55,64},
{-1548,787,44,63},
{-1572,775,30,36},
{-1520,819,41,52},
{-1632,567,52,61},
{-1716,557,78,87},
{-1678,570,63,86},
{-1774,350,32,45},
{-1750,397,75,83},
{-1767,358,77,105},
{-1802,213,66,72},
{-1735,204,51,63},
{-1786,181,60,69},
{-1753,91,34,48},
{-1827,155,59,80},
{-1723,-95,43,56},
{-1771,-41,81,94},
{-1772,-80,41,53},
{-1785,-316,25,26},
{-1756,-345,54,56},
{-1717,-390,45,49},
{-1771,-625,37,40},
{-1656,-645,41,56},
{-1716,-569,28,38},
{-1656,-799,64,56},
{-1596,-809,25,26},
{-1592,-785,38,42},
{-1617,-861,62,56},
{-1500,-949,25,33},
{-1511,-1069,63,56},
{-1571,-960,62,56},
{-1479,-1054,52,56},
{-1493,-1032,38,52},
{-1352,-1129,65,56},
{-1381,-1191,57,56},
{-1322,-1171,37,39},
{-1430,-1148,45,54},
{-1133,-1292,43,54},
{-1149,-1340,34,43},
{-1146,-1325,55,66},
{-1214,-1282,61,70},
{-1125,-1311,48,57},
{-1024,-1394,53,67},
{-1104,-1444,46,65},
{-1079,-1432,65,91},
{-1097,-1511,44,53},
{-827,-1657,37,45},
{-811,-1679,57,62},
{-865,-1634,60,74},
{-615,-1679,36,50},
{-673,-1570,35,47},
{-617,-1691,62,66},
{-645,-1657,65,82},
{-560,-1622,36,42},
{-462,-1802,31,36},
{-473,-1718,79,99},
{-457,-1697,84,108},
{-225,-1771,35,39},
{-234,-1772,69,92},
{-165,-1744,30,35},
{-177,-1757,58,65},
{25,-1804,36,47},
{23,-1806,81,87},
{22,-1751,33,35},
{3,-1783,70,78},
{182,-1784,82,97},
{201,-1720,32,42},
{150,-1715,49,54},
{421,-1735,61,83},
{466,-1731,75,81},
{429,-1802,60,74},
{556,-1579,75,102},
{704,-1699,82,94},
{719,-1659,49,57},
{884,-1584,82,96},
{870,-1530,83,89},
{901,-1599,70,87},
{806,-1612,81,108},
{992,-1423,76,103},
{963,-1509,50,69},
{952,-1495,72,83},
{1110,-1499,61,72},
{1230,-1233,42,51},
{1213,-1235,37,46},
{1242,-1290,60,82},
{1242,-1107,51,68},
{1334,-1121,39,54},
{1320,-1121,52,76},
{1350,-1063,75,99},
{1410,-952,81,87},
{1538,-933,84,108},
{1525,-1036,79,97},
{1537,-987,83,91},
{1578,-856,32,47},
{1567,-793,76,104},
{1555,-845,65,70},
{1693,-584,67,75},
{1674,-558,45,65},
{1683,-530,33,44},
{1703,-549,31,42},
{1678,-413,54,60},
{1675,-410,50,69},
{1739,-388,38,52},
{1778,-118,38,44},
{1771,-57,57,79},
{1802,-56,37,53}
	},
}
local e4 = { allume = true, tete = nil, prochaine = 0, cle = nil, co = nil, prets = false, n = 0, total = 0, pic = 0, erreur = nil }
local G4 = { unis = {}, feuilles = {} }
local MAT_UNI = CreateMaterial("sumii_p4_uni_v1", "UnlitGeneric", { ["$basetexture"] = "vgui/white", ["$vertexcolor"] = "1",
	["$nocull"] = "1" })
local MATS_F = {}
local GRIS = 0.64 * 255

local function hache(x) x = math.sin(x) * 43758.5453 return x - math.floor(x) end
local fin = 0
local function souffle() if coroutine.running() and SysTime() > fin then coroutine.yield() end end

local function chercherTete() return SumiiAncre.tete() end
local function versMonde(p) return e4.tete:LocalToWorld(p - P4.TETE) end
local function e2build(e)
	return function(v) return e4.tete:WorldToLocal(e:LocalToWorld(v)) + P4.TETE end
end
local function dedans()
	if not e4.allume or not IsValid(e4.tete) then return false end
	local p = e4.tete:WorldToLocal(EyePos()) + P4.TETE
	return p.x * p.x + p.y * p.y <= P4.BX * P4.BX and p.z >= P4.BZ0 and p.z <= P4.BZ1
end

local function detruire()
	for _, m in ipairs(G4.unis) do m:Destroy() end
	for _, l in ipairs(G4.feuilles) do for _, m in ipairs(l.lots) do m:Destroy() end end
	G4 = { unis = {}, feuilles = {} }
	e4.prets, e4.co = false, nil
end

-- triangles { p1, p2, p3, c1, c2, c3 } en repère du build -> lots de maillages
local function lotsUnis(tris, dest)
	local k = 1
	while k <= #tris do
		local n = math.min(P4.LOT, #tris - k + 1)
		local m = Mesh()
		mesh.Begin(m, MATERIAL_TRIANGLES, n)
		for q = k, k + n - 1 do
			local t = tris[q]
			for v = 1, 3 do
				local p, c = versMonde(t[v]), t[v + 3]
				mesh.Position(p); mesh.Color(math.min(c[1], 255), math.min(c[2], 255), math.min(c[3], 255), 255); mesh.AdvanceVertex()
			end
		end
		mesh.End()
		dest[#dest + 1] = m
		k = k + n
		souffle()
	end
end

local function cleFeuille(col)
	local function q(x) return math.floor(math.min(x, GRIS) / 18 + 0.5) * 18 end
	local r, g, b = q(col[1]), q(col[2]), q(col[3])
	local cle = r .. "_" .. g .. "_" .. b
	if not MATS_F[cle] then
		MATS_F[cle] = CreateMaterial("sumii_p4_f_" .. cle .. "_v1", "UnlitGeneric", { ["$basetexture"] = "particle/leaf/leaf_nocolor",
			["$alphatest"] = "1", ["$alphatestreference"] = "0.35", ["$nocull"] = "1",
			["$color"] = string.format("[%.3f %.3f %.3f]", r / GRIS, g / GRIS, b / GRIS) })
	end
	return cle
end

local function carte(cartes, p, nrm, taille, graine, col)
	local U0 = nrm:Cross(Vector(0, 0, 1))
	if U0:LengthSqr() < 0.01 then U0 = Vector(1, 0, 0) end
	U0:Normalize()
	local V0, ang = U0:Cross(nrm), (hache(graine + 5.3) - 0.5) * 0.4
	local U = (U0 * math.cos(ang) + V0 * math.sin(ang)) * taille
	local V = (V0 * math.cos(ang) - U0 * math.sin(ang)) * taille
	local cle = cleFeuille(col)
	cartes[cle] = cartes[cle] or {}
	local l = cartes[cle]
	l[#l + 1] = { p - U - V, p + U - V, p + U + V, p - U + V, math.floor(hache(graine) * 4) * 0.25 }
end

local function melange(a, b, t) return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t } end

-- couleur d'un point de la masse : bas sombre, dessus clair, liseré d'or côté soleil
local function teinte(n, contreJour)
	local s = math.max(n.z, 0)
	local c = s < 0.5 and melange(P4.DESSOUS, P4.MILIEU, s * 2) or melange(P4.MILIEU, P4.DESSUS, (s - 0.5) * 2)
	local d = math.max(n:Dot(P4.SOLEIL), 0) ^ 2 * 0.55
	c = melange(c, P4.OR, d)
	return { c[1] * contreJour, c[2] * contreJour, c[3] * contreJour }
end

-- un dôme cabossé enfoncé de 30 %, puis ses feuilles
local function dome(tris, cartes, x, y, R, H, graine, contreJour, fleur)
	local M, N = P4.MERIDIENS, P4.PARALLELES
	local centre = Vector(x, y, -H * 0.16)
	local g1, g2 = hache(graine) * 6.28, hache(graine + 1.7) * 6.28
	local pts, cols, nrms = {}, {}, {}
	for a = 0, N do
		pts[a], cols[a], nrms[a] = {}, {}, {}
		local th = a / N * math.rad(108)
		for b = 0, M - 1 do
			local ph = b / M * math.pi * 2
			local n = Vector(math.sin(th) * math.cos(ph), math.sin(th) * math.sin(ph), math.cos(th))
			local bosse = 1 + 0.16 * math.sin(3 * ph + g1) * math.sin(th) + 0.09 * math.sin(5 * th + g2)
			pts[a][b] = centre + Vector(n.x * R * bosse, n.y * R * bosse, n.z * H * 0.95 * bosse)
			nrms[a][b] = n
			cols[a][b] = teinte(n, contreJour * 0.86)
		end
	end
	for a = 0, N - 1 do
		for b = 0, M - 1 do
			local b2 = (b + 1) % M
			if a > 0 then tris[#tris + 1] = { pts[a][b], pts[a + 1][b], pts[a][b2], cols[a][b], cols[a + 1][b], cols[a][b2] } end
			tris[#tris + 1] = { pts[a][b2], pts[a + 1][b], pts[a + 1][b2], cols[a][b2], cols[a + 1][b], cols[a + 1][b2] }
		end
	end
	for a = 0, N - 1 do                          -- feuilles sur la surface, serrées sur le haut et le contour
		for b = 0, M - 1 do
			for j = 1, 3 do
				local g = graine + a * 17.3 + b * 5.1 + j * 29.7
				local fa, fb = hache(g), hache(g + 1.1)
				local b2 = (b + 1) % M
				local haut = LerpVector(fb, pts[a][b], pts[a][b2])
				local bas = LerpVector(fb, pts[a + 1][b], pts[a + 1][b2])
				local p = LerpVector(fa, haut, bas)
				local n = (nrms[a][b] + nrms[a + 1][b2]):GetNormalized()
				if p.z > 2 then
					local col = teinte(n, contreJour * (0.9 + hache(g + 2.3) * 0.25))
					if fleur and n.z > 0.45 and hache(g + 9.1) < 0.07 then col = fleur end
					carte(cartes, centre + (p - centre) * 1.04, (n + Vector(0, 0, -0.22)):GetNormalized(), 6.5 + R * 0.05, g + 6.1, col)
				end
			end
		end
	end
end

local function jupe(cartes, x, y, R, graine, contreJour)
	local n = math.floor(14 + R * 0.28)
	for k = 1, n do
		local g = graine + k * 9.17
		local a = (k + hache(g)) / n * math.pi * 2
		local dehors = Vector(math.cos(a), math.sin(a), 0)
		local d = R * (0.92 + hache(g + 1) * 0.28)
		local col = teinte(Vector(dehors.x, dehors.y, 0.3):GetNormalized(), contreJour * (0.8 + hache(g + 2) * 0.3))
		carte(cartes, Vector(x, y, 3 + hache(g + 3) * 12) + dehors * d, (dehors + Vector(0, 0, 0.5)):GetNormalized(), 7 + R * 0.07, g + 4, col)
	end
end

local function lotsFeuilles(cartes)
	for cle, l in pairs(cartes) do
		local bloc, k = { mat = MATS_F[cle], lots = {} }, 1
		while k <= #l do
			local n = math.min(1500, #l - k + 1)
			local m = Mesh()
			mesh.Begin(m, MATERIAL_QUADS, n)
			for q = k, k + n - 1 do
				local c = l[q]
				local u0 = c[5]
				mesh.Position(versMonde(c[1])); mesh.TexCoord(0, u0, 0.5); mesh.AdvanceVertex()
				mesh.Position(versMonde(c[2])); mesh.TexCoord(0, u0 + 0.25, 0.5); mesh.AdvanceVertex()
				mesh.Position(versMonde(c[3])); mesh.TexCoord(0, u0 + 0.25, 0.25); mesh.AdvanceVertex()
				mesh.Position(versMonde(c[4])); mesh.TexCoord(0, u0, 0.25); mesh.AdvanceVertex()
			end
			mesh.End()
			bloc.lots[#bloc.lots + 1] = m
			k = k + n
			souffle()
		end
		G4.feuilles[#G4.feuilles + 1] = bloc
	end
end

-- Mousse : calculée sur le maillage AFFICHÉ de chaque rocher (util.GetModelMeshes), pas sur la collision,
-- pour qu'elle épouse la surface (v2 et v3 : éclats flottants sur les flancs, sommets nus).
local function bruit(x, y)
	local i, j = math.floor(x), math.floor(y)
	local fx, fy = x - i, y - j
	fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
	local function h(a, b) return hache(a * 127.1 + b * 311.7) end
	local a, b, c, d = h(i, j), h(i + 1, j), h(i, j + 1), h(i + 1, j + 1)
	return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy
end

local function trouverRochers()
	local props, trouves = ents.FindByClass("prop_physics"), {}
	for _, r in ipairs(P4.ROCHERS) do
		local place = versMonde(Vector(r[2], r[3], r[4]))
		for _, e in ipairs(props) do
			if IsValid(e) and string.lower(e:GetModel() or "") == r[1] and e:GetPos():DistToSqr(place) < 400 then
				trouves[#trouves + 1] = e
				break
			end
		end
	end
	return trouves
end

local function mousseDe(e, dest)
	local maillages = util.GetModelMeshes(e:GetModel())
	if not maillages then print("[sumii_p4] maillage illisible : " .. tostring(e:GetModel())) return end
	local up, base = e2build(e), {}
	local haut = 1
	for _, m in ipairs(maillages) do
		for i, v in ipairs(m.triangles) do
			local p = up(v.pos)
			base[#base + 1] = { p, up(v.pos + v.normal) - p }
			if p.z > haut then haut = p.z end
			if i % 900 == 0 then souffle() end
		end
	end
	local seuilZ = haut * (haut > 180 and 0.52 or 0.34)
	for k = 1, #base - 2, 3 do
		local a, b, c = base[k], base[k + 1], base[k + 2]
		local m = (a[1] + b[1] + c[1]) / 3
		local n = (a[2] + b[2] + c[2]):GetNormalized()
		if m.z > math.max(8, seuilZ) and n.z > 0.38 then
			local hr = m.z / haut
			local score = (n.z - 0.38) + 0.55 * hr + 0.6 * (bruit(m.x / 30, m.y / 30) - 0.5)
			if score > 0.5 then
				local f = math.Clamp((score - 0.5) * 1.5, 0, 1)
				local g = 0.9 + 0.22 * bruit(m.x / 8 + 9, m.y / 8 + 3)
				local col = { Lerp(f, P4.CREUX[1], P4.VERT[1]) * g, Lerp(f, P4.CREUX[2], P4.VERT[2]) * g, Lerp(f, P4.CREUX[3], P4.VERT[3]) * g }
				dest[#dest + 1] = { a[1] + a[2] * 1.8, b[1] + b[2] * 1.8, c[1] + c[2] * 1.8, col, col, col, n }
			end
		end
		if k % 900 == 1 then souffle() end
	end
end

local function construire()
	local t0 = SysTime()
	local mousse = {}
	local limite, rochers = CurTime() + P4.ATTENTE_ROCHERS, trouverRochers()
	while #rochers < #P4.ROCHERS and CurTime() < limite do      -- les props arrivent parfois après la plaque repère
		coroutine.yield()
		rochers = trouverRochers()
	end
	if #rochers < #P4.ROCHERS then print(string.format("[sumii_p4] %d rochers trouvés sur %d", #rochers, #P4.ROCHERS)) end
	for _, e in ipairs(rochers) do
		if IsValid(e) then mousseDe(e, mousse) end
	end
	lotsUnis(mousse, G4.unis)
	local tris, cartes = {}, {}
	local pas = math.max(1, math.floor(#mousse / 2600))          -- 2 600 touffes au plus sur la mousse
	for i = 1, #mousse, pas do
		local t = mousse[i]
		local p, n, c, k = (t[1] + t[2] + t[3]) / 3, t[7], t[4], 0.95 + hache(i * 1.9) * 0.3
		carte(cartes, p + n * 1.4, n, 4 + hache(i * 5.3) * 3.5, i * 7.1, { c[1] * k, c[2] * k, c[3] * k })
		if i % 300 == 1 then souffle() end
	end
	for i, b in ipairs(P4.BUISSONS) do
		local x, y, R, H = b[1], b[2], b[3], b[4]
		local d = Vector(x, y, 0):GetNormalized()
		local contreJour = 1 - 0.22 * math.max(d:Dot(Vector(P4.SOLEIL.x, P4.SOLEIL.y, 0):GetNormalized()), 0)
		local bosquet = math.floor((i - 1) / 5)
		local fleur = bosquet % 5 == 2 and P4.FLEURS[1 + bosquet % 2] or nil
		dome(tris, cartes, x, y, R, H, i * 13.37, contreJour, fleur)
		jupe(cartes, x, y, R, i * 5.71, contreJour)
		souffle()
	end
	lotsUnis(tris, G4.unis)
	lotsFeuilles(cartes)
	e4.prets = true
	print(string.format("[sumii_p4] mousse %d triangles, %d buissons, construit en %.0f ms (étalé)", #mousse, #P4.BUISSONS,
		(SysTime() - t0) * 1000))
end

SumiiNoyau.hook("Think", "sumii_p4_construction", function()
	if CurTime() >= e4.prochaine then
		e4.prochaine = CurTime() + 1
		if not IsValid(e4.tete) then e4.tete = chercherTete() end
		if not IsValid(e4.tete) then
			if e4.cle then detruire(); e4.cle = nil end
		else
			local cle = tostring(e4.tete:GetPos()) .. tostring(e4.tete:GetAngles())
			if cle ~= e4.cle then
				detruire()
				e4.cle, e4.co = cle, coroutine.create(construire)
			end
		end
	end
	if e4.co then
		fin = SysTime() + P4.MS_PAR_IMAGE / 1000
		local ok, err = coroutine.resume(e4.co)
		if not ok then ErrorNoHalt("[sumii_p4] construction : " .. tostring(err) .. "\n") end
		if not ok or coroutine.status(e4.co) == "dead" then e4.co = nil end
	end
end)

SumiiNoyau.hook("PostDrawOpaqueRenderables", "sumii_p4_dessin", function(profondeur, ciel, ciel3d)
	if profondeur or ciel or ciel3d or not e4.prets or not dedans() then return end
	local t0 = SysTime()
	local pli = SumiiScene and SumiiScene.pliForet and SumiiScene.pliForet()
	if pli then cam.PushModelMatrix(pli) end
	render.SetMaterial(MAT_UNI)
	for _, m in ipairs(G4.unis) do m:Draw() end
	for _, l in ipairs(G4.feuilles) do
		render.SetMaterial(l.mat)
		for _, m in ipairs(l.lots) do m:Draw() end
	end
	if pli then cam.PopModelMatrix() end
	local ms = (SysTime() - t0) * 1000
	e4.n, e4.total, e4.pic = e4.n + 1, e4.total + ms, math.max(e4.pic, ms)
end)

SumiiNoyau.banc("sumii_p4", function(_, _, args)
	e4.allume = args[1] ~= "0"
	print("[sumii_p4] " .. (e4.allume and "affiché" or "masqué"))
end)
SumiiNoyau.banc("sumii_p4_mesure", function()
	if e4.n == 0 then print("[sumii_p4] aucune image mesurée (hors de la boîte ?)") return end
	print(string.format("[sumii_p4] appels=%d moyenne_ms=%.3f pic_ms=%.3f (temps processeur)", e4.n, e4.total / e4.n, e4.pic))
	e4.n, e4.total, e4.pic = 0, 0, 0
end)
SumiiNoyau.hook("ShutDown", "sumii_p4_fin", detruire)

SumiiNoyau.surExtinction(function() detruire() e4.cle = nil end)
