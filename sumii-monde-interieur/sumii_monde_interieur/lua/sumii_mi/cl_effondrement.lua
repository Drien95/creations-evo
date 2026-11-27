-- Temps 8 : le ciel se fissure et tombe, la lisière s'enfonce, l'herbe s'éteint, puis tout devient blanc.
-- La boîte blanche elle-même est peinte par cl_cylindre ; cl_noyau cache alors tous les autres dessins.
local C, M, E = SumiiMI.config, SumiiMI.monde, SumiiMI.effondrement
local A, K, SC = SumiiAncre, SumiiNoyau, SumiiScene

local MARGE = 2600
local LOIN = 1400                                -- les props au-delà (lisière, grands arbres) s'enfoncent avec elle
local CERISIER = "models/propper/rp_seireitei_v1/watcher_skr_treesakura_1.mdl"   -- plié et enfoncé par cl_perte

function SC.blanc() return E.blanc(SC.S, CurTime()) end
function SC.enfoncement() return E.enfoncement(SC.S, CurTime()) end

local herbeAvant, pliAvant = SC.herbe, SC.pliForet
function SC.herbe(bloc, k, ky)
	local h
	h, k, ky = herbeAvant(bloc, k, ky)
	return h * E.herbe(SC.S, CurTime(), math.sqrt(bloc.x * bloc.x + bloc.y * bloc.y)), k, ky
end
local descente = Matrix()
function SC.pliForet()
	local m, bas = pliAvant(), SC.enfoncement()
	if bas <= 0 then return m end
	if not m then descente:Identity() m = descente end
	m:SetField(3, 4, -bas)
	return m
end

-- ---------- props : les lointains s'enfoncent, puis tous sont masqués ; tout est rendu au retour ----------
local liste, prochaine, enfonces, masques = {}, 0, {}, {}
local function rendre(table_, fn)
	for e in pairs(table_) do
		if IsValid(e) then fn(e) end
		table_[e] = nil
	end
end
local function redresser() rendre(enfonces, function(e) e:DisableMatrix("RenderMultiply") end) end
local function montrer() rendre(masques, function(e) e:SetNoDraw(false) end) end
local function props(maintenant)
	local bas, caches = E.enfoncement(SC.S, maintenant), E.masque(SC.S, maintenant)
	if bas <= 0 then redresser() end
	if not caches then montrer() end
	if (bas <= 0 and not caches) or not A.tete() then return end
	if maintenant >= prochaine then
		prochaine, liste = maintenant + 0.5, {}
		for _, e in ipairs(ents.GetAll()) do               -- pas de recherche par zone : vide à plusieurs
			-- les props du dupe, et les cailloux que le sol pose lui-même (vus flottant dans le blanc au banc du 27/11) ;
			-- marge large : des rochers ont leur centre enfoui sous le bas de la boîte
			if IsValid(e) and (e.sumiiCaillou or e:GetClass() == "prop_physics") then
				local p = A.versBuild(e:GetPos())
				if p.x * p.x + p.y * p.y <= MARGE * MARGE and p.z > -1500 and p.z < C.BZ1 then liste[#liste + 1] = e end
			end
		end
	end
	for _, e in ipairs(liste) do
		if IsValid(e) then
			if caches then
				e:SetNoDraw(true)
				masques[e] = true
			elseif string.lower(e:GetModel() or "") ~= CERISIER then
				local p = A.versBuild(e:GetPos())
				if p.x * p.x + p.y * p.y > LOIN * LOIN then
					local m = Matrix()
					m:SetTranslation(e:WorldToLocal(e:GetPos() - Vector(0, 0, bas)))
					e:EnableMatrix("RenderMultiply", m)
					enfonces[e] = true
				end
			end
		end
	end
end

-- ---------- veines du ciel (peintes dans la passe du ciel de P1), recette des veines du Lac noir ----------
-- bord sombre un peu plus large, braise carmin, cœur orangé plus clair, halo doux sans bord dur, léger scintillement,
-- tête de braise qui court pendant l'ouverture. Bande continue : la largeur est portée par les points.
local VEINES = E.fissures()
local RAYON, ECHELLE = 470, 1.15
local repere, coin = Matrix(), Vector(0, 0, 0)
local GEO = {}                                   -- par veine : points sur le dôme et travers (unitaire) en chaque point
for i, v in ipairs(VEINES) do
	local pts, travers = {}, {}
	for k, p in ipairs(v) do
		local a, e = math.rad(p[1]), math.rad(p[2])
		pts[k] = Vector(math.cos(a) * math.cos(e), math.sin(a) * math.cos(e), math.sin(e)) * RAYON
	end
	for k = 1, #pts do                           -- normale lissée aux jonctions : pas de pointillés
		local t = pts[k]:Cross(pts[math.min(k + 1, #pts)] - pts[math.max(k - 1, 1)])
		t:Normalize()
		travers[k] = t
	end
	GEO[i] = { p = pts, t = travers, v = v }
end
local function sommetVeine(p, travers, ecart, r, g, b, alpha)
	coin:SetUnpacked(p.x + travers.x * ecart, p.y + travers.y * ecart, p.z + travers.z * ecart)
	mesh.Position(coin); mesh.Color(r, g, b, alpha); mesh.AdvanceVertex()
end
-- les sommets d'une veine jusqu'au point n, pour une couche (à appeler entre mesh.Begin et mesh.End)
local function remplir(geo, n, facteur, marge, r, g, b, centre, bord)
	for k = 1, n - 1 do
		local a, c = geo.p[k], geo.p[k + 1]
		local ta, tc = geo.t[k], geo.t[k + 1]
		local wa, wc = geo.v[k][3] * ECHELLE * facteur + marge, geo.v[k + 1][3] * ECHELLE * facteur + marge
		for cote = -1, 1, 2 do                     -- deux demi-bandes : pleine au centre, fondue vers le bord
			sommetVeine(a, ta, 0, r, g, b, centre); sommetVeine(a, ta, cote * wa, r, g, b, bord)
			sommetVeine(c, tc, cote * wc, r, g, b, bord); sommetVeine(c, tc, 0, r, g, b, centre)
		end
	end
end
-- couches, du dessous au dessus : facteur de largeur, marge, rouge, vert, bleu, opacité au centre, au bord, scintille
local COUCHES = {
	{ 4.2, 3.2, 255, 52, 22, 105, 0, true },       -- halo doux et serré
	{ 1, 1.2, 16, 2, 4, 255, 235, false },         -- la fissure, sombre : elle tranche sur le ciel rouge
	{ 0.86, 0.1, 232, 36, 18, 255, 215, true },    -- braise carmin
	{ 0.36, 0.05, 255, 168, 104, 255, 240, true }, -- cœur orangé, plus clair
}
local BRAISE = Material("sprites/light_glow02_add")
local lueurTete = Color(255, 150, 80, 230)
-- Une veine finie est figée dans ses propres maillages (une fois). Quand toutes sont finies, elles sont réunies en
-- un maillage par couche, une seule fois : plus aucun recalcul ensuite.
local reunies, seules = nil, {}
local function maillage(veines, q)
	local quads = 0
	for _, geo in ipairs(veines) do quads = quads + (#geo.p - 1) * 2 end
	local m = Mesh()
	mesh.Begin(m, MATERIAL_QUADS, quads)
	for _, geo in ipairs(veines) do remplir(geo, #geo.p, q[1], q[2], q[3], q[4], q[5], q[6], q[7]) end
	mesh.End()
	return m
end
local function oublierSeules()
	for geo, couches in pairs(seules) do
		for _, m in ipairs(couches) do m:Destroy() end
		seules[geo] = nil
	end
end
local function oublierFiges()
	oublierSeules()
	for _, m in ipairs(reunies or {}) do m:Destroy() end
	reunies = nil
end
K.surExtinction(oublierFiges)
local function figee(geo)
	local couches = seules[geo]
	if not couches then
		couches = {}
		for k, q in ipairs(COUCHES) do couches[k] = maillage({ geo }, q) end
		seules[geo] = couches
	end
	return couches
end
local function reunir()
	if reunies then return end
	reunies = {}
	for k, q in ipairs(COUCHES) do reunies[k] = maillage(GEO, q) end
	oublierSeules()
end
local finies, ouvertes = {}, {}
local function dessinerVeines(s)
	table.Empty(finies)
	table.Empty(ouvertes)
	for _, geo in ipairs(GEO) do
		local part = math.Clamp((s - geo.v.debut) / (geo.v.fin - geo.v.debut), 0, 1)
		local n = math.floor(part * (#geo.p - 1) + 0.5) + 1
		if part >= 1 then finies[#finies + 1] = geo
		elseif part > 0 and n >= 2 then ouvertes[#ouvertes + 1] = { geo = geo, n = n } end
	end
	local toutes = #finies == #GEO
	if toutes then reunir() end
	render.SetColorMaterial()
	repere:Identity()
	repere:SetAngles(A.tete():GetAngles())
	cam.PushModelMatrix(repere)
	for k, q in ipairs(COUCHES) do
		if toutes then reunies[k]:Draw()
		else
			for _, geo in ipairs(finies) do figee(geo)[k]:Draw() end
		end
		for i, o in ipairs(ouvertes) do
			local sc = q[8] and (0.86 + 0.14 * math.sin(s * 7.3 + i * 1.9) * math.sin(s * 3.1 + i * 0.7)) or 1
			mesh.Begin(MATERIAL_QUADS, (o.n - 1) * 2)
			remplir(o.geo, o.n, q[1], q[2], q[3], q[4], q[5], q[6] * sc, q[7] * sc)
			mesh.End()
		end
	end
	cam.PopModelMatrix()
	render.SetMaterial(BRAISE)                           -- la tête de braise qui court pendant que la fente s'ouvre
	for _, o in ipairs(ouvertes) do
		if o.geo.v[1][3] <= 0.2 and #o.geo.p > 40 then render.DrawSprite(repere * o.geo.p[o.n], 22, 22, lueurTete) end
	end
end
local cielAvant = SC.cielPar
function SC.cielPar(soleil)
	cielAvant(soleil)
	local s = E.instant(SC.S, CurTime())
	if s and s > 1 and s < 18 and A.tete() then dessinerVeines(s) end
end

-- ---------- morceaux de ciel qui tombent derrière la lisière, et rideau de poussière ----------
local function sommet(x, y, z, r, g, b)
	mesh.Position(A.versMonde(Vector(x, y, z))); mesh.Color(r, g, b, 255); mesh.AdvanceVertex()
end
local function eclats(s)
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	render.OverrideDepthEnable(true, true)            -- le matériau « color » n'écrit pas la profondeur de lui-même
	for i = 1, E.ECLATS do
		local x, y, z, angle, taille = E.eclat(i, s)
		if x then
			local rayon = math.sqrt(x * x + y * y)
			local tx, ty = -y / rayon, x / rayon            -- l'éclat reste à plat contre le mur
			local c, sn = math.cos(angle), math.sin(angle)
			mesh.Begin(MATERIAL_TRIANGLES, 1)
			sommet(x + tx * c * taille, y + ty * c * taille, z + sn * taille, 190, 38, 22)
			sommet(x + tx * math.cos(angle + 2.4) * taille, y + ty * math.cos(angle + 2.4) * taille, z + math.sin(angle + 2.4) * taille, 96, 10, 10)
			sommet(x + tx * math.cos(angle + 4.1) * taille * 0.7, y + ty * math.cos(angle + 4.1) * taille * 0.7, z + math.sin(angle + 4.1) * taille * 0.7, 255, 196, 170)
			mesh.End()
		end
	end
	render.OverrideDepthEnable(false, false)
	render.CullMode(MATERIAL_CULLMODE_CCW)
end
K.hook("PostDrawOpaqueRenderables", "sumii_mi_effondrement", function(profondeur, ciel)
	if profondeur or ciel or not A.tete() or not A.dedans(EyePos()) then return end
	local s = E.instant(SC.S, CurTime())
	if s and s >= 4 and s < 14 then eclats(s) end
end)

local POUSSIERE = CreateMaterial("sumii_mi_poussiere_v1", "UnlitGeneric", { ["$basetexture"] = "particle/smokesprites0001",
	["$translucent"] = "1", ["$vertexcolor"] = "1", ["$vertexalpha"] = "1" })
local teinte = Color(112, 84, 66, 255)
local function rideau(s)
	local force = math.Clamp((s - 3) / 2, 0, 1) * math.Clamp((15 - s) / 2, 0, 1)
	if force <= 0 then return end
	render.SetMaterial(POUSSIERE)
	for i = 1, 72 do
		local g, h = (i * 0.6180339887) % 1, (i * 0.3819660113) % 1
		local a, r = i / 72 * math.pi * 2, 1900 + 220 * h
		local monte = ((s - 3) * (0.12 + 0.1 * g) + h) % 1
		teinte.a = 170 * force * math.sin(monte * math.pi)
		render.DrawSprite(A.versMonde(Vector(math.cos(a) * r, math.sin(a) * r, 20 + 220 * monte)), 260 + 200 * g, 150 + 110 * g, teinte)
	end
end
K.hook("PostDrawTranslucentRenderables", "sumii_mi_effondrement_voiles", function(profondeur, ciel)
	if profondeur or ciel or not A.tete() or not A.dedans(EyePos()) then return end
	local s = E.instant(SC.S, CurTime())
	if s and s < 15 then rideau(s) end
end)

-- ---------- voile blanc (fondu vers la boîte, puis retour en douceur), grondement, secousse chez Sumii ----------
local avant, etaitBlanc, retourDe = nil, false, nil
-- opacité du voile plein écran : le fondu vers la boîte, ou sa sortie à la reconstruction
function SC.voileDeLaBoite()
	local maintenant = CurTime()
	local blanc = E.blanc(SC.S, maintenant)
	if blanc > 0 and blanc < 1 then return blanc end
	if retourDe then return math.Clamp(1 - (maintenant - retourDe) / 2, 0, 1) end
	return 0
end
K.hook("Think", "sumii_mi_effondrement", function()
	local maintenant = CurTime()
	props(maintenant)
	local blanc = E.blanc(SC.S, maintenant)
	if etaitBlanc and blanc <= 0 then retourDe = maintenant end
	etaitBlanc = blanc >= 1
	if retourDe and maintenant - retourDe > 2 then retourDe = nil end
	local t0 = SC.S.inst.effondrement
	if avant and t0 and A.tete() and A.dedans(EyePos()) and M.echu(t0, 0, avant, maintenant) then
		SC.jouerBorne("effondrement", nil, C.SONS.GRONDEMENT_FINAL, 1, 70, 15)
		if LocalPlayer():EntIndex() == SC.cible then util.ScreenShake(LocalPlayer():GetPos(), 6, 40, 3, 400) end
	end
	avant = maintenant
end)
K.surExtinction(function()
	redresser()
	montrer()
	liste, prochaine, avant, etaitBlanc, retourDe = {}, 0, nil, false, nil
end)
