-- Temps 6, vu par tous : ciel rouge venu de l'est, soleil qui plonge, silhouette géante, trait rouge, vent qui forcit.
-- Chargé après cl_apparition ; les dessins de ciel sont appelés par P1, dans ses caméras.
local C, V = SumiiMI.config, SumiiMI.souvenirs
local A, K, SC = SumiiAncre, SumiiNoyau, SumiiScene

local rouge, dernier = 0, nil                    -- rouge affiché : suit l'état, redescend en 1 s au retour
local function azimutSoleil() return math.rad(C.SOLEIL_AZ) end

-- ---------- crochets lus par P1 ----------
function SC.teinte() return rouge end
local lumiereAvant = SC.lumiere
function SC.lumiere()
	local avant = lumiereAvant()
	return math.min(avant, avant + (V.SOMBRE - avant) * rouge)
end
function SC.facteurVent() return V.facteurVent(SC.S, CurTime()) end

local function elevation() return C.SOLEIL_EL + (V.SOLEIL_FIN - C.SOLEIL_EL) * rouge end
function SC.voileHalo() return V.voileHalo(elevation()) end
function SC.dirSoleil(tete)
	if rouge <= 0 then return nil end
	local az, el = azimutSoleil(), math.rad(elevation())
	local d = Vector(math.cos(az) * math.cos(el), math.sin(az) * math.cos(el), math.sin(el))
	return tete:LocalToWorld(d) - tete:GetPos()
end
function SC.teinteNuage(r, g, b)
	return r * (1 - 0.45 * rouge), g * (1 - 0.82 * rouge), b * (1 - 0.86 * rouge)
end

-- ---------- ciel : tout est écrit dans les axes du build, tournés une seule fois par la matrice ----------
local POINT, REPERE, ZERO = Vector(0, 0, 0), Matrix(), Vector(0, 0, 0)
local function ouvrirRepere()
	local tete = A.tete()
	REPERE:Identity()
	REPERE:SetAngles(tete:GetAngles())
	cam.PushModelMatrix(REPERE)
end
local function sommet(x, y, z, r, g, b, a)
	POINT:SetUnpacked(x, y, z)
	mesh.Position(POINT); mesh.Color(r, g, b, a); mesh.AdvanceVertex()
end

local TOURS, ETAGES, RAYON = 24, 12, 495
local function direction(i, j)
	local a, e = i / TOURS * math.pi * 2, math.rad(-12 + (j / ETAGES) ^ 1.5 * 102)   -- serré près de l'horizon
	return math.cos(a) * math.cos(e), math.sin(a) * math.cos(e), math.sin(e)
end
local function coinCiel(i, j)
	local x, y, z = direction(i, j)
	local r, g, b = V.couleurCiel(math.max(z, 0))
	sommet(x * RAYON, y * RAYON, z * RAYON, r, g, b, 255 * V.alphaCiel(rouge, x))
end
function SC.voileRouge()
	if rouge <= 0 then return end
	render.SetColorMaterial()
	ouvrirRepere()
	mesh.Begin(MATERIAL_QUADS, TOURS * ETAGES)
	for i = 0, TOURS - 1 do
		for j = 0, ETAGES - 1 do
			coinCiel(i, j); coinCiel(i + 1, j); coinCiel(i + 1, j + 1); coinCiel(i, j + 1)
		end
	end
	mesh.End()
	cam.PopModelMatrix()
end

-- ombre géante voûtée, vue de face : (côté, haut) en unités du maillage de ciel, posée derrière les collines
local CORPS = { { -150, -60 }, { -128, 18 }, { -96, 56 }, { -44, 66 }, { -30, 92 }, { -34, 120 }, { -18, 140 },
	{ 6, 144 }, { 26, 128 }, { 28, 100 }, { 40, 72 }, { 104, 54 }, { 134, 10 }, { 152, -60 } }
local OMBRE_AZ, OMBRE_DIST = math.rad(190), 440
local OMBRE_LEVEE = 66                           -- relevée pour dépasser la lisière et les collines (à juger au banc)
local function pointOmbre(cote, haut, alpha)
	local ax, ay = math.cos(OMBRE_AZ), math.sin(OMBRE_AZ)
	sommet(ax * OMBRE_DIST - ay * cote, ay * OMBRE_DIST + ax * cote, haut + OMBRE_LEVEE, 18, 4, 8, alpha)
end
local function dessinerOmbre(opacite)
	render.SetColorMaterial()
	ouvrirRepere()
	mesh.Begin(MATERIAL_TRIANGLES, #CORPS - 1)
	for i = 1, #CORPS - 1 do                       -- éventail depuis le milieu du bas
		pointOmbre(0, -60, 235 * opacite)
		pointOmbre(CORPS[i][1], CORPS[i][2], 235 * opacite)
		pointOmbre(CORPS[i + 1][1], CORPS[i + 1][2], 235 * opacite)
	end
	mesh.End()
	cam.PopModelMatrix()
end

-- le couteau : un trait effilé, plein (l'additif est invisible sur un ciel clair), qui tranche le disque du soleil
-- à ce moment le soleil est sous l'horizon : le souvenir le fait reparaître au-dessus des arbres, et le trait
-- le tranche en son milieu
-- à ce moment le soleil est sous l'horizon : le souvenir le fait reparaître au-dessus des arbres, et le trait
-- le tranche en son milieu
local TRAIT_EL = math.rad(14)
local function placeDuTrait(distance)
	local az, tete = azimutSoleil(), A.tete()
	local d = Vector(math.cos(az) * math.cos(TRAIT_EL), math.sin(az) * math.cos(TRAIT_EL), math.sin(TRAIT_EL))
	return (tete:LocalToWorld(d) - tete:GetPos()) * distance
end
-- Disque en maillage plein : le halo additif ne se voyait pas sur ce ciel (prouvé au banc le 27/11).
-- anneaux : rayon intérieur, rayon extérieur, couleur, opacité au bord intérieur et au bord extérieur
local DISQUE = {
	{ 0, 21, { 255, 224, 176 }, 255, 255 },       -- le disque
	{ 21, 27, { 255, 186, 112 }, 235, 90 },       -- son bord
	{ 27, 62, { 255, 108, 56 }, 90, 0 },          -- sa lueur
}
local PANS = 36
local function soleilTranche(centre, opacite)
	local ang = centre:Angle()
	local droite, haut = ang:Right(), ang:Up()
	local function point(r, i, c, alpha)
		local a = i / PANS * math.pi * 2
		mesh.Position(centre + droite * (math.cos(a) * r) + haut * (math.sin(a) * r))
		mesh.Color(c[1], c[2], c[3], alpha * opacite); mesh.AdvanceVertex()
	end
	render.SetColorMaterial()
	for _, an in ipairs(DISQUE) do
		mesh.Begin(MATERIAL_QUADS, PANS)
		for i = 0, PANS - 1 do
			point(an[1], i, an[3], an[4]); point(an[2], i, an[3], an[5])
			point(an[2], i + 1, an[3], an[5]); point(an[1], i + 1, an[3], an[4])
		end
		mesh.End()
	end
end
local function dessinerTrait(soleil, opacite, longueur)
	local ang = soleil:Angle()
	local axe = ang:Right() * math.cos(math.rad(28)) + ang:Up() * math.sin(math.rad(28))
	local travers = ang:Up() * math.cos(math.rad(28)) - ang:Right() * math.sin(math.rad(28))
	local centre = soleil * 0.98
	soleilTranche(centre, opacite)
	local debut = centre - axe * 95
	local fin = debut + axe * (190 * longueur)
	local milieu = (debut + fin) * 0.5
	render.SetColorMaterial()
	for _, couche in ipairs({ { 7, 150, 10, 0 }, { 2.4, 255, 70, 40 } }) do      -- largeur, rouge, vert, bleu
		mesh.Begin(MATERIAL_QUADS, 1)
		for _, p in ipairs({ debut, milieu + travers * couche[1], fin, milieu - travers * couche[1] }) do
			mesh.Position(p); mesh.Color(couche[2], couche[3], couche[4], 255 * opacite); mesh.AdvanceVertex()
		end
		mesh.End()
	end
end

local cielAvant = SC.cielPar
function SC.cielPar(soleil)
	cielAvant(soleil)                              -- le nuage du temps 1
	local maintenant = CurTime()
	local ombre = V.silhouette(SC.S, maintenant)
	if ombre > 0 then dessinerOmbre(ombre) end
	local opacite, longueur = V.trait(SC.S, maintenant)
	if opacite then dessinerTrait(placeDuTrait(soleil:Length()), opacite, longueur) end
end

-- ---------- rouge affiché et plainte du vent ----------
local plainte = nil
local function tairePlainte(net)
	if not plainte then return end
	if net then plainte:Stop() else plainte:FadeOut(0.5) end
	plainte = nil
end
K.hook("Think", "sumii_mi_souvenirs", function()
	local maintenant = CurTime()
	rouge = V.adoucir(rouge, V.rouge(SC.S, maintenant), maintenant - (dernier or maintenant))
	dernier = maintenant
	local coupe = V.coupure(SC.S, maintenant)
	local volume = A.tete() and A.dedans(EyePos()) and not coupe and V.gemissement(SC.S, maintenant) or 0
	if volume <= 0.01 then tairePlainte(coupe)
	elseif not plainte then
		plainte = CreateSound(LocalPlayer(), C.SONS.PLAINTE)
		plainte:PlayEx(volume, 100)
	else plainte:ChangeVolume(volume, 0.5) end
end)
K.surExtinction(function()
	tairePlainte(true)
	rouge, dernier = 0, nil
end)
