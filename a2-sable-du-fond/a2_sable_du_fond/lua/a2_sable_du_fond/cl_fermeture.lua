-- A2 « Le Sable du Fond » : fermeture de la scène en script. Passe 2 (26/11/2026). Client seulement.
-- Passe 12 (scène 2, planche 3) : dalle renforcée par l'éclairage de nuit (gain au centre), ambiance un peu
--   relevée pour lire les assises cendre, brume légèrement froide.
-- Passe 11 (scène 2, planche 2) : dalle plus claire (lumière peinte et liseré), brume plus claire pour lire l'écart.
-- Passe 10 (scène 2, planche 1) : éclairage de nuit en script des props de la boîte (le banc les éclaire en plein
--   jour) : moteur coupé, ambiance presque noire, seule la lumière clé au-dessus de la dalle les éclaire, en
--   décroissant avec la distance ; pénombre posée sur la hauteur exacte du sable (hook a2_sable_hauteur), plus fine.
-- Passe 9 (scène, finition) : faisceau plus large et plus clair ; halo faible limité au disque de jeu (r 350) ;
--   pénombre un peu moins dense.
-- Passe 8 (scène, planche 3) : pénombre plus forte, liseré de lumière froide sur le bord de la dalle.
-- Passe 7 (scène, planche 2) : pénombre peinte sur le sable hors du cercle de lumière (dalle + 4 places, r 320),
--   brume plus sombre : la dalle et les pierres redeviennent les seules zones claires.
-- Passe 6 (point focal) : la dalle est la seule zone claire avec les pierres (lumière peinte plus forte, halo large
--   baissé pour garder le sable sombre) ; la brume s'écarte devant le front de la vague (hook a2_vague_front).
-- Passe 5 (pièce 2, dalle v4) : lumière clé plus forte et plus basse sur les props, lumière peinte SUR la dalle
--   (la flaque au niveau du sable était cachée sous la dalle).
-- Passe 4 (finition) : faisceau vertical au-dessus de la dalle, brume plus claire, horizon en bande basse plus nette.
-- Passe 3 : rideau en dégradé (bande de cendre à l'horizon, noir en haut), brume entre le creux et le pied des dunes
--   (elle était dans les dunes), brouillard des maillages couleur cendre.
-- Passe 2 : brume claire et dense au pied des dunes, flaque froide en deux couches, brouillard posé aussi sur
--   les maillages du sable et des dunes (hook a2_brouillard_maillages appelé par leurs scripts).
-- Pour le joueur dont la caméra est dans la boîte de scène (relative au prop de tête du dupe) :
--   ciel noir (ni skybox de jour, ni soleil), brouillard noir-cendre du monde et du ciel 3D, rideau opaque de la couleur
--   du brouillard autour des dunes (plus d'herbe, de bâtiment ni de bord), brume basse qui roule, lumière clé froide
--   au-dessus de la dalle (DynamicLight pour les props et les joueurs, flaque de lumière peinte pour le sable en script).
-- Ne modifie ni la surface de sable v4 ni les dunes : il se dessine à côté, avec ses propres hooks (préfixe a2_ferm).
-- Console (aucune touche en dur) :
--   a2_fermeture <0|1>          éteint / allumé
--   a2_fermeture_brouillard <debut> <opaque>   réglage du brouillard (u), défaut 350 1350
--   a2_fermeture_mesure         temps moyen et pic du script (ms), écrit dans data/a2_fermeture/mesure.txt

local MODELE_TETE = "models/hunter/plates/plate5x5.mdl"
local TEINTE_TETE = { 75, 70, 64 }
local TETE = Vector(-226, -226, -61.5)       -- position de la tête en coordonnées du build (centre du creux en 0, 0)
local F = {                                  -- réglages (une table : pas de locales en trop)
	-- boîte de scène autour du centre du creux : 3 600 x 3 600 (les dunes en script vont jusqu'à r 1 750), 200 sous le sol, 700 au-dessus
	BX = 1800, BZ0 = -200, BZ1 = 700,
	COUL = { 13, 11, 10 },                   -- noir-cendre légèrement chaud (brouillard, rideau, ciel)
	FOG0 = 350, FOG1 = 1350,
	R_RIDEAU = 1780, H_RIDEAU = 2400,        -- rideau cylindrique juste derrière le bord des dunes (r 1 750)
	R_SOL0 = 1690,                           -- anneau de sol sombre entre le pied des dunes et le rideau
	SEG = 48,
	N_BRUME = 170,
	BRUME_COUL = { 120, 128, 146 },
	PENOMBRE = { R = { 300, 325, 350, 375, 400, 425, 450, 475, 500, 530, 560, 640, 760, 1100, 1690 }, A = { 0, 40, 80, 112, 140, 160, 175, 185, 190, 196, 200, 203, 205, 210, 215 } },
	NUIT = { AMB = { 0.06, 0.06, 0.075 }, CENTRE = 1.6, CLE = { 0.70, 0.78, 0.98 }, R = 320, Z_CLE = 180, GAIN = 1.3 },
	LISERE = { R = 95, Z = -48.6, N = 0,   -- passe 13c : liseré retiré (socle usé, plus d'anneau net)
		 TAILLE = 20, COUL = { 116, 122, 136 } },   -- lumière sur le bord de la dalle
	FAISCEAU = { N = 11, H0 = -50, H1 = 320, TAILLE = 230, COUL = { 108, 112, 122 } },   -- halo vertical (passe 10c : blanc froid désaturé, plus de bleu franc) au-dessus de la dalle
	HORIZON = { 38, 37, 40 }, H_BANDE = 200, H_NOIR = 480,   -- bas du rideau couleur cendre, noir au-dessus
	FOGM0 = 420, FOGM1 = 1700,                -- brouillard des maillages en script (sable, dunes)
	LUM_ID = 4520,                           -- plage d'id DynamicLight réservée : 4520 à 4529
	LUM_H = 180, LUM_TAILLE = 820, LUM_COUL = { 150, 165, 195 }, LUM_FORCE = 2.2,
	DALLE_Z = -50.2, DALLE_LUM = 230, DALLE_COUL = { 70, 72, 78 },   -- lumière peinte sur le dessus de la dalle (passe 5)
	FLAQUE = 620, FLAQUE_COUL = { 98, 104, 118 },       -- cœur de la lumière sur la dalle
	HALO = 720, HALO_COUL = { 30, 35, 46 },           -- halo large qui tombe vers les places
}
local etat = { allume = true, masquer = false }
local tete, prochaineRecherche = nil, 0
local temps = { n = 0, total = 0, pic = 0 }
local MAT_BRUME = { Material("particle/smokesprites_0001"), Material("particle/smokesprites_0002"),
	Material("particle/smokesprites_0003"), Material("particle/smokesprites_0004") }
local MAT_FLAQUE = Material("sprites/light_glow02_add")

-- ---------- repère ----------
local function chercherTete() return A2_SABLE.tete and A2_SABLE.tete() or nil end   -- ancre par motif de props (sh_ancre.lua)
local function majTete()
	if CurTime() >= prochaineRecherche then
		prochaineRecherche = CurTime() + 1
		tete = chercherTete()
	end
	return IsValid(tete)
end
local function versMonde(x, y, z) return tete:LocalToWorld(Vector(x, y, z) - TETE) end
local function versBuild(p) return tete:WorldToLocal(p) + TETE end

-- la caméra est-elle dans la boîte ? (calculé une fois par image)
local dedansCache, dedansImage = false, -1
local function dedans()
	if not etat.allume or not majTete() then return false end
	local img = FrameNumber()
	if img ~= dedansImage then
		dedansImage = img
		local p = versBuild(EyePos())
		dedansCache = math.abs(p.x) <= F.BX and math.abs(p.y) <= F.BX and p.z >= F.BZ0 and p.z <= F.BZ1
	end
	return dedansCache
end

local function mesurer(t0)
	local dt = (SysTime() - t0) * 1000
	temps.n, temps.total, temps.pic = temps.n + 1, temps.total + dt, math.max(temps.pic, dt)
end

-- ---------- ciel noir et brouillard ----------
hook.Add("PostDraw2DSkyBox", "a2_ferm_ciel", function()
	if not dedans() then return end
	render.Clear(F.COUL[1], F.COUL[2], F.COUL[3], 255, false, false)      -- plus de ciel de jour ni de soleil
end)
local function brouillard(k)
	if not dedans() then return end
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(F.FOG0 * k); render.FogEnd(F.FOG1 * k)
	render.FogMaxDensity(1)
	render.FogColor(F.COUL[1], F.COUL[2], F.COUL[3])
	return true
end
hook.Add("SetupWorldFog", "a2_ferm_brouillard", function() return brouillard(1) end)
hook.Add("SetupSkyboxFog", "a2_ferm_brouillard", function(k) return brouillard(k) end)   -- collines du ciel 3D noyées
-- les maillages en script (UnlitGeneric) se dessinent après le monde : leur script appelle ce hook avant de dessiner
hook.Add("a2_brouillard_maillages", "a2_ferm", function()
	if not dedans() then return end
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(F.FOGM0); render.FogEnd(F.FOGM1)
	render.FogMaxDensity(0.92)
	render.FogColor(F.HORIZON[1], F.HORIZON[2], F.HORIZON[3])
end)

-- ---------- rideau et anneau de sol sombre (maillage construit une fois par position de la tête) ----------
local rideau, cleRideau = nil, nil
local function construireRideau()
	if rideau then rideau:Destroy() end
	rideau = Mesh()
	local c = F.COUL
	mesh.Begin(rideau, MATERIAL_QUADS, F.SEG * 4)
	for i = 0, F.SEG - 1 do
		local a0, a1 = i / F.SEG * math.pi * 2, (i + 1) / F.SEG * math.pi * 2
		local c0, s0, c1, s1 = math.cos(a0), math.sin(a0), math.cos(a1), math.sin(a1)
		local R, h = F.R_RIDEAU, F.HORIZON
		for _, b in ipairs({ { F.BZ0, F.H_BANDE, h, h }, { F.H_BANDE, F.H_NOIR, h, c } }) do
			local z0, z1, cb, ch = b[1], b[2], b[3], b[4]
			for k, p in ipairs({ { c0 * R, s0 * R, z0 }, { c1 * R, s1 * R, z0 }, { c1 * R, s1 * R, z1 }, { c0 * R, s0 * R, z1 } }) do
				local col = k <= 2 and cb or ch
				mesh.Position(versMonde(p[1], p[2], p[3])); mesh.Color(col[1], col[2], col[3], 255); mesh.AdvanceVertex()
			end
		end
		for _, p in ipairs({ { c0 * R, s0 * R, F.H_NOIR }, { c1 * R, s1 * R, F.H_NOIR }, { c1 * R, s1 * R, F.H_RIDEAU }, { c0 * R, s0 * R, F.H_RIDEAU } }) do
			mesh.Position(versMonde(p[1], p[2], p[3])); mesh.Color(c[1], c[2], c[3], 255); mesh.AdvanceVertex()
		end
		local r0, zs = F.R_SOL0, 2.4                                         -- au ras du sable (dessus v4 : 1,67)
		for _, p in ipairs({ { c0 * r0, s0 * r0 }, { c0 * R, s0 * R }, { c1 * R, s1 * R }, { c1 * r0, s1 * r0 } }) do
			mesh.Position(versMonde(p[1], p[2], zs)); mesh.Color(c[1], c[2], c[3], 255); mesh.AdvanceVertex()
		end
	end
	mesh.End()
end
hook.Add("PostDrawOpaqueRenderables", "a2_ferm_rideau", function(prof, ciel)
	if prof or ciel or not dedans() then return end
	local t0 = SysTime()
	local cle = tostring(tete:GetPos()) .. tostring(tete:GetAngles())
	if cle ~= cleRideau or not rideau then cleRideau = cle; construireRideau() end
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	rideau:Draw()
	render.CullMode(MATERIAL_CULLMODE_CCW)
	mesurer(t0)
end)

-- ---------- pénombre : voile sombre sur le sable hors du cercle de lumière (construit une fois par position) ----------
local penombre, clePenombre = nil, nil
local function solPenombre(r)
	if r <= 280 then return -56.6 end
	if r >= 520 then return 2.6 end
	return -56.6 + (r - 280) / 240 * 59.2
end
local SEG_P = 128
local function zPenombre(r, a)                 -- hauteur exacte du sable + 1,6 si le script du sable la donne
	local h = hook.Run("a2_sable_hauteur", r, a)
	return h and h + 1.6 or solPenombre(r)
end
local function construirePenombre()
	if penombre then penombre:Destroy() end
	penombre = Mesh()
	local P, c = F.PENOMBRE, F.COUL
	mesh.Begin(penombre, MATERIAL_QUADS, SEG_P * (#P.R - 1))
	for i = 0, SEG_P - 1 do
		local a0, a1 = i / SEG_P * math.pi * 2, (i + 1) / SEG_P * math.pi * 2
		local c0, s0, c1, s1 = math.cos(a0), math.sin(a0), math.cos(a1), math.sin(a1)
		for k = 1, #P.R - 1 do
			local r0, r1, al0, al1 = P.R[k], P.R[k + 1], P.A[k], P.A[k + 1]
			for _, p in ipairs({ { c0 * r0, s0 * r0, zPenombre(r0, a0), al0 }, { c0 * r1, s0 * r1, zPenombre(r1, a0), al1 },
				{ c1 * r1, s1 * r1, zPenombre(r1, a1), al1 }, { c1 * r0, s1 * r0, zPenombre(r0, a1), al0 } }) do
				mesh.Position(versMonde(p[1], p[2], p[3])); mesh.Color(c[1], c[2], c[3], p[4]); mesh.AdvanceVertex()
			end
		end
	end
	mesh.End()
end
local function dessinerPenombre()
	local cle = tostring(tete:GetPos()) .. tostring(tete:GetAngles())
	if cle ~= clePenombre or not penombre then clePenombre = cle; construirePenombre() end
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	penombre:Draw()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end

-- ---------- brume basse qui roule ----------
-- sol approché du creux (dessus du sable v4) : fond -57,5 jusqu'à r 280, pente jusqu'à r 520, puis 1,7
local function solCreux(r)
	if r <= 280 then return -57.5 end
	if r >= 520 then return 1.7 end
	return -57.5 + (r - 280) / 240 * 59.2
end
local brume = {}
do
	local rnd = 0.31
	local function alea() rnd = (rnd * 9301 + 0.49297) % 1 return rnd end   -- suite fixe : même brume chez tous
	for i = 1, F.N_BRUME do
		-- plus dense vers les dunes, presque rien au centre : rayon tiré vers l'extérieur
		local r = alea() < 0.75 and 330 + 260 * alea() or 60 + 220 * alea()   -- 75 % entre le creux et le pied des dunes
		brume[i] = { a = alea() * math.pi * 2, r = r, w = (0.006 + 0.01 * alea()) * (alea() < 0.5 and -1 or 1),
			h = 8 + 26 * alea(), taille = 200 + 220 * alea(), alpha = r < 300 and 16 + 16 * alea() or 40 + 40 * alea(),
			mat = 1 + math.floor(alea() * 4) % 4, ph = alea() * 6.28, rot = alea() * 360 }
	end
end
hook.Add("PostDrawTranslucentRenderables", "a2_ferm_brume", function(prof, ciel)
	if prof or ciel or not dedans() then return end
	local t0 = SysTime()
	local t = CurTime()
	dessinerPenombre()
	local front, force = hook.Run("a2_vague_front")   -- rayon du front de vague (script de séquence), ou nil
	for _, b in ipairs(brume) do
		local a = b.a + b.w * t
		local r = b.r + 25 * math.sin(t * 0.05 + b.ph)
		if front then                        -- la brume est chassée devant le front puis revient lentement
			local d = r - front
			if d > -260 and d < 120 then r = r + 110 * (force or 1) * (1 - math.abs(d + 70) / 190) end
		end
		local z = solCreux(r) + b.h + 4 * math.sin(t * 0.13 + b.ph)
		render.SetMaterial(MAT_BRUME[b.mat])
		render.DrawSprite(versMonde(math.cos(a) * r, math.sin(a) * r, z), b.taille, b.taille * 0.45, Color(F.BRUME_COUL[1], F.BRUME_COUL[2], F.BRUME_COUL[3], b.alpha))
	end
	-- flaque de lumière peinte sur le sable de la dalle (le sable en script n'est pas éclairé par DynamicLight)
	render.SetMaterial(MAT_FLAQUE)
	local h, c = F.HALO_COUL, F.FLAQUE_COUL
	-- passe 15d : halo et flaque plats retirés : depuis que le sable monte contre le socle (bosse), ces quads plats le
	-- coupaient en un arc clair net ; le sable porte déjà sa propre lumière de dalle (DALLE.GAIN du script du sable).
	local li = F.LISERE
	for i = 1, li.N do
		local a = i / li.N * math.pi * 2
		render.DrawSprite(versMonde(math.cos(a) * li.R, math.sin(a) * li.R, li.Z), li.TAILLE, li.TAILLE * 0.6, Color(li.COUL[1], li.COUL[2], li.COUL[3], 255))
	end
	local dc = F.DALLE_COUL
	render.DrawQuadEasy(versMonde(0, 0, F.DALLE_Z), tete:GetUp(), F.DALLE_LUM, F.DALLE_LUM, Color(dc[1], dc[2], dc[3], 255), 0)
	-- faisceau : sprites additifs empilés de la dalle vers la lumière, plus étroits en haut
	local fa = F.FAISCEAU
	for i = 0, fa.N - 1 do
		local t = i / (fa.N - 1)
		local tail = fa.TAILLE * (1.25 - 0.6 * t)
		local k = 1 - 0.7 * t
		render.DrawSprite(versMonde(0, 0, fa.H0 + (fa.H1 - fa.H0) * t), tail, tail * 1.6, Color(fa.COUL[1] * k, fa.COUL[2] * k, fa.COUL[3] * k, 255))
	end
	mesurer(t0)
end)

-- ---------- lumière clé froide au-dessus de la dalle ----------
hook.Add("Think", "a2_ferm_lumiere", function()
	if not dedans() then return end
	local d = DynamicLight(F.LUM_ID)
	if not d then return end
	d.pos = versMonde(0, 0, F.LUM_H)
	d.r, d.g, d.b = F.LUM_COUL[1], F.LUM_COUL[2], F.LUM_COUL[3]
	d.brightness = F.LUM_FORCE
	d.size = F.LUM_TAILLE
	d.decay = 0
	d.dietime = CurTime() + 0.5
	d.nomodel = false
end)

-- ---------- éclairage de nuit des props de la boîte ----------
local FACES = { { BOX_FRONT, Vector(1, 0, 0) }, { BOX_BACK, Vector(-1, 0, 0) }, { BOX_RIGHT, Vector(0, -1, 0) },
	{ BOX_LEFT, Vector(0, 1, 0) }, { BOX_TOP, Vector(0, 0, 1) }, { BOX_BOTTOM, Vector(0, 0, -1) } }
local function eclairerNuit(pw)              -- pw : centre de l'objet dans le monde ; refermer par SuppressEngineLighting(false)
	local N = F.NUIT
	local p = versBuild(pw)
	local d2 = p.x * p.x + p.y * p.y
	local k = N.GAIN / (1 + d2 / (N.R * N.R)) * (1 + N.CENTRE * math.exp(-d2 / (110 * 110)))   -- la dalle d'abord
	local vers = (versMonde(0, 0, N.Z_CLE) - pw):GetNormalized()
	local a, c = N.AMB, N.CLE
	render.SuppressEngineLighting(true)
	render.ResetModelLighting(a[1], a[2], a[3])
	for _, f in ipairs(FACES) do
		local l = math.max(vers:Dot(f[2]), 0) * k
		render.SetModelLighting(f[1], a[1] + c[1] * l, a[2] + c[2] * l, a[3] + c[3] * l)
	end
end
local function dessinNuit(self)
	if not dedans() then self:DrawModel() return end
	eclairerNuit(self:WorldSpaceCenter())
	local k = self.a2_eclat                    -- série 7 : objets éclaircis par un autre script (cailloux du socle)
	if k then render.SetColorModulation(k, k, k) end
	if self.a2_matiere then render.MaterialOverride(self.a2_matiere) end   -- série 8 : matière imposée par un autre script
	self:DrawModel()
	if self.a2_matiere then render.MaterialOverride(nil) end
	if k then render.SetColorModulation(1, 1, 1) end
	render.SuppressEngineLighting(false)
end
local nuits, prochaineNuit = {}, 0
hook.Add("Think", "a2_ferm_nuit", function()
	if CurTime() < prochaineNuit then return end
	prochaineNuit = CurTime() + 1
	if not etat.allume or not majTete() then
		for e in pairs(nuits) do if IsValid(e) then e.RenderOverride = nil end nuits[e] = nil end
		return
	end
	for e in pairs(nuits) do if not IsValid(e) then nuits[e] = nil end end
	for _, e in ipairs(ents.FindByClass("prop_physics")) do
		if IsValid(e) and not nuits[e] and not e.a2_cache then   -- a2_cache : disques du socle cachés par a2_sequence
			local p = versBuild(e:GetPos())
			if math.abs(p.x) <= F.BX and math.abs(p.y) <= F.BX and p.z >= F.BZ0 and p.z <= F.BZ1 then
				e.RenderOverride = dessinNuit; nuits[e] = true
			end
		end
	end
end)
-- autres scripts : éclairer un objet dessiné à la main, ou confier une entité client (doublures du banc)
hook.Add("a2_eclairage_nuit", "a2_ferm", function(pw) if not dedans() then return end eclairerNuit(pw) return true end)
hook.Add("a2_eclairer", "a2_ferm", function(e) if IsValid(e) then e.RenderOverride = dessinNuit; nuits[e] = true end end)

-- ---------- commandes ----------
concommand.Add("a2_fermeture", function(_, _, args)
	etat.allume = tonumber(args[1] or "") == 1
	temps.n, temps.total, temps.pic = 0, 0, 0
	print("[a2_fermeture] " .. (etat.allume and "allumée" or "éteinte"))
end)
concommand.Add("a2_fermeture_brouillard", function(_, _, args)
	local a, b = tonumber(args[1] or ""), tonumber(args[2] or "")
	if not a or not b or a < 0 or b <= a then print("[a2_fermeture] usage : a2_fermeture_brouillard <debut> <opaque>") return end
	F.FOG0, F.FOG1 = a, b
	print("[a2_fermeture] brouillard : " .. a .. " à " .. b)
end)
-- ---------- props de collision masqués côté client (le sable en script est la seule surface visible) ----------
-- Seulement les plaques et tubes PHX (models/hunter/plates, models/hunter/tubes) dans la boîte de scène ;
-- la collision ne change pas (SetNoDraw est visuel, client seulement).
local MASQUABLES = { "^models/hunter/plates/", "^models/hunter/tubes/" }
local masques, prochainMasque = {}, 0
local function masquable(e)
	local m = string.lower(e:GetModel() or "")
	for _, motif in ipairs(MASQUABLES) do if string.find(m, motif) then return true end end
	return false
end
hook.Add("Think", "a2_ferm_masquer", function()
	if CurTime() < prochainMasque then return end
	prochainMasque = CurTime() + 1
	local voulu = etat.masquer and dedans()
	for e in pairs(masques) do
		if not IsValid(e) then masques[e] = nil elseif not voulu then e:SetNoDraw(false); masques[e] = nil end
	end
	if not voulu then return end
	for _, e in ipairs(ents.FindByClass("prop_physics")) do
		if IsValid(e) and not masques[e] and masquable(e) then
			local p = versBuild(e:GetPos())
			if math.abs(p.x) <= F.BX and math.abs(p.y) <= F.BX and p.z >= F.BZ0 and p.z <= F.BZ1 then
				e:SetNoDraw(true); masques[e] = true
			end
		end
	end
end)
concommand.Add("a2_fermeture_masquer", function(_, _, args)
	etat.masquer = tonumber(args[1] or "") == 1
	prochainMasque = 0
	print("[a2_fermeture] props de collision masqués : " .. tostring(etat.masquer))
end)

concommand.Add("a2_fermeture_mesure", function()
	local moy = temps.n > 0 and temps.total / temps.n or 0
	local ligne = string.format("%s fermeture appels=%d moyenne_ms=%.4f pic_ms=%.4f brume=%d", os.date("%H:%M:%S"),
		temps.n, moy, temps.pic, F.N_BRUME)
	print("[a2_fermeture] " .. ligne)
	file.CreateDir("a2_fermeture")
	file.Append("a2_fermeture/mesure.txt", ligne .. "\n")
	temps.n, temps.total, temps.pic = 0, 0, 0
end)

print("[a2_fermeture] chargée passe 17")   -- trace de chargement (rechargement à chaud vérifiable dans la console)
