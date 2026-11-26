-- A2 « Le Sable du Fond » : surface de sable en script sur le sol en creux. v4 (finition, 26/11/2026). Client seulement.
-- Les props (build v3, a2-sol-v3.txt) donnent la forme et la collision ; ce maillage pose le sable au-dessus.
-- Tout est placé relativement au prop de tête du dupe (pan du fond, plate5x5 teinte 75,70,64) : aucune coordonnée de map.
-- v8 : la hauteur exacte du sable est donnée aux surcouches des autres scripts (hook a2_sable_hauteur) :
--       la pénombre et les rides de vague suivaient un profil approché et passaient sous le sable (bandes).
-- v7 : finition : lumière de la dalle plus forte et plus serrée, rides plus marquées.
-- v6c : passes de détail, voile et rides en $decal (biais de profondeur) et plus décalées : les « fragments »
--       anguleux étaient du z-fighting entre passes superposées, pas la texture.
-- v6 : lumière de la dalle peinte dans le sable (centre froid et clair, anneau assombri) ; rides plus calmes.
-- v5 : rides de vent (orientées, pas variable, ruptures) en surcouche d'ombre fine éclairée depuis la dalle ;
--      les anneaux réguliers de v4 sont retirés. Brouillard demandé à la fermeture (hook a2_brouillard_maillages).
-- v4 : teinte et éclairage par sommet (dégradé continu), contour bruité, bourrelet, rides anciennes, fondu au noir
--      au-delà de r 1 000, couche de détail fine (128 u) et voile gris qui désature la texture.
-- Console (aucune touche en dur) :
--   a2_sable <0|1|2>     0 = éteint, n = texture n de MATS
--   a2_sable_nuit <0|1>  nuit simulée à l'écran (le banc ne baisse pas la lumière de la map)
--   a2_sable_mesure      temps moyen et pic du dessin (ms), écrit dans data/a2_sable/mesure.txt
--   a2_sable_copies <dx...>  banc seulement : copies du sol décalées de dx en x de build (ex. 0 4000)

local MODELE_TETE = "models/hunter/plates/plate5x5.mdl"
local TEINTE_TETE = { 75, 70, 64 }
-- géométrie des props, en coordonnées de build.py (la tête est le pan du fond centré en -226, -226)
local TETE = Vector(-226, -226, -61.5)
local FOND_Z, R_IN, R_OUT = -60, 280, 520
local HAUT_COURONNE, APO_COURONNE, HAUT_EXT = -1.23, 515, -0.83   -- mesurés par build.py v3
local PENTE_PROPS = 0.25
local MARGE = 1.2           -- le sable ne descend jamais à moins de 1,2 u au-dessus d'une plaque
-- le sable
local DESSUS = 2.5
local R_FIN = 1400          -- au-delà de toutes les plaques (coins des 16x16 vers r 1 330)
local SEG = 96
local MATS = { "nature/dirtfloor_mine001a", "nature/sandfloor009c", "nature/sandfloor010a", "nature/sandfloor005a",
	"nature/sandfloor009a", "vgui/white" }   -- 6 = uni (teinte et lumière par sommet seulement)
local ECHELLE, ECHELLE_DETAIL = 512, 128
local VOILE = { 85, 82, 78 }      -- teinte visée
local ALPHA_VOILE, ALPHA_DETAIL = 0.5, 0.4
local RELIEF = 2.2
local DALLE = { R = 230, GAIN = 0.9, ANNEAU = 0.6, FROID = { 20, 38, 78 } }   -- lumière de la dalle peinte
-- rides de vent : surcouche d'ombre (pas de relief : le maillage de base est trop lâche pour des rides de 20 u)
local RIDES = { R0 = 52,   -- v11 : rides jusqu'au pied de la dalle centrale
	 R1 = 820, PAS_R = 5, SEG = 448, SECTEURS = 16, VENT = 0.6, PAS = 38,
	OMBRE = { 18, 16, 15 }, CLAIR = { 150, 156, 170 }, ALPHA = 110 }

local etat = { choix = 1, nuit = true, rides = true }   -- v11d : nuit par défaut (scène de nuit ; a2_sable_nuit 0 pour le jour)
local DECALAGES, decal = { 0 }, 0
local mats = {}
local tete, prochaineRecherche = nil, 0
local meshes, clePos, cleAng = nil, nil, nil
local temps = { n = 0, total = 0, pic = 0 }

-- ---------- matériaux ----------
local function creer(nom, suffixe, params)
	local m = CreateMaterial("a2_sable4_" .. string.gsub(nom, "%W", "_") .. suffixe, "UnlitGeneric", params)
	local tex = m:GetTexture("$basetexture")
	if m:IsError() or not tex or tex:IsError() then return nil end
	return m
end
local function materiaux(n)
	if mats[n] ~= nil then return mats[n] end
	local nom = MATS[n]
	local base = nom and creer(nom, "", { ["$basetexture"] = nom, ["$vertexcolor"] = 1, ["$nocull"] = 1 })
	local detail = nom and creer(nom, "_d6", { ["$basetexture"] = nom, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1,
		["$translucent"] = 1, ["$nocull"] = 1, ["$decal"] = 1 })
	local voile = creer("vgui/white", "_v6", { ["$basetexture"] = "vgui/white", ["$vertexcolor"] = 1, ["$vertexalpha"] = 1,
		["$translucent"] = 1, ["$nocull"] = 1, ["$decal"] = 1 })
	if not (base and detail and voile) then
		print("[a2_sable] texture absente : " .. tostring(nom))
		mats[n] = false
		return false
	end
	mats[n] = { base = base, detail = detail, voile = voile }
	print("[a2_sable] matériau " .. n .. " : " .. nom)
	return mats[n]
end

-- ---------- repère ----------
local function chercherTete() return A2_SABLE.tete and A2_SABLE.tete() or nil end   -- ancre par motif de props (sh_ancre.lua)
local function versMonde(x, y, z) return tete:LocalToWorld(Vector(x + decal, y, z) - TETE) end

-- ---------- forme ----------
local function lisse(a, b, t) t = math.Clamp((t - a) / (b - a), 0, 1) return t * t * (3 - 2 * t) end
local function softmax(a, b, k) local m = math.max(a, b) return m + k * math.log(math.exp((a - m) / k) + math.exp((b - m) / k)) end
local function softmin(a, b, k) return -softmax(-a, -b, k) end
-- plafond des plaques au rayon r (majorant sur tous les angles)
local function plaques(r)
	if r < APO_COURONNE then return math.max(FOND_Z, HAUT_COURONNE - (APO_COURONNE - r) * PENTE_PROPS) end
	return HAUT_EXT
end
-- bruit lisse d'angle : somme de sinus à phases fixes (pas d'aléatoire par sommet)
local function bruitAngle(a, amp)
	return amp * (0.55 * math.sin(3 * a + 0.7) + 0.3 * math.sin(7 * a + 2.1) + 0.15 * math.sin(13 * a + 4.4))
end
local Z_FOND, Z_HAUT = FOND_Z + DESSUS, HAUT_EXT + DESSUS
local PENTE = (Z_HAUT - Z_FOND) / (R_OUT - R_IN)
local function hauteur(r, a)
	local rr = r - bruitAngle(a, 10) * lisse(0, 200, r)                -- contour vivant ±10 u (nul au centre : pas d'étoile)
	local lin = Z_FOND + (rr - R_IN) * PENTE
	local z = softmin(softmax(Z_FOND, lin, 6), Z_HAUT, 6)              -- coins arrondis
	z = z + 5 * math.exp(-((rr - 530) / 38) ^ 2)                       -- bourrelet en haut de pente
	z = z + (hook.Run("a2_sable_bosse", r, a) or 0)                    -- v9 : bosses posées par la scène (sable contre le socle, lèvres des places)
	return math.max(z, plaques(r) + MARGE)
end

A2_SABLE.hook("a2_sable_hauteur", "a2_sable", function(r, a) return hauteur(r, a) end)   -- coordonnées du build

-- ---------- couleur ----------
local function soleil()
	local info = util.GetSunInfo and util.GetSunInfo()
	local d = info and info.direction
	if not d or d.z < 0.2 then d = Vector(-0.45, 0.35, 0.82) end
	return d:GetNormalized()
end

-- ---------- maillage ----------
local function anneaux()
	local t, r = { 0 }, 0
	while r < R_FIN do
		r = r + (r < 200 and 6 or (r < 600 and 12 or (r < 1000 and 20 or 40)))   -- v10b : 6 u au centre (talus du socle) ; 4 u dépassait 65 535 indices du maillage (pic de sable)
		t[#t + 1] = math.min(r, R_FIN)
	end
	return t
end
local RAYONS = anneaux()

local construireRides                -- défini plus bas (déclaration anticipée : sinon appel d'une globale nil)
local function construireUne()
	local sun = soleil()
	-- grille : position, couleur (éclairage x ombre de rayon x fondu), une fois par sommet
	local G = {}
	local da = math.pi * 2 / SEG
	for i, r in ipairs(RAYONS) do
		local ligne = {}
		for j = 0, SEG - 1 do
			local a = j * da
			local z = hauteur(r, a)
			local dr = 6
			local dzr = r < dr and 0 or (hauteur(r + dr, a) - hauteur(r - dr, a)) / (2 * dr)   -- centre : pente nulle, pas d'étoile
			local arc = math.max(r, 6) * da
			local dzt = (hauteur(r, a + da) - hauteur(r, a - da)) / (2 * arc)
			local ca, sa = math.cos(a), math.sin(a)
			-- normale : -grad z (dans le repère radial / tangentiel) puis vers x, y
			local nx = -(dzr * ca - dzt * sa); local ny = -(dzr * sa + dzt * ca)
			local n = Vector(nx, ny, 1):GetNormalized()
			local lum = math.Clamp(1 + RELIEF * (n:Dot(sun) / sun.z - 1), 0.4, 1.4)
			-- lumière clé de la dalle : le creux est le plus clair, l'anneau et le pied des dunes plus sombres
			local dalle = math.exp(-(r / DALLE.R) ^ 2)
			local ombre = Lerp(lisse(DALLE.R, 700, r), 1.0, DALLE.ANNEAU)
			local fondu = 1 - lisse(1000, R_FIN, r)
			ligne[j] = { x = ca * r, y = sa * r, z = z, k = lum * ombre * fondu * (1 + DALLE.GAIN * dalle), f = dalle }
		end
		G[i] = ligne
	end
	local function passe(dz, echelle, rot, couleur, alpha)
		local m = Mesh()
		local cr, sr = math.cos(rot), math.sin(rot)
		mesh.Begin(m, MATERIAL_QUADS, (#RAYONS - 1) * SEG)
		for i = 1, #RAYONS - 1 do
			local A, B = G[i], G[i + 1]
			for j = 0, SEG - 1 do
				local j2 = (j + 1) % SEG
				for _, s in ipairs({ A[j], B[j], B[j2], A[j2] }) do
					mesh.Position(versMonde(s.x, s.y, s.z + dz))
					mesh.TexCoord(0, (s.x * cr - s.y * sr) / echelle, (s.x * sr + s.y * cr) / echelle)
					mesh.Color(math.min(255, couleur[1] * s.k + DALLE.FROID[1] * s.f), math.min(255, couleur[2] * s.k + DALLE.FROID[2] * s.f),
						math.min(255, couleur[3] * s.k + DALLE.FROID[3] * s.f), alpha)
					mesh.AdvanceVertex()
				end
			end
		end
		mesh.End()
		return m
	end
	local blanc = { 225, 222, 216 }
	return {
		base = passe(0, ECHELLE, 0, blanc, 255),
		detail = passe(0.3, ECHELLE_DETAIL, 0.41, blanc, 255 * ALPHA_DETAIL),
		voile = passe(0.6, ECHELLE, 0, { VOILE[1] * 1.15, VOILE[2] * 1.15, VOILE[3] * 1.15 }, 255 * ALPHA_VOILE),
		rides = construireRides(),
	}
end
-- hauteur relative des rides (sans unité) : crêtes courbées, pas variable, face douce au vent et face raide sous le vent
local function ride(x, y)
	local cv, sv = math.cos(RIDES.VENT), math.sin(RIDES.VENT)
	local u, v = x * cv + y * sv, -x * sv + y * cv
	local pas = RIDES.PAS * (1 + 0.3 * math.sin(v / 97 + 0.6) + 0.18 * math.sin(u / 61 + 2.0))
	local ph = u / pas * math.pi * 2 + 0.6 * math.sin(v / 83 + 1.1) + 0.25 * math.sin(v / 41 + u / 151)
	local f = math.sin(ph) + 0.33 * math.sin(2 * ph)
	local rupture = lisse(-0.35, 0.45, math.sin(u / 131 + v / 89) + 0.55 * math.sin(v / 47 - 1.3))
	return f * (0.25 + 0.75 * rupture)
end
construireRides = function()
	local R, rings = RIDES, {}
	-- rides près du socle selon la variante de la scène (a2_socle 7 : comme la série 7 ; 8 : jusqu'au pied de la dalle)
	local v7 = hook.Run("a2_socle_version") == 7
	local R0, RAMPE, BOOST = v7 and 90 or R.R0, v7 and 60 or 30, v7 and 0 or 0.9
	for r = R0, R.R1, R.PAS_R do rings[#rings + 1] = r end
	local da = math.pi * 2 / R.SEG
	local G = {}
	for i, r in ipairs(rings) do
		local amp = lisse(R0, R0 + RAMPE, r) * (1 - lisse(560, R.R1, r))
		local ligne = {}
		for j = 0, R.SEG - 1 do
			local a = j * da
			local x, y = math.cos(a) * r, math.sin(a) * r
			-- lumière clé au-dessus de la dalle : une pente qui monte en s'éloignant du centre lui fait face
			local e = 2
			local g = ((ride(x + e, y) - ride(x - e, y)) * x + (ride(x, y + e) - ride(x, y - e)) * y) / (2 * e * r)
			local s = math.Clamp(g * 3, -1, 1) * amp
			local c = s > 0 and R.CLAIR or R.OMBRE
			ligne[j] = { x = x, y = y, z = hauteur(r, a) + 0.9, c = c, al = math.min(255, math.abs(s) * R.ALPHA * (1 + BOOST * (1 - lisse(150, 280, r)))) }   -- v11b : rides plus marquées autour du socle (sable clair sous la lumière)
		end
		G[i] = ligne
	end
	local parts, pas = {}, R.SEG / R.SECTEURS
	for k = 0, R.SECTEURS - 1 do
		local m = Mesh()
		mesh.Begin(m, MATERIAL_QUADS, (#rings - 1) * pas)
		for i = 1, #rings - 1 do
			for j = k * pas, (k + 1) * pas - 1 do
				local j2 = (j + 1) % R.SEG
				for _, q in ipairs({ G[i][j], G[i + 1][j], G[i + 1][j2], G[i][j2] }) do
					mesh.Position(versMonde(q.x, q.y, q.z)); mesh.TexCoord(0, 0, 0)
					mesh.Color(q.c[1], q.c[2], q.c[3], q.al); mesh.AdvanceVertex()
				end
			end
		end
		mesh.End()
		parts[#parts + 1] = m
	end
	return parts
end
local function construire()
	for _, c in ipairs(meshes or {}) do
		for k, m in pairs(c) do
			if k == "rides" then for _, p in ipairs(m) do p:Destroy() end else m:Destroy() end
		end
	end
	meshes = {}
	A2_SABLE.solVersion = (A2_SABLE.solVersion or 0) + 1   -- le sol a pu changer : caches de sommets de la séquence à refaire
	for _, dx in ipairs(DECALAGES) do decal = dx; table.insert(meshes, construireUne()) end
	decal = 0
end

local function dessiner()
	if etat.choix == 0 then return end
	local t0 = SysTime()
	if CurTime() >= prochaineRecherche then
		prochaineRecherche = CurTime() + 1
		tete = chercherTete()
	end
	if not IsValid(tete) then return end
	local M = materiaux(etat.choix)
	if not M then return end
	if not A2_SABLE.cameraPres(tete) then return end   -- loin de la scène : rien à dessiner
	local p, a = tete:GetPos(), tete:GetAngles()   -- clé = position et angle : le passage du prop (secours) au repère du serveur ne reconstruit rien
	if not meshes or not clePos or clePos:DistToSqr(p) > 0.01 or cleAng ~= a then clePos, cleAng = p, a; construire() end
	hook.Run("a2_brouillard_maillages")
	for _, c in ipairs(meshes) do
		render.SetMaterial(M.base); c.base:Draw()
		render.SetMaterial(M.detail); c.detail:Draw()
		render.SetMaterial(M.voile); c.voile:Draw()
		if etat.rides then for _, p in ipairs(c.rides) do p:Draw() end end
	end
	local dt = (SysTime() - t0) * 1000
	temps.n, temps.total, temps.pic = temps.n + 1, temps.total + dt, math.max(temps.pic, dt)
end
local enPanne = false                -- une erreur de dessin arrête le script proprement, un seul message
A2_SABLE.hook("PostDrawOpaqueRenderables", "a2_sable_surface", function(prof, ciel)
	if prof or ciel or enPanne then return end
	local ok, err = pcall(dessiner)
	if not ok then
		enPanne = true
		print("[a2_sable] dessin arrêté après une erreur : " .. tostring(err))
	end
end)

-- v12 : la nuit ne s'applique qu'à la caméra dans la boîte de scène (relative à la tête) ; dehors, l'image reste normale
local BOITE = { BX = 1800, BZ0 = -200, BZ1 = 700 }    -- mêmes bornes que la fermeture et la séquence
local function cameraDansBoite()
	if not IsValid(tete) then return false end
	local p = tete:WorldToLocal(EyePos()) + TETE
	return math.abs(p.x) <= BOITE.BX and math.abs(p.y) <= BOITE.BX and p.z >= BOITE.BZ0 and p.z <= BOITE.BZ1
end
local FILTRE_NUIT = { ["$pp_colour_addr"] = 0, ["$pp_colour_addg"] = 0, ["$pp_colour_addb"] = 0.015,   -- table réutilisée
	["$pp_colour_brightness"] = -0.05, ["$pp_colour_contrast"] = 0.6, ["$pp_colour_colour"] = 0.4,
	["$pp_colour_mulr"] = 0, ["$pp_colour_mulg"] = 0, ["$pp_colour_mulb"] = 0 }
A2_SABLE.hook("RenderScreenspaceEffects", "a2_sable_nuit", function()
	if not etat.nuit or not cameraDansBoite() then return end
	DrawColorModify(FILTRE_NUIT)
end)

concommand.Add("a2_sable", function(_, _, args)
	local n = math.floor(tonumber(args[1] or "") or -1)
	if n < 0 or n > #MATS then print("[a2_sable] usage : a2_sable <0.." .. #MATS .. ">") return end
	etat.choix = n
	print("[a2_sable] surface : " .. (n == 0 and "éteinte" or MATS[n]))
end)

concommand.Add("a2_sable_rides", function(_, _, args)
	etat.rides = tonumber(args[1] or "") == 1
	print("[a2_sable] rides : " .. tostring(etat.rides))
end)

concommand.Add("a2_sable_nuit", function(_, _, args)
	etat.nuit = tonumber(args[1] or "") == 1
	print("[a2_sable] nuit : " .. tostring(etat.nuit))
end)

concommand.Add("a2_sable_copies", function(_, _, args)
	local t = {}
	for _, a in ipairs(args) do local n = tonumber(a) if n then t[#t + 1] = n end end
	if #t == 0 then t = { 0 } end
	DECALAGES, meshes, clePos = t, nil, nil
	print("[a2_sable] copies : " .. table.concat(t, " "))
end)

concommand.Add("a2_sable_mesure", function()
	local moy = temps.n > 0 and temps.total / temps.n or 0
	local ligne = string.format("%s v6 images=%d moyenne_ms=%.4f pic_ms=%.4f quads=%d", os.date("%H:%M:%S"),
		temps.n, moy, temps.pic, (#RAYONS - 1) * SEG * 3)
	print("[a2_sable] " .. ligne)
	file.CreateDir("a2_sable")
	file.Append("a2_sable/mesure.txt", ligne .. "\n")
	temps.n, temps.total, temps.pic = 0, 0, 0
end)

A2_SABLE.hook("a2_sable_reconstruire", "a2_sable", function() clePos = nil end)   -- reconstruit au prochain dessin (anciens maillages détruits)
print("[a2_sable] chargé v12")   -- trace de chargement (rechargement à chaud vérifiable dans la console)

A2_SABLE.surExtinction(function()               -- a2_tout_effacer : maillages détruits, repère oublié
	for _, c in ipairs(meshes or {}) do
		for k, m in pairs(c) do
			if k == "rides" then for _, p in ipairs(m) do p:Destroy() end else m:Destroy() end
		end
	end
	meshes, clePos, tete, prochaineRecherche = nil, nil, nil, 0
end)
