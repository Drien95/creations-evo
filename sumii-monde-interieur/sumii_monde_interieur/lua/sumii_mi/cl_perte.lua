-- Temps 7 : rafales, herbe couchée, arbres pliés, terriers en chaîne ; et le vertige, chez Sumii seule.
-- Chargé après cl_pov, dont il complète les crochets.
local C, M, F, T = SumiiMI.config, SumiiMI.monde, SumiiMI.perte, SumiiMI.terriers
local A, K, SC = SumiiAncre, SumiiNoyau, SumiiScene

local PLI = 0.085                                -- cisaillement des arbres au plus fort d'une rafale
local CERISIER = "models/propper/rp_seireitei_v1/watcher_skr_treesakura_1.mdl"
local ORDRE = F.ordre(T)

-- ---------- vent : herbe couchée, horloge accélérée, arbres pliés ----------
local herbeAvant, ventAvant = SC.herbe, SC.facteurVent
function SC.herbe(bloc, k, ky)
	local h
	h, k, ky = herbeAvant(bloc, k, ky)
	return h, F.herbe(SC.S, CurTime(), k, bloc.x * 0.01 + bloc.y * 0.013), ky
end
function SC.facteurVent() return ventAvant() * (1 + 2.5 * F.rafale(SC.S, CurTime())) end

-- matrice qui plie vers l'est tout maillage du build dessiné à l'intérieur : x += k * hauteur, pied au sol immobile
local pli = Matrix()
function SC.pliForet()
	local k = PLI * F.rafale(SC.S, CurTime())
	if k <= 0 or not A.tete() then return nil end
	local vent, sol = A.tete():GetForward(), A.versMonde(Vector(0, 0, 0)).z
	pli:Identity()
	pli:SetField(1, 3, k * vent.x); pli:SetField(2, 3, k * vent.y)
	pli:SetField(1, 4, -k * vent.x * sol); pli:SetField(2, 4, -k * vent.y * sol)
	return pli
end

-- les cerisiers sont des props : même pli, dans leur propre repère
local cerisiers, prochaine, plies = {}, 0, false
local function redresser()
	for _, e in ipairs(cerisiers) do
		if IsValid(e) then e:DisableMatrix("RenderMultiply") end
	end
	plies = false
end
local function plierCerisiers(maintenant)
	local k = PLI * F.rafale(SC.S, maintenant)
	if k <= 0 or not A.tete() then
		if plies then redresser() end
		return
	end
	if maintenant >= prochaine then
		prochaine, cerisiers = maintenant + 1, {}
		for _, e in ipairs(ents.FindByClass("prop_physics")) do   -- pas de recherche par zone : vide à plusieurs
			if string.lower(e:GetModel() or "") == CERISIER and A.dedans(e:GetPos()) then cerisiers[#cerisiers + 1] = e end
		end
	end
	local vent = A.tete():GetForward()
	for _, e in ipairs(cerisiers) do
		if IsValid(e) then
			local d = e:WorldToLocal(e:GetPos() + vent)
			local m = Matrix()
			local bas = SC.enfoncement and SC.enfoncement() or 0
			if bas > 0 then m:SetTranslation(e:WorldToLocal(e:GetPos() - Vector(0, 0, bas))) end   -- ils s'enfoncent avec la lisière
			m:SetField(1, 3, k * d.x); m:SetField(2, 3, k * d.y)
			e:EnableMatrix("RenderMultiply", m)
			plies = true
		end
	end
end

-- ---------- vertige : roulis, champ qui respire, ciel qui tourne ; chez Sumii, dans la vue du MJ et en aperçu ----------
local function etatDuVertige()
	local t0 = SC.apercuDe and SC.apercuDe("perte")
	if t0 then return { i = F.PERTE, inst = { perte = t0 } } end
	if SC.povEnCours or LocalPlayer():EntIndex() == SC.cible then return SC.S end
end
-- rend l'état à utiliser, ou nil si cet écran n'a pas de vertige à cet instant
local function vertigeIci()
	local etat = etatDuVertige()
	if etat and F.vertige(etat, CurTime()) > 0 then return etat end
end
function SC.vertigeVue(angles, champ)
	local etat = vertigeIci()
	if not etat then return angles, champ end
	return Angle(angles.p, angles.y, angles.r + F.roulis(etat, CurTime())), champ + F.champ(etat, CurTime())
end
function SC.tournerCiel(angles)
	local etat = vertigeIci()
	if not etat then return angles end
	return Angle(angles.p, angles.y - F.tourne(etat, CurTime()), angles.r)
end
-- [à prouver sur EVO] un autre addon qui prend aussi CalcView peut passer devant
K.hook("CalcView", "sumii_mi_vertige", function(_, origine, angles, champ)
	if not vertigeIci() or (SC.plaquageIci and SC.plaquageIci()) then return end
	local a, f = SC.vertigeVue(angles, champ)
	return { origin = origine, angles = a, fov = f }
end)

-- ---------- terriers en chaîne, rafales et éboulements ----------
local departs = {}
for rang, n in ipairs(ORDRE) do departs[n] = F.depart(rang, n) end

local avant, prochaineRafale = nil, 0
local function sons(maintenant)
	local t0 = SC.S.inst.perte
	if SC.S.i == F.PERTE and maintenant >= prochaineRafale then
		prochaineRafale = maintenant + math.Rand(2.5, 4.5)
		sound.Play(C.SONS.RAFALE_FORTE, EyePos() + Vector(-500, 0, 100), 75, math.random(90, 105), 0.8)
	end
	if not t0 or SC.S.i < F.PERTE then return end
	for n, retard in pairs(departs) do
		if M.echu(t0, retard, avant, maintenant) then
			sound.Play(string.format(C.SONS.EBOULIS, math.random(1, 5)), SC.boucheMonde(n), 80, math.random(85, 100), 0.9)
		end
	end
end
K.hook("Think", "sumii_mi_perte", function()
	local maintenant = CurTime()
	if SumiiP2 and SumiiP2.chaine then SumiiP2.chaine(F.chaine(SC.S), departs) end
	plierCerisiers(maintenant)
	if avant and A.tete() and A.dedans(EyePos()) then sons(maintenant) end
	avant = maintenant
end)
K.surExtinction(function()
	redresser()
	cerisiers, prochaine, avant, prochaineRafale = {}, 0, nil, 0
end)
