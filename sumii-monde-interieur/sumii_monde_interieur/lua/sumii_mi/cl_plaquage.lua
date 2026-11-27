-- Plaquage : ce que voit Sumii (caméra au sol, silhouette, lame, entailles, noir) et, pour les autres, son modèle
-- couché sur le dos. Le gel est fait par le serveur. Chargé après cl_ecran (aperçu du MJ).
local L = SumiiMI.plaquage
local K, SC = SumiiNoyau, SumiiScene

-- secondes de plaquage à montrer SUR CET écran : pour la cible, ou chez le MJ en aperçu
function SC.plaquageIci()
	local maintenant = CurTime()
	if LocalPlayer():EntIndex() == SC.cible then
		local s = L.instant(SC.S, maintenant)
		if s then return s end
	end
	local t0 = SC.apercuDe and SC.apercuDe("plaquage")
	if t0 and maintenant - t0 <= L.DUREE then return maintenant - t0 end
end

function SC.vueDe(joueur, s)
	local hauteur, tangage, lacet, roulis = L.vue(s)
	return joueur:GetPos() + Vector(0, 0, hauteur), Angle(tangage, joueur:EyeAngles().y + lacet, roulis)
end
-- [à prouver sur EVO] un autre addon qui prend aussi CalcView peut passer devant
K.hook("CalcView", "sumii_mi_plaquage", function()
	local s = SC.plaquageIci()
	if not s then return end
	local origine, angles = SC.vueDe(LocalPlayer(), s)
	return { origin = origine, angles = angles, drawviewer = false }
end)
K.hook("HUDShouldDraw", "sumii_mi_plaquage_hud", function()
	if SC.cible and SC.plaquageIci() then return false end
end)
K.hook("PreDrawViewModel", "sumii_mi_plaquage_arme", function()
	if SC.plaquageIci() then return true end
end)

-- ---------- effets peints sur l'écran, aux proportions de la maquette (W x H : écran ou petite fenêtre du MJ) ----------
local function polygone(points)                    -- surface.DrawPoly n'accepte que le sens horaire
	local aire = 0
	for i, a in ipairs(points) do
		local b = points[i % #points + 1]
		aire = aire + a.x * b.y - b.x * a.y
	end
	if aire < 0 then points = table.Reverse(points) end
	surface.DrawPoly(points)
end
local function silhouette(s, W, H)
	local k = L.penche(s)
	if k <= 0 then return end
	local ox, oy, taille = -0.6 + 0.6 * k, -2.4 + 1.5 * k, 0.7 + 0.6 * k
	surface.SetDrawColor(5, 4, 4, 255)
	for _, morceau in ipairs(L.SILHOUETTE) do
		local points = {}
		for i, p in ipairs(morceau) do
			local x, y = L.ecran(ox + p[1] * taille, oy + p[2] * taille, 2.4, W, H)
			points[i] = { x = x, y = y }
		end
		polygone(points)
	end
end
local ANGLE_LAME = 0.5
local function lame(s, W, H)
	local k = L.lame(s)
	if not k then return end
	local cx, cy = 0.5 - 0.45 * k, 0.9 - 1.0 * k
	local ax, ay = math.sin(ANGLE_LAME), math.cos(ANGLE_LAME)
	local function p(le_long, travers)
		local x, y = L.ecran(cx + ax * le_long - ay * travers, cy + ay * le_long + ax * travers, 1.6, W, H)
		return { x = x, y = y }
	end
	surface.SetDrawColor(236, 238, 242, 255)        -- lame effilée, pointe en bas (repli sans le modèle de kunaï)
	polygone({ p(0.4, 0), p(0.24, 0.04), p(-0.4, 0), p(0.24, -0.025) })
	surface.SetDrawColor(150, 154, 166, 255)
	polygone({ p(0.4, 0), p(0.24, 0.006), p(-0.4, 0), p(0.24, -0.025) })
end
local ENTAILLES = { { 0.42, 2 }, { 0.47, -3 } }     -- hauteur (part de l'écran), inclinaison (degrés)
local function entailles(s, W, H)
	local k = L.entailles(s)
	if k <= 0 then return end
	for _, e in ipairs(ENTAILLES) do
		local a = math.rad(e[2])
		local dx, dy = math.cos(a), math.sin(a)
		local demi, epais, cx, cy = W * 0.32 * k, H * 0.011, W / 2, H * e[1]
		surface.SetDrawColor(176, 8, 8, 235)
		polygone({ { x = cx - dx * demi, y = cy - dy * demi }, { x = cx + dy * epais, y = cy - dx * epais },
			{ x = cx + dx * demi, y = cy + dy * demi }, { x = cx - dy * epais, y = cy + dx * epais } })
	end
end
-- à appeler dans un contexte 2D (cam.Start2D)
function SC.dessinerPlaquage(s, W, H)
	draw.NoTexture()
	silhouette(s, W, H)
	lame(s, W, H)
	entailles(s, W, H)
	local noir = L.noir(s)
	if noir > 0 then
		surface.SetDrawColor(0, 0, 0, 255 * noir)
		surface.DrawRect(0, 0, W, H)
	end
end

-- ---------- pour les autres : son modèle couché sur le dos (affichage seul, rien n'est déplacé) ----------
-- [à prouver au banc] les accessoires qu'EVO pose sur ses os sont dessinés à part : ils pourraient rester debout
local couche = nil
local function relever()
	if IsValid(couche) then couche:DisableMatrix("RenderMultiply") end
	couche = nil
end
K.hook("Think", "sumii_mi_couchee", function()
	local s = L.instant(SC.S, CurTime())
	local joueur = s and SC.cible > 0 and Entity(SC.cible) or nil
	if not IsValid(joueur) or joueur == LocalPlayer() then relever() return end
	if couche ~= joueur then relever() end
	couche = joueur
	local k = L.couche(s)
	local m = Matrix()
	m:Translate(Vector(0, 0, 4 * k))
	m:Rotate(Angle(-90 * k, 0, 0))                  -- sur le dos : la tête part en arrière, le visage vers le ciel
	joueur:EnableMatrix("RenderMultiply", m)
end)
K.surExtinction(relever)
