-- Temps 6 bis à 6 fin : le lapin qui broute, la tache et les poils, les brins arrachés sous ses pas, la fumée noire
-- qui l'emporte. L'Arrancar est un vrai joueur (désigné par sumii_arrancar). Chargé après cl_souvenirs.
local C, M, R = SumiiMI.config, SumiiMI.monde, SumiiMI.arrancar
local A, K, SC = SumiiAncre, SumiiNoyau, SumiiScene

local POINT = Vector(0, 0, 0)
local function monde(x, y, z)
	POINT:SetUnpacked(x, y, z)
	return A.versMonde(POINT)
end
local function arrancar()
	local e = SC.arrancar > 0 and Entity(SC.arrancar) or nil
	if IsValid(e) and e:IsPlayer() then return e end
end

local vent = SC.facteurVent
function SC.facteurVent() return vent() * R.facteurVent(SC.S) end

-- ---------- lapin (modèle côté joueur, 0 posé) ----------
local lapin = nil
local function retirerLapin()
	if IsValid(lapin) then lapin:Remove() end
	lapin = nil
end
local function poserLapin()
	lapin = ClientsideModel("models/compagnons/rabbit.mdl", RENDERGROUP_OPAQUE)
	if not IsValid(lapin) then return end
	lapin:SetNoDraw(true)
	lapin:SetPos(monde(R.LAPIN[1], R.LAPIN[2], 1))
	local dos = math.deg(math.atan2(R.LAPIN[2], R.LAPIN[1]))        -- il tourne le dos au centre : il ne la voit pas
	lapin:SetAngles(A.tete():LocalToWorldAngles(Angle(0, dos, 0)))
	local seq = lapin:LookupSequence("idle")
	if seq >= 0 then lapin:ResetSequence(seq) end
end
local function dessinerLapin()
	if not R.lapin(SC.S) then retirerLapin() return end
	if not IsValid(lapin) then poserLapin() end
	if not IsValid(lapin) then return end
	lapin:FrameAdvance(FrameTime())
	local k = SC.lumiere()
	render.SuppressEngineLighting(true)
	render.ResetModelLighting(0.5 * k, 0.36 * k, 0.36 * k)
	render.SetModelLighting(BOX_TOP, 0.9 * k, 0.6 * k, 0.55 * k)
	lapin:DrawModel()
	render.SuppressEngineLighting(false)
end

-- ---------- brins arrachés sous ses pas ----------
local pas, dernierPas = {}, nil
local function suivrePas(maintenant)
	if SC.S.i ~= R.COURSE then dernierPas = nil return end
	local e = arrancar()
	if not e then return end
	local ou = A.versBuild(e:GetPos())
	if dernierPas and ou:DistToSqr(dernierPas) < 34 * 34 then return end
	dernierPas = ou
	pas[#pas + 1] = { x = ou.x, y = ou.y, z = ou.z, t = maintenant }
	if #pas > 16 then table.remove(pas, 1) end       -- borné : seuls les derniers pas volent encore
end
local function dessinerBrins(maintenant)
	render.SetColorMaterial()
	for _, p in ipairs(pas) do
		local s = maintenant - p.t
		if s < R.VIE_BRIN then
			for i = 1, R.BRINS do
				local x, y, z = R.brin(i, s)
				local pied = monde(p.x + x, p.y + y, p.z + z)
				local pointe = monde(p.x + x * 1.3, p.y + y * 1.3, p.z + z + 11)
				local flanc = monde(p.x + x - y * 0.12, p.y + y + x * 0.12, p.z + z + 2)
				mesh.Begin(MATERIAL_TRIANGLES, 1)
				mesh.Position(pied); mesh.Color(70, 96, 22, 255); mesh.AdvanceVertex()
				mesh.Position(flanc); mesh.Color(96, 124, 30, 255); mesh.AdvanceVertex()
				mesh.Position(pointe); mesh.Color(150, 168, 54, 255); mesh.AdvanceVertex()
				mesh.End()
			end
		end
	end
end

K.hook("PostDrawOpaqueRenderables", "sumii_mi_arrancar", function(profondeur, ciel)
	if profondeur or ciel or not A.tete() or not A.dedans(EyePos()) then return end
	dessinerLapin()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	render.OverrideDepthEnable(true, true)             -- le matériau « color » n'écrit pas la profondeur de lui-même
	dessinerBrins(CurTime())
	render.OverrideDepthEnable(false, false)
	render.CullMode(MATERIAL_CULLMODE_CCW)
end)

-- ---------- tache, poils, fumée ----------
local VOILE = CreateMaterial("sumii_mi_arrancar_v1", "UnlitGeneric", { ["$basetexture"] = "particle/smokesprites0001",
	["$translucent"] = "1", ["$vertexcolor"] = "1", ["$vertexalpha"] = "1" })
local POIL, NOIR = Color(236, 226, 214, 220), Color(8, 6, 9, 255)
local function coinTache(a, rayon, alpha)
	local r = rayon * (1 + 0.22 * math.sin(a * 3) + 0.13 * math.sin(a * 7))    -- bord irrégulier, pas un disque
	mesh.Position(monde(R.LAPIN[1] + math.cos(a) * r, R.LAPIN[2] + math.sin(a) * r, 2.5))
	mesh.Color(30, 6, 5, alpha); mesh.AdvanceVertex()
end
local function dessinerTache(opacite)
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_TRIANGLES, 28)
	for i = 0, 27 do
		mesh.Position(monde(R.LAPIN[1], R.LAPIN[2], 2.5)); mesh.Color(30, 6, 5, 255 * opacite); mesh.AdvanceVertex()
		coinTache(i / 28 * math.pi * 2, 30, 255 * opacite)
		coinTache((i + 1) / 28 * math.pi * 2, 30, 255 * opacite)
	end
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end
local function dessinerPoils(t)
	render.SetMaterial(VOILE)
	for i = 1, 30 do
		local g, h = (i * 0.6180339887) % 1, (i * 0.3819660113) % 1
		local p = (t * 0.7 + h) % 1
		local x = R.LAPIN[1] + (g - 0.5) * 90 * p
		local y = R.LAPIN[2] + (h - 0.5) * 90 * p
		local taille = 4 + 4 * g
		POIL.a = 220 * (1 - p)
		render.DrawSprite(monde(x, y, 10 + 70 * p * (1 - p)), taille, taille * 0.8, POIL)
	end
end
local lieuFumee = nil                              -- gardé : le joueur caché peut déjà être parti en noclip
local function dessinerFumee(maintenant)
	local t0 = SC.S.inst.fumee
	if not t0 or SC.S.i < R.FUMEE or maintenant - t0 > 4 then lieuFumee = nil return end
	if not lieuFumee then
		local e = arrancar()
		lieuFumee = e and A.versBuild(e:GetPos()) or Vector(R.LAPIN[1], R.LAPIN[2], 0)
	end
	render.SetMaterial(VOILE)
	for i = 1, R.VOLUTES do
		local x, y, z, taille, alpha = R.volute(i, maintenant - t0)
		NOIR.a = alpha
		render.DrawSprite(monde(lieuFumee.x + x, lieuFumee.y + y, lieuFumee.z + z), taille, taille, NOIR)
	end
end
K.hook("PostDrawTranslucentRenderables", "sumii_mi_arrancar_voiles", function(profondeur, ciel)
	if profondeur or ciel or not A.tete() or not A.dedans(EyePos()) then return end
	local maintenant = CurTime()
	local opacite = R.tache(SC.S, maintenant)
	if opacite > 0 then dessinerTache(opacite) end
	if SC.S.i == R.DEVORE then dessinerPoils(maintenant) end
	dessinerFumee(maintenant)
end)

-- [à prouver au banc] les accessoires posés sur ses os par EVO sont dessinés à part : ils pourraient rester visibles
K.hook("PrePlayerDraw", "sumii_mi_arrancar_cache", function(joueur)
	if joueur:EntIndex() == SC.arrancar and R.cache(SC.S, CurTime()) then return true end
end)

-- ---------- sons entendus par tous ----------
local avant, prochaineBouchee = nil, 0
local function bouchee(volume, hauteur)
	sound.Play(string.format(C.SONS.BOUCHEE, math.random(1, 7)), monde(R.LAPIN[1], R.LAPIN[2], 12), 70, hauteur, volume)
end
K.hook("Think", "sumii_mi_arrancar", function()
	local maintenant = CurTime()
	suivrePas(maintenant)
	if avant and A.tete() and A.dedans(EyePos()) then
		local S = SC.S
		if S.inst.devore and M.echu(S.inst.devore, 0, avant, maintenant) then bouchee(1, 55) end   -- le coup sourd
		if S.i == R.DEVORE and maintenant >= prochaineBouchee then
			prochaineBouchee = maintenant + math.Rand(0.5, 1.2)
			bouchee(0.35, math.random(70, 90))
		end
		if S.inst.fumee and M.echu(S.inst.fumee, 0, avant, maintenant) then
			sound.Play(C.SONS.RAFALE, monde(R.LAPIN[1], R.LAPIN[2], 40), 80, 60, 1)
		end
	end
	avant = maintenant
end)
K.surExtinction(function()
	retirerLapin()
	pas, dernierPas, lieuFumee, avant, prochaineBouchee = {}, nil, nil, nil, 0
end)
