-- Fermeture : un cylindre en script (0 posé) cache la vraie map. Il sert de fenêtre au pochoir : le ciel de P1 est
-- repeint dedans, avec une caméra décalée par plan (parallaxe). Dépend de SumiiP1 (ciel) et de SumiiAncre.
local C, G, A, K = SumiiMI.config, SumiiMI.ciel, SumiiAncre, SumiiNoyau
local SEGMENTS = 96
local HORIZON, SOUSBOIS = { 156, 182, 222 }, { 40, 62, 44 }
-- le mur n'est visible que sous le bas du dôme (vu d'en haut) : sombre au pied comme un sous-bois, brume au-dessus
local HAUTEURS = { { C.BZ0, SOUSBOIS }, { 0, SOUSBOIS }, { 280, HORIZON }, { C.BZ1, HORIZON } }
local maillage, cle, erreur = nil, nil, false
local blanche = nil                               -- la boîte blanche de la fin : mur, plafond et sol, blanc VIF
local BLANC_MUR, BLANC_PIED, BLANC_SOL, BLANC_PLAFOND = { 255, 255, 255 }, { 246, 246, 248 }, { 241, 241, 244 }, { 251, 251, 252 }
local ZERO = Vector(0, 0, 0)

local function detruire()
	if maillage then maillage:Destroy() end
	if blanche then blanche:Destroy() end
	maillage, blanche, cle = nil, nil, nil
end

local function point(a, z, r) return A.versMonde(Vector(math.cos(a) * r, math.sin(a) * r, z)) end
local function sommet(p, c)
	mesh.Position(p); mesh.Color(c[1], c[2], c[3], 255); mesh.AdvanceVertex()
end
local function construire()
	maillage = Mesh()
	mesh.Begin(maillage, MATERIAL_TRIANGLES, SEGMENTS * ((#HAUTEURS - 1) * 2 + 1))
	local centre = A.versMonde(Vector(0, 0, C.BZ1))
	for i = 0, SEGMENTS - 1 do
		local a0, a1 = i / SEGMENTS * math.pi * 2, (i + 1) / SEGMENTS * math.pi * 2
		for k = 1, #HAUTEURS - 1 do
			local bas, haut = HAUTEURS[k], HAUTEURS[k + 1]
			local b0, b1 = point(a0, bas[1], G.RAYON), point(a1, bas[1], G.RAYON)
			local h0, h1 = point(a0, haut[1], G.RAYON), point(a1, haut[1], G.RAYON)
			sommet(b0, bas[2]); sommet(b1, bas[2]); sommet(h1, haut[2])
			sommet(b0, bas[2]); sommet(h1, haut[2]); sommet(h0, haut[2])
		end
		sommet(centre, HORIZON); sommet(point(a0, C.BZ1, G.RAYON), HORIZON); sommet(point(a1, C.BZ1, G.RAYON), HORIZON)
	end
	mesh.End()
end

local function construireBlanche()
	blanche = Mesh()
	mesh.Begin(blanche, MATERIAL_TRIANGLES, SEGMENTS * 4)
	local haut, bas = A.versMonde(Vector(0, 0, C.BZ1)), A.versMonde(Vector(0, 0, 0.6))
	for i = 0, SEGMENTS - 1 do
		local a0, a1 = i / SEGMENTS * math.pi * 2, (i + 1) / SEGMENTS * math.pi * 2
		local b0, b1 = point(a0, 0.6, G.RAYON), point(a1, 0.6, G.RAYON)
		local h0, h1 = point(a0, C.BZ1, G.RAYON), point(a1, C.BZ1, G.RAYON)
		sommet(b0, BLANC_PIED); sommet(b1, BLANC_PIED); sommet(h1, BLANC_MUR)
		sommet(b0, BLANC_PIED); sommet(h1, BLANC_MUR); sommet(h0, BLANC_MUR)
		sommet(haut, BLANC_PLAFOND); sommet(h0, BLANC_MUR); sommet(h1, BLANC_MUR)
		sommet(bas, BLANC_SOL); sommet(b0, BLANC_PIED); sommet(b1, BLANC_PIED)
	end
	mesh.End()
end

local function oeilBuild() return A.versBuild(EyePos()) end

-- le cylindre dessine-t-il pour cette vue ? (ciel de P1 prêt, œil dans le mur)
local function couvre()
	if erreur or not SumiiP1 or not SumiiP1.visible() or not A.tete() then return false end
	local p = oeilBuild()
	return G.dedans(p.x, p.y)
end

local function camera(plan, rayonMaillage)
	local distance
	if plan == "nuages" then distance = G.NUAGES elseif plan then distance = G.PLANS[plan] end
	if not distance then return ZERO end
	local p, tete = oeilBuild(), A.tete()
	local x, y, z = G.decalage(p.x, p.y, p.z, rayonMaillage, distance)
	return tete:LocalToWorld(Vector(x, y, z)) - tete:GetPos()     -- le ciel est construit dans les axes du repère
end

local function peindreBlanc()
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	render.OverrideDepthEnable(true, true)
	blanche:Draw()
end

local function peindre()
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(1)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	-- 1) le mur : il écrit sa profondeur (la map derrière disparaît) et marque ses pixels visibles
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	render.OverrideDepthEnable(true, true)             -- le matériau « color » n'écrit pas la profondeur de lui-même
	maillage:Draw()
	-- un second OverrideDepthEnable(true, ...) ne change pas le réglage : désactiver d'abord (prouvé au banc, 27/11)
	render.OverrideDepthEnable(false, false)
	-- 2) le ciel, dans ces pixels seulement, sans toucher à la profondeur
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.OverrideDepthEnable(true, false)
	SumiiP1.peindreCiel(camera)
end

-- AVANT le décor des pièces : le matériau « color » de P1 n'écrit pas la profondeur. Dessiné après lui, le mur
-- repeignait le ciel sur la forêt (vu au banc le 27/11).
K.hook("PreDrawOpaqueRenderables", "sumii_mi_cylindre", function(profondeur, ciel)
	if profondeur or ciel or not couvre() then return end
	local tete = A.tete()
	local p, a = tete:GetPos(), tete:GetAngles()
	local neuve = string.format("%.0f %.0f %.0f %.1f %.1f %.1f", p.x, p.y, p.z, a.p, a.y, a.r)
	if neuve ~= cle then detruire() construire() construireBlanche() cle = neuve end
	local brouillard = render.GetFogMode()
	render.FogMode(MATERIAL_FOG_NONE)                -- le brouillard de la map ne doit pas voiler le mur
	local fini = SumiiScene and SumiiScene.blanc and SumiiScene.blanc() >= 1
	local bon, motif = pcall(fini and peindreBlanc or peindre)
	render.SetStencilEnable(false)                   -- état de rendu remis, même après une erreur
	render.OverrideDepthEnable(false, false)
	render.ClearStencil()
	render.CullMode(MATERIAL_CULLMODE_CCW)
	render.FogMode(brouillard)
	if not bon then erreur = true; print("[sumii] cylindre coupé après une erreur : " .. tostring(motif)) end
end)
K.surExtinction(function() detruire() erreur = false end)

SumiiCylindre = {
	couvre = couvre,
	-- le halo du soleil de P1 se pose au ras du mur (nil : pas de cylindre, distance d'origine)
	distanceHalo = function(oeil, soleil)
		if not couvre() then return nil end
		return G.distanceMur(oeil.x, oeil.y, soleil.x, soleil.y, soleil.z)
	end,
}
