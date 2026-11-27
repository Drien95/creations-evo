-- Vue de Sumii chez le MJ : une petite fenêtre dans un coin, en direct, avec ses effets. Chargé après cl_plaquage.
local L, V = SumiiMI.plaquage, SumiiMI.souvenirs
local K, SC = SumiiNoyau, SumiiScene

local LARGE, HAUTE, CADENCE = 480, 270, 1 / 15     -- [à mesurer au banc] images par seconde et coût
local actif, prochaine, pret = false, 0, false
local cible_rt, matiere = nil, nil

local function preparer()
	if cible_rt then return end
	cible_rt = GetRenderTarget("sumii_mi_pov_rt", LARGE, HAUTE)
	matiere = CreateMaterial("sumii_mi_pov_mat", "UnlitGeneric", { ["$basetexture"] = cible_rt:GetName() })
end
local function sumii()
	local e = SC.cible > 0 and Entity(SC.cible) or nil
	if IsValid(e) and e:IsPlayer() and e ~= LocalPlayer() then return e end
end

local function peindreEffets(maintenant)
	local blanc = V.blanc(SC.S, maintenant)
	local s = L.instant(SC.S, maintenant)
	if blanc <= 0 and not s then return end
	cam.Start2D()
	if s then SC.dessinerPlaquage(s, LARGE, HAUTE) end
	if blanc > 0 then
		surface.SetDrawColor(255, 255, 255, 255 * blanc)
		surface.DrawRect(0, 0, LARGE, HAUTE)
	end
	cam.End2D()
end

K.hook("PreRender", "sumii_mi_pov", function()
	if not actif then return end
	local maintenant = CurTime()
	if maintenant < prochaine then return end
	prochaine = maintenant + CADENCE
	local joueur = sumii()
	pret = joueur ~= nil
	if not joueur then return end
	preparer()
	local s = L.instant(SC.S, maintenant)
	local origine, angles = joueur:EyePos(), joueur:EyeAngles()
	if s then origine, angles = SC.vueDe(joueur, s) end
	local champ = 90
	SC.povEnCours = true
	if SC.vertigeVue and not s then angles, champ = SC.vertigeVue(angles, champ) end   -- son vertige, vu par le MJ
	render.PushRenderTarget(cible_rt)
	local bon, motif = pcall(function()
		render.Clear(0, 0, 0, 255, true, true)
		render.RenderView({ origin = origine, angles = angles, fov = champ, x = 0, y = 0, w = LARGE, h = HAUTE, aspectratio = LARGE / HAUTE,
			drawviewmodel = false, drawhud = false })
		peindreEffets(maintenant)
	end)
	render.PopRenderTarget()                           -- la cible de rendu est toujours rendue, même après une erreur
	SC.povEnCours = false
	if not bon then actif = false print("[sumii] vue de Sumii coupée après une erreur : " .. tostring(motif)) end
end)

-- le moteur ne dessine jamais le joueur de cet écran : dans la vue de Sumii, le MJ doit apparaître s'il est devant elle
K.hook("ShouldDrawLocalPlayer", "sumii_mi_pov_mj", function()
	if SC.povEnCours then return true end
end)
K.hook("PrePlayerDraw", "sumii_mi_pov_corps", function(joueur)
	if SC.povEnCours and joueur:EntIndex() == SC.cible then return true end   -- elle ne se voit pas elle-même
end)

K.hook("HUDPaint", "sumii_mi_pov_fenetre", function()
	if not actif or not pret or not matiere then return end
	local w = math.floor(ScrW() * 0.22)
	local h = math.floor(w * HAUTE / LARGE)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(22, 22, w + 4, h + 4)
	surface.SetMaterial(matiere)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(24, 24, w, h)
end)

concommand.Add("sumii_pov", function()
	if not SC.mj then print("[sumii] réservé au MJ (tape d'abord sumii_etat)") return end
	actif, pret = not actif, false
	print("[sumii] vue de Sumii " .. (actif and "affichée (désigne-la avec sumii_cible)" or "fermée"))
end)
K.surExtinction(function() actif, pret, SC.povEnCours = false, false, false end)
