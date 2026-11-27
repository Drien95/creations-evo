-- Temps 3 à 5 : détresse (poussière, tas), révélation (vent figé, lumière, yeux, oreilles), voix, nom.
-- Chargé après cl_temps, dont il complète les crochets d'herbe et utilise le lecteur de sons.
local C, M, T, P = SumiiMI.config, SumiiMI.monde, SumiiMI.terriers, SumiiMI.apparition
local A, K, SC = SumiiAncre, SumiiNoyau, SumiiScene

local ZERO, POINT, REPERE = Vector(0, 0, 0), Vector(0, 0, 0), Matrix()
local function etat() return SC.S end

-- ---------- crochets lus par les pièces ----------
function SC.lumiere() return P.lumiere(etat(), CurTime()) end
function SC.lapinCache() return not P.lapinEndormi(etat()) end

-- la voix couche l'herbe en un anneau qui s'élargit autour du terrier
local anneau = {}                                  -- recalculé une fois par image
local function majAnneau(maintenant)
	local rayon = P.rayonVoix(etat(), maintenant)
	anneau.rayon = rayon
	if not rayon then return end
	local n = P.terrier(etat())
	local h = T[n]
	anneau.n, anneau.x, anneau.y, anneau.fx = n, h.x + h.fx * 26, h.y + h.fy * 26, h.fx
	anneau.s = maintenant - etat().inst.voix
end
local herbeDeBase, fremitDeBase = SC.herbe, SC.fremit
function SC.herbe(bloc, k, ky)
	local h
	h, k, ky = herbeDeBase(bloc, k, ky)
	if anneau.rayon then
		local dx, dy = bloc.x - anneau.x, bloc.y - anneau.y
		local d = math.sqrt(dx * dx + dy * dy)
		local p = d > 1 and P.poussee(d, anneau.rayon, anneau.s) or 0
		if p > 0 then k, ky = k + p * dx / d, ky + p * dy / d end
	end
	return h, k, ky
end
function SC.fremit(n)
	local v = fremitDeBase(n)
	if anneau.rayon and n == anneau.n then          -- la touffe devant la bouche se couche fort
		v = v + 0.9 * math.sin(anneau.s / P.VOIX * math.pi) * (anneau.fx < 0 and -1 or 1)
	end
	return v
end

-- ---------- maillages fixes : oreilles et tas de terre ----------
local oreille, tas = nil, nil
local dessinerOreilles
local function triangle(a, b, c, col)
	for _, p in ipairs({ a, b, c }) do
		mesh.Position(p); mesh.Color(col[1], col[2], col[3], 255); mesh.AdvanceVertex()
	end
end
-- oreille de lapin noire et mate : lame plate à bout rond, origine au bout, pied 28 u plus bas.
-- profil : (hauteur sous le bout, demi-largeur, demi-épaisseur)
local PROFIL = { { 0, 0, 0 }, { 2, 2.6, 0.9 }, { 6, 4.2, 1.5 }, { 12, 4.8, 1.8 }, { 19, 4, 1.6 }, { 28, 2.4, 1.2 } }
local function construireOreille()
	local m = Mesh()
	local FACES_O = 8
	mesh.Begin(m, MATERIAL_TRIANGLES, (#PROFIL - 1) * FACES_O * 2)
	local function p(k, i)
		local q, an = PROFIL[k], i / FACES_O * math.pi * 2
		return Vector(math.cos(an) * q[3], math.sin(an) * q[2], -q[1])     -- plate d'avant en arrière
	end
	for k = 1, #PROFIL - 1 do
		for i = 0, FACES_O - 1 do
			local creux = (i == 0 or i == FACES_O - 1) and k > 1 and k < 5   -- le dedans de l'oreille, à peine éclairci
			local col = creux and { 34, 20, 22 } or { 9, 7, 8 }
			triangle(p(k, i), p(k + 1, i), p(k + 1, i + 1), col)
			triangle(p(k, i), p(k + 1, i + 1), p(k, i + 1), col)
		end
	end
	mesh.End()
	return m
end
-- 5 mottes anguleuses posées au sol, autour de l'origine
local MOTTES = { { 16, 4, 11, 8 }, { -12, 13, 9, 6 }, { -15, -9, 12, 7 }, { 7, -16, 8, 5 }, { 1, 2, 14, 10 } }   -- x, y, rayon, haut
local function construireTas()
	local m = Mesh()
	mesh.Begin(m, MATERIAL_TRIANGLES, #MOTTES * 6)
	for k, q in ipairs(MOTTES) do
		local x, y, r, haut = q[1], q[2], q[3], q[4]
		local sommet = Vector(x + (k % 3 - 1) * 2, y + (k % 2) * 3 - 1, haut)
		for i = 0, 5 do
			local a0, a1 = (i + k * 0.37) / 6 * math.pi * 2, (i + 1 + k * 0.37) / 6 * math.pi * 2
			local clair = 0.75 + 0.35 * ((i * 7 + k * 3) % 5) / 5
			triangle(Vector(x + math.cos(a0) * r, y + math.sin(a0) * r, 0), Vector(x + math.cos(a1) * r, y + math.sin(a1) * r, 0),
				sommet, { 104 * clair, 74 * clair, 50 * clair })
		end
	end
	mesh.End()
	return m
end
local function dessinerPose(m, position, angle, echelle)
	REPERE:Identity()
	REPERE:SetTranslation(position)
	REPERE:SetAngles(angle)
	REPERE:Scale(Vector(echelle, echelle, echelle))
	cam.PushModelMatrix(REPERE)
	m:Draw()
	cam.PopModelMatrix()
end

local function dessinerTas(maintenant)
	local taille = P.tas(etat(), maintenant)
	local lieu = etat().lieu
	if taille <= 0 or not lieu then return end
	POINT:SetUnpacked(lieu[1], lieu[2], lieu[3])
	dessinerPose(tas, A.versMonde(POINT), A.tete():GetAngles(), taille)
end
K.hook("PostDrawOpaqueRenderables", "sumii_mi_apparition", function(profondeur, ciel)
	if profondeur or ciel or not A.tete() or not A.dedans(EyePos()) then return end
	tas = tas or construireTas()
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	render.OverrideDepthEnable(true, true)             -- le matériau « color » n'écrit pas la profondeur de lui-même
	dessinerTas(CurTime())
	render.OverrideDepthEnable(false, false)
	render.CullMode(MATERIAL_CULLMODE_CCW)
end)

-- ---------- yeux et oreilles (au fond du tunnel, peints par la passe au pochoir de P2) ----------
-- Tout ce qui est peint ici est découpé par la bouche : rien ne peut flotter devant le trou ni se voir de côté
--.
local PENTE, TAILLE_OREILLE = math.rad(16), 0.52
local axeX, axeY, axeZ, bout = Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0)
function dessinerOreilles(b, maintenant)
	local montee = P.oreilles(etat(), maintenant)
	if montee <= 0 then return end
	oreille = oreille or construireOreille()
	local haut = A.tete():GetUp()
	local cotes = b.droite:GetNormalized()
	render.SetColorMaterialIgnoreZ()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	for cote = -1, 1, 2 do
		axeZ:Set(haut * math.cos(PENTE) + cotes * (cote * math.sin(PENTE)))   -- les bouts s'écartent en V
		axeX:Set(b.f:GetNormalized())
		axeY:Set(axeZ:Cross(axeX))
		bout:Set(b.o - b.f * 16 + cotes * (cote * 10) + haut * (b.haut * (0.45 + 0.52 * montee)))
		REPERE:Identity()
		for i = 1, 3 do
			REPERE:SetField(i, 1, axeX[i] * TAILLE_OREILLE); REPERE:SetField(i, 2, axeY[i] * TAILLE_OREILLE)
			REPERE:SetField(i, 3, axeZ[i] * TAILLE_OREILLE); REPERE:SetField(i, 4, bout[i])
		end
		cam.PushModelMatrix(REPERE)
		oreille:Draw()
		cam.PopModelMatrix()
	end
	render.CullMode(MATERIAL_CULLMODE_CCW)
end

local HALO = Material("sprites/light_glow02_add")
local ROUGE, LUEUR = Color(255, 28, 12), Color(255, 20, 8, 150)
function SC.dansTrou(b)
	if b.n ~= P.terrier(etat()) then return end
	dessinerOreilles(b, CurTime())                  -- d'abord : elles sont derrière les yeux
	local ouverture = P.yeux(etat(), CurTime())
	if ouverture <= 0 then return end
	local gros = P.pulsation(etat(), CurTime())
	local haut = A.tete():GetUp()
	local centre = b.o - b.f * 10 + haut * (b.haut * 0.45)
	for cote = -1, 1, 2 do
		local oeil = centre + b.droite * (cote * 8)
		render.SetMaterial(HALO)
		render.DrawSprite(oeil, 26 * gros * ouverture, 18 * gros * ouverture, LUEUR)
		render.SetColorMaterialIgnoreZ()
		render.DrawSphere(oeil, 2.6 * gros * ouverture, 10, 8, ROUGE)
	end
	render.SetColorMaterialIgnoreZ()
end

-- ---------- translucides : poussière de la détresse, onde rouge du nom ----------
local TERRE = CreateMaterial("sumii_mi_terre_v1", "UnlitGeneric", { ["$basetexture"] = "particle/smokesprites0001",
	["$translucent"] = "1", ["$vertexcolor"] = "1", ["$vertexalpha"] = "1" })
local couleurTerre = Color(112, 86, 60, 255)
local function poussiere(maintenant)
	local t0, lieu = etat().inst.detresse, etat().lieu
	if not t0 or not lieu or maintenant - t0 > 6 then return end
	render.SetMaterial(TERRE)
	for i = 1, P.BOUFFEES do
		local x, y, z, taille, alpha = P.bouffee(i, maintenant - t0)
		POINT:SetUnpacked(lieu[1] + x, lieu[2] + y, lieu[3] + z)
		couleurTerre.a = alpha
		render.DrawSprite(A.versMonde(POINT), taille, taille, couleurTerre)
	end
end

local SEGMENTS, LARGEUR, HAUT_ONDE = 120, 6, 12      -- 12 u : comme l'aperçu validé, au-dessus des brins courts
local function coin(x, y, alpha)
	POINT:SetUnpacked(x, y, HAUT_ONDE)
	mesh.Position(POINT); mesh.Color(255, 40, 24, alpha); mesh.AdvanceVertex()
end
local function ondeDuNom(maintenant)
	local rayon, opacite = P.anneauNom(etat(), maintenant)
	if not rayon then return end
	local h = T[P.terrier(etat())]
	local cx, cy, alpha = h.x + h.fx * 26, h.y + h.fy * 26, 255 * opacite
	render.SetColorMaterial()
	render.CullMode(MATERIAL_CULLMODE_NONE)
	REPERE:Identity()
	REPERE:SetTranslation(A.versMonde(ZERO))
	REPERE:SetAngles(A.tete():GetAngles())
	cam.PushModelMatrix(REPERE)
	mesh.Begin(MATERIAL_QUADS, SEGMENTS)
	for i = 0, SEGMENTS - 1 do
		local a0, a1 = i / SEGMENTS * math.pi * 2, (i + 1) / SEGMENTS * math.pi * 2
		local c0, s0, c1, s1 = math.cos(a0), math.sin(a0), math.cos(a1), math.sin(a1)
		local int = math.max(rayon - LARGEUR, 0)
		coin(cx + c0 * int, cy + s0 * int, alpha); coin(cx + c0 * rayon, cy + s0 * rayon, alpha)
		coin(cx + c1 * rayon, cy + s1 * rayon, alpha); coin(cx + c1 * int, cy + s1 * int, alpha)
	end
	mesh.End()
	cam.PopModelMatrix()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end
K.hook("PostDrawTranslucentRenderables", "sumii_mi_apparition_voiles", function(profondeur, ciel)
	if profondeur or ciel or not A.tete() or not A.dedans(EyePos()) then return end
	local maintenant = CurTime()
	poussiere(maintenant)
	ondeDuNom(maintenant)
end)

-- ---------- horloge du vent et sons ponctuels ----------
local avant = nil
local function sonsPonctuels(maintenant)
	local S, sons = etat(), C.SONS
	local function parti(cle, retard) return S.inst[cle] and M.echu(S.inst[cle], retard, avant, maintenant) end
	local bouche = SC.boucheMonde(P.terrier(S))
	if parti("reveler", 5) then SC.jouerBorne("souffle", bouche, sons.SOUFFLE_GRAVE, 0.9, 50, 4) end
	if parti("voix", 0) then
		SC.jouerBorne("grondement", bouche, sons.GRONDEMENT, 1, 45, P.VOIX)
		sound.Play(sons.COUP_GROTTE, bouche, 75, 60, 1)
	end
	if parti("nom", 0) then sound.Play(sons.COUP_SOURD, bouche, 90, 40, 1) end   -- un seul coup, puis rien
end
K.hook("Think", "sumii_mi_apparition", function()
	local maintenant = CurTime()
	-- l'herbe lit cette horloge : elle avance à la vitesse du vent, donc se fige sans se redresser
	SC.tVent = (SC.tVent or maintenant) + (maintenant - (avant or maintenant)) * P.vitesseVent(etat(), maintenant)
		* (SC.facteurVent and SC.facteurVent() or 1)             -- il forcit aux souvenirs
	majAnneau(maintenant)
	if avant and A.tete() and A.dedans(EyePos()) then sonsPonctuels(maintenant) end
	avant = maintenant
end)
K.surExtinction(function()
	if oreille then oreille:Destroy() end
	if tas then tas:Destroy() end
	oreille, tas, avant, SC.tVent, anneau.rayon = nil, nil, nil, nil, nil
end)
