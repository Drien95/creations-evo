-- GÉNÉRÉ par addon/construire.py depuis arbre-pierre/banc/cl_sumii_p3.lua : ne pas modifier ici.
-- Sumii, monde intérieur · P3 « arbre isolé et pierre plate » (banc, 27/11/2026, S1). Client seulement.
-- Dupe : tronc, pierre, écuelle (3 posés, rééclairés par P1). Ici : cime au style de la lisière (sphereCime et
-- poserFeuilles recopiées de P1, qui est figée), racines, lapin endormi (0 posé), herbe écartée sous le lapin.
-- Repère : celui de P1. Console : sumii_p3 <0|1>, sumii_p3_lapin <0|1>, sumii_p3_mesure.

local P = {
	MODELE_TETE = "models/hunter/plates/plate32x32.mdl", TEINTE_TETE = { 88, 124, 56 }, TETE = Vector(0, 0, -1.5),
	BX = 2400, BZ0 = -200, BZ1 = 1400, SOLEIL_AZ = 208, SOLEIL_EL = 6,
	AZ = 198.5, DIST = 1200,                    -- pied de l'arbre
	CONTRE = 0.55, VALEUR = 1.12,               -- contre-jour de la cime (1 = lisière côté soleil) et clarté
	FEUILLE = 13,                             -- demi-taille d'une carte de feuille
	LAPIN = "models/compagnons/rabbit.mdl", LAPIN_UVZ = { 19, 23, 0 },
}
-- touffes : u (droite vu de l'arrivée), v (au fond), z, rayon, aplatissement
-- masses plus larges que hautes, avec des vides entre elles (critique v3 : « boules en brocoli »)
local TOUFFES = { { 8, 0, 262, 52, 0.7 }, { -62, 6, 226, 48, 0.68 }, { 78, -4, 232, 50, 0.7 }, { -100, 10, 182, 30, 0.65 },
	{ 112, 0, 186, 34, 0.65 }, { 10, -46, 214, 40, 0.68 }, { 30, 46, 226, 40, 0.7 }, { -20, -10, 300, 34, 0.7 }, { 50, 12, 296, 28, 0.72 } }
-- branches visibles : départ (u, v, z), arrivée dans une masse
local BRANCHES = { { { 0, 0, 120 }, { -70, 6, 215 } }, { { 2, 0, 132 }, { 80, -4, 222 } }, { { 0, 0, 150 }, { 8, 0, 250 } },
	{ { -30, 3, 172 }, { -98, 10, 180 } }, { { 38, -2, 178 }, { 108, 0, 184 } } }
local RACINES = { 15, 80, 200, 300 }          -- degrés dans le plan (u, v)

local etat = { allume = true, lapin = true, tete = nil, prochaine = 0, erreur = nil, n = 0, total = 0, pic = 0 }
local G = {}
local az = math.rad(P.AZ)
local AXE_D, AXE_R = Vector(math.cos(az), math.sin(az), 0), Vector(math.sin(az), -math.cos(az), 0)
local PIED = AXE_D * P.DIST
local function local3(u, v, z) return PIED + AXE_R * u + AXE_D * v + Vector(0, 0, z) end
local SOL_N = Vector(math.cos(math.rad(P.SOLEIL_AZ)) * math.cos(math.rad(P.SOLEIL_EL)),
	math.sin(math.rad(P.SOLEIL_AZ)) * math.cos(math.rad(P.SOLEIL_EL)), math.sin(math.rad(P.SOLEIL_EL))):GetNormalized()

local budget = { fin = 0 }
local function souffle() if coroutine.running() and SysTime() > budget.fin then coroutine.yield() end end
local function hache(x) x = math.sin(x) * 43758.5453 return x - math.floor(x) end

-- ---------- repère (comme P1) ----------
local function chercherTete() return SumiiAncre.tete() end
local function versMonde(p) return etat.tete:LocalToWorld(p - P.TETE) end
local function dedans()
	if not etat.allume or not IsValid(etat.tete) then return false end
	local p = etat.tete:WorldToLocal(EyePos()) + P.TETE
	return p.x * p.x + p.y * p.y <= P.BX * P.BX and p.z >= P.BZ0 and p.z <= P.BZ1
end

-- ---------- feuilles (copie de P1, v33b) ----------
local GRIS_FEUILLE = 0.64 * 255
local MATS_F = {}
local function matFeuille(col)
	local q = function(x) return math.floor(math.min(x, GRIS_FEUILLE) / 18 + 0.5) * 18 end
	local r, g, b = q(col[1]), q(col[2]), q(col[3])
	local cle = r .. "_" .. g .. "_" .. b
	if not MATS_F[cle] then
		MATS_F[cle] = CreateMaterial("sumii_p3_f_" .. cle .. "_v1", "UnlitGeneric", { ["$basetexture"] = "particle/leaf/leaf_nocolor",
			["$alphatest"] = "1", ["$alphatestreference"] = "0.35", ["$nocull"] = "1",
			["$color"] = string.format("[%.3f %.3f %.3f]", r / GRIS_FEUILLE, g / GRIS_FEUILLE, b / GRIS_FEUILLE) })
	end
	return cle
end
local CELLULES = { { 0, 0.25 }, { 0.25, 0.25 }, { 0.5, 0.25 }, { 0.75, 0.25 } }
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
		uv = { { u0, v0 + 0.25 }, { u0 + 0.25, v0 + 0.25 }, { u0 + 0.25, v0 }, { u0, v0 } } }
end

-- ---------- cime ----------
local function sphereCime(tri, c, r, sz, graine, bas, mil, hautc, zBas, H, feuilles)
	local NM, NP = 18, 12                     -- plus fin que la lisière (11 x 7) : l'arbre se voit à 200 u
	local pts, cols = {}, {}
	for a = 0, NP do
		pts[a], cols[a] = {}, {}
		local th = a / NP * math.pi
		for b = 0, NM - 1 do
			local ph = b / NM * math.pi * 2
			local n = Vector(math.sin(th) * math.cos(ph), math.sin(th) * math.sin(ph), math.cos(th))
			local g1, g2 = hache(graine) * 6.28, hache(graine + 1.7) * 6.28
			local rv = r * (1 + 0.1 * math.sin(3 * ph + g1) * math.sin(th) + 0.07 * math.sin(2 * th + g2))
			local p = c + Vector(n.x * rv, n.y * rv, n.z * rv * sz)
			local s = n.z
			local col = s > 0 and { hautc[1] * 1.18, hautc[2] * 1.18, hautc[3] * 1.12 } or bas
			local m = math.abs(s)
			local base = { mil[1] + (col[1] - mil[1]) * m, mil[2] + (col[2] - mil[2]) * m, mil[3] + (col[3] - mil[3]) * m }
			local d = math.max(n:Dot(SOL_N), 0) ^ 1.5 * (0.45 + 0.55 * math.max(s, 0)) * 0.6
			local ao = 0.56 + 0.44 * math.min(1, math.max(0, (p.z - zBas) / (H * 0.5)))
			pts[a][b] = p
			cols[a][b] = { (base[1] + (240 - base[1]) * d) * ao, (base[2] + (182 - base[2]) * d) * ao, (base[3] + (104 - base[3]) * d) * ao }
		end
	end
	for a = 0, NP - 1 do
		for b = 0, NM - 1 do
			local b2 = (b + 1) % NM
			if a > 0 then tri(pts[a][b], pts[a + 1][b], pts[a][b2], cols[a][b], cols[a + 1][b], cols[a][b2]) end
			if a < NP - 1 then tri(pts[a][b2], pts[a + 1][b], pts[a + 1][b2], cols[a][b2], cols[a + 1][b], cols[a + 1][b2]) end
		end
	end
	local si = #feuilles.sph + 1
	feuilles.sph[si] = { c = c, r = r, sz = sz }
	for a = 1, NP - 1 do
		for b = 0, NM - 1 do
			for j = 1, 3 do
				local g = graine + a * 17.3 + b * 5.1 + j * 29.7
				local th = (a + (hache(g) - 0.5) * 0.8) / NP * math.pi
				local ph = (b + hache(g + 1.1)) / NM * math.pi * 2
				local n = Vector(math.sin(th) * math.cos(ph), math.sin(th) * math.sin(ph), math.cos(th))
				local garde = n.z > 0.3 and 1 or (n.z < -0.45 and 0.6 or 0.85)
				if hache(g + 7.7) < garde then
					local col = cols[a][b]
					local k = 0.88 + hache(g + 2.3) * 0.24
					local d = math.max(n:Dot(SOL_N), 0)
					local lum = (d > 0.4 and hache(g + 3.7) < 0.6) and 0.6 or 0
					local omb = (n.z < -0.15) and 0.84 or 1
					local cf = { (col[1] * k + (235 - col[1] * k) * lum) * omb, (col[2] * k + (210 - col[2] * k) * lum) * omb, (col[3] * k + (120 - col[3] * k) * lum) * omb }
					for q = 1, 3 do cf[q] = math.max(cf[q], mil[q] * 0.82) end
					if n.z > 0.1 and hache(g + 9.1) < 0.15 then cf = { 200, 180, 70 } end   -- mouchetures de la lisière
					feuilles.cand[#feuilles.cand + 1] = { p = c + Vector(n.x, n.y, n.z * sz) * r * 1.02, n = n, g = g, si = si, col = cf }
				end
			end
		end
		souffle()
	end
end
local function poserFeuilles(ft, dest)
	for fi, f in ipairs(ft.cand) do
		if fi % 150 == 0 then souffle() end
		local cachee = false
		local px, py, pz = f.p.x, f.p.y, f.p.z
		for sj, s in ipairs(ft.sph) do
			if sj ~= f.si then
				local c = s.c
				local dx, dy, dz = px - c.x, py - c.y, (pz - c.z) / s.sz
				local rr = s.r * 0.97
				if dx * dx + dy * dy + dz * dz < rr * rr then cachee = true break end
			end
		end
		if not cachee then
			local nrm = (f.n + Vector(0, 0, -0.22)):GetNormalized()
			carteFeuille(dest, f.p, nrm, P.FEUILLE, (hache(f.g + 5.3) - 0.5) * 0.3, f.col, f.g + 6.1)
		end
	end
end

-- ---------- racines : tubes qui plongent dans le sol ----------
local function bezier(t, a, b, c, d)
	local s = 1 - t
	return a * (s * s * s) + b * (3 * s * s * t) + c * (3 * s * t * t) + d * (t * t * t)
end
local function tube(tri, p0, p1, p2, p3, r0, r1)
	local prec
	for k = 0, 10 do
		local t = k / 10
		local p = bezier(t, p0, p1, p2, p3)
		local axe = (bezier(math.min(1, t + 0.05), p0, p1, p2, p3) - bezier(math.max(0, t - 0.05), p0, p1, p2, p3)):GetNormalized()
		local U = axe:Cross(Vector(0, 0, 1)); if U:LengthSqr() < 0.01 then U = Vector(1, 0, 0) end
		U:Normalize()
		local V = U:Cross(axe)
		local ray = r0 + (r1 - r0) * t
		local anneau = {}
		for q = 0, 6 do
			local w = q / 7 * math.pi * 2
			local n = U * math.cos(w) + V * math.sin(w)
			local l = 0.55 + 0.35 * math.max(n.z, 0) + 0.45 * math.max(n:Dot(SOL_N), 0)
			anneau[q] = { p + n * ray, { 78 * l, 56 * l, 40 * l } }
		end
		if prec then
			for q = 0, 6 do
				local r = (q + 1) % 7
				tri(prec[q][1], anneau[q][1], prec[r][1], prec[q][2], anneau[q][2], prec[r][2])
				tri(prec[r][1], anneau[q][1], anneau[r][1], prec[r][2], anneau[q][2], anneau[r][2])
			end
		end
		prec = anneau
	end
end
local function racines(tri)                   -- courtes, la pointe sous le sol (critique v3 : « trépied »)
	for i, deg in ipairs(RACINES) do
		local c, s = math.cos(math.rad(deg)), math.sin(math.rad(deg))
		local function pt(d, z) return local3(c * d, s * d, z) end
		tube(tri, pt(5, 22), pt(15, 5), pt(25, 5), pt(34 + i, -8), 7, 2.5)
	end
end
local function branches(tri)
	for _, br in ipairs(BRANCHES) do
		local p0, p3 = local3(br[1][1], br[1][2], br[1][3]), local3(br[2][1], br[2][2], br[2][3])
		local d = p3 - p0
		tube(tri, p0, p0 + Vector(d.x * 0.15, d.y * 0.15, d.z * 0.55), p0 + Vector(d.x * 0.6, d.y * 0.6, d.z * 0.8), p3, 6, 2)
	end
end
local function touffesPied(tri)               -- herbe haute à la jonction du tronc et du sol
	for i = 1, 170 do
		local a, d = hache(i * 3.7) * 6.283, 9 + hache(i * 5.3) ^ 0.7 * 40
		local u, v = math.cos(a) * d, math.sin(a) * d
		if (u - P.LAPIN_UVZ[1]) ^ 2 + (v - P.LAPIN_UVZ[2]) ^ 2 > 15 * 15 then
			local h = 6 + hache(i * 7.9) * 12
			local base = local3(u, v, 0)
			local cote = AXE_R * (math.cos(a * 3) * 1.6) + AXE_D * (math.sin(a * 3) * 1.6)
			local pointe = local3(u + math.cos(a) * h * 0.35, v + math.sin(a) * h * 0.35, h)
			local bas, haut = { 62, 110, 44 }, { 132 + hache(i) * 40, 172 + hache(i + 1) * 20, 52 }
			tri(base - cote, base + cote, pointe, bas, bas, haut)
		end
	end
end

local function maillageTris(t)
	local res, k = {}, 1
	while k <= #t do
		local n = math.min(3000, #t - k + 1)
		local m = Mesh()
		mesh.Begin(m, MATERIAL_TRIANGLES, n)
		for q = k, k + n - 1 do
			local f = t[q]
			for i = 1, 3 do
				local c = f[i + 3]
				mesh.Position(versMonde(f[i])); mesh.Color(math.min(c[1], 255), math.min(c[2], 255), math.min(c[3], 255), 255); mesh.AdvanceVertex()
			end
		end
		mesh.End()
		res[#res + 1] = m
		k = k + n
		souffle()
	end
	return res
end
local function maillagesCartes(cartes)
	local res, k = {}, 1
	while k <= #cartes do
		local n = math.min(1500, #cartes - k + 1)
		local m = Mesh()
		mesh.Begin(m, MATERIAL_TRIANGLES, n * 2)
		for q = k, k + n - 1 do
			local c = cartes[q]
			for _, i in ipairs({ 1, 2, 3, 1, 3, 4 }) do
				local uv = c.uv[i]
				mesh.Position(versMonde(c.p[i])); mesh.TexCoord(0, uv[1], uv[2]); mesh.Color(255, 255, 255, 255); mesh.AdvanceVertex()
			end
		end
		mesh.End()
		res[#res + 1] = m
		k = k + n
		souffle()
	end
	return res
end
local function detruire()
	for _, l in ipairs({ G.spheres or {}, G.racines or {} }) do for _, m in ipairs(l) do m:Destroy() end end
	for _, l in pairs(G.feuilles or {}) do for _, m in ipairs(l) do m:Destroy() end end
	G.spheres, G.racines, G.feuilles, G.pret = nil, nil, nil, false
end
local function construire()
	local trisS, trisR, ft, cartes = {}, {}, { sph = {}, cand = {} }, {}
	local f, v = P.CONTRE, P.VALEUR
	local bas = { (30 - 10 * f) * v, (60 - 24 * f) * v, (32 - 6 * f) * v }
	local mil = { (62 - 24 * f) * v, (108 - 44 * f) * v, (48 - 12 * f) * v }
	local hautc = { (112 - 30 * f) * v, (160 - 66 * f) * v, (66 - 14 * f) * v }
	local function triS(p1, p2, p3, c1, c2, c3) trisS[#trisS + 1] = { p1, p2, p3, c1, c2, c3 } end
	for i, t in ipairs(TOUFFES) do
		sphereCime(triS, local3(t[1], t[2], t[3]), t[4], t[5], i * 13.7, bas, mil, hautc, 140, 160, ft)
	end
	poserFeuilles(ft, cartes)
	local function triR(p1, p2, p3, c1, c2, c3) trisR[#trisR + 1] = { p1, p2, p3, c1, c2, c3 } end
	racines(triR); branches(triR); touffesPied(triR)
	detruire()
	G.spheres, G.racines, G.feuilles = maillageTris(trisS), maillageTris(trisR), {}
	local total = 0
	for cle, l in pairs(cartes) do G.feuilles[cle] = maillagesCartes(l); total = total + #l end
	G.pret = true
	print(string.format("[sumii_p3] arbre construit : %d feuilles, %d triangles de cime", total, #trisS))
end

-- ---------- lapin endormi (modèle côté joueur, 0 posé) ----------
local FACES = { { BOX_FRONT, Vector(1, 0, 0) }, { BOX_BACK, Vector(-1, 0, 0) }, { BOX_RIGHT, Vector(0, -1, 0) },
	{ BOX_LEFT, Vector(0, 1, 0) }, { BOX_TOP, Vector(0, 0, 1) }, { BOX_BOTTOM, Vector(0, 0, -1) } }
local function dessinLapin(self)
	render.SuppressEngineLighting(true)
	render.ResetModelLighting(0.34, 0.40, 0.46)
	for _, fa in ipairs(FACES) do
		local l, h = math.max(SOL_N:Dot(fa[2]), 0), math.max(fa[2].z, 0)
		render.SetModelLighting(fa[1], 0.34 + 1.1 * l + 0.25 * h, 0.40 + 0.82 * l + 0.28 * h, 0.46 + 0.52 * l + 0.34 * h)
	end
	self:DrawModel()
	render.SuppressEngineLighting(false)
end
-- pose couchée choisie sur image (essai v5, pose C) : le modèle n'a aucune séquence de sommeil, on plie ses os
local POSE = { ["Bip001 Neck"] = Angle(28, 0, 0), ["Bip001 Head"] = Angle(22, 0, 0), Bone001 = Angle(75, 0, 0), Bone004 = Angle(75, 0, 0),
	["Bip001 L Thigh"] = Angle(45, 0, 0), ["Bip001 R Thigh"] = Angle(45, 0, 0), ["Bip001 L Calf"] = Angle(-70, 0, 0), ["Bip001 R Calf"] = Angle(-70, 0, 0) }
local function coucher(e)
	for nom, angle in pairs(POSE) do
		local i = e:LookupBone(nom)
		if i then e:ManipulateBoneAngles(i, angle) else print("[sumii_p3] os introuvable : " .. nom) end
	end
	e:SetPos(e:GetPos() + Vector(0, 0, -4))
end
local function retirerLapin()
	if IsValid(G.lapin) then G.lapin:Remove() end
	G.lapin = nil
end
local function poserLapin()
	retirerLapin()
	local e = ClientsideModel(P.LAPIN, RENDERGROUP_OPAQUE)
	if not IsValid(e) then print("[sumii_p3] lapin introuvable : " .. P.LAPIN) return end
	local u = P.LAPIN_UVZ
	e:SetPos(versMonde(local3(u[1], u[2], u[3])))
	e:SetAngles(etat.tete:LocalToWorldAngles(Angle(0, AXE_R:Angle().y, 0)))
	e:DrawShadow(false)
	local noms, choix = {}, nil
	for i, nom in pairs(e:GetSequenceList()) do noms[#noms + 1] = i .. "=" .. nom end
	for _, mot in ipairs({ "sleep", "lie", "rest", "sit_idle", "sit", "idle" }) do
		for i, nom in pairs(e:GetSequenceList()) do
			if not choix and string.find(string.lower(nom), mot, 1, true) then choix = i end
		end
		if choix then break end
	end
	print("[sumii_p3] sequences du lapin : " .. table.concat(noms, ", ") .. " | choisie : " .. tostring(choix))
	if choix then e:ResetSequence(choix) end
	e:SetCycle(0); e:SetPlaybackRate(0)        -- figé : seule la pose des os compte
	e.RenderOverride = dessinLapin
	e:SetNoDraw(true)                          -- dessiné par notre hook, seulement pour qui est dans la boîte
	G.lapin = e
	coucher(e)
end

-- herbe de P1 écartée autour du lapin : deux demi-disques opposés au format de SumiiHerbe (publié par P2)
local function disque(nom, x, y, dx, dy, long, lat)   -- deux moitiés opposées le long de (dx, dy)
	for suffixe, s in pairs({ _a = 1, _b = -1 }) do
		SumiiHerbe.zones[nom .. suffixe] = { x = x, y = y, fx = dx * s, fy = dy * s, rx = -dy * s, ry = dx * s, long = long, lat = lat }
		SumiiHerbe.masque[nom .. suffixe] = true
	end
end
local function zonesHerbe()
	SumiiHerbe = SumiiHerbe or { zones = {}, masque = {} }
	if SumiiHerbe.zones.arbre_a then return end
	local c = local3(P.LAPIN_UVZ[1], P.LAPIN_UVZ[2], 0)
	disque("arbre", c.x, c.y, AXE_R.x, AXE_R.y, 16, 16)
	local axe = math.rad(12)                   -- grand axe de la pierre
	disque("pierre", 0, 0, math.cos(axe), math.sin(axe), 96, 40)
end
zonesHerbe()

local chantier
SumiiNoyau.hook("Think", "sumii_p3_chantier", function()
	if etat.erreur or not etat.allume then return end
	zonesHerbe()
	if CurTime() >= etat.prochaine then
		etat.prochaine = CurTime() + 1
		if not IsValid(etat.tete) then
			etat.tete = chercherTete()
			if not IsValid(etat.tete) then detruire(); retirerLapin() end
		end
		if IsValid(etat.tete) then
			local p, a = etat.tete:GetPos(), etat.tete:GetAngles()
			local cle = tostring(p) .. tostring(a)
			if cle ~= etat.cle then etat.cle = cle; retirerLapin(); chantier = coroutine.create(construire) end
			if chantier == nil and not IsValid(G.lapin) then poserLapin() end
		end
	end
	if not chantier then return end
	budget.fin = SysTime() + 0.004
	local ok, err = coroutine.resume(chantier)
	if not ok then etat.erreur = true; chantier = nil; print("[sumii_p3] erreur construction : " .. tostring(err)) return end
	if coroutine.status(chantier) == "dead" then chantier = nil end
end)

SumiiNoyau.hook("PostDrawOpaqueRenderables", "sumii_p3_dessin", function(prof, ciel)
	if etat.erreur or prof or ciel or not G.pret or not dedans() then return end
	local t0 = SysTime()
	local ok, err = pcall(function()
		render.SetColorMaterial()
		render.CullMode(MATERIAL_CULLMODE_NONE)
		local pli = SumiiScene and SumiiScene.pliForet and SumiiScene.pliForet()
		if pli then cam.PushModelMatrix(pli) end
		for _, m in ipairs(G.racines) do m:Draw() end
		render.CullMode(MATERIAL_CULLMODE_CW)
		for _, m in ipairs(G.spheres) do m:Draw() end
		render.CullMode(MATERIAL_CULLMODE_NONE)
		for cle, l in pairs(G.feuilles) do render.SetMaterial(MATS_F[cle]) for _, m in ipairs(l) do m:Draw() end end
		if pli then cam.PopModelMatrix() end
		local parti = SumiiScene and SumiiScene.lapinCache and SumiiScene.lapinCache()   -- parti à la révélation
		if etat.lapin and not parti and IsValid(G.lapin) then dessinLapin(G.lapin) end
	end)
	render.CullMode(MATERIAL_CULLMODE_CCW)
	if not ok then etat.erreur = true; print("[sumii_p3] erreur dessin : " .. tostring(err)) return end
	local dt = (SysTime() - t0) * 1000
	etat.n, etat.total, etat.pic = etat.n + 1, etat.total + dt, math.max(etat.pic, dt)
end)

SumiiNoyau.banc("sumii_p3", function(_, _, args)
	etat.allume = tonumber(args[1] or "") == 1
	etat.erreur = nil
	if not etat.allume then detruire(); retirerLapin() end
	etat.cle = nil
end)
SumiiNoyau.banc("sumii_p3_lapin", function(_, _, args) etat.lapin = tonumber(args[1] or "") ~= 0 end)
SumiiNoyau.banc("sumii_p3_mesure", function()
	print(string.format("[sumii_p3] appels=%d moyenne_ms=%.4f pic_ms=%.3f", etat.n, etat.n > 0 and etat.total / etat.n or 0, etat.pic))
end)
SumiiNoyau.hook("ShutDown", "sumii_p3_fin", function() detruire(); retirerLapin() end)
detruire()

SumiiNoyau.surExtinction(function() chantier, etat.cle = nil detruire() retirerLapin() end)
