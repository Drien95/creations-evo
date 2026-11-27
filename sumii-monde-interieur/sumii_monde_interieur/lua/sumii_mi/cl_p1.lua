-- GÉNÉRÉ par addon/construire.py depuis sol/banc/cl_sumii_p1.lua : ne pas modifier ici.
-- Sumii, monde intérieur · P1 « Sol, fermeture, ciel couchant » (banc, 27/11/2026). Client seulement.
-- Pour le joueur dont la caméra est dans la boîte (4 800 x 4 800 x 1 600 autour du prop repère) :
--   ciel couchant (dôme en dégradé, soleil bas à l'ouest-sud-ouest, rayons, nuages), lisière lointaine en silhouettes
--   (2 anneaux de cimes), sol d'herbe peint (taches de soleil et d'ombre), herbe haute qui ondule (touffes par blocs,
--   cisaillement par le vent), rééclairage or des props de la boîte, étalonnage « anime » (couleur, contraste, bloom).
-- Repère : centre de la plaine en (0, 0), dessus du sol à z 0, ouest = -X (soleil).
-- Banc seulement : le repère est la plaque centrale (modèle + teinte). À la livraison : gravure d'usine (sh_gravure).
-- Console (aucune touche en dur) : sumii_p1 <0|1>, sumii_p1_mesure.

local P = {                                   -- réglages (une table : peu de locales)
	MODELE_TETE = "models/hunter/plates/plate32x32.mdl", TEINTE_TETE = { 88, 124, 56 }, TETE = Vector(0, 0, -1.5),
	BX = 2400, BZ0 = -200, BZ1 = 1400,
	SOLEIL_AZ = 208, SOLEIL_EL = 6,            -- degrés : ouest = 180, sud-ouest = 225 ; le soleil est à gauche vu de la pierre
	CIEL_R = 500,
	ZENITH = { 50, 68, 160 }, MILIEU = { 72, 128, 212 }, HORIZON = { 156, 182, 222 },
	CHAUD = { 255, 168, 84 }, ROSE = { 236, 138, 132 }, HALO = { 255, 226, 160 },
	SOL_Z = 0.6, SOL_PAS = 80,
	OMBRES = { { -585, -749 }, { -788, 616 }, { -1060, -1060 } },   -- pieds des arbres de cadrage (repère du dupe)
	OMBRE_DIR = { 0.883, 0.469 },              -- à l'opposé du soleil (azimut 208 + 180)
	NUAGES_SOL = { { 650, -500, 520 }, { -300, 900, 600 }, { 1250, 700, 480 }, { -1100, 150, 420 }, { 300, -1500, 560 } },
	CREUX = { 62, 151, 208, 302 },               -- azimuts (degrés) des creux de la lisière
	OMBRE = { 44, 84, 46 }, LUMIERE = { 108, 156, 50 },
	BLOC = 400, DENSE = 1500, MOYEN = 640, CLAIR = 300, D_DENSE = 850, D_MOYEN = 1600, D_CLAIR = 2500,
	VENT = { 0.16, 0.10 },                    -- cisaillement de base et amplitude de la vague
	ID_LUM = 4600,                            -- plage DynamicLight réservée 4600 à 4609 (pas utilisée en P1)
}
local etat = { allume = true, tete = nil, prochaine = 0, cle = nil, erreurs = {}, n = 0, total = 0, pic = 0 }
local G = {}                                  -- géométrie construite une fois par position du repère
local MAT = {
	glow = Material("sprites/light_glow02_add"),
	fumee = {},
	add = CreateMaterial("sumii_p1_add_v1", "UnlitGeneric", { ["$basetexture"] = "vgui/white", ["$additive"] = "1",
		["$vertexcolor"] = "1", ["$vertexalpha"] = "1", ["$nocull"] = "1" }),
}
local TEX_FUMEE = { "particle/smokesprites0001", "particle/smokesprites0001", "particle/smokesprites0001" }   -- seule texture de fumée du jeu de base (0002 et 0003 viennent d un addon)
for i = 1, 3 do
	MAT.fumee[i] = CreateMaterial("sumii_p1_nuage" .. i .. "_v4", "UnlitGeneric", { ["$basetexture"] = TEX_FUMEE[i],
		["$vertexcolor"] = "1", ["$vertexalpha"] = "1", ["$translucent"] = "1", ["$nocull"] = "1" })
end
local COUL = Color(0, 0, 0, 0)
local function coul(r, g, b, a)
	COUL.r, COUL.g, COUL.b, COUL.a = math.min(r, 255), math.min(g, 255), math.min(b, 255), math.min(a or 255, 255)
	return COUL
end
local function lerp3(t, a, b) return a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t end
local function lisse(a, b, x) local t = math.Clamp((x - a) / (b - a), 0, 1) return t * t * (3 - 2 * t) end

-- ---------- bruit (même résultat chez tous) ----------
local function hache(i, j) local s = math.sin(i * 127.1 + j * 311.7) * 43758.5453 return s - math.floor(s) end
local function bruit(x, y)
	local i, j = math.floor(x), math.floor(y)
	local fx, fy = x - i, y - j
	fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
	local a, b, c, d = hache(i, j), hache(i + 1, j), hache(i, j + 1), hache(i + 1, j + 1)
	return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy
end
local function fbm(x, y) return 0.55 * bruit(x, y) + 0.3 * bruit(x * 2.1 + 17, y * 2.1 + 5) + 0.15 * bruit(x * 4.3 + 3, y * 4.3 + 41) end
local alea = { v = 0.4321 }
function alea.n() alea.v = (alea.v * 9301 + 0.49297) % 1 return alea.v end
-- v32 : la construction tourne dans une coroutine, quelques ms par image
local budget = { fin = 0 }
local function souffle() if coroutine.running() and SysTime() > budget.fin then coroutine.yield() end end
local VQ = Vector(0, 0, 0)                    -- sommet réutilisé : aucune allocation par image (ramasse-miettes)
local function sommet(x, y, z, u, v) VQ:SetUnpacked(x, y, z); mesh.Position(VQ); if u then mesh.TexCoord(0, u, v) end end

-- ---------- repère ----------
local function chercherTete() return SumiiAncre.tete() end
local function majTete()
	if CurTime() >= etat.prochaine then
		etat.prochaine = CurTime() + 1
		if not IsValid(etat.tete) then etat.tete = chercherTete() end
	end
	return IsValid(etat.tete)
end
local function versMonde(x, y, z) return etat.tete:LocalToWorld(Vector(x, y, z) - P.TETE) end
local function versBuild(p) return etat.tete:WorldToLocal(p) + P.TETE end
-- cache par image ET par œil : Think (œil du joueur) et le rendu d'une vue (autre œil) partagent le même FrameNumber
local dedansCache, dedansImage, dedansOeil = false, -1, Vector(0, 0, 0)
local function dedans()
	if not etat.allume or not majTete() then return false end
	local img, oeil = FrameNumber(), EyePos()
	if img ~= dedansImage or oeil ~= dedansOeil then
		dedansImage, dedansOeil = img, oeil
		local p = versBuild(oeil)
		dedansCache = p.x * p.x + p.y * p.y <= P.BX * P.BX and p.z >= P.BZ0 and p.z <= P.BZ1
		if dedansCache then etat.vuDedans = CurTime() end
	end
	return dedansCache
end

local SOLEIL = Vector(math.cos(math.rad(P.SOLEIL_AZ)) * math.cos(math.rad(P.SOLEIL_EL)),
	math.sin(math.rad(P.SOLEIL_AZ)) * math.cos(math.rad(P.SOLEIL_EL)), math.sin(math.rad(P.SOLEIL_EL)))

-- ---------- couleurs ----------
local function couleurCiel(d)                 -- d : direction unitaire dans le repère du build
	local el = math.max(d.z, 0)
	local cs = d:Dot(SOLEIL)
	local r, g, b
	if el < 0.35 then r, g, b = lerp3(lisse(0, 0.35, el), P.HORIZON, P.MILIEU)
	else r, g, b = lerp3(lisse(0.35, 1, el), P.MILIEU, P.ZENITH) end
	local chaud = ((cs + 1) / 2) ^ 3 * (1 - lisse(0, 0.6, el))   -- côté soleil, près de l'horizon
	local rose = ((cs + 1) / 2) ^ 2 * lisse(0.05, 0.25, el) * (1 - lisse(0.25, 0.7, el)) * 0.45
	r, g, b = r + (P.CHAUD[1] - r) * chaud, g + (P.CHAUD[2] - g) * chaud, b + (P.CHAUD[3] - b) * chaud
	r, g, b = r + (P.ROSE[1] - r) * rose, g + (P.ROSE[2] - g) * rose, b + (P.ROSE[3] - b) * rose
	local halo = math.max(cs, 0) ^ 26 * 0.7 + math.max(cs, 0) ^ 5 * 0.2     -- v32 : soleil voilé, lueur large
	r, g, b = r + (P.HALO[1] - r) * halo, g + (P.HALO[2] - g) * halo, b + (P.HALO[3] - b) * halo
	local bande = (1 - lisse(0.05, 0.62, el)) * 0.48            -- bas du ciel rosé-orangé tout autour (couchant)
	r, g, b = r + (240 - r) * bande, g + (176 - g) * bande, b + (156 - b) * bande
	return math.min(r, 255), math.min(g, 255), math.min(b, 255)
end
local function couleurSol(x, y)
	local n1 = fbm(x / 950 + 3.1, y / 950 + 7.7)
	local n2 = fbm(x / 170, y / 170)
	local l = lisse(0.38, 0.62, n1)
	local rr = math.sqrt(x * x + y * y)
	local ombreLisiere = lisse(1700, 2200, rr) * math.max(0, -(x / math.max(rr, 1)) * 0.9 + 0.1)   -- ombre portée par la lisière ouest
	l = l * (1 - 0.85 * ombreLisiere)
	for _, a in ipairs(P.OMBRES) do              -- ombre douce et longue de chaque arbre de cadrage (positions du dupe, relatives)
		local px, py = x - a[1], y - a[2]
		local le = px * P.OMBRE_DIR[1] + py * P.OMBRE_DIR[2]
		if le > -160 and le < 1700 then
			local tr = math.abs(px * P.OMBRE_DIR[2] - py * P.OMBRE_DIR[1])
			local w = 200 + le * 0.12
			local o = (1 - lisse(w * 0.45, w, tr)) * lisse(-160, 60, le) * (1 - lisse(900, 1700, le))
			l = l * (1 - 0.9 * o)
		end
	end
	for _, n in ipairs(P.NUAGES_SOL) do         -- ombres de nuages : grandes taches douces qui cassent le tapis
		local dx, dy = (x - n[1]) / n[3], (y - n[2]) / (n[3] * 0.62)
		l = l * (1 - 0.6 * (1 - lisse(0.55, 1, math.sqrt(dx * dx + dy * dy))))
	end
	local r, g, b = lerp3(l, P.OMBRE, P.LUMIERE)
	local teinte = fbm(x / 1400 + 31, y / 1400 + 17)   -- prairie plus profonde par endroits, plus jaune ailleurs
	local tj = lisse(0.35, 0.7, teinte)
	r, g, b = r * (0.86 + 0.3 * tj), g * (0.97 + 0.06 * tj), b * (1.12 - 0.3 * tj)
	local k = 0.86 + 0.26 * n2
	return r * k + 10 * l, g * k + 4 * l, b * k, l
end

-- ---------- construction ----------
local function detruire()
	for _, m in pairs({ G.ciel, G.sol, G.anneau1, G.anneau2 }) do if m then m:Destroy() end end
	for _, m in ipairs(G.lointains or {}) do m:Destroy() end
	for _, m in pairs(G.nuagesF or {}) do m:Destroy() end
	for _, m in ipairs(G.arbres or {}) do m:Destroy() end
	for _, m in ipairs(G.spheres or {}) do m:Destroy() end
	for _, l in pairs(G.feuilles or {}) do for _, m in ipairs(l) do m:Destroy() end end
	for _, m in ipairs(G.cartes or {}) do m:Destroy() end
	for _, m in ipairs(G.chaudes or {}) do m:Destroy() end
	for _, m in ipairs(G.fonds or {}) do m:Destroy() end
	for _, e in ipairs(G.cailloux or {}) do if IsValid(e) then e:Remove() end end
	G.cailloux, G.caillouxAFaire = {}, false
	for _, l in ipairs(G.accents or {}) do for _, m in ipairs(l) do m:Destroy() end end
	for _, b in ipairs(G.blocs or {}) do
		for _, k in ipairs({ "dense", "moyen", "clair" }) do
			if b[k] then b[k]:Destroy() end
			for _, z in ipairs(b.zones or {}) do if z[k] then z[k]:Destroy() end end
		end
	end
	G = {}
end
local function directionMonde(d) return (etat.tete:LocalToWorld(d) - etat.tete:GetPos()) end
local function construireCiel()
	local m = Mesh()
	local NA, NE = 48, 20
	mesh.Begin(m, MATERIAL_QUADS, NA * NE)
	for i = 0, NA - 1 do
		for j = 0, NE - 1 do
			local pts = { { i, j }, { i + 1, j }, { i + 1, j + 1 }, { i, j + 1 } }
			for _, q in ipairs(pts) do
				local a = q[1] / NA * math.pi * 2
				local e = math.rad(-12 + q[2] / NE * 102)
				local d = Vector(math.cos(a) * math.cos(e), math.sin(a) * math.cos(e), math.sin(e))
				local r, g, b = couleurCiel(d)
				mesh.Position(directionMonde(d) * P.CIEL_R); mesh.Color(r, g, b, 255); mesh.AdvanceVertex()
			end
		end
	end
	mesh.End()
	G.ciel = m
	G.soleil = directionMonde(SOLEIL):GetNormalized()
	-- nuages : amas de bouffées, plus denses vers le haut du ciel ; aucun devant le disque du soleil
	alea.v = 0.2718
	G.nuages = {}
	for c = 1, 46 do
		local az = alea.n() * 360
		local el = 7 + alea.n() ^ 1.4 * 48
		local d0 = Vector(math.cos(math.rad(az)) * math.cos(math.rad(el)), math.sin(math.rad(az)) * math.cos(math.rad(el)), math.sin(math.rad(el)))
		if d0:Dot(SOLEIL) < 0.985 then
			local cs = d0:Dot(SOLEIL)
			local n = 5 + math.floor(alea.n() * 7)
			local largeur = 9 + alea.n() * 14
			for k = 1, n do
				local daz, del = (alea.n() - 0.5) * largeur, (alea.n() - 0.3) * largeur * 0.3
				local haut = math.Clamp(del / (largeur * 0.2) * 0.5 + 0.5, 0, 1)
				G.nuages[#G.nuages + 1] = { az = az + daz, el = math.max(el + del, 3), t = (55 + alea.n() * 60) * (1 + el / 70),
					haut = haut,
					a = 150 + alea.n() * 80, mat = 1 + math.floor(alea.n() * 3) % 3, rot = alea.n() * 360 }
			end
		end
	end
	G.nuagesM = { {}, {}, {} }
	for _, n in ipairs(G.nuages) do local l = G.nuagesM[n.mat]; l[#l + 1] = n end
end
-- v32 : 3 plans dans le ciel, du plus loin au plus près,
-- collines pâles puis forêts bleutées, mêlés à la couleur du ciel (perspective aérienne) ; le soleil se pose derrière la crête du fond.
local LOINTAINS = {
	{ base = 6.4, amp = 7.5, f = 1.6, bosse = 0.3, nb = 48, voile = 0.46, alpha = 0.62, teinte = { 150, 150, 196 }, g = 1.7, sol = 4.4 },
	{ base = 4.6, amp = 3.8, f = 3.2, bosse = 0.8, nb = 170, voile = 0.32, alpha = 0.78, teinte = { 104, 116, 168 }, g = 4.2, sol = 2.9 },
	{ base = 3.2, amp = 2.4, f = 6, bosse = 1.1, nb = 300, voile = 0.2, alpha = 0.9, teinte = { 74, 96, 124 }, g = 8.9, sol = 1.9 },
}
local function dirEl(a, e) local ce = math.cos(math.rad(e)) return Vector(math.cos(a) * ce, math.sin(a) * ce, math.sin(math.rad(e))) end
local function construireLointains()
	G.lointains = {}
	local SEG, saz = 1440, math.rad(P.SOLEIL_AZ)
	for _, L in ipairs(LOINTAINS) do
		local EL = {}
		for i = 0, SEG do
			local a = i / SEG * math.pi * 2
			local h = L.base + L.amp * (fbm(math.cos(a) * L.f + L.g, math.sin(a) * L.f + L.g * 2) - 0.35)   -- crêtes douces (bouclées)
			local u = a / (math.pi * 2) * L.nb + 1.6 * bruit(math.cos(a) * L.nb * 0.04 + 9, math.sin(a) * L.nb * 0.04)
			local c = u % 1
			local hc = 0.45 + 0.9 * hache(math.floor(u), L.g)          -- v32 : cimes de tailles inégales (pas de clôture)
			h = h + L.bosse * hc * math.sqrt(math.max(0, 1 - (2 * c - 1) ^ 2))                                 -- cimes rondes
			local da = math.abs((a - saz + math.pi) % (math.pi * 2) - math.pi)
			local w = math.exp(-(da / 0.3) ^ 2)                    -- autour du soleil : crête calme, le disque s'y pose
			h = h + (L.sol - h) * w
			EL[i] = math.max(h, 0.6)
			if i % 120 == 0 then souffle() end
		end
		local HA, BA = {}, {}                   -- sommets haut et bas précalculés (la construction cède la main ici, pas dans le maillage)
		for i = 0, SEG do
			local a = i / SEG * math.pi * 2
			for k, e in ipairs({ EL[i], -4 }) do
				local haut = k == 1
				local cr, cg, cb = couleurCiel(dirEl(a, haut and e or 0.5))
				local v = haut and L.voile or (L.voile + (1 - L.voile) * 0.55)   -- pied dans la brume
				local p = directionMonde(dirEl(a, e)) * (P.CIEL_R * 0.9)
				local s = { p.x, p.y, p.z, L.teinte[1] + (cr - L.teinte[1]) * v, L.teinte[2] + (cg - L.teinte[2]) * v, L.teinte[3] + (cb - L.teinte[3]) * v }
				if haut then HA[i] = s else BA[i] = s end
			end
			if i % 60 == 0 then souffle() end
		end
		local m = Mesh()
		local al = L.alpha * 255
		mesh.Begin(m, MATERIAL_QUADS, SEG)
		for i = 0, SEG - 1 do
			for _, s in ipairs({ BA[i], BA[i + 1], HA[i + 1], HA[i] }) do
				sommet(s[1], s[2], s[3]); mesh.Color(s[4], s[5], s[6], al); mesh.AdvanceVertex()
			end
		end
		mesh.End()
		G.lointains[#G.lointains + 1] = m
	end
end
local function construireSol()
	local m = Mesh()
	local pas, R = P.SOL_PAS, P.BX
	local quads = {}
	for x = -R, R - pas, pas do
		for y = -R, R - pas, pas do
			local cx, cy = x + pas / 2, y + pas / 2
			if cx * cx + cy * cy <= (R - 10) ^ 2 then quads[#quads + 1] = { x, y } end
		end
	end
	mesh.Begin(m, MATERIAL_QUADS, #quads)
	for _, q in ipairs(quads) do
		local x, y = q[1], q[2]
		for _, c in ipairs({ { x, y }, { x + pas, y }, { x + pas, y + pas }, { x, y + pas } }) do
			local r, g, b = couleurSol(c[1], c[2])
			mesh.Position(versMonde(c[1], c[2], P.SOL_Z)); mesh.Color(r, g, b, 255); mesh.AdvanceVertex()
		end
	end
	mesh.End()
	G.sol = m
end
local function creuxLisiere(a)
	local k = 1
	for _, cr in ipairs(P.CREUX) do
		local da = math.abs((a - math.rad(cr) + math.pi) % (math.pi * 2) - math.pi)
		local s = cr == P.SOLEIL_AZ
		k = k * (1 - (s and 0.82 or 0.72) * math.exp(-(da / (s and 0.26 or 0.2)) ^ 2))
	end
	return k
end
local function construireAnneau(R, nCimes, hMin, hMax, voile, graine)
	alea.v = graine
	local cimes = {}
	for i = 1, nCimes do
		local w = 70 + alea.n() * 90
		cimes[i] = { a = (i + alea.n() * 0.8) / nCimes * math.pi * 2, w = w, h = hMin + alea.n() * (hMax - hMin) }
	end
	for i = 1, nCimes do                      -- petites bosses sur chaque cime : un feuillage, pas une bulle
		local c = cimes[i]
		for _ = 1, 3 do
			local w = 22 + alea.n() * 26
			local da = (alea.n() - 0.5) * 1.5 * c.w / R
			local d = math.abs(da) * R
			cimes[#cimes + 1] = { a = c.a + da, w = w, h = c.h - c.w + math.sqrt(math.max(c.w * c.w - d * d, 0)) + w * (0.3 + alea.n() * 0.5) }
		end
	end
	local SEG = 900
	local hb = hMin * 0.72                    -- haut du sous-bois : jamais de ciel entre deux cimes
	local function hauteur(a)
		local h = hb
		for _, c in ipairs(cimes) do
			local da = math.abs(a - c.a); if da > math.pi then da = math.pi * 2 - da end
			local d = da * R
			if d < c.w then h = math.max(h, c.h - c.w + math.sqrt(c.w * c.w - d * d)) end
		end
		return h
	end
	local HT, KC = {}, {}
	for i = 0, SEG do
		HT[i], KC[i] = hauteur(i / SEG * math.pi * 2), creuxLisiere(i / SEG * math.pi * 2)
		if i % 60 == 0 then souffle() end
	end
	local m = Mesh()
	mesh.Begin(m, MATERIAL_QUADS, SEG * 2)
	local s2 = Vector(SOLEIL.x, SOLEIL.y, 0):GetNormalized()
	for i = 0, SEG - 1 do
		local a0, a1 = i / SEG * math.pi * 2, (i + 1) / SEG * math.pi * 2
		local h0, h1 = HT[i], HT[i + 1]
		local k0, k1 = KC[i], KC[i + 1]
		local f = (Vector(math.cos(a0), math.sin(a0), 0):Dot(s2) + 1) / 2     -- 1 = côté soleil (contre-jour, sombre)
		local hr, hg, hbb = 26 + (22 - 26) * f, 44 + (34 - 44) * f, 26 + (28 - 26) * f            -- sous-bois
		local br, bg, bb = 44 + (30 - 44) * f, 92 + (52 - 92) * f, 40 + (36 - 40) * f             -- bas des cimes
		local tr, tg, tb = 104 + (58 - 104) * f, 150 + (72 - 150) * f, 58 + (44 - 58) * f        -- haut des cimes
		local v = 0.8 + 0.4 * bruit(a0 * R / 140, graine * 10)                                      -- arbres plus ou moins clairs
		tr, tg, tb, br, bg, bb = tr * v, tg * v, tb * v, br * (0.85 + 0.3 * (v - 0.8)), bg * (0.85 + 0.3 * (v - 0.8)), bb
		local cr, cg, cb = couleurCiel(Vector(math.cos(a0), math.sin(a0), 0.04))
		hr, hg, hbb = hr + (cr - hr) * voile * 0.6, hg + (cg - hg) * voile * 0.6, hbb + (cb - hbb) * voile * 0.6
		br, bg, bb = br + (cr - br) * voile, bg + (cg - bg) * voile, bb + (cb - bb) * voile
		tr, tg, tb = tr + (cr - tr) * voile, tg + (cg - tg) * voile, tb + (cb - tb) * voile
		local c0, s0, c1, s1 = math.cos(a0) * R, math.sin(a0) * R, math.cos(a1) * R, math.sin(a1) * R
		for _, p in ipairs({ { c0, s0, -6, hr, hg, hbb, k0 }, { c1, s1, -6, hr, hg, hbb, k1 }, { c1, s1, hb, br, bg, bb, k1 }, { c0, s0, hb, br, bg, bb, k0 } }) do
			mesh.Position(versMonde(p[1], p[2], p[3] * p[7])); mesh.Color(p[4], p[5], p[6], 255); mesh.AdvanceVertex()
		end
		-- haut des cimes : plus clair au sommet d'un arbre, plus sombre dans le creux entre deux (on lit chaque arbre) ;
		-- côté soleil, un liseré d'or sur le bord (contre-jour)
		local function haut(h)
			local k = 0.55 + 0.6 * math.Clamp((h - hb) / (hMax + 40 - hb), 0, 1)
			local o = f * f * math.Clamp((h - hb) / (hMax - hb), 0, 1) * 0.55
			return math.min(tr * k + (230 - tr * k) * o, 255), math.min(tg * k + (178 - tg * k) * o, 255), math.min(tb * k + (96 - tb * k) * o, 255)
		end
		local t0r, t0g, t0b = haut(h0)
		local t1r, t1g, t1b = haut(h1)
		for _, p in ipairs({ { c0, s0, hb, br, bg, bb, k0 }, { c1, s1, hb, br, bg, bb, k1 }, { c1, s1, h1, t1r, t1g, t1b, k1 }, { c0, s0, h0, t0r, t0g, t0b, k0 } }) do
			mesh.Position(versMonde(p[1], p[2], p[3] * p[7])); mesh.Color(p[4], p[5], p[6], 255); mesh.AdvanceVertex()
		end
	end
	mesh.End()
	return m
end
-- Lisière : 3 rangs serrés d'arbres
-- dont les cimes se chevauchent ; chaque cime = 8 à 11 boules aux bords cassés, réparties en masse large et basse ;
-- tronc évasé au pied avec 2 branches, caché aux deux tiers ; rangs du fond plus sombres et plus bleus (air).
local function maillagesDe(tris)                -- lots de 9 000 triangles au plus (limite de 32 768 indices)
	local res, k = {}, 1
	while k <= #tris do
		local n = math.min(3000, #tris - k + 1)   -- v32 : lots plus petits, la construction cède la main entre deux
		local m = Mesh()
		mesh.Begin(m, MATERIAL_TRIANGLES, n)
		for q = k, k + n - 1 do
			local tr = tris[q]
			for v = 1, 3 do
				local p, c = tr[v], tr[v + 3]
				mesh.Position(versMonde(p.x, p.y, p.z)); mesh.Color(math.min(c[1], 255), math.min(c[2], 255), math.min(c[3], 255), 255); mesh.AdvanceVertex()
			end
		end
		mesh.End()
		res[#res + 1] = m
		k = k + n
		souffle()
	end
	return res
end
-- Cartes de branches peintes (passe J, 27/11 04 h 05 : textures des addons du catalogue EVO seulement).
-- La texture est verte (~70,130,40) : la couleur de sommet x $color 2 la ramène aux valeurs de la cime (ombre, lumière, or).
local function matBranches(nom, couleur, tex)
	return CreateMaterial(nom, "UnlitGeneric", { ["$basetexture"] = tex or "td/dbz/props/cmn/T_Tree_CamphorA_01_D",
		["$alphatest"] = "1", ["$alphatestreference"] = "0.45", ["$nocull"] = "1", ["$color"] = couleur })
end
-- teinte par $color : la couleur de sommet est ignorée sur ces cartes alphatest (v16 à v19, hypothèse)
local BRANCHES = matBranches("sumii_p1_branches_froid_v2", "[0.54 0.58 0.70]")    -- ombre de contre-jour, un peu bleutée
local BRANCHES_FOND = matBranches("sumii_p1_branches_fond_v1", "[0.34 0.38 0.50]")    -- rang du fond : sombre, air bleuté
local BRANCHES_CHAUD = matBranches("sumii_p1_branches_chaud_v2", "[0.66 0.50 0.40]")  -- cimes côté couchant
-- notes de couleur : touffes jaunes, orangées, rousses parmi les verts ;
-- pas de rouge vif (réservé aux yeux et au ciel des souvenirs, fiche DA)
-- v23 : $color multiplie la texture ; sur une feuille verte, l'orange donne de l'olive.
-- Les notes de couleur partent donc de feuilles grises neutres (particle/leaf/leaf_nocolor, addon #10).
local function matFeuilles(nom, couleur)
	return CreateMaterial(nom, "UnlitGeneric", { ["$basetexture"] = "particle/leaf/leaf_nocolor",
		["$alphatest"] = "1", ["$alphatestreference"] = "0.4", ["$nocull"] = "1", ["$color"] = couleur })
end
local ACCENTS = { matFeuilles("sumii_p1_feuilles_jaune_v1", "[0.92 0.74 0.28]"), matFeuilles("sumii_p1_feuilles_orange_v2", "[0.86 0.58 0.34]"),
	matFeuilles("sumii_p1_feuilles_rose_v1", "[0.98 0.66 0.76]") }
-- la texture du camphrier porte une tige noire qui part du coin bas-droit : on ne prend que le haut-gauche (feuilles)
local UV_BRANCHE = { { 0.06, 0.72 }, { 0.78, 0.72 }, { 0.78, 0 }, { 0.06, 0 } }
local UV_PLEIN = { { 0, 1 }, { 1, 1 }, { 1, 0 }, { 0, 0 } }
local TEINTES_CIME = { { 224, 190, 72 }, { 212, 130, 68 }, { 232, 142, 152 } }   -- jaune, orangé adouci, rose cerisier (couleurs de sommet des boules)
local BLANC4 = { { 255, 255, 255 }, { 255, 255, 255 }, { 255, 255, 255 }, { 255, 255, 255 } }
local function hache(x) x = math.sin(x) * 43758.5453 return x - math.floor(x) end   -- tirage fixe : ne décale pas alea (la lisière ne bouge pas)
local TEX_BRANCHE = { 70, 130, 40 }
local function teinteCarte(c)
	local K = 1 / 0.62                           -- $color d'UnlitGeneric ne dépasse pas 1 : cible x 0,62 = cimes de contre-jour sous le plafond
	local r, g, b = c[1] * 255 / (TEX_BRANCHE[1] * K), c[2] * 255 / (TEX_BRANCHE[2] * K), c[3] * 255 / (TEX_BRANCHE[3] * K)
	local m = (r + g + b) / 3                    -- 25 % vers le gris : moins saturé
	return { math.min(255, r + (m - r) * 0.25), math.min(255, g + (m - g) * 0.25), math.min(255, b + (m - b) * 0.25) }
end
local function maillagesCartes(cartes)        -- 2 triangles par carte, lots de 4 000 cartes
	local res, k = {}, 1
	while k <= #cartes do
		local n = math.min(1500, #cartes - k + 1)
		local m = Mesh()
		mesh.Begin(m, MATERIAL_TRIANGLES, n * 2)
		for q = k, k + n - 1 do
			local c = cartes[q]
			for _, i in ipairs({ 1, 2, 3, 1, 3, 4 }) do
				local p, uv, col = c.p[i], c.uv[i], c.c[i]
				mesh.Position(versMonde(p.x, p.y, p.z)); mesh.TexCoord(0, uv[1], uv[2]); mesh.Color(col[1], col[2], col[3], 255); mesh.AdvanceVertex()
			end
		end
		mesh.End()
		res[#res + 1] = m
		k = k + n
		souffle()
	end
	return res
end
-- Sphère cabossée d'une cime (v26) : 8 méridiens x 5 parallèles ; couleur par sommet = haut/bas (ciel), soleil (liseré chaud),
-- ombre interne (le bas de la cime plus sombre). bas, mil, hautc = couleurs déjà réglées par l'arbre (contre-jour, air, accent).
-- v29 : petites feuilles collées à la surface des sphères,
-- serrées sur le pourtour (bord en festons), une feuille de l'atlas particle/leaf/leaf_nocolor (addon #10, gris 0,64) par carte.
-- La teinte passe par $color (couleur de sommet ignorée sur ces cartes) : couleurs quantifiées, un matériau par teinte.
local GRIS_FEUILLE = 0.64 * 255
local MATS_F = {}
local function matFeuille(col)
	local q = function(x) return math.floor(math.min(x, GRIS_FEUILLE) / 18 + 0.5) * 18 end
	local r, g, b = q(col[1]), q(col[2]), q(col[3])
	local cle = r .. "_" .. g .. "_" .. b
	if not MATS_F[cle] then
		MATS_F[cle] = CreateMaterial("sumii_p1_f_" .. cle .. "_v1", "UnlitGeneric", { ["$basetexture"] = "particle/leaf/leaf_nocolor",
			["$alphatest"] = "1", ["$alphatestreference"] = "0.35", ["$nocull"] = "1",
			["$color"] = string.format("[%.3f %.3f %.3f]", r / GRIS_FEUILLE, g / GRIS_FEUILLE, b / GRIS_FEUILLE) })
	end
	return cle
end
local CELLULES = { { 0, 0.25 }, { 0.25, 0.25 }, { 0.5, 0.25 }, { 0.75, 0.25 } }   -- v30 : un seul rang de l'atlas, feuilles de même sens
local function carteFeuille(dest, p, normale, taille, ang, col, graine)
	local up = Vector(0, 0, 1)
	local U0 = normale:Cross(up); if U0:LengthSqr() < 0.01 then U0 = Vector(1, 0, 0) end
	U0:Normalize()
	local V0 = U0:Cross(normale)
	local U = U0 * math.cos(ang) + V0 * math.sin(ang)
	local V = U0 * -math.sin(ang) + V0 * math.cos(ang)
	local ce = CELLULES[1 + math.floor(hache(graine) * #CELLULES)]
	local u0, v0 = ce[1], ce[2]
	local cle = matFeuille(col)
	dest[cle] = dest[cle] or {}
	local l = dest[cle]
	l[#l + 1] = { p = { p - U * taille - V * taille, p + U * taille - V * taille, p + U * taille + V * taille, p - U * taille + V * taille },
		uv = { { u0, v0 + 0.25 }, { u0 + 0.25, v0 + 0.25 }, { u0 + 0.25, v0 }, { u0, v0 } }, c = BLANC4 }
end
-- v29 : quelques feuilles qui tombent autour des 3 arbres de cadrage (12 chacun), chute lente et balancée, en boucle
local VOL_MATS = { "vert", "jaune", "rose" }
local VOL_COUL = { vert = { 120, 150, 70 }, jaune = { 160, 140, 60 }, rose = { 163, 110, 120 } }
local function dessinFeuillesVol()
	local t = CurTime()
	for qi, nom in ipairs(VOL_MATS) do
		render.SetMaterial(MATS_F[matFeuille(VOL_COUL[nom])])
		local nq = qi == 1 and 2 or 1                -- v30 : peu de feuilles (12 en tout)
		mesh.Begin(MATERIAL_QUADS, nq * #P.OMBRES)
		for ti, o in ipairs(P.OMBRES) do
			for j = 1, nq do
				local g = ti * 31.7 + j * 7.3 + qi * 3.1
				local dur = 9 + hache(g) * 6
				local ph = (t / dur + hache(g + 1)) % 1
				local ang = hache(g + 2) * 6.28
				local rad = 20 + hache(g + 3) * 130          -- sous la cime
				local x = o[1] + math.cos(ang) * rad + ph * 150 + math.sin(t * 0.9 + g) * 12   -- dérive avec le vent
				local y = o[2] + math.sin(ang) * rad + math.cos(t * 0.7 + g) * 12
				local z = 8 + (1 - ph) * (230 + hache(g + 4) * 120)
				local A, o = G.ax, G.o
				x, y, z = x - P.TETE.x, y - P.TETE.y, z - P.TETE.z
				local cx, cy, cz = o[1] + A[1] * x + A[4] * y + A[7] * z, o[2] + A[2] * x + A[5] * y + A[8] * z, o[3] + A[3] * x + A[6] * y + A[9] * z
				local a = t * (1.5 + hache(g + 5)) + g
				local Ux, Uy = math.cos(a) * 7, math.sin(a) * 7
				local Vx, Vy, Vz = -math.sin(a) * 2.8, math.cos(a) * 2.8, 6.3
				local u0 = (j % 4) * 0.25
				sommet(cx - Ux - Vx, cy - Uy - Vy, cz - Vz, u0, 0.25); mesh.AdvanceVertex()
				sommet(cx + Ux - Vx, cy + Uy - Vy, cz - Vz, u0 + 0.25, 0.25); mesh.AdvanceVertex()
				sommet(cx + Ux + Vx, cy + Uy + Vy, cz + Vz, u0 + 0.25, 0); mesh.AdvanceVertex()
				sommet(cx - Ux + Vx, cy - Uy + Vy, cz + Vz, u0, 0); mesh.AdvanceVertex()
			end
		end
		mesh.End()
	end
end
local SOL_N = SOLEIL:GetNormalized()
local function sphereCime(tri, c, r, sz, graine, bas, mil, hautc, zBas, H, feuilles, dens)
	local M, P = 11, 7                         -- v27 : plus fin (facettes en bandes visibles en v26)
	local pts, cols = {}, {}
	for a = 0, P do
		pts[a], cols[a] = {}, {}
		local th = a / P * math.pi                -- 0 = haut
		for b = 0, M - 1 do
			local ph = b / M * math.pi * 2
			local n = Vector(math.sin(th) * math.cos(ph), math.sin(th) * math.sin(ph), math.cos(th))
			local g1, g2 = hache(graine) * 6.28, hache(graine + 1.7) * 6.28   -- bosses douces (bruit par sommet = facettes, pôles ouverts)
			local rv = r * (1 + 0.1 * math.sin(3 * ph + g1) * math.sin(th) + 0.07 * math.sin(2 * th + g2))
			local p = c + Vector(n.x * rv, n.y * rv, n.z * rv * sz)
			local s = n.z
			local col = s > 0 and { hautc[1] * 1.18, hautc[2] * 1.18, hautc[3] * 1.12 } or bas
			local m = math.abs(s)
			local base = { mil[1] + (col[1] - mil[1]) * m, mil[2] + (col[2] - mil[2]) * m, mil[3] + (col[3] - mil[3]) * m }
			local d = math.max(n:Dot(SOL_N), 0) ^ 1.5 * (0.45 + 0.55 * math.max(s, 0)) * 0.6   -- liseré chaud côté soleil
			local ao = 0.56 + 0.44 * math.min(1, math.max(0, (p.z - zBas) / (H * 0.5)))        -- ombre interne : bas de la cime plus sombre
			pts[a][b] = p
			cols[a][b] = { (base[1] + (240 - base[1]) * d) * ao, (base[2] + (182 - base[2]) * d) * ao, (base[3] + (104 - base[3]) * d) * ao }
		end
	end
	for a = 0, P - 1 do
		for b = 0, M - 1 do
			local b2 = (b + 1) % M
			if a > 0 then tri(pts[a][b], pts[a + 1][b], pts[a][b2], cols[a][b], cols[a + 1][b], cols[a][b2]) end
			if a < P - 1 then tri(pts[a][b2], pts[a + 1][b], pts[a + 1][b2], cols[a][b2], cols[a + 1][b], cols[a + 1][b2]) end
		end
	end
	if not feuilles then return end
	-- v30 : candidats seulement ; poserFeuilles les range à l'échelle de l'arbre
	local si = #feuilles.sph + 1
	feuilles.sph[si] = { c = c, r = r, sz = sz }
	local vue = Vector(-c.x, -c.y, 60 - c.z):GetNormalized()
	for a = 1, P - 1 do
		for b = 0, M - 1 do
			for j = 1, (dens >= 1 and 4 or 2) do
			local g = graine + a * 17.3 + b * 5.1 + j * 29.7
			local th = (a + (hache(g) - 0.5) * 0.8) / P * math.pi
			local ph = (b + hache(g + 1.1)) / M * math.pi * 2
			local n = Vector(math.sin(th) * math.cos(ph), math.sin(th) * math.sin(ph), math.cos(th))
			do                                                   -- v33 : tous les côtés (plus de face cachée nue)
				local garde = n.z > 0.3 and 1 or (n.z < -0.45 and 0.6 or 0.85)   -- dessus plein, dessous plus clair-semé
				if hache(g + 7.7) < garde * math.min(dens, 1) then
					local col = cols[a][b]
					local k = 0.88 + hache(g + 2.3) * 0.24
					local d = math.max(n:Dot(SOL_N), 0)
					local lum = (d > 0.4 and hache(g + 3.7) < 0.6) and 0.6 or 0        -- touches de lumière côté soleil
					local omb = (n.z < -0.15) and 0.84 or 1                            -- ombre douce sous les touffes (v33 : jamais noire)
					local cf = { (col[1] * k + (235 - col[1] * k) * lum) * omb, (col[2] * k + (210 - col[2] * k) * lum) * omb, (col[3] * k + (120 - col[3] * k) * lum) * omb }
					for q = 1, 3 do cf[q] = math.max(cf[q], mil[q] * 0.82) end     -- plancher : la feuille reste plus claire que le creux
					feuilles.cand[#feuilles.cand + 1] = { p = c + Vector(n.x, n.y, n.z * sz) * r * 1.02, n = n, g = g, si = si, col = cf }
				end
			end
			end
		end
	end
end
-- Range les feuilles d'un arbre : rien à l'intérieur d'une autre touffe ni dans le vide, face vers l'extérieur un peu vers le bas
-- (gravité), même sens de pousse, même taille sur tout l'arbre.
local function poserFeuilles(ft, dest, taille, centreArbre)
	local vue = Vector(-centreArbre.x, -centreArbre.y, 60 - centreArbre.z):GetNormalized()
	for fi, f in ipairs(ft.cand) do
		if fi % 150 == 0 then souffle() end
		local cachee = false
		local px, py, pz = f.p.x, f.p.y, f.p.z
		for sj, s in ipairs(ft.sph) do          -- v32 : en nombres (sans Vector), la construction allait 4 fois plus lentement
			if sj ~= f.si then
				local c = s.c
				local dx, dy, dz = px - c.x, py - c.y, (pz - c.z) / s.sz
				local rr = s.r * 0.97
				if dx * dx + dy * dy + dz * dz < rr * rr then cachee = true break end
			end
		end
		if not cachee then
			local nrm = (f.n + Vector(0, 0, -0.22)):GetNormalized()   -- v33 : face vers l'extérieur de tous les côtés, un peu vers le bas
			carteFeuille(dest, f.p, nrm, taille, (hache(f.g + 5.3) - 0.5) * 0.3, f.col, f.g + 6.1)
		end
	end
end
local function construireArbres(graine)
	alea.v = graine
	local tris, cartes, chaudes, fonds, accents = {}, {}, {}, {}, { {}, {}, {} }
	local function tri(p1, p2, p3, c1, c2, c3) tris[#tris + 1] = { p1, p2, p3, c1, c2, c3 } end
	local feuillesS = {}                         -- v29 : cartes de feuilles par teinte (clé = matériau)
	local trisS = {}                             -- sphères des cimes : maillage à part, dessiné avec élimination des faces arrière
	local function triS(p1, p2, p3, c1, c2, c3) trisS[#trisS + 1] = { p1, p2, p3, c1, c2, c3 } end
	local s2 = Vector(SOLEIL.x, SOLEIL.y, 0):GetNormalized()
	local RANGS = { { r = 2150, n = 92, air = 0.24, h = 1.05, v = 0.78 }, { r = 2030, n = 78, air = 0.1, h = 0.95, v = 0.9 }, { r = 1910, n = 58, air = 0.0, h = 0.85, v = 1 } }
	for _, rg in ipairs(RANGS) do                -- du fond vers l'avant : l'avant se dessine par-dessus
		local cr, cg, cb = P.HORIZON[1], P.HORIZON[2], P.HORIZON[3]
		for i = 1, rg.n do
			souffle()
			local trou = rg.v == 1 and alea.n() < 0.14
			local a = (i + (alea.n() - 0.5) * 0.9) / rg.n * math.pi * 2
			local R = rg.r + (alea.n() - 0.5) * 210                  -- rangs cassés : pas d'alignement
			local dir = Vector(math.cos(a), math.sin(a), 0)
			local cote = Vector(-dir.y, dir.x, 0)
			local base = dir * R
			local f = (dir:Dot(s2) + 1) / 2                     -- 1 = contre-jour (côté couchant)
			local accentA = alea.n() < 0.26 and (1 + math.floor(alea.n() * 3)) or nil   -- tirages gardés (la lisière ne bouge pas)
			accentA = (rg.v >= 0.8 and (i + (rg.v < 1 and 2 or 0)) % 4 == 0) and (1 + math.floor(i / 4) % 3) or nil   -- v30 : une cime sur quatre, en alternance
			local grandA = alea.n() < 0.12                         -- quelques grands arbres qui dépassent
			local H = (170 + alea.n() ^ 1.3 * 560) * rg.h * (grandA and 1.45 or 1)
			H = H * creuxLisiere(a)                  -- v32 : trouées plus larges et plus profondes, les lointains passent
			if trou then H = 0.5 end                              -- trouée : on voit le rang sombre derrière
			local W = H * (0.42 + alea.n() * 0.22)
			local function air(c) return { c[1] + (cr - c[1]) * rg.air, c[2] + (cg - c[2]) * rg.air, c[3] + (cb - c[3]) * rg.air } end
			-- tronc évasé + 2 branches
			local brun = { 95 - 30 * f, 65 - 20 * f, 40 - 12 * f }   -- sans air, brun chaud (critique v25 : troncs noirs en allumettes)
			local tw = (8 + alea.n() * 6) * 1.4
			local up = Vector(0, 0, 1)
			local z1 = H * 0.5
			tri(base - cote * tw * 1.8 - up * 4, base + cote * tw * 1.8 - up * 4, base + cote * tw * 0.7 + up * z1, brun, brun, brun)
			tri(base - cote * tw * 1.8 - up * 4, base + cote * tw * 0.7 + up * z1, base - cote * tw * 0.7 + up * z1, brun, brun, brun)
			alea.n(); alea.n(); alea.n(); alea.n()       -- anciens tirages des branches v20, gardés (la lisière ne bouge pas)
			if rg.v >= 0.9 and not trou then          -- v26 : 2 ou 3 branches brunes qui montent du tronc dans la cime
				local nbr = 2 + math.floor(hache(i * 7.13 + rg.r) * 2)
				for j = 1, nbr do
					local s = (j % 2 == 0) and 1 or -1
					local p0 = base + up * (z1 * (0.75 + 0.15 * hache(i * 3.1 + j)))
					local p1 = base + cote * s * W * (0.22 + 0.2 * hache(i * 5.7 + j * 2.3)) + up * (H * (0.66 + 0.12 * hache(i * 1.9 + j)))
					local e0, e1 = tw * 0.45, tw * 0.18
					tri(p0 - cote * e0, p0 + cote * e0, p1 + cote * e1, brun, brun, brun)
					tri(p0 - cote * e0, p1 + cote * e1, p1 - cote * e1, brun, brun, brun)
				end
			end
			-- cime : boules aux bords cassés
			local nb = 8 + math.floor(alea.n() * 4)
			local feuillesT = { sph = {}, cand = {} }   -- v30 : feuilles de cet arbre, rangées après la cime
			for k = 1, nb do
				souffle()
				local ox = (alea.n() - 0.5) * W * 1.4
				local oz = H * (0.48 + alea.n() * 0.4) - math.abs(ox) / W * H * 0.15
				local rr = W * (0.26 + alea.n() * 0.22)
				local centre = base + cote * ox + up * oz - dir * (k * 1.5)
				local v = (0.72 + alea.n() * 0.45) * rg.v
				local bas = air({ (30 - 10 * f) * v, (60 - 24 * f) * v, (32 - 6 * f) * v })
				local mil = air({ (62 - 24 * f) * v, (108 - 44 * f) * v, (48 - 12 * f) * v })
				local hautc = air({ (112 - 30 * f) * v, (160 - 66 * f) * v, (66 - 14 * f) * v })
				if accentA and rg.v >= 0.8 then         -- cime entière teintée (jaune, orangé adouci, rose cerisier), plus sombre en contre-jour
					local ac = TEINTES_CIME[accentA]
					local function tz(c, k) return { c[1] + (ac[1] * k * (1 - 0.35 * f) * v - c[1]) * 0.7, c[2] + (ac[2] * k * (1 - 0.35 * f) * v - c[2]) * 0.7, c[3] + (ac[3] * k * (1 - 0.35 * f) * v - c[3]) * 0.7 } end
					bas, mil, hautc = tz(bas, 0.45), tz(mil, 0.72), tz(hautc, 1)
				end
				local N, ray = 12, {}
				for q = 0, N - 1 do ray[q] = rr * (0.8 + alea.n() * 0.38) end
				if rg.v >= 0.9 then                       -- v26 : sphère cabossée en 3D
					sphereCime(triS, centre, rr * (0.9 + hache(i * 2.7 + k * 9.1) * 0.25), 0.88 + hache(i * 4.3 + k * 1.7) * 0.34,
						i * 13.7 + k * 3.1 + rg.r, bas, mil, hautc, base.z + H * 0.45, H, feuillesT, rg.v >= 1 and 1 or 0.45)
				end
				for q = 0, (rg.v >= 0.9) and -1 or (N - 1) do   -- disque plat seulement pour le rang du fond
					local b0, b1 = q / N * math.pi * 2, (q + 1) / N * math.pi * 2
					local r0, r1 = ray[q], ray[(q + 1) % N]
					local q0 = centre + cote * math.cos(b0) * r0 + up * math.sin(b0) * r0 * 0.82
					local q1 = centre + cote * math.cos(b1) * r1 + up * math.sin(b1) * r1 * 0.82
					local function c(b)
						local s = math.sin(b)
						local col = s > 0 and hautc or bas
						local o = f * math.max(s, 0) ^ 2 * 0.55         -- liseré d'or en haut, côté couchant
						local m = math.abs(s)
						return { mil[1] + (col[1] - mil[1]) * m + (235 - mil[1]) * o, mil[2] + (col[2] - mil[2]) * m + (180 - mil[2]) * o,
							mil[3] + (col[3] - mil[3]) * m + (100 - mil[3]) * o }
					end
					tri(centre, q0, q1, mil, c(b0), c(b1))
				end
				local ang = alea.n() * math.pi * 2
				local U = cote * math.cos(ang) + up * math.sin(ang)
				local V = cote * -math.sin(ang) + up * math.cos(ang)
				local h = rr * 0.8
				local cc = centre + dir * 6 + up * rr * 0.4      -- derrière la boule : la boule ombrée reste la masse, les feuilles font la frange
				local o = f ^ 1.5 * 0.7                    -- liseré orange du couchant, fort côté soleil
				local haut = teinteCarte({ hautc[1] + (250 - hautc[1]) * o, hautc[2] + (150 - hautc[2]) * o, hautc[3] + (70 - hautc[3]) * o })
				local bs, mi = teinteCarte(bas), teinteCarte(mil)
				local pts = { cc - U * h - V * h, cc + U * h - V * h, cc + U * h + V * h, cc - U * h + V * h }
				local function col(p) return (p - centre).z > 0 and haut or ((p - centre).z > -h * 0.3 and mi or bs) end
				local dest = f > 0.62 and chaudes or cartes
				if rg.v < 0.8 then dest = fonds elseif accentA then alea.n() end   -- tirage gardé (v22) : la lisière ne bouge pas
				dest[#dest + 1] = { p = pts, uv = UV_BRANCHE, c = { col(pts[1]), col(pts[2]), col(pts[3]), col(pts[4]) } }
				if accentA and rg.v >= 0.8 then          -- 3 cartes de feuilles colorées sur le haut de chaque boule de l'arbre
					local acc = accents[accentA]
					for j = 1, 3 do
						local h1, h2 = hache(i * 12.9898 + k * 78.233 + j * 37.719 + rg.r), hache(i * 39.3468 + k * 11.135 + j * 83.155 + rg.r)
						local a2 = h1 * math.pi * 2
						local U2 = cote * math.cos(a2) + up * math.sin(a2)
						local V2 = cote * -math.sin(a2) + up * math.cos(a2)
						local c2 = centre - dir * (8 + j * 2) + cote * (h2 - 0.5) * rr * 0.9 + up * rr * (0.15 + h1 * 0.4)
						local h3 = rr * (0.7 + h2 * 0.3)
						acc[#acc + 1] = { p = { c2 - U2 * h3 - V2 * h3, c2 + U2 * h3 - V2 * h3, c2 + U2 * h3 + V2 * h3, c2 - U2 * h3 + V2 * h3 }, uv = UV_PLEIN, c = BLANC4 }
					end
				end
			end
			if #feuillesT.cand > 0 then poserFeuilles(feuillesT, feuillesS, W * (rg.v >= 1 and 0.075 or 0.1), base + up * H * 0.7) end   -- même taille sur l'arbre
		end
	end
	local BUISSONS = { { 222, 290 }, { 232, 340 }, { 214, 360 }, { 152, 300 }, { 143, 350 }, { 160, 380 },
		{ 300, 700 }, { 40, 900 }, { 110, 1200 }, { 260, 1300 }, { 345, 1000 }, { 80, 520 } }   -- (azimut, distance) depuis la pierre d'arrivée
	for i, bu in ipairs(BUISSONS) do
		local a = math.rad(bu[1])
		local c = Vector(math.cos(a) * bu[2], math.sin(a) * bu[2], 0)
		local taille = 26 + alea.n() * 18 + bu[2] / 60
		for q = 1, 5 do
			local ang = alea.n() * math.pi
			local U = Vector(math.cos(ang), math.sin(ang), 0)
			local h = taille * (0.7 + alea.n() * 0.5)
			local cc = c + U * ((alea.n() - 0.5) * taille) + Vector(0, 0, h * 0.75)
			local V = Vector(0, 0, 1)
			local pts = { cc - U * h - V * h, cc + U * h - V * h, cc + U * h + V * h, cc - U * h + V * h }
			local blanc = { 255, 255, 255 }
			local dest = (q == 5 and i % 2 == 0) and accents[3] or cartes   -- une touffe rose sur deux buissons
			if i > 6 then dest[#dest + 1] = { p = pts, uv = dest == cartes and UV_BRANCHE or UV_PLEIN, c = { blanc, blanc, blanc, blanc } } end   -- v24 : buissons de l'arrivée retirés
		end
	end
	local feuillesM, nf = {}, 0
	for cle, l in pairs(feuillesS) do feuillesM[cle] = maillagesCartes(l); nf = nf + #l; souffle() end
	print("[sumii_p1] feuilles : " .. nf .. " cartes, " .. table.Count(feuillesM) .. " teintes")
	return maillagesDe(tris), {}, {}, {}, { {}, {}, {} }, maillagesDe(trisS), feuillesM   -- v25 : boules seules (v12) ; couleur des cimes d'accent en couleur de sommet
end
-- 27/11 : P2 publie SumiiHerbe.zones (devant chaque terrier héros). Les brins de ces zones vont
-- dans de petits maillages à part, que P1 ne dessine plus une fois le terrier fouillé. Le tirage ne change pas.
local function zonesDuBloc(cx, cy)
	local out = {}
	for n, z in pairs(SumiiHerbe and SumiiHerbe.zones or {}) do
		if math.abs(z.x - cx) < P.BLOC / 2 + 110 and math.abs(z.y - cy) < P.BLOC / 2 + 110 then out[n] = z end
	end
	return out
end
local function zoneDe(zones, x, y)
	for n, z in pairs(zones) do
		local dx, dy = x - z.x, y - z.y
		local b, a = dx * z.fx + dy * z.fy + 3, dx * z.rx + dy * z.ry
		if b > -4 and a * a + b * b < z.long * z.long and math.abs(a) < 0.82 * math.max(b, 0) + z.lat then return n end
	end
end
local function maillageBrins(t)
	local m = Mesh()
	mesh.Begin(m, MATERIAL_TRIANGLES, #t / 3)
	for _, v in ipairs(t) do VQ:SetUnpacked(v[1], v[2], v[3]); mesh.Position(VQ); mesh.Color(v[4], v[5], v[6], 255); mesh.AdvanceVertex() end
	mesh.End()
	return m
end
local function construireBloc(cx, cy, n, graine, kw)
	alea.v = graine
	local m = Mesh()
	mesh.Begin(m, MATERIAL_TRIANGLES, n * 3)
	local d = P.BLOC / 2
	local zones, aPart, cible = zonesDuBloc(cx, cy), {}, nil
	local function sommet(x, y, z, r, g, b)
		r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
		if cible then
			local t = aPart[cible] or {}
			aPart[cible] = t
			t[#t + 1] = { x, y, z, r, g, b }
			x, y, z = 0, 0, P.SOL_Z - 3                -- triangle nul sous le sol : le compte du maillage ne change pas
		end
		VQ:SetUnpacked(x, y, z); mesh.Position(VQ); mesh.Color(r, g, b, 255); mesh.AdvanceVertex()
	end
	for _ = 1, n do
		local x, y = cx + (alea.n() * 2 - 1) * d, cy + (alea.n() * 2 - 1) * d
		local r, g, b, l = couleurSol(x, y)
		cible = zoneDe(zones, x, y)
		local fleurs = fbm(x / 260 + 11, y / 260 + 23)      -- les fleurs poussent en taches, comme sur l'image du joueur
		if fleurs > 0.6 and alea.n() < (fleurs - 0.6) * 3.2 then
			-- une fleur : étoile à 6 pointes posée à plat dans l herbe + cœur jaune ; rose ou blanche
			local bx, by = x - cx, y - cy
			local h = 8 + alea.n() * 12
			local rose = alea.n() < 0.55
			local fr, fg, fb = rose and 246 or 252, rose and 150 or 246, rose and 196 or 236
			local s = 0.9 + alea.n() * 0.8
			local a = alea.n() * math.pi
			local ca, sa = math.cos(a) * s, math.sin(a) * s
			local z = P.SOL_Z + h
			local function pt(ang, rr, dz) return bx + math.cos(a + ang) * rr, by + math.sin(a + ang) * rr, z + dz end
			local x1, y1, z1 = pt(0, s * 1.5, 0.5); local x2, y2, z2 = pt(2.094, s * 1.5, 0.2); local x3, y3, z3 = pt(4.189, s * 1.5, 0.4)
			sommet(x1, y1, z1, fr, fg, fb); sommet(x2, y2, z2, fr, fg, fb); sommet(x3, y3, z3, fr, fg, fb)
			x1, y1, z1 = pt(1.047, s * 1.5, 0.3); x2, y2, z2 = pt(3.141, s * 1.5, 0.5); x3, y3, z3 = pt(5.236, s * 1.5, 0.2)
			sommet(x1, y1, z1, fr * 0.92, fg * 0.92, fb * 0.92); sommet(x2, y2, z2, fr * 0.92, fg * 0.92, fb * 0.92); sommet(x3, y3, z3, fr * 0.92, fg * 0.92, fb * 0.92)
			x1, y1, z1 = pt(0.5, s * 0.45, 0.8); x2, y2, z2 = pt(2.6, s * 0.45, 0.8); x3, y3, z3 = pt(4.7, s * 0.45, 0.8)
			sommet(x1, y1, z1, 255, 214, 80); sommet(x2, y2, z2, 255, 214, 80); sommet(x3, y3, z3, 255, 214, 80)
		else
			local grand = alea.n() < 0.07
			-- or côté soleil : les brins de l'ouest (vers le couchant) et des taches de lumière ont la pointe dorée
			local ouest = math.Clamp(-x / 2200, 0, 1)
			local dore = 0.55 * l + 0.45 * ouest
			for _ = 1, 3 do
				local bx, by = x - cx + (alea.n() - 0.5) * 8, y - cy + (alea.n() - 0.5) * 8
				local h = (grand and 30 or 9) + alea.n() * (grand and 22 or 14)
				local w = (0.45 + alea.n() * 0.7) * kw
				local a = alea.n() * math.pi * 2
				local px, py = math.cos(a) * w, math.sin(a) * w
				local lx, ly = (alea.n() - 0.5) * h * 0.5, (alea.n() - 0.5) * h * 0.5
				local k = 0.42 + alea.n() * 0.22
				local v = 0.82 + alea.n() * 0.3
				local pr = (r * 1.05 + 18 + 62 * dore) * v
				local pg = (g * 1.08 + 26 * dore) * v
				local pb = (b * 0.9 - 8 * dore) * v
				sommet(bx - px, by - py, P.SOL_Z - 0.4, r * k, g * k, b * k)
				sommet(bx + px, by + py, P.SOL_Z - 0.4, r * k, g * k, b * k)
				sommet(bx + lx, by + ly, P.SOL_Z + h, pr, pg, math.max(pb, 0))
			end
		end
	end
	mesh.End()
	local lots = {}
	for k, t in pairs(aPart) do lots[k] = maillageBrins(t) end
	return m, lots
end
local function construire()
	detruire()
	local X, Y, Z = directionMonde(Vector(1, 0, 0)), directionMonde(Vector(0, 1, 0)), directionMonde(Vector(0, 0, 1))
	G.ax = { X.x, X.y, X.z, Y.x, Y.y, Y.z, Z.x, Z.y, Z.z }
	local o = versMonde(P.TETE.x, P.TETE.y, P.TETE.z)
	G.o = { o.x, o.y, o.z }
	for _, e in ipairs(ents.GetAll()) do         -- restes de la v14 (modèles client nt) : ils survivent au rechargement à chaud
		if IsValid(e) and e:EntIndex() == -1 and (e.sumiiCaillou or string.find(string.lower(e:GetModel() or ""), "models/nt/props_nature/", 1, true)) then e:Remove() end
	end
	etat.phase = "ciel"; construireCiel(); souffle()
	etat.phase = "lointains"; construireLointains(); souffle()
	etat.phase = "sol"; construireSol(); souffle()
	etat.phase = "anneaux"
	G.anneau1 = construireAnneau(2360, 118, 330, 480, 0.16, 0.1234); souffle()
	G.anneau2 = construireAnneau(2250, 96, 250, 380, 0.04, 0.5678); souffle()
	etat.phase = "arbres"
	G.arbres, G.cartes, G.chaudes, G.fonds, G.accents, G.spheres, G.feuilles = construireArbres(0.3141)
	etat.phase = "herbe"
	G.blocs = {}
	local d = P.BLOC
	for cx = -P.BX + d / 2, P.BX - d / 2, d do
		for cy = -P.BX + d / 2, P.BX - d / 2, d do
			if cx * cx + cy * cy <= 2300 * 2300 then
				local g = hache(cx, cy) * 0.9 + 0.05
				local b = { x = cx, y = cy, origine = versMonde(cx, cy, 0), zones = {} }
				local parZone = {}
				local function bloc(lod, nb, kw)
					local m, lots = construireBloc(cx, cy, nb, g, kw)
					b[lod] = m
					for k, mz in pairs(lots) do
						if not parZone[k] then
							parZone[k] = { n = k }
							b.zones[#b.zones + 1] = parZone[k]
						end
						parZone[k][lod] = mz
					end
				end
				bloc("dense", P.DENSE, 1)
				G.blocs[#G.blocs + 1] = b
				souffle()
				bloc("moyen", P.MOYEN, 1.6); souffle()
				bloc("clair", P.CLAIR, 2.4)
				souffle()
			end
		end
	end
	G.matrice = Matrix()
	local s2 = Vector(SOLEIL.x, SOLEIL.y, 0):GetNormalized()
	G.s2x, G.s2y = s2.x, s2.y
	G.caillouxAFaire = true
	G.pret = true                                -- rien n'est dessiné avant : pas de scène à moitié faite
end

-- ---------- hooks protégés ----------
local function ajouter(ev, nom, f)
	SumiiNoyau.hook(ev, "sumii_p1_" .. nom, function(...)
		if etat.erreurs[nom] then return end
		local ok, a, b = pcall(f, ...)
		if not ok then etat.erreurs[nom] = true; print("[sumii_p1] erreur " .. nom .. " : " .. tostring(a)) return end
		return a, b
	end)
end
local function mesurer(t0)
	local dt = (SysTime() - t0) * 1000
	etat.n, etat.total, etat.pic = etat.n + 1, etat.total + dt, math.max(etat.pic, dt)
end
local chantier, BUDGET_MS = nil, 6
ajouter("Think", "chantier", function()
	if not etat.allume or not majTete() then return end
	if CurTime() >= (etat.controle or 0) then      -- repère déplacé ou recollé : on reconstruit (contrôle 1 fois par seconde)
		etat.controle = CurTime() + 1
		local p, a = etat.tete:GetPos(), etat.tete:GetAngles()
		local q = etat.angT
		if not etat.posT or p:DistToSqr(etat.posT) > 1 or math.abs(math.AngleDifference(a.p, q.p)) + math.abs(math.AngleDifference(a.y, q.y)) + math.abs(math.AngleDifference(a.r, q.r)) > 0.3 then
			etat.posT, etat.angT = p, a
			chantier = coroutine.create(construire)
			etat.ch = { ms = 0, images = 0, pic = 0, phases = {} }
		end
	end
	if not chantier then return end
	local t0 = SysTime()
	budget.fin = t0 + BUDGET_MS / 1000
	local ph = etat.phase or "debut"
	local ok, err = coroutine.resume(chantier)
	local dt = (SysTime() - t0) * 1000
	local ch = etat.ch
	ch.ms, ch.images, ch.pic = ch.ms + dt, ch.images + 1, math.max(ch.pic, dt)
	ch.phases[ph] = (ch.phases[ph] or 0) + dt
	if dt >= ch.pic then ch.picPh = ph end
	if not ok then chantier = nil; print("[sumii_p1] erreur construction : " .. tostring(err)) return end
	if coroutine.status(chantier) == "dead" then
		chantier = nil
		local s = {}
		for k, v in pairs(ch.phases) do s[#s + 1] = k .. "=" .. math.floor(v) end
		local ligne = string.format("%s sumii_p1 construction calcul_ms=%d images=%d pic_image_ms=%.2f (%s) %s", os.date("%H:%M:%S"), ch.ms, ch.images, ch.pic, tostring(ch.picPh), table.concat(s, " "))
		print("[sumii_p1] " .. ligne)
		file.CreateDir("sumii_p1")
		file.Append("sumii_p1/mesure.txt", ligne .. "\n")
	end
end)

-- ---------- ciel ----------
local CENTRE_CIEL = Vector(0, 0, 0)
-- camera(plan) : origine de la caméra d'un plan (nil : à l'infini ; "nuages" ; 1 à 3 : lointains). Sans camera, tout est à l'infini.
local function peindreCiel(camera)
	local function ouvrir(plan)
		local angles = EyeAngles()
		if SumiiScene and SumiiScene.tournerCiel then angles = SumiiScene.tournerCiel(angles) end   -- vertige : le ciel tourne
		cam.Start3D(camera and camera(plan, P.CIEL_R * 0.9) or CENTRE_CIEL, angles)
		cam.IgnoreZ(true)                          -- à chaque caméra : le ciel ne teste jamais la profondeur
	end
	local SC = SumiiScene
	local voile = SC and SC.voileSoleil and SC.voileSoleil() or 1   -- 1 : soleil dégagé
	ouvrir(nil)
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	G.ciel:Draw()
	if SC and SC.voileRouge then SC.voileRouge() end   -- souvenirs : le ciel rouge, sous les nuages
	cam.End3D()
	ouvrir("nuages")
	local t = CurTime()
	-- nuages qui passent lentement (vers l'est)
	-- v32 : un maillage dynamique par matériau, calcul en nombres (plus de Vector par nuage et par image)
	local A, RC = G.ax, P.CIEL_R * 0.9
	local SX, SY, SZ = SOLEIL.x, SOLEIL.y, SOLEIL.z
	G.nuagesF = G.nuagesF or {}
	local refaire = t >= (G.nuagesA or 0)          -- deux fois par seconde : 0,075 degré de dérive, invisible
	if refaire then G.nuagesA = t + 0.5 end
	for mi = 1, 3 do
		local liste = G.nuagesM[mi]
		if #liste > 0 and (refaire or not G.nuagesF[mi]) then
			if G.nuagesF[mi] then G.nuagesF[mi]:Destroy() end
			G.nuagesF[mi] = Mesh()
			mesh.Begin(G.nuagesF[mi], MATERIAL_QUADS, #liste)
			for _, n in ipairs(liste) do
				local az, el = math.rad(n.az + t * 0.15), math.rad(n.el)
				local ce = math.cos(el)
				local dx, dy, dz = math.cos(az) * ce, math.sin(az) * ce, math.sin(el)
				-- teinte au dessin : les nuages dérivent (0,15 degré par seconde), la couleur suit leur position par rapport au soleil
				local chaud = ((dx * SX + dy * SY + dz * SZ + 1) / 2) ^ 2.5
				local lr, lg, lb = 248 + 7 * chaud, 248 - 52 * chaud, 252 - 102 * chaud
				local or_, og, ob = 172 + 24 * chaud, 186 - 68 * chaud, 218 - 72 * chaud
				local h = n.haut
				local r, g, b = math.min(or_ + (lr - or_) * h, 255), math.min(og + (lg - og) * h, 255), math.min(ob + (lb - ob) * h, 255)
				if SC and SC.teinteNuage then r, g, b = SC.teinteNuage(r, g, b) end
				local wx, wy, wz = A[1] * dx + A[4] * dy + A[7] * dz, A[2] * dx + A[5] * dy + A[8] * dz, A[3] * dx + A[6] * dy + A[9] * dz
				-- quad tourné vers le centre du dôme : U horizontal, V vers le haut du repère, tourné de rot
				local ux, uy, uz = wy * A[9] - wz * A[8], wz * A[7] - wx * A[9], wx * A[8] - wy * A[7]
				local ul = math.sqrt(ux * ux + uy * uy + uz * uz); ux, uy, uz = ux / ul, uy / ul, uz / ul
				local vx, vy, vz = uy * wz - uz * wy, uz * wx - ux * wz, ux * wy - uy * wx
				local ro = math.rad(n.rot % 30 - 15)
				local cr_, sr = math.cos(ro), math.sin(ro)
				local w2, h2 = n.t / 2, n.t * 0.31
				local Ux, Uy, Uz = (ux * cr_ + vx * sr) * w2, (uy * cr_ + vy * sr) * w2, (uz * cr_ + vz * sr) * w2
				local Vx, Vy, Vz = (vx * cr_ - ux * sr) * h2, (vy * cr_ - uy * sr) * h2, (vz * cr_ - uz * sr) * h2
				local cx, cy, cz = wx * RC, wy * RC, wz * RC
				sommet(cx - Ux - Vx, cy - Uy - Vy, cz - Uz - Vz, 0, 1); mesh.Color(r, g, b, n.a); mesh.AdvanceVertex()
				sommet(cx + Ux - Vx, cy + Uy - Vy, cz + Uz - Vz, 1, 1); mesh.Color(r, g, b, n.a); mesh.AdvanceVertex()
				sommet(cx + Ux + Vx, cy + Uy + Vy, cz + Uz + Vz, 1, 0); mesh.Color(r, g, b, n.a); mesh.AdvanceVertex()
				sommet(cx - Ux + Vx, cy - Uy + Vy, cz - Uz + Vz, 0, 0); mesh.Color(r, g, b, n.a); mesh.AdvanceVertex()
			end
			mesh.End()
		end
		if G.nuagesF[mi] then
			render.SetMaterial(MAT.fumee[mi])
			G.nuagesF[mi]:Draw()
		end
	end
	cam.End3D()
	ouvrir(nil)
	-- soleil : halo large, halo moyen, disque
	local versSoleil = SC and SC.dirSoleil and SC.dirSoleil(etat.tete) or G.soleil   -- il plonge aux souvenirs
	local s = versSoleil * (P.CIEL_R * 0.95)
	render.SetMaterial(MAT.glow)
	render.DrawSprite(s, 640, 640, coul(255, 150, 80, 64 * voile))         -- v32 : voilé (lueur large, disque doux)
	render.DrawSprite(s, 280, 280, coul(255, 196, 140, 150 * voile))
	render.DrawSprite(s, 90, 90, coul(255, 232, 196, 210 * voile))
	render.DrawSprite(s, 40, 40, coul(255, 246, 226, 230 * voile))
	-- rayons : éventail additif autour du soleil, qui respire
	render.SetMaterial(MAT.add)
	local ang = versSoleil:Angle()
	local dr, du = ang:Right(), ang:Up()
	mesh.Begin(MATERIAL_TRIANGLES, 14)
	for i = 0, 13 do
		local a = (i / 14 + 0.013 * math.sin(t * 0.21 + i)) * math.pi * 2
		local l = 170 + 60 * math.sin(i * 2.7) + 20 * math.sin(t * 0.4 + i * 1.3)
		local w = 0.09 + 0.04 * math.sin(i * 1.9)
		local v0 = dr * math.cos(a - w) + du * math.sin(a - w)
		local v1 = dr * math.cos(a + w) + du * math.sin(a + w)
		local al = (18 + 8 * math.sin(t * 0.5 + i * 2.1)) * voile
		mesh.Position(s); mesh.Color(255, 220, 150, al); mesh.AdvanceVertex()
		mesh.Position(s + v0 * l); mesh.Color(255, 200, 120, 0); mesh.AdvanceVertex()
		mesh.Position(s + v1 * l); mesh.Color(255, 200, 120, 0); mesh.AdvanceVertex()
	end
	mesh.End()
	if SC and SC.cielPar then SC.cielPar(s) end   -- nuage devant le soleil, puis les effets de ciel des temps
	cam.End3D()
	for i, m in ipairs(G.lointains) do           -- lointains par-dessus le soleil : il se pose derrière la crête du fond
		ouvrir(i)
		render.SetColorMaterial()
		m:Draw()
		cam.End3D()
	end
	render.CullMode(MATERIAL_CULLMODE_CCW)
	cam.IgnoreZ(false)
end
SumiiP1 = { visible = function() return G.pret == true and dedans() and true or false end, peindreCiel = peindreCiel }

ajouter("PreDrawSkyBox", "ciel", function()
	if not G.pret or not dedans() then return end
	local t0 = SysTime()
	render.Clear(P.HORIZON[1], P.HORIZON[2], P.HORIZON[3], 255, false, false)
	if not (SumiiCylindre and SumiiCylindre.couvre()) then peindreCiel() end   -- sinon le cylindre le peint dans sa fenêtre
	mesurer(t0)
	return true                                -- ni le ciel 2D ni le ciel 3D (collines) de la map
end)

-- ---------- sol, lisière, herbe ----------
ajouter("PostDrawOpaqueRenderables", "decor", function(prof, ciel)
	if prof or ciel or not G.pret or not dedans() then return end
	local t0 = SysTime()
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	G.sol:Draw()
	local pli = SumiiScene and SumiiScene.pliForet and SumiiScene.pliForet()   -- la forêt plie sous le vent, puis s'enfonce
	if pli then cam.PushModelMatrix(pli) end
	G.anneau1:Draw()
	G.anneau2:Draw()
	for _, m in ipairs(G.arbres) do m:Draw() end
	render.CullMode(MATERIAL_CULLMODE_CW)        -- faces extérieures des sphères tournées dans l'autre sens : on garde l'extérieur
	for _, m in ipairs(G.spheres or {}) do m:Draw() end
	render.CullMode(MATERIAL_CULLMODE_NONE)
	for cle, l in pairs(G.feuilles or {}) do render.SetMaterial(MATS_F[cle]) for _, m in ipairs(l) do m:Draw() end end
	dessinFeuillesVol()
	render.SetMaterial(BRANCHES)
	for _, m in ipairs(G.cartes) do m:Draw() end
	render.SetMaterial(BRANCHES_FOND)
	for _, m in ipairs(G.fonds) do m:Draw() end
	render.SetMaterial(BRANCHES_CHAUD)
	for _, m in ipairs(G.chaudes) do m:Draw() end
	for i, l in ipairs(G.accents) do render.SetMaterial(ACCENTS[i]) for _, m in ipairs(l) do m:Draw() end end
	if pli then cam.PopModelMatrix() end
	render.SetColorMaterial()
	-- herbe : un cisaillement par bloc (le vent souffle d'ouest en est, vague lente + frémissement)
	local oeil = versBuild(EyePos())
	local av = versBuild(EyePos() + EyeAngles():Forward() * 100) - oeil
	local t = SumiiScene and SumiiScene.tVent or CurTime()
	local M, tete = G.matrice, etat.tete
	local f, l, u = tete:GetForward(), -tete:GetRight(), tete:GetUp()
	for i = 1, 3 do M:SetField(i, 1, f[i]); M:SetField(i, 2, l[i]) end
	for _, b in ipairs(G.blocs) do
		local dx, dy = b.x - oeil.x, b.y - oeil.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist < P.D_CLAIR and (dist < 500 or (dx * av.x + dy * av.y) > -0.35 * dist * 100) then
			local k = P.VENT[1] + P.VENT[2] * math.sin(t * 0.9 - b.x * 0.0021 - b.y * 0.0007) + 0.03 * math.sin(t * 2.3 + b.x * 0.01 + b.y * 0.013)
			local ky = 0.04 * math.sin(t * 0.6 - b.y * 0.0018)
			local h = 1
			if SumiiScene and SumiiScene.herbe then h, k, ky = SumiiScene.herbe(b, k, ky) end
			for i = 1, 3 do M:SetField(i, 3, u[i] * h + f[i] * k + l[i] * ky); M:SetField(i, 4, b.origine[i]) end   -- v32 : sans Vector
			cam.PushModelMatrix(M)
			-- contre-jour : l'herbe entre l'œil et le soleil s'allume d'or (la lumière la traverse)
			local cj = dist > 1 and math.max((dx * G.s2x + dy * G.s2y) / dist, 0) ^ 2 or 0
			render.SetColorModulation(1 + 0.22 * cj, 1 + 0.06 * cj, 1 - 0.25 * cj)
			local lod = dist < P.D_DENSE and "dense" or (dist < P.D_MOYEN and "moyen" or "clair")
			b[lod]:Draw()
			local masque = SumiiHerbe and SumiiHerbe.masque
			for i = 1, #b.zones do
				local z = b.zones[i]
				if z[lod] and not (masque and masque[z.n]) then
					local dk = SumiiScene and SumiiScene.fremit and SumiiScene.fremit(z.n) or 0
					if dk == 0 then z[lod]:Draw()
					else                          -- la touffe devant ce terrier frémit seule
						for j = 1, 3 do M:SetField(j, 3, u[j] * h + f[j] * (k + dk) + l[j] * ky) end
						cam.PushModelMatrix(M)
						z[lod]:Draw()
						cam.PopModelMatrix()
						for j = 1, 3 do M:SetField(j, 3, u[j] * h + f[j] * k + l[j] * ky) end
					end
				end
			end
			cam.PopModelMatrix()
		end
	end
	render.SetColorModulation(1, 1, 1)
	render.CullMode(MATERIAL_CULLMODE_CCW)
	mesurer(t0)
end)

-- halo du soleil par-dessus les cimes (contre-jour or)
ajouter("PostDrawTranslucentRenderables", "halo", function(prof, ciel)
	if prof or ciel or not G.pret or not dedans() then return end
	local t0 = SysTime()
	-- v32 : test de visibilité réelle au-delà de la lisière
	-- (3 200 u > anneaux à 2 360 u) ; halo et rayons pondérés, les rayons filtrent seulement à travers les trouées
	G.pv = G.pv or util.GetPixelVisibleHandle()
	local loin = SumiiCylindre and SumiiCylindre.distanceHalo(versBuild(EyePos()), SOLEIL) or 3200
	local e = loin / 3200                        -- même angle à l'écran, quelle que soit la distance au mur
	local versSoleil = SumiiScene and SumiiScene.dirSoleil and SumiiScene.dirSoleil(etat.tete) or G.soleil
	local s = EyePos() + versSoleil * loin
	local vis = (util.PixelVisible(s, 110 * e, G.pv) or 0) * (SumiiScene and SumiiScene.voileSoleil and SumiiScene.voileSoleil() or 1)
		* (SumiiScene and SumiiScene.voileHalo and SumiiScene.voileHalo() or 1)
	if vis <= 0.01 then mesurer(t0) return end
	-- v33b : halo et rayons testés en profondeur, au-delà de la lisière :
	-- tout ce qui est devant (tronc, feuilles, cimes) les cache, ils ne passent que par les trous
	cam.IgnoreZ(false)
	render.SetMaterial(MAT.glow)
	render.DrawSprite(s, 2400 * e, 2400 * e, coul(255, 170, 90, 34 * vis))
	render.DrawSprite(s, 1100 * e, 1100 * e, coul(255, 200, 140, 26 * vis))
	render.SetMaterial(MAT.add)                  -- rayons par-dessus les cimes, plus longs et plus discrets que ceux du ciel
	local ang = versSoleil:Angle()
	local dr, du, t = ang:Right(), ang:Up(), CurTime()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_TRIANGLES, 14)
	for i = 0, 13 do
		local a = (i / 14 + 0.013 * math.sin(t * 0.21 + i)) * math.pi * 2
		local l = (170 + 60 * math.sin(i * 2.7) + 20 * math.sin(t * 0.4 + i * 1.3)) * 6.7 * e   -- même angle qu'à 2 000 u
		local w = 0.07 + 0.03 * math.sin(i * 1.9)
		local v0 = dr * math.cos(a - w) + du * math.sin(a - w)
		local v1 = dr * math.cos(a + w) + du * math.sin(a + w)
		mesh.Position(s); mesh.Color(255, 210, 140, (12 + 5 * math.sin(t * 0.5 + i * 2.1)) * vis); mesh.AdvanceVertex()
		mesh.Position(s + v0 * l); mesh.Color(255, 190, 110, 0); mesh.AdvanceVertex()
		mesh.Position(s + v1 * l); mesh.Color(255, 190, 110, 0); mesh.AdvanceVertex()
	end
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
	cam.IgnoreZ(false)
	mesurer(t0)
end)

-- ---------- rééclairage or des props de la boîte (la flatgrass les éclaire en blanc) ----------
local FACES = { { BOX_FRONT, Vector(1, 0, 0) }, { BOX_BACK, Vector(-1, 0, 0) }, { BOX_RIGHT, Vector(0, -1, 0) },
	{ BOX_LEFT, Vector(0, 1, 0) }, { BOX_TOP, Vector(0, 0, 1) }, { BOX_BOTTOM, Vector(0, 0, -1) } }
local ECL = { AMB = { 0.30, 0.37, 0.46 }, SOLEIL = { 1.35, 0.98, 0.58 }, CIEL = { 0.16, 0.22, 0.34 } }
local function dessinOr(self)
	if not dedans() then self:DrawModel() return end
	local s = G.soleil or Vector(-1, 0, 0)
	render.SuppressEngineLighting(true)
	render.ResetModelLighting(ECL.AMB[1], ECL.AMB[2], ECL.AMB[3])
	for _, fa in ipairs(FACES) do
		local l = math.max(s:Dot(fa[2]), 0)
		local h = math.max(fa[2].z, 0)
		render.SetModelLighting(fa[1], ECL.AMB[1] + ECL.SOLEIL[1] * l + ECL.CIEL[1] * h, ECL.AMB[2] + ECL.SOLEIL[2] * l + ECL.CIEL[2] * h,
			ECL.AMB[3] + ECL.SOLEIL[3] * l + ECL.CIEL[3] * h)
	end
	self:DrawModel()
	render.SuppressEngineLighting(false)
end
-- feuillage du cerisier (rose) passé au vert par $color2 : le tronc garde son brun, les feuilles gardent leurs valeurs
local CERISIER = "models/propper/rp_seireitei_v1/watcher_skr_treesakura_1.mdl"
local FEUILLES = CreateMaterial("sumii_p1_feuilles_v2", "VertexLitGeneric", { ["$basetexture"] = "watchertextures/T_Tree_OakA_02_sakura",
	["$alphatest"] = "1", ["$nocull"] = "1", ["$color2"] = "[0.36 0.80 0.28]" })
local CAILLOUX = { "models/props_wasteland/rockgranite02a.mdl", "models/props_wasteland/rockgranite02b.mdl", "models/props_wasteland/rockgranite02c.mdl",
	"models/props_wasteland/rockgranite03a.mdl", "models/props_wasteland/rockgranite03b.mdl", "models/props_wasteland/rockgranite03c.mdl" }
local function dessinCaillou(self) if dedans() then dessinOr(self) end end
local function poserCailloux()                -- 12 cailloux sur 3 plans (400 à 1 750 u), plus gros au loin ; loin des arbres de cadrage
	G.caillouxAFaire, G.cailloux = false, G.cailloux or {}
	alea.v = 0.4242
	local n = 0
	while n < 12 do
		local a, r = alea.n() * math.pi * 2, 400 + alea.n() * 1350
		local x, y = math.cos(a) * r, math.sin(a) * r
		local libre = true
		for _, o in ipairs(P.OMBRES) do if (x - o[1]) ^ 2 + (y - o[2]) ^ 2 < 260 * 260 then libre = false end end
		if libre then
			n = n + 1
			local e = ClientsideModel(CAILLOUX[1 + math.floor(alea.n() * #CAILLOUX)], RENDERGROUP_OPAQUE)
			if IsValid(e) then
				e:SetPos(versMonde(x, y, -4))
				e:SetAngles(etat.tete:LocalToWorldAngles(Angle(0, alea.n() * 360, 0)))
				e:SetModelScale(math.min(3, 1.6 + (r - 400) / 1350 * 3.2 + alea.n() * 0.8), 0)   -- v26 : plafond (dalle de l'arrivée)
				e:DrawShadow(false)
				e.sumiiCaillou = true
				e.RenderOverride = dessinCaillou
				G.cailloux[#G.cailloux + 1] = e
			end
		end
	end
end
-- le sous-matériau posé une fois sautait sur certaines vues (diagnostic P3 du 27/11 : un cerisier avait perdu son
-- RenderOverride alors que le script le croyait posé) : feuillage imposé à chaque dessin, override revérifié chaque seconde
local function dessinCerisier(self)
	if not dedans() then self:DrawModel() return end
	self.sumiiDessins = (self.sumiiDessins or 0) + 1
	render.MaterialOverrideByIndex(1, FEUILLES)
	dessinOr(self)
	render.MaterialOverrideByIndex()
end
local eclaires, prochainOr = {}, 0
ajouter("Think", "or", function()
	if CurTime() < prochainOr then return end
	prochainOr = CurTime() + 1
	if not IsValid(etat.tete) then return end   -- v32 : repère retiré (nettoyage) : rien à faire
	if G.caillouxAFaire and G.pret and IsValid(etat.tete) then poserCailloux() end
	-- une vue rendue dans la boîte depuis moins de 3 s compte aussi (banc : caméra ailleurs que le joueur)
	if not dedans() and CurTime() - (etat.vuDedans or -10) > 3 then
		for e in pairs(eclaires) do if IsValid(e) then e.RenderOverride = nil; e:SetSubMaterial() end eclaires[e] = nil end
		return
	end
	if not IsValid(etat.tete) then return end   -- v32 : repère retiré (nettoyage) entre deux contrôles
	-- liste complète puis test de boîte : à 2 places, ents.FindInBox ne rendait aucun prop côté joueur et les rochers
	-- au centre enfoui sortaient noirs
	for _, e in ipairs(ents.FindByClass("prop_physics")) do
		local p = IsValid(e) and versBuild(e:GetPos())
		local dedansBoite = p and p.x * p.x + p.y * p.y <= P.BX * P.BX and p.z >= P.BZ0 and p.z <= P.BZ1
		local modele = dedansBoite and string.lower(e:GetModel() or "")
		if modele and not string.find(modele, "^models/hunter/") then
			local voulu = modele == CERISIER and dessinCerisier or dessinOr
			if e.RenderOverride ~= voulu then e.RenderOverride = voulu end
			eclaires[e] = true
		end
	end
end)

-- ---------- étalonnage « anime » (seulement dans la boîte) ----------
local CM = { ["$pp_colour_addr"] = 0.01, ["$pp_colour_addg"] = 0.005, ["$pp_colour_addb"] = 0, ["$pp_colour_brightness"] = 0.0,
	["$pp_colour_contrast"] = 1.06, ["$pp_colour_colour"] = 1.12, ["$pp_colour_mulr"] = 0.06, ["$pp_colour_mulg"] = 0.02, ["$pp_colour_mulb"] = 0 }
ajouter("RenderScreenspaceEffects", "etalonnage", function()
	if not dedans() then return end
	if SumiiScene and SumiiScene.blanc and SumiiScene.blanc() >= 1 then
		if SumiiScene.voileEcran then SumiiScene.voileEcran() end
		return
	end
	CM["$pp_colour_contrast"] = 1.06 * (SumiiScene and SumiiScene.lumiere and SumiiScene.lumiere() or 1)
	local rouge = SumiiScene and SumiiScene.teinte and SumiiScene.teinte() or 0
	CM["$pp_colour_addr"], CM["$pp_colour_addg"], CM["$pp_colour_addb"] = 0.01 + 0.04 * rouge, 0.005 - 0.015 * rouge, -0.02 * rouge
	CM["$pp_colour_mulr"] = 0.06 + 0.2 * rouge
	DrawColorModify(CM)
	DrawBloom(0.8, 0.55, 9, 9, 2, 1, 1, 0.86, 0.66)
	if SumiiScene and SumiiScene.voileEcran then SumiiScene.voileEcran() end   -- après l'étalonnage : le blanc reste blanc
end)

-- ---------- commandes ----------
SumiiNoyau.banc("sumii_p1", function(_, _, args)
	etat.allume = tonumber(args[1] or "") == 1
	etat.erreurs = {}
	print("[sumii_p1] " .. (etat.allume and "allumé" or "éteint"))
end)
SumiiNoyau.banc("sumii_p1_mesure", function()
	local moy = etat.n > 0 and etat.total / etat.n or 0
	local ligne = string.format("%s sumii_p1 appels=%d moyenne_ms=%.4f pic_ms=%.4f blocs=%d", os.date("%H:%M:%S"), etat.n, moy, etat.pic, #(G.blocs or {}))
	print("[sumii_p1] " .. ligne)
	file.CreateDir("sumii_p1")
	file.Append("sumii_p1/mesure.txt", ligne .. "\n")
	etat.n, etat.total, etat.pic = 0, 0, 0
end)
SumiiNoyau.banc("sumii_p1_diag", function()
	local n, vus = 0, {}
	for _, e in ipairs(ents.FindByClass("prop_physics")) do
		n = n + 1
		if #vus < 4 then local c = e:GetColor() vus[#vus + 1] = (e:GetModel() or "?") .. " " .. c.r .. "," .. c.g .. "," .. c.b end
	end
	etat.prochaine = 0
	local ok = majTete()
	print("[sumii_p1] diag : props=" .. n .. " tete=" .. tostring(ok) .. " dedans=" .. tostring(ok and dedans()) ..
		" oeil=" .. (ok and tostring(versBuild(EyePos())) or "-") .. " appels=" .. etat.n .. " erreurs=" .. table.Count(etat.erreurs))
	for _, v in ipairs(vus) do print("[sumii_p1]   " .. v) end
end)
SumiiNoyau.hook("ShutDown", "sumii_p1_fin", detruire)
print("[sumii_p1] chargé v33b")

SumiiNoyau.surExtinction(function() chantier, etat.posT, etat.angT, etat.controle, etat.phase = nil detruire() end)
