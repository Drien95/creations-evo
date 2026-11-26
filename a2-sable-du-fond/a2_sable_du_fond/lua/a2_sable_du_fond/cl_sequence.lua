-- A2 « Le Sable du Fond » : séquence du cours (vagues) et pierres des places. Passe 2 (26/11/2026). Client.
-- Passe 14 (série 5) : socle d'Adler dessiné en script (cœur + couronne brisée en 5 morceaux, base enterrée),
--   disques du dupe gardés pour la collision et cachés côté client.
-- Passe 13 (série 4) : socle d'Adler usé (sable sur le bord et dans les creux, fentes, écaillures, jumelles et
--   éclats au pied), assises et tablettes en dalles basses chanfreinées, pierres plus grosses, vague plus haute près d'Adler.
-- Passe 12 (série 3) : signature en couleur par place (halo, anneau qui respire, braises), cercle ratissé autour
--   de chaque assise, poses des pierres nettes (couchée, à demi enfouie, lueur éteinte), nappe au sol de la vague.
-- Passe 11 (scène 2, planche 3) : front de vague plus dense, sprites fins et peu nombreux (plus de « dents » vues
--   d'en haut), sillons plus marqués ; pierres plus grosses, traînées plus nettes ; assises plus claires.
-- Passe 10 (scène 2, planche 2) : rideau de poussière continu (bande verticale en dégradé, lisible au sol), sprites
--   moins nombreux et de tailles tirées ; assises et tablettes en matière claire (concrete2).
-- Passe 9 (scène 2, planche 1) : pierres d'assise plates et basses en script (ClientsideModel aplati, aucun posé)
--   et tablette devant chaque place ; rides posées sur la hauteur exacte du sable (hook a2_sable_hauteur) ;
--   assises et tablettes éclairées par l'éclairage de nuit de la fermeture (hook a2_eclairage_nuit).
-- Passe 8 (scène, finition) : pierres gris-bleu pâle, ombre de contact sous les pierres posées.
-- Passe 7 (scène, planche 3) : vague en 3 couches denses et claires ; traces au sol des résultats (traînée
--   derrière la pierre qui glisse, creux sous celle qui s'enfonce), éclats plus gros ; pierres légèrement bleutées.
-- Passe 6 : les pierres glissent vers Adler (vers l'extérieur, elles passaient derrière la tablette).
-- Passe 5 : sprites de poussière ronds (vus d'en haut, les sprites aplatis faisaient des dents) ; en échec les
--   pierres restent à demi visibles dans le sable.
-- Passe 4 : anneau de poussière fin au bord doux (une crête, tailles et rayons tirés), pierres plus grosses et
--   lueur plus large (lisibles à 275 u).
-- Passe 3 : rides irrégulières (rayon ondulé, largeur et force variables, ruptures) : plus de « cible » ;
--   anneau de poussière plus dense et plus haut.
-- Passe 2 : rides visibles (faces à une seule face culées : CullMode NONE), poussière claire qui accroche la lumière,
--   pouls et lueur plus nets, lévitation plus lisible.
-- Tout est relatif au prop de tête du dupe (boîte 3 600 x 3 600) ; rien n'est dessiné hors de la boîte.
-- Livraison (addon a2_sable_du_fond) : les commandes a2_* sont des commandes serveur (droits MJ vérifiés par
--   sv_scene.lua) ; le serveur envoie l'état complet par net aux joueurs de la boîte, ce fichier le dessine.
--   Commandes et usage : README.md de l'addon.
-- Fil d'Injerto (livraison) : fil blanc pâle au-dessus d'Adler, à peine visible, deviné surtout à la 2e vague.
-- Résultats : réussite immobiles ; partiel une glisse dans le sable ; échec les deux glissent et s'enfoncent ;
--   fiasco éclatent ; crit lévitent d'un doigt et restent.

local MODELE_TETE = "models/hunter/plates/plate5x5.mdl"
local TEINTE_TETE = { 75, 70, 64 }
local TETE = Vector(-226, -226, -61.5)       -- tête en coordonnées du build (centre du creux en 0, 0)
local S = {                                  -- réglages
	BX = 1800, BZ0 = -200, BZ1 = 700,
	PLACES = { 130, 160, 200, 230 },         -- angles des places (build v5), rayon 275
	R_PLACE = 275, R_TABLETTE = 225,         -- tablette = petite pierre plate 50 u devant la place
	Z_TABLETTE = 6,                          -- dessus de la tablette au-dessus du sable
	ASSISES = { { m = "models/props_wasteland/rockgranite02c.mdl", e = Vector(1.1, 1.1, 0.4), yaw = 0 },
		{ m = "models/props_wasteland/rockgranite02a.mdl", e = Vector(0.95, 1.15, 0.36), yaw = 90 },
		{ m = "models/props_wasteland/rockgranite02c.mdl", e = Vector(1.0, 0.95, 0.42), yaw = 200 } },
	ASSISE_DESSUS = 8, ASSISE_COUL = { 1.0, 0.98, 0.95 },
	TABLETTE = { m = "models/props_wasteland/rockgranite02c.mdl", e = Vector(0.42, 0.42, 0.18) },                      -- dessus approché de la tablette (sable -57,5 + 9)
	PIERRE_MODELE = "models/props_wasteland/rockgranite03b.mdl", PIERRE_ECH = 0.27,
	PIERRE_COUL = { 0.80, 0.85, 0.94 },      -- blanc pâle d'Injerto (seul blanc de la scène)
	-- signatures par défaut (une par place, MJ : a2_signature) : braise, améthyste, jade, grenat. Pas de bleu franc :
	-- la nuit est froide, le blanc reste aux pierres ; la couleur ne dit pas le résultat, elle dit l'élève.
	SIGS = { { 240, 125, 50 }, { 175, 95, 235 }, { 60, 215, 135 }, { 235, 70, 110 } },
	R_SIG = 50,                              -- rayon de l'anneau du pouls autour de la place (seat + tablette)
	R_MARQUE = 44,                           -- cercle clair ratissé autour de l'assise (place lisible de loin)
	DOIGT = 7,                               -- lévitation « d'un doigt » (u)
	V = 150, R0 = 100, R_FIN = 640,          -- vague : vitesse (u/s), départ (bord de la dalle), fin (pied des dunes)
	N_POUSS = 48, H_POUSS = 14, H_RIDEAU = 18, SEG_RIDEAU = 96,
	RIDE_PAS = 18, RIDE_SEG = 64,
}
local etat = { tete = nil, prochain = 0, vagues = {}, n = 0, adler = NULL, entendu = 0 }
local places = {}
for i = 1, #S.PLACES do places[i] = { on = false, res = "reussite", t0 = 0, joueur = nil, sig = S.SIGS[(i - 1) % #S.SIGS + 1] } end

local MAT_POUSS = { Material("particle/smokesprites_0001"), Material("particle/smokesprites_0003") }
local MAT_LUEUR = Material("sprites/light_glow02_add")
local MAT_BLANC = Material("models/debug/debugwhite")
local MAT_ASSISE = Material("phoenix_storms/concrete2")
local MAT_RIDEAU = CreateMaterial("a2_seq_rideau_1", "UnlitGeneric", { ["$basetexture"] = "vgui/white",
	["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$translucent"] = 1 })
local MAT_ADD = CreateMaterial("a2_seq_add_1", "UnlitGeneric", { ["$basetexture"] = "vgui/white",
	["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$additive"] = 1 })
local MAT_RIDE = CreateMaterial("a2_seq_ride_1", "UnlitGeneric", { ["$basetexture"] = "vgui/white",
	["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$translucent"] = 1, ["$decal"] = 1 })

-- ---------- repère ----------
local function chercherTete()
	local meilleur, score = nil, math.huge
	for _, e in ipairs(ents.FindByModel(MODELE_TETE)) do
		local c = IsValid(e) and e:GetColor()
		if c and math.abs(c.r - TEINTE_TETE[1]) <= 1 and math.abs(c.g - TEINTE_TETE[2]) <= 1 and math.abs(c.b - TEINTE_TETE[3]) <= 1 then
			local p = e:GetPos()
			if p.x + p.y < score then meilleur, score = e, p.x + p.y end
		end
	end
	return meilleur
end
local function majTete()
	if CurTime() >= etat.prochain then etat.prochain = CurTime() + 1; etat.tete = chercherTete() end
	return IsValid(etat.tete)
end
local function versMonde(x, y, z) return etat.tete:LocalToWorld(Vector(x, y, z) - TETE) end
local dedansCache, dedansImage = false, -1
local function dedans()
	if not majTete() then return false end
	local img = FrameNumber()
	if img ~= dedansImage then
		dedansImage = img
		local p = etat.tete:WorldToLocal(EyePos()) + TETE
		dedansCache = math.abs(p.x) <= S.BX and math.abs(p.y) <= S.BX and p.z >= S.BZ0 and p.z <= S.BZ1
	end
	return dedansCache
end
local function solCreux(r)                   -- dessus du sable en script (même profil que la fermeture)
	if r <= 280 then return -57.5 end
	if r >= 520 then return 1.7 end
	return -57.5 + (r - 280) / 240 * 59.2
end
local function sol(r, a)                     -- hauteur exacte du sable (script du sable), sinon le profil approché
	return hook.Run("a2_sable_hauteur", r, a or 0) or solCreux(r)
end
local function lisse(x) x = math.Clamp(x, 0, 1) return x * x * (3 - 2 * x) end

-- ---------- vagues ----------
local function rayonVague(v, t) return S.R0 + S.V * (t - v.t0) end
-- la brume de la fermeture s'écarte devant le front (elle appelle ce hook)
hook.Add("a2_vague_front", "a2_seq", function()
	local v = etat.vagues[#etat.vagues]
	if not v then return end
	local r = rayonVague(v, CurTime())
	if r > S.R_FIN + 200 then return end
	return r, v.force
end)

local function jouerSouffle(force)
	local centre = versMonde(0, 0, -40)
	sound.Play("ambient/wind/wind_hit2.wav", centre, 85, 55, 0.9 * force)
	sound.Play("ambient/atmosphere/hole_hit1.wav", centre, 80, 70, 0.6 * force)
end

local function dessinerRideau(v, t, r, env)  -- bande verticale continue : voile bas, plus dense au tiers, fondu en haut
	local n = S.SEG_RIDEAU
	render.SetMaterial(MAT_RIDEAU)
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_QUADS, n * 4)
	local function sommet(x, y, z, al) mesh.Color(196, 192, 184, al) mesh.Position(versMonde(x, y, z)) mesh.AdvanceVertex() end
	for c = 0, 1 do                          -- front clair puis traîne plus large derrière
		local pres = 1 - lisse((r - 100) / 600)    -- près d'Adler : front plus haut et plus clair
		local rc, h, al = r - 30 * c, S.H_RIDEAU * v.force * (1 - 0.3 * c) * (1 + 1.6 * pres), math.min((80 - 35 * c) * env * (1 + 0.6 * pres), 200)
		for i = 0, n - 1 do
			local a0, a1 = i / n * math.pi * 2, (i + 1) / n * math.pi * 2
			local r0 = rc + 14 * math.sin(5 * a0 + v.n + t) + 6 * math.sin(11 * a0 - t)
			local r1 = rc + 14 * math.sin(5 * a1 + v.n + t) + 6 * math.sin(11 * a1 - t)
			local tr = math.max(0, math.sin(3 * a0 + v.n) * 0.6 + math.sin(13 * a0 - 2 * t) * 0.5)   -- trous : bouffées, pas un mur
			local al = al * tr
			local h0 = h * (0.6 + 0.4 * (0.5 + 0.5 * math.sin(7 * a0 + 2 * t)) * (0.5 + 0.5 * math.sin(17 * a0 - t)))
			local h1 = h * (0.6 + 0.4 * (0.5 + 0.5 * math.sin(7 * a1 + 2 * t)) * (0.5 + 0.5 * math.sin(17 * a1 - t)))
			local x0, y0, x1, y1 = math.cos(a0) * r0, math.sin(a0) * r0, math.cos(a1) * r1, math.sin(a1) * r1
			local z0, z1 = sol(r0, a0), sol(r1, a1)
			sommet(x0, y0, z0, al * 0.55) sommet(x1, y1, z1, al * 0.55)          -- pied
			sommet(x1, y1, z1 + h1 * 0.3, al) sommet(x0, y0, z0 + h0 * 0.3, al) -- cœur au tiers
			sommet(x0, y0, z0 + h0 * 0.3, al) sommet(x1, y1, z1 + h1 * 0.3, al)
			sommet(x1, y1, z1 + h1, 0) sommet(x0, y0, z0 + h0, 0)               -- haut fondu
		end
	end
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end

-- nappe au sol (lisible en plongée) : ombre devant le front, bande claire sur le front, voile qui s'éclaircit derrière
local function dessinerNappe(v, t, r, env)
	local n = S.SEG_RIDEAU
	render.SetMaterial(MAT_RIDEAU)
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_QUADS, n * 3)
	local f = math.min(v.force, 1.5)
	local bandes = {                          -- { rayon intérieur, rayon extérieur, couleur, alpha int, alpha ext }
		{ r + 8, r + 36, { 14, 13, 12 }, 105, 0 },
		{ r - 22, r + 8, { 222, 216, 204 }, 60, 160 },
		{ r - 110, r - 34, { 190, 184, 174 }, 0, 22 },
	}
	for _, b in ipairs(bandes) do
		local c = b[3]
		for i = 0, n - 1 do
			local a0, a1 = i / n * math.pi * 2, (i + 1) / n * math.pi * 2
			local d0 = 10 * math.sin(5 * a0 + v.n + t) + 5 * math.sin(11 * a0 - t)
			local d1 = 10 * math.sin(5 * a1 + v.n + t) + 5 * math.sin(11 * a1 - t)
			local k0 = 0.55 + 0.45 * math.sin(3 * a0 + v.n + 0.7 * t)
			local k1 = 0.55 + 0.45 * math.sin(3 * a1 + v.n + 0.7 * t)
			local ri0, re0 = math.max(b[1] + d0, S.R0 * 0.6), math.max(b[2] + d0, S.R0 * 0.6)
			local ri1, re1 = math.max(b[1] + d1, S.R0 * 0.6), math.max(b[2] + d1, S.R0 * 0.6)
			local pres = 1 + 0.6 * (1 - lisse((r - 100) / 600))
			local ai, ae = math.min(b[4] * env * f * pres, 255), math.min(b[5] * env * f * pres, 255)
			local function p(rr, a, al) mesh.Color(c[1], c[2], c[3], al) mesh.Position(versMonde(math.cos(a) * rr, math.sin(a) * rr, sol(rr, a) + 1.4)) mesh.AdvanceVertex() end
			p(ri0, a0, ai * k0) p(ri1, a1, ai * k1) p(re1, a1, ae * k1) p(re0, a0, ae * k0)
		end
	end
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end

local function dessinerPoussiere(v, t)
	local r = rayonVague(v, t)
	if r > S.R_FIN + 150 then return end
	local env = lisse((t - v.t0) / 0.4) * (1 - lisse((r - (S.R_FIN - 120)) / 220))   -- s'éteint avant les dunes (plus d'arc clair sur la pente)
	local plonge = 1 - 0.55 * lisse((EyeAngles().p - 35) / 30)   -- vue d'en haut : la nappe porte la vague, les sprites feraient des dents
	dessinerNappe(v, t, r, env)
	dessinerRideau(v, t, r, env)
	for c = 0, 2 do                          -- 3 couches : front net et clair, corps, traîne qui s'efface
		local recul, hc, ac, tc = c * 26, 1 - 0.25 * c, 1 - 0.3 * c, 1 + 0.25 * c
		if r - recul > S.R0 then
			for i = 1, S.N_POUSS do
				local a = (i + 0.33 * c) / S.N_POUSS * math.pi * 2
				local j = math.sin(i * 12.9898 + v.n + c) * 0.5 + 0.5
				local ri = r - recul - 12 * j + 6 * math.sin(i * 3.1 + t * 2)
				local z = solCreux(ri) + S.H_POUSS * (0.35 + 0.65 * j) * hc
				local tail = (22 + 30 * j * j) * tc * v.force
				render.SetMaterial(MAT_POUSS[1 + ((i + c) % 2)])
				render.DrawSprite(versMonde(math.cos(a) * ri, math.sin(a) * ri, z), tail, tail * 0.85,
					Color(205 - 15 * c, 200 - 15 * c, 192 - 15 * c, (120 + 60 * j) * env * ac * plonge))
			end
		end
	end
end

-- rides qui se creusent derrière le front : sillon sombre + crête claire, sur le sable
local function anneau(r, w, dz, col, ph)   -- anneau ondulé : rayon, largeur et opacité varient avec l'angle
	local n = S.RIDE_SEG
	local function pt(i)
		local a = i / n * math.pi * 2
		local dr = 7 * math.sin(3 * a + ph) + 4 * math.sin(7 * a + 2.3 * ph) + 2 * math.sin(13 * a + ph * 0.7)
		local k = math.Clamp(0.55 + 0.45 * math.sin(5 * a + 1.7 * ph) + 0.3 * math.sin(11 * a - ph), 0, 1)
		return math.cos(a), math.sin(a), r + dr, w * (0.5 + 0.8 * k), k, sol(r + dr, a) + dz
	end
	local c0, s0, r0, w0, k0, z0 = pt(0)
	for i = 1, n do
		local c1, s1, r1, w1, k1, z1 = pt(i)
		local a0, a1 = col.a * k0, col.a * k1
		mesh.Color(col.r, col.g, col.b, a0) mesh.Position(versMonde(c0 * r0, s0 * r0, z0)) mesh.AdvanceVertex()
		mesh.Color(col.r, col.g, col.b, a0) mesh.Position(versMonde(c0 * (r0 + w0), s0 * (r0 + w0), z0)) mesh.AdvanceVertex()
		mesh.Color(col.r, col.g, col.b, a1) mesh.Position(versMonde(c1 * (r1 + w1), s1 * (r1 + w1), z1)) mesh.AdvanceVertex()
		mesh.Color(col.r, col.g, col.b, a1) mesh.Position(versMonde(c1 * r1, s1 * r1, z1)) mesh.AdvanceVertex()
		c0, s0, r0, w0, k0, z0 = c1, s1, r1, w1, k1, z1
	end
end
local SILLON, CRETE = Color(20, 18, 17, 0), Color(150, 146, 140, 0)
local function dessinerRides(t)
	local v = etat.vagues[#etat.vagues]
	if not v then return end
	local front = math.min(rayonVague(v, t), S.R_FIN)
	local nb = math.floor((front - S.R0) / S.RIDE_PAS)
	if nb < 1 then return end
	render.SetMaterial(MAT_RIDE)
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_QUADS, nb * S.RIDE_SEG * 2)   -- ≤ 30 anneaux x 64 x 2 = 3 840 quads
	for i = 1, nb do
		local r = S.R0 + i * S.RIDE_PAS + 5 * math.sin(i * 2.7 + v.n)
		local age = (front - r) / S.V           -- secondes depuis le passage du front
		local k = lisse(age / 1.5) * v.force * (1 - 0.5 * lisse((r - 300) / 300))
		SILLON.a = 85 * math.min(k, 1.2); CRETE.a = 40 * math.min(k, 1.2)
		anneau(r, 3, 1.1, SILLON, i * 1.9 + v.n)
		anneau(r + 3, 2.5, 1.1, CRETE, i * 1.9 + v.n)
	end
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end

-- ---------- pierres des places ----------
local pierreModele
local function modele()
	if not IsValid(pierreModele) then
		pierreModele = ClientsideModel(S.PIERRE_MODELE, RENDERGROUP_OPAQUE)
		if not IsValid(pierreModele) then return nil end
		pierreModele:SetNoDraw(true)
		pierreModele:SetModelScale(S.PIERRE_ECH, 0)
	end
	return pierreModele
end
local function basePierre(i, j)              -- repos de la pierre j (1, 2) de la place i, en coordonnées du build
	local a = math.rad(S.PLACES[i])
	local tx, ty = -math.sin(a), math.cos(a)  -- tangente : les deux pierres côte à côte
	local cx, cy = math.cos(a) * S.R_TABLETTE, math.sin(a) * S.R_TABLETTE
	local d = j == 1 and -7 or 7
	return cx + tx * d, cy + ty * d, sol(S.R_TABLETTE, a) + S.Z_TABLETTE + 3.2, a
end
-- position animée selon le résultat ; renvoie x, y, z, visible, lueur (0-1), éclat (0-1 ou nil)
local function poser(p, i, j, t)
	local x, y, z, a = basePierre(i, j)
	local dt = t - p.t0
	local res = p.res
	local glisse = (res == "partiel" and j == 2) or res == "echec"
	-- sixième retour : bascule (degrés) ; les poses se lisent à la silhouette : debout, couchée, à demi enfouie
	if res == "crit" then
		local k = lisse(dt / 1.6)
		return x, y, z + S.DOIGT * k + 0.4 * k * math.sin(t * 1.7 + j), true, 0.7 + 0.6 * k, nil, 0
	elseif glisse then
		local k = lisse((dt - 0.25 * (j - 1)) / 1.3)
		local rx, ry = -math.cos(a), -math.sin(a)  -- glisse vers Adler (visible depuis la place), puis le sable
		local d = (res == "echec" and (34 + 12 * j) or 40) * k
		local zs = sol(S.R_TABLETTE - d, a) + 1.6
		local zz = z + (zs - z) * lisse((k - 0.3) / 0.7)
		local bascule = 70 * k
		if res == "echec" then                  -- s'enfoncent à moitié, la lueur s'éteint
			local e = lisse((dt - 1.5) / 1.8)
			return x + rx * d, y + ry * d, zz - 2.5 * e, true, 0.35 * (1 - e) + 0.03, nil, bascule
		end
		return x + rx * d, y + ry * d, zz, true, 0.22, nil, bascule
	elseif res == "fiasco" then
		if dt < 0.35 then return x, y, z + 0.6 * math.sin(dt * 90), true, 0.8, nil, 0 end   -- tremble puis éclate
		return x, y, z, false, 0, dt - 0.35, 0
	end
	return x, y, z, true, 0.55, nil, 0
end

local function dessinerEclats(x, y, z, de, j, m, coul)
	local g = 260
	for k = 1, 8 do
		local a = (k / 8 + j * 0.13) * math.pi * 2
		local v = 30 + 12 * math.sin(k * 7.1)
		local px, py = x + math.cos(a) * v * math.min(de, 0.6), y + math.sin(a) * v * math.min(de, 0.6)
		local pz = math.max(z + (40 + 25 * (k % 2)) * de - 0.5 * g * de * de, sol(S.R_TABLETTE, math.atan2(py, px)) + 0.6)
		m:SetModelScale(S.PIERRE_ECH * (0.35 + 0.15 * (k % 3)), 0)
		m:SetRenderOrigin(versMonde(px, py, pz))
		m:SetRenderAngles(Angle(de * 400 + k * 40, k * 70, 0))
		m:SetupBones()
		m:DrawModel()
	end
	m:SetModelScale(S.PIERRE_ECH, 0)
	if de < 1.2 then                         -- bouffée de poussière blanche
		local al = 120 * (1 - de / 1.2)
		render.SetMaterial(MAT_POUSS[1])
		render.DrawSprite(versMonde(x, y, z + 4 + 10 * de), 20 + 40 * de, 14 + 30 * de, Color(coul, coul, coul, al))
	end
end

-- ---------- assises et tablettes : pierres plates basses en script (modèles aplatis par matrice) ----------
local rocs = {}
local function roc(nom)
	if not IsValid(rocs[nom]) then
		rocs[nom] = ClientsideModel(nom, RENDERGROUP_OPAQUE)
		if IsValid(rocs[nom]) then rocs[nom]:SetNoDraw(true) end
	end
	return rocs[nom]
end
local function dessinerRoc(def, x, y, dessus, yaw)
	local m = roc(def.m)
	if not IsValid(m) then return end
	local mx = Matrix(); mx:Scale(def.e); m:EnableMatrix("RenderMultiply", mx)
	local _, haut = m:GetModelBounds()
	m:SetRenderOrigin(versMonde(x, y, dessus - haut.z * def.e.z))
	m:SetRenderAngles(etat.tete:LocalToWorldAngles(Angle(0, yaw, 0)))
	m:SetupBones()
	local nuit = hook.Run("a2_eclairage_nuit", versMonde(x, y, dessus))
	m:DrawModel()
	if nuit then render.SuppressEngineLighting(false) end
end
hook.Remove("PostDrawOpaqueRenderables", "a2_seq_assises")   -- passe 13 : remplacé par les dalles chanfreinées (a2_seq_dalles)

hook.Add("PostDrawOpaqueRenderables", "a2_seq_pierres", function(prof, ciel)
	if prof or ciel or not dedans() then return end
	local m = modele()
	if not m then return end
	local t = CurTime()
	render.SuppressEngineLighting(true)
	render.ResetModelLighting(0.55, 0.57, 0.62)
	render.SetModelLighting(BOX_TOP, 1, 1, 1.05)
	render.SetColorModulation(S.PIERRE_COUL[1], S.PIERRE_COUL[2], S.PIERRE_COUL[3])
	render.MaterialOverride(MAT_BLANC)
	for i, p in ipairs(places) do
		if p.on then
			for j = 1, 2 do
				local x, y, z, vis, _, de, bascule = poser(p, i, j, t)
				if vis then
					m:SetRenderOrigin(versMonde(x, y, z))
					m:SetRenderAngles(etat.tete:LocalToWorldAngles(Angle(bascule or 0, S.PLACES[i] + 40 * j, (bascule or 0) * 0.4)))
					m:SetupBones()
					m:DrawModel()
				elseif de then
					dessinerEclats(x, y, z, de, j, m, 230)
				end
			end
		end
	end
	render.MaterialOverride(nil)
	render.SetColorModulation(1, 1, 1)
	render.SuppressEngineLighting(false)
end)

-- ---------- usure : socle d'Adler à demi enfoui, assises et tablettes en dalles basses chanfreinées ----------
-- (passe 13, série 4) Tout est en script, aucun posé : sable qui monte sur le bord et dans les creux, fentes,
-- écaillures, deux pierres jumelles à demi enfouies au pied, éclats autour ; ombrage par sommet vers la lumière clé.
local U = {
	Z1 = -50.2, Z2 = -46.7, ZL = -45.0,       -- dessus : grand disque, petit disque, liseré (build v11, comme DALLE_Z de la fermeture)
	R1 = 95, R2 = 47.5, R_BOURRELET = 150,    -- rayons des disques ; pied du bourrelet de sable
	VENT = 15,                                -- angle d'où vient le sable (côté opposé aux places)
	SABLE = { 132, 126, 117 }, FENTE = { 22, 20, 19 },
	CENDRE = { 138, 133, 125 },               -- assises et tablettes
	LUMIERE = Vector(0, 0, 180), R_LUM = 470, -- lumière clé (comme la fermeture) pour l'ombrage des dalles
	JUMELLES = { { a = 172, r = 108, e = 0.7, yaw = 30, p = 28, rl = 14 }, { a = 186, r = 113, e = 0.38, yaw = 150, p = -10, rl = 35 } },   -- série 8 : tailles et poses différentes
	PIERRE_JUMELLE = { 1.3, 1.26, 1.2 },     -- passe 16b : gris cendre (0,62 rendait noir)
}
local MAT_SABLE_U = CreateMaterial("a2_seq_sable_u1", "UnlitGeneric", { ["$basetexture"] = "nature/sandfloor009a",
	["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$translucent"] = 1, ["$decal"] = 1 })
local MAT_SOCLE = CreateMaterial("a2_seq_socle_2", "UnlitGeneric", { ["$basetexture"] = "vgui/white",
	["$vertexcolor"] = 1 })
local function hasard(n) local x = math.sin(n * 12.9898 + 78.233) * 43758.5453 return x - math.floor(x) end
local function bruit(a, ph) return 0.5 + 0.3 * math.sin(3 * a + ph) + 0.2 * math.sin(7 * a - 1.7 * ph) end   -- 0..1 lisse
local function zDalle(r) if r <= U.R2 then return U.Z2 end return U.Z1 end   -- v13 : plus de liseré
local function eclaire(x, y, z, nx, ny, nz)  -- facteur de lumière d'un sommet (lumière clé seule, décroissance douce)
	local lx, ly, lz = U.LUMIERE.x - x, U.LUMIERE.y - y, U.LUMIERE.z - z
	local d = math.sqrt(lx * lx + ly * ly + lz * lz)
	local diff = math.max(0, (nx * lx + ny * ly + nz * lz) / d)
	return (0.55 + 0.8 * diff) / (1 + (x * x + y * y) / (U.R_LUM * U.R_LUM))
end
local function sommetU(x, y, z, c, k, al)
	mesh.Color(math.min(c[1] * k, 255), math.min(c[2] * k, 255), math.min(c[3] * k, 255), al)
	mesh.Position(versMonde(x, y, z)) mesh.AdvanceVertex()
end


-- bosse du vrai sable (passe 15) : le script du sable l'ajoute à sa hauteur, donc teinte, lumière et pénombre exactes.
-- Bourrelet contre le socle (plus haut côté vent, crête ondulée) et lèvre autour des assises et des tablettes.
local BOSSE = { PLACE = { 30, 3.5, 9 }, TABLETTE = { 15, 2.5, 6 } }
-- série 7 : le sable recouvre le socle. Plateau au-dessus du disque (collision) puis talus, plus haut et plus large
-- côté amas ; chaque morceau et chaque caillou a son propre talus (talusAmas, défini avec les morceaux).
-- socle : série 8 (cuvette, bord franc), choisie par Adrien le 26/11/2026
local V = { creux = true, talusCoeur = false, coeur = { 116, 113, 118 }, biseauCoeur = 1.0,
	eclat = 1.35, matiere = true, rTalus = 28, hTalus = 7,
	jumelles = { { a = 172, r = 108, e = 0.7, yaw = 30, p = 28, rl = 14, dz = -8.6 }, { a = 186, r = 113, e = 0.38, yaw = 150, p = -10, rl = 35, dz = -6.04 } } }
hook.Add("a2_socle_version", "a2_seq", function() return 8 end)
local NAPPE = { Z = -51.5, FOND = -57.5, Z_CREUX = -54.2, R = U.R1 + 2, W = 34, W_AMAS = 70, H_AMAS = 2.2, A_AMAS = math.rad(105),   -- 16d : de côté (à 40° l'amas était caché derrière Adler depuis les places)
	 L_AMAS = math.rad(75) }
local function lobe(d, r0, h, w) return h * math.exp(-((d - r0) / w) ^ 2) end
local function versAmas(a)                  -- 1 face au centre de l'amas, 0 à l'opposé (lissé)
	local d = math.abs(math.atan2(math.sin(a - NAPPE.A_AMAS), math.cos(a - NAPPE.A_AMAS)))
	return math.exp(-(d / NAPPE.L_AMAS) ^ 2)
end
local function nappe(r, a)                  -- surélévation du sable par la nappe seule (sans les talus des morceaux)
	local k = versAmas(a)
	local rp = NAPPE.R + 8 * (bruit(a, 1.3) - 0.5) + 25 * k
	local w = NAPPE.W + (NAPPE.W_AMAS - NAPPE.W) * k
	local h = NAPPE.Z - NAPPE.FOND + NAPPE.H_AMAS * k * (0.7 + 0.6 * bruit(a, 4.1))
	if r > rp then h = h * (1 - lisse((r - rp) / w)) end
	-- série 8 : cuvette creusée par le vent autour de la dalle centrale (sable à -54) : la dalle ressort de 2 à 3 u de plus
	if not V.creux then return h end
	local hc = NAPPE.Z_CREUX - NAPPE.FOND
	return hc + (h - hc) * lisse((r - U.R2 - 4) / 24)
end
local talusAmas                             -- talus des morceaux du socle (assigné plus bas)
hook.Add("a2_sable_bosse", "a2_seq", function(r, a)
	local z = nappe(r, a) + (talusAmas and talusAmas(r, a) or 0)
	if r > 180 and r < 320 then
		local x, y = math.cos(a) * r, math.sin(a) * r
		for _, ang in ipairs(S.PLACES) do
			local t = math.rad(ang)
			local dp = math.sqrt((x - math.cos(t) * S.R_PLACE) ^ 2 + (y - math.sin(t) * S.R_PLACE) ^ 2)
			local dt = math.sqrt((x - math.cos(t) * S.R_TABLETTE) ^ 2 + (y - math.sin(t) * S.R_TABLETTE) ^ 2)
			z = z + lobe(dp, BOSSE.PLACE[1], BOSSE.PLACE[2], BOSSE.PLACE[3]) + lobe(dt, BOSSE.TABLETTE[1], BOSSE.TABLETTE[2], BOSSE.TABLETTE[3])
		end
	end
	return z
end)

-- bourrelet de sable autour d'un centre : crête au rayon rIn (hauteur zCrete + bruit), pied fondu au rayon rOut ;
-- varR (0..1) fait onduler le rayon de la crête : le contour n'est plus un cercle
local function bourrelet(cx, cy, rIn, rOut, zCrete, amp, n, ph, varR, alCrete)
	varR, alCrete = varR or 0, alCrete or 190
	for i = 0, n - 1 do
		local a0, a1 = i / n * math.pi * 2, (i + 1) / n * math.pi * 2
		local function rc(a) return rIn * (1 + varR * (bruit(a, ph + 1.1) - 0.5)) end
		local function pt(a, r, z, al)
			local x, y = cx + math.cos(a) * r, cy + math.sin(a) * r
			local k = 0.72 - 0.25 * lisse((math.sqrt(x * x + y * y) - 90) / 220)
			sommetU(x, y, z, U.SABLE, k, al)
		end
		local function zc(a) return zCrete + amp * (bruit(a, ph) - 0.5) end
		local function so(a) local x, y = cx + math.cos(a) * rOut, cy + math.sin(a) * rOut return sol(math.sqrt(x * x + y * y), math.atan2(y, x)) + 0.3 end
		pt(a0, rc(a0), zc(a0), alCrete) pt(a1, rc(a1), zc(a1), alCrete) pt(a1, rOut, so(a1), 0) pt(a0, rOut, so(a0), 0)
	end
end

-- sable qui déborde vers l'intérieur du socle, surtout du côté du vent
local function debordSocle(n)
	local vent = math.rad(U.VENT)
	for i = 0, n - 1 do
		local a0, a1 = i / n * math.pi * 2, (i + 1) / n * math.pi * 2
		local function long(a) return 3 + 22 * math.max(0, math.cos(a - vent)) ^ 2 + 6 * bruit(a, 4.1) end
		local function pt(a, r, al)
			sommetU(math.cos(a) * r, math.sin(a) * r, zDalle(r) + 0.35, U.SABLE, 0.75, al)
		end
		pt(a0, U.R1 - 1, 200) pt(a1, U.R1 - 1, 200) pt(a1, U.R1 - 1 - long(a1), 0) pt(a0, U.R1 - 1 - long(a0), 0)
	end
end

-- taches de sable dans les creux : au pied de la marche entre les deux disques et près des fentes
local TACHES = {}
for i = 1, 14 do
	local a = math.rad(U.VENT + (hasard(i) - 0.5) * 260)
	local r = i <= 6 and U.R2 + 3 + 8 * hasard(i + 20) or (i <= 10 and 70 + 20 * hasard(i + 50) or 15 + 25 * hasard(i + 40))
	TACHES[i] = { x = math.cos(a) * r, y = math.sin(a) * r, s = 7 + 9 * hasard(i + 60), ph = i * 1.3 }
end
local function tache(t, zFixe)
	local n = 10
	for k = 0, n - 1 do
		local a0, a1 = k / n * math.pi * 2, (k + 1) / n * math.pi * 2
		local r0, r1 = t.s * (0.6 + 0.5 * bruit(a0, t.ph)), t.s * (0.6 + 0.5 * bruit(a1, t.ph))
		local z = zFixe or zDalle(math.sqrt(t.x * t.x + t.y * t.y)) + 0.4
		sommetU(t.x, t.y, z, U.SABLE, 1.15, 200) sommetU(t.x, t.y, z, U.SABLE, 1.15, 200)
		sommetU(t.x + math.cos(a1) * r1, t.y + math.sin(a1) * r1, z, U.SABLE, 1.15, 0)
		sommetU(t.x + math.cos(a0) * r0, t.y + math.sin(a0) * r0, z, U.SABLE, 1.15, 0)
	end
end

-- fentes : lignes brisées sombres qui partent du bord vers l'intérieur (chaque disque séparément)
local FENTES = {}
for i = 1, 8 do
	local interieur = i > 5
	local a = hasard(i + 80) * math.pi * 2
	local r = interieur and U.R2 - 2 or U.R1 - 4
	local rMin = interieur and 6 or U.R2 + 3
	local pts = { { math.cos(a) * r, math.sin(a) * r } }
	local dir = a + math.pi
	for s = 1, 6 do
		dir = dir + (hasard(i * 10 + s) - 0.5) * 1.1
		local x, y = pts[s][1] + math.cos(dir) * (5 + 5 * hasard(i * 7 + s)), pts[s][2] + math.sin(dir) * (5 + 5 * hasard(i * 7 + s))
		if math.sqrt(x * x + y * y) < rMin then break end
		pts[#pts + 1] = { x, y }
	end
	FENTES[i] = pts
end
local function fente(pts)
	for s = 1, #pts - 1 do
		local x0, y0, x1, y1 = pts[s][1], pts[s][2], pts[s + 1][1], pts[s + 1][2]
		local dx, dy = x1 - x0, y1 - y0
		local l = math.sqrt(dx * dx + dy * dy)
		local w0, w1 = 1.1 * (1 - (s - 1) / #pts) + 0.15, 1.1 * (1 - s / #pts) + 0.15
		local nx, ny = -dy / l, dx / l
		local z = zDalle(math.sqrt(x0 * x0 + y0 * y0)) + 0.3
		sommetU(x0 + nx * w0, y0 + ny * w0, z, U.FENTE, 1, 150) sommetU(x1 + nx * w1, y1 + ny * w1, z, U.FENTE, 1, 150)
		sommetU(x1 - nx * w1, y1 - ny * w1, z, U.FENTE, 1, 150) sommetU(x0 - nx * w0, y0 - ny * w0, z, U.FENTE, 1, 150)
	end
end

-- écaillures : encoches sombres sur le bord du petit disque et sur le liseré
local function ecaillures(r, z, n, ph)
	for i = 1, n do
		local a = (i + hasard(i + ph) * 0.8) / n * math.pi * 2
		local l, p = 0.08 + 0.1 * hasard(i * 3 + ph), 2.5 + 3 * hasard(i * 5 + ph)
		local function pt(aa, rr, al) sommetU(math.cos(aa) * rr, math.sin(aa) * rr, z + 0.3, U.FENTE, 1, al) end
		pt(a - l, r + 0.5, 200) pt(a + l, r + 0.5, 200) pt(a + l * 0.4, r - p, 120) pt(a - l * 0.4, r - p, 120)
	end
end

hook.Add("PostDrawTranslucentRenderables", "a2_seq_usure", function(prof, ciel)
	if prof or ciel or not dedans() then return end
	render.CullMode(MATERIAL_CULLMODE_NONE)
	render.SetMaterial(MAT_RIDE)
	mesh.Begin(MATERIAL_QUADS, 8 * 6 + 22 + 30)
	for k = 6, #FENTES do fente(FENTES[k]) end   -- passe 15b : fentes du cœur seulement
	ecaillures(U.R2, U.Z2, 10, 3)
	mesh.End()
	render.SetMaterial(MAT_SABLE_U)
	mesh.Begin(MATERIAL_QUADS, 80 + 80 + #TACHES * 10 + #S.PLACES * (2 * 32 + 20))
	-- passe 15 : bourrelet retiré (remplacé par la bosse du vrai sable, hook a2_sable_bosse)   -- v13 : liseré retiré, le sable mange le bord en vagues   -- le liseré disparaît par endroits sous le sable
	-- passe 15b : débord retiré (son bord à r 94 traçait un cercle net au-dessus des morceaux enfoncés)
	for k = 11, #TACHES do tache(TACHES[k]) end   -- passe 15b : seulement sur le cœur (la couronne est enfoncée)
	for i, ang in ipairs(S.PLACES) do                -- assises et tablettes prises dans le sable
		local a = math.rad(ang)
		local x, y = math.cos(a) * S.R_PLACE, math.sin(a) * S.R_PLACE
		-- passe 15 : bourrelet retiré (bosse du vrai sable)
		for k = 1, 2 do                             -- sable posé sur l'assise, côté du vent
			local aa = math.rad(U.VENT) + (hasard(i * 5 + k) - 0.5) * 2
			tache({ x = x + math.cos(aa) * 16, y = y + math.sin(aa) * 16, s = 8 + 5 * hasard(i + k), ph = i + k }, sol(S.R_PLACE, a) + S.ASSISE_DESSUS + 0.3)
		end
		x, y = math.cos(a) * S.R_TABLETTE, math.sin(a) * S.R_TABLETTE
		-- passe 15 : bourrelet retiré (bosse du vrai sable)
	end
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end)

-- dalle basse chanfreinée : polygone irrégulier, base enfouie, épaule, arête biseautée, dessus plat ; ombrée par sommet
local DALLES = {}
local function formeDalle(seed, n)
	local f = {}
	for k = 1, n do f[k] = { a = (k - 1 + 0.35 * (hasard(seed + k) - 0.5)) / n * math.pi * 2, k = 0.85 + 0.3 * hasard(seed * 3 + k) } end
	return f
end
for i = 1, #S.PLACES do DALLES[i] = { assise = formeDalle(i * 17, 7), tablette = formeDalle(i * 29, 6) } end
local function dalle(cx, cy, forme, rb, dessus, base, biseau, yaw)
	local n = #forme
	local function anneauPts(r, z)
		local l = {}
		for k = 1, n do
			local a = forme[k].a + yaw
			l[k] = { cx + math.cos(a) * r * forme[k].k, cy + math.sin(a) * r * forme[k].k, z, math.cos(a), math.sin(a), 0.85 + 0.3 * hasard(k * 7.3 + z + cx) }
		end
		return l
	end
	local bas, epaule, haut = anneauPts(rb, base), anneauPts(rb, dessus - biseau), anneauPts(rb - biseau * 1.3, dessus)
	local function face(p, q, nz, kc)
		local nx, ny = (p[4] + q[4]) / 2, (p[5] + q[5]) / 2
		local s = math.sqrt(1 - nz * nz)
		return eclaire(p[1], p[2], p[3], nx * s, ny * s, nz) * kc * p[6]
	end
	for k = 1, n do
		local k2 = k % n + 1
		local f1 = face(bas[k], bas[k2], 0, 1)
		sommetU(bas[k][1], bas[k][2], bas[k][3], U.CENDRE, f1, 255) sommetU(bas[k2][1], bas[k2][2], bas[k2][3], U.CENDRE, f1, 255)
		sommetU(epaule[k2][1], epaule[k2][2], epaule[k2][3], U.CENDRE, f1, 255) sommetU(epaule[k][1], epaule[k][2], epaule[k][3], U.CENDRE, f1, 255)
		local f2 = face(epaule[k], epaule[k2], 0.7, 1.08)   -- biseau : accroche la lumière
		sommetU(epaule[k][1], epaule[k][2], epaule[k][3], U.CENDRE, f2, 255) sommetU(epaule[k2][1], epaule[k2][2], epaule[k2][3], U.CENDRE, f2, 255)
		sommetU(haut[k2][1], haut[k2][2], haut[k2][3], U.CENDRE, f2, 255) sommetU(haut[k][1], haut[k][2], haut[k][3], U.CENDRE, f2, 255)
		local f3 = eclaire(cx, cy, dessus, 0, 0, 1)       -- dessus en éventail (quads dégénérés vers le centre)
		sommetU(cx, cy, dessus, U.CENDRE, f3, 255) sommetU(cx, cy, dessus, U.CENDRE, f3, 255)
		sommetU(haut[k][1], haut[k][2], haut[k][3], U.CENDRE, f3, 255) sommetU(haut[k2][1], haut[k2][2], haut[k2][3], U.CENDRE, f3, 255)
	end
end
local jumelle
hook.Add("PostDrawOpaqueRenderables", "a2_seq_dalles", function(prof, ciel)
	if prof or ciel or not dedans() then return end
	render.SetMaterial(MAT_SOCLE)
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_QUADS, #S.PLACES * (7 + 6) * 3)
	for i, ang in ipairs(S.PLACES) do
		local a = math.rad(ang)
		dalle(math.cos(a) * S.R_PLACE, math.sin(a) * S.R_PLACE, DALLES[i].assise, 28, sol(S.R_PLACE, a) + S.ASSISE_DESSUS,
			sol(S.R_PLACE, a) - 3, 2.2, a + i)
		dalle(math.cos(a) * S.R_TABLETTE, math.sin(a) * S.R_TABLETTE, DALLES[i].tablette, 15, sol(S.R_TABLETTE, a) + S.Z_TABLETTE,
			sol(S.R_TABLETTE, a) - 2, 1.4, a * 2 + i)
	end
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
	-- deux pierres jumelles à demi enfouies au pied du socle, éclats autour
	if not IsValid(jumelle) then
		jumelle = ClientsideModel(S.PIERRE_MODELE, RENDERGROUP_OPAQUE)
		if not IsValid(jumelle) then return end
		jumelle:SetNoDraw(true)
	end
	render.SetColorModulation(U.PIERRE_JUMELLE[1], U.PIERRE_JUMELLE[2], U.PIERRE_JUMELLE[3])
	render.MaterialOverride(MAT_ASSISE)
	local function poserRoc(x, y, z, e, ang)
		jumelle:SetModelScale(e, 0)
		jumelle:SetRenderOrigin(versMonde(x, y, z))
		jumelle:SetRenderAngles(etat.tete:LocalToWorldAngles(ang))
		jumelle:SetupBones()
		local nuit = hook.Run("a2_eclairage_nuit", versMonde(x, y, z))
		jumelle:DrawModel()
		if nuit then render.SuppressEngineLighting(false) end
	end
	for _, j in ipairs(V.jumelles) do
		local a = math.rad(j.a)
		poserRoc(math.cos(a) * j.r, math.sin(a) * j.r, sol(j.r, a) + j.dz, j.e, Angle(j.p, j.yaw, j.rl))
	end
	for k = 1, 12 do                                 -- éclats du socle tombés dans le sable
		local a = hasard(k + 300) * math.pi * 2
		local r = U.R1 + 4 + 56 * hasard(k + 310)
		poserRoc(math.cos(a) * r, math.sin(a) * r, sol(r, a) - 1.5, 0.14 + 0.12 * hasard(k + 320), Angle(40 * hasard(k), 360 * hasard(k + 1), 30))
	end
	render.MaterialOverride(nil)
	render.SetColorModulation(1, 1, 1)
end)

-- ---------- socle d'Adler en script (passe 14, série 5) ----------
-- Les deux disques du dupe restent pour la collision et sont cachés côté client ; on dessine à leur place une dalle
-- brisée : un cœur irrégulier (où se tient Adler, au niveau du petit disque) et une couronne en 5 morceaux séparés par
-- des failles, dessus au niveau du grand disque, base enterrée. Mêmes ombrage, grain et teinte que les assises.
local SOCLE = {
	MODELES = { ["models/hunter/tubes/circle4x4.mdl"] = true, ["models/hunter/tubes/circle2x2.mdl"] = true },
	R_CACHE = 12,                             -- seuls les disques centrés sur le creux sont cachés
	COUL = { 100, 98, 104 }, COUL_COEUR = { 116, 113, 118 },   -- série 8 : cœur plus clair que l'amas (point focal)
	BISEAU_COEUR = 1.0,
	BASE = -60, BISEAU = 3.4,
	N_MORCEAUX = 7, FAILLE = 0.11,            -- largeur angulaire des failles (rad)
}
local cachesSocle, prochainCache = {}, 0
local function rienDessiner() end
local traceCache = ""
-- passe 15 : SetNoDraw seul ne tenait pas (hypothèse : l'état réseau du serveur le rétablit) ; on réapplique chaque
-- seconde et on remplace aussi le rendu (RenderOverride vide, marque a2_cache lue par la fermeture). Trace en console.
hook.Add("Think", "a2_seq_socle_cache", function()
	if CurTime() < prochainCache then return end
	prochainCache = CurTime() + 1
	local voulu = dedans()
	for e in pairs(cachesSocle) do
		if not IsValid(e) then cachesSocle[e] = nil
		elseif not voulu then
			e.a2_cache = nil; e.RenderOverride = nil; e:SetNoDraw(false); cachesSocle[e] = nil
			hook.Run("a2_eclairer", e)
		end
	end
	if not voulu then return end
	local trouves, caches, avantNoDraw = 0, 0, 0
	for m in pairs(SOCLE.MODELES) do
		for _, e in ipairs(ents.FindByModel(m)) do
			if IsValid(e) then
				local p = etat.tete:WorldToLocal(e:GetPos()) + TETE
				if p.x * p.x + p.y * p.y <= SOCLE.R_CACHE * SOCLE.R_CACHE and math.abs(p.z + 50) < 30 then
					trouves = trouves + 1
					if cachesSocle[e] and not e:GetNoDraw() then avantNoDraw = avantNoDraw + 1 end
					e.a2_cache = true; e.RenderOverride = rienDessiner; e:SetNoDraw(true); cachesSocle[e] = true
					caches = caches + 1
				end
			end
		end
	end
	local t = trouves .. " trouvés, " .. caches .. " cachés, " .. avantNoDraw .. " redevenus visibles"
	if t ~= traceCache then traceCache = t; print("[a2_sequence] disques du socle : " .. t) end
end)

-- prisme à arête biseautée sur un polygone quelconque (points dans l'ordre), base enterrée
local function prisme(pts, dessus, base, biseau, c, px, py)
	px, py = px or 0, py or 0                 -- pente du dessus (u par u) : morceau basculé
	local n = #pts
	local gx, gy = 0, 0
	for _, p in ipairs(pts) do gx, gy = gx + p[1], gy + p[2] end
	gx, gy = gx / n, gy / n
	local function zt(x, y) return dessus + px * (x - gx) + py * (y - gy) end
	local function vers(p, d)                 -- point rentré de d vers le centre du morceau
		local dx, dy = gx - p[1], gy - p[2]
		local l = math.max(math.sqrt(dx * dx + dy * dy), 0.01)
		return p[1] + dx / l * d, p[2] + dy / l * d
	end
	-- série 7 : arête arrondie en deux pans (mur, pan 1 à mi-pente, pan 2 presque plat, dessus), ombrage progressif
	for k = 1, n do
		local p, q = pts[k], pts[k % n + 1]
		local nx, ny = q[2] - p[2], -(q[1] - p[1])
		local l = math.max(math.sqrt(nx * nx + ny * ny), 0.01)
		nx, ny = nx / l, ny / l
		if (p[1] - gx) * nx + (p[2] - gy) * ny < 0 then nx, ny = -nx, -ny end
		local g1, g2 = 0.88 + 0.24 * hasard(p[1] * 0.37 + p[2]), 0.88 + 0.24 * hasard(q[1] * 0.37 + q[2])
		local zp, zq = zt(p[1], p[2]), zt(q[1], q[2])
		local ax, ay = vers(p, biseau * 0.7)
		local bx, by = vers(q, biseau * 0.7)
		local cx, cy = vers(p, biseau * 1.8)
		local dx, dy = vers(q, biseau * 1.8)
		local f1 = eclaire(p[1], p[2], zp, nx, ny, 0)
		local f2 = eclaire(p[1], p[2], zp, nx * 0.8, ny * 0.8, 0.6)
		local f3 = eclaire(p[1], p[2], zp, nx * 0.35, ny * 0.35, 0.94)
		local f4 = eclaire(gx, gy, dessus, -px, -py, 1)
		sommetU(p[1], p[2], base, c, f1 * g1, 255) sommetU(q[1], q[2], base, c, f1 * g2, 255)
		sommetU(q[1], q[2], zq - biseau, c, f1 * g2, 255) sommetU(p[1], p[2], zp - biseau, c, f1 * g1, 255)
		sommetU(p[1], p[2], zp - biseau, c, f2 * g1, 255) sommetU(q[1], q[2], zq - biseau, c, f2 * g2, 255)
		sommetU(bx, by, zt(bx, by) - biseau * 0.3, c, f2 * g2, 255) sommetU(ax, ay, zt(ax, ay) - biseau * 0.3, c, f2 * g1, 255)
		sommetU(ax, ay, zt(ax, ay) - biseau * 0.3, c, f3 * g1, 255) sommetU(bx, by, zt(bx, by) - biseau * 0.3, c, f3 * g2, 255)
		sommetU(dx, dy, zt(dx, dy), c, f3 * g2, 255) sommetU(cx, cy, zt(cx, cy), c, f3 * g1, 255)
		sommetU(gx, gy, dessus, c, f4, 255) sommetU(gx, gy, dessus, c, f4, 255)
		sommetU(cx, cy, zt(cx, cy), c, f4 * g1, 255) sommetU(dx, dy, zt(dx, dy), c, f4 * g2, 255)
	end
	return n * 4
end

-- géométrie figée une fois (série 7) : cœur mordu côté amas, amas de morceaux basculés et enterrés d'un seul côté,
-- débris surtout côté amas. Les dessus sont placés par rapport à la nappe de sable (nappe()), pas au niveau du disque.
local COEUR, AMAS, DEBRIS = {}, {}, {}
do
	local N = 14
	for k = 1, N do
		local a = (k - 1 + 0.5 * (hasard(k + 500) - 0.5)) / N * math.pi * 2
		local morsure = math.exp(-((math.atan2(math.sin(a - NAPPE.A_AMAS), math.cos(a - NAPPE.A_AMAS))) / 0.45) ^ 2)
		local r = U.R2 * (0.8 + 0.24 * hasard(k + 510)) * (1 - 0.42 * morsure)   -- bord ébréché + grande morsure
		COEUR[k] = { math.cos(a) * r, math.sin(a) * r }
	end
end
local function polygone(cx, cy, rb, n, graine)   -- éclat irrégulier autour de (cx, cy)
	local pts = {}
	local rot = hasard(graine) * math.pi * 2
	for i = 1, n do
		local b = rot + (i - 1 + 0.6 * (hasard(graine * 7 + i) - 0.5)) / n * math.pi * 2
		local rr = rb * (0.55 + 0.55 * hasard(graine * 13 + i))
		pts[i] = { cx + math.cos(b) * rr, cy + math.sin(b) * rr }
	end
	return pts
end
local SOCLE7 = { N = 9, SPREAD = math.rad(95), R_MIN = 62, R_MAX = 118, RB = { 10, 24 } }
for m = 1, SOCLE7.N do
	local u = hasard(m + 700) - 0.5                              -- -0,5..0,5, resserré au centre de l'amas
	local a = NAPPE.A_AMAS + SOCLE7.SPREAD * u * (0.35 + 1.3 * math.abs(u))
	local k = versAmas(a)
	local r = SOCLE7.R_MIN + (SOCLE7.R_MAX - SOCLE7.R_MIN) * hasard(m + 710)
	local rb = math.min(SOCLE7.RB[1] + (SOCLE7.RB[2] - SOCLE7.RB[1]) * k * (0.6 + 0.4 * hasard(m + 720)), r - 44)
	local cx, cy = math.cos(a) * r, math.sin(a) * r
	local pente = 0.15 + 0.3 * hasard(m + 730)                    -- plaques qui piquent dans le sable
	local b = hasard(m + 740) * math.pi * 2
	local d0 = 3 + 4 * hasard(m + 750) * (0.5 + 0.5 * k)   -- passe 16b : plus hauts côté amas
	AMAS[m] = { pts = polygone(cx, cy, rb, 6, m + 760), x = cx, y = cy, rb = rb, r = r, a = a, d0 = d0, dessus = NAPPE.FOND + nappe(r, a) + d0,
		px = math.cos(b) * pente, py = math.sin(b) * pente }
end
for k = 1, 9 do                               -- débris : 6 côté amas, 3 dispersés
	local a = k <= 6 and NAPPE.A_AMAS + math.rad(110) * (hasard(k + 600) - 0.5) or hasard(k + 600) * math.pi * 2
	local r = U.R1 + 10 + 60 * hasard(k + 610)
	local cx, cy, rb = math.cos(a) * r, math.sin(a) * r, 4 + 7 * hasard(k + 620)
	DEBRIS[k] = { pts = polygone(cx, cy, rb, 5, k + 800), x = cx, y = cy, rb = rb, r = r, a = a, h = 0.8 + 2.2 * hasard(k + 630),
		px = 0.3 * (hasard(k + 640) - 0.5), py = 0.3 * (hasard(k + 650) - 0.5) }
end
-- cailloux du dupe : éclaircis (lus par la fermeture, e.a2_eclat) et pris dans un talus de sable
local CAILLOUX = { MODELE = "models/props_wasteland/rockgranite03b.mdl", ECLAT = 1.35, R_TALUS = 28, H_TALUS = 7 }   -- série 8 : matière cendre, plus enterrés
local cailloux = nil                          -- positions (repère du build), relevées une fois
local function releverCailloux()
	if cailloux or not IsValid(etat.tete) then return cailloux end
	cailloux = {}
	for _, e in ipairs(ents.FindByClass("prop_physics")) do   -- 16c : props du dupe seulement (FindByModel rendait aussi les modèles client, pic de sable)
		if IsValid(e) and string.lower(e:GetModel() or "") == CAILLOUX.MODELE then
			local p = etat.tete:WorldToLocal(e:GetPos()) + TETE
			if math.abs(p.x) <= S.BX and math.abs(p.y) <= S.BX then
				e.a2_eclat = V.eclat; e.a2_matiere = V.matiere and MAT_ASSISE or nil   -- texture brune du granite remplacée (lue par la fermeture)
				cailloux[#cailloux + 1] = { x = p.x, y = p.y }
			end
		end
	end
	if #cailloux == 0 then cailloux = nil end
	return cailloux
end
local H_TALUS = 0.4                           -- part de la hauteur visible d'un morceau recouverte par son talus
talusAmas = function(r, a)
	local x, y = math.cos(a) * r, math.sin(a) * r
	local z, zm = 0, 0
	local zc = math.max(0, U.Z2 - (NAPPE.FOND + nappe(r, a)))
	if V.talusCoeur then z = z + lobe(r, U.R2 * 0.9, H_TALUS * 0.8 * zc, 9) end   -- série 7 seulement (série 8 : cuvette dans nappe)
	for _, m in ipairs(AMAS) do
		local d = math.sqrt((x - m.x) ^ 2 + (y - m.y) ^ 2)
		if d < m.rb + 40 then
			local h = math.max(0, m.dessus - (NAPPE.FOND + nappe(r, a)))
			zm = math.max(zm, H_TALUS * h * math.exp(-(math.max(0, d - m.rb * 0.6) / (6 + 0.35 * m.rb)) ^ 2))   -- 16c : max, pas somme (l'amas s'enterrait sous une butte)
		end
	end
	z = z + zm
	for _, d0 in ipairs(DEBRIS) do
		local d = math.sqrt((x - d0.x) ^ 2 + (y - d0.y) ^ 2)
		if d < d0.rb + 20 then z = z + 1.6 * math.exp(-(math.max(0, d - d0.rb * 0.5) / 6) ^ 2) end
	end
	local cs = releverCailloux()
	if cs then
		for _, c in ipairs(cs) do
			local d = math.sqrt((x - c.x) ^ 2 + (y - c.y) ^ 2)
			if d < V.rTalus * 2.5 then z = z + V.hTalus * math.exp(-(d / V.rTalus) ^ 2) end
		end
	end
	return z
end
local quadsSocle = #COEUR * 4
for _, m in ipairs(AMAS) do quadsSocle = quadsSocle + #m.pts * 4 end
for _, d in ipairs(DEBRIS) do quadsSocle = quadsSocle + #d.pts * 4 end
hook.Remove("PostDrawTranslucentRenderables", "a2_seq_socle_sable")   -- passe 15 : failles laissées sombres (sable réel au fond)
hook.Add("PostDrawOpaqueRenderables", "a2_seq_socle", function(prof, ciel)
	if prof or ciel or not dedans() then return end
	render.SetMaterial(MAT_SOCLE)
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_QUADS, quadsSocle)
	prisme(COEUR, U.Z2, SOCLE.BASE, V.biseauCoeur, V.coeur, 0.05, -0.04)   -- bord franc   -- plus sombre : la lumière clé tombe d'aplomb
	for _, m in ipairs(AMAS) do prisme(m.pts, m.dessus, SOCLE.BASE, SOCLE.BISEAU, SOCLE.COUL, m.px, m.py) end
	for _, d in ipairs(DEBRIS) do prisme(d.pts, sol(d.r, d.a) + d.h, SOCLE.BASE, 1.2, SOCLE.COUL, d.px, d.py) end   -- sur le vrai sable (talus compris)   -- posés sur le vrai sable (bosse comprise)
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end)

-- ---------- places lisibles de loin et signature (pouls) de chaque élève ----------
local function centrePlace(i)               -- entre l'assise et la tablette
	local a = math.rad(S.PLACES[i])
	local r = (S.R_PLACE + S.R_TABLETTE) / 2
	return math.cos(a) * r, math.sin(a) * r, a
end
local function anneauPlat(cx, cy, r0, r1, n, col, a0, a1, dz, ph)   -- anneau posé sur le sable, alpha intérieur a0, extérieur a1
	for k = 0, n - 1 do
		local u0, u1 = k / n * math.pi * 2, (k + 1) / n * math.pi * 2
		local o0 = 1 + 0.08 * math.sin(3 * u0 + ph) + 0.05 * math.sin(7 * u0 - ph)
		local o1 = 1 + 0.08 * math.sin(3 * u1 + ph) + 0.05 * math.sin(7 * u1 - ph)
		local function p(rr, u, al)
			local x, y = cx + math.cos(u) * rr, cy + math.sin(u) * rr
			mesh.Color(col[1], col[2], col[3], al)
			mesh.Position(versMonde(x, y, sol(math.sqrt(x * x + y * y), math.atan2(y, x)) + dz))
			mesh.AdvanceVertex()
		end
		p(r0 * o0, u0, a0) p(r0 * o1, u1, a0) p(r1 * o1, u1, a1) p(r1 * o0, u0, a1)
	end
end
local MARQUE_CLAIR, MARQUE_SOMBRE = { 150, 145, 138 }, { 16, 15, 14 }
local function dessinerMarques()            -- cercle ratissé clair + sillon sombre autour de l'assise
	render.SetMaterial(MAT_RIDE)
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_QUADS, #S.PLACES * 40 * 4)
	for i, ang in ipairs(S.PLACES) do
		local a = math.rad(ang)
		local cx, cy = math.cos(a) * S.R_PLACE, math.sin(a) * S.R_PLACE
		anneauPlat(cx, cy, S.R_MARQUE - 4, S.R_MARQUE, 40, MARQUE_SOMBRE, 0, 120, 1.0, i)
		anneauPlat(cx, cy, S.R_MARQUE, S.R_MARQUE + 5, 40, MARQUE_CLAIR, 110, 110, 1.0, i)
		anneauPlat(cx, cy, S.R_MARQUE + 5, S.R_MARQUE + 14, 40, MARQUE_CLAIR, 55, 0, 1.0, i)
		local tx, ty = math.cos(a) * S.R_TABLETTE, math.sin(a) * S.R_TABLETTE   -- liseré clair autour de la tablette
		anneauPlat(tx, ty, 15, 19, 40, MARQUE_CLAIR, 120, 0, 1.0, i + 2)
	end
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
end
local function dessinerSignature(p, i, t)        -- pouls en couleur : halo au sol, anneau qui respire, braises qui montent
	local s = p.sig
	local pouls = 0.5 + 0.5 * math.sin(t * 2 * math.pi / 1.8 + i)
	local attenue = (p.res == "echec" and 1 - 0.45 * lisse((t - p.t0 - 1.5) / 1.8))
		or (p.res == "fiasco" and (t - p.t0 < 0.35 and 1 or math.max(0.15, 1 - (t - p.t0 - 0.35) * 2)))
		or (p.res == "crit" and 1.25) or 1
	local k = (0.55 + 0.45 * pouls) * attenue
	local cx, cy = centrePlace(i)
	render.SetMaterial(MAT_LUEUR)              -- halo large et doux au sol
	render.DrawQuadEasy(versMonde(cx, cy, sol(250, math.rad(S.PLACES[i])) + 1.5), etat.tete:GetUp(), 150, 150,
		Color(s[1] * k, s[2] * k, s[3] * k, 255), 0)
	render.SetMaterial(MAT_ADD)                -- anneau qui respire avec le pouls
	render.CullMode(MATERIAL_CULLMODE_NONE)
	mesh.Begin(MATERIAL_QUADS, 48 * 2)
	local r = S.R_SIG + 6 * pouls
	anneauPlat(cx, cy, r - 16, r, 48, s, 0, 255 * k, 1.8, t * 0.3 + i)
	anneauPlat(cx, cy, r, r + 10, 48, s, 255 * k, 0, 1.8, t * 0.3 + i)
	mesh.End()
	render.CullMode(MATERIAL_CULLMODE_CCW)
	render.SetMaterial(MAT_LUEUR)              -- braises qui montent de l'anneau (cycle 3 s, 10 points)
	for b = 1, 6 do
		local u = (t / 3 + b * 0.137 + i * 0.31) % 1
		local ang = b * 2.399 + i
		local rr = S.R_SIG * (0.9 + 0.1 * math.sin(b * 5.3))
		local x, y = cx + math.cos(ang) * rr, cy + math.sin(ang) * rr
		local al = 255 * math.sin(u * math.pi) * attenue
		render.DrawSprite(versMonde(x, y, sol(math.sqrt(x * x + y * y), math.atan2(y, x)) + 2 + 34 * u), 8, 8,
			Color(s[1] * al / 255, s[2] * al / 255, s[3] * al / 255, 255))
	end
end

hook.Add("PostDrawTranslucentRenderables", "a2_seq_effets", function(prof, ciel)
	if prof or ciel or not dedans() then return end
	local t = CurTime()
	dessinerRides(t)
	for _, v in ipairs(etat.vagues) do dessinerPoussiere(v, t) end
	-- lueur propre des pierres + pouls faible de la signature autour (pendant l'assise)
	dessinerMarques()
	for i, p in ipairs(places) do if p.on then dessinerSignature(p, i, t) end end
	render.SetMaterial(MAT_LUEUR)
	for i, p in ipairs(places) do
		if p.on then
			local MAT_TRACE = MAT_POUSS[1]
			for j = 1, 2 do
				local x, y, z, vis, lueur = poser(p, i, j, t)
				if vis then                          -- ombre de contact (s'éloigne et pâlit quand la pierre lévite)
					local bx, by, bz = basePierre(i, j)
					local h = math.max(z - bz, 0)
					render.SetMaterial(MAT_TRACE)
					render.DrawQuadEasy(versMonde(x, y, math.min(z, bz) - 1.9), etat.tete:GetUp(), 9 + h, 9 + h, Color(10, 10, 12, 170 / (1 + 0.4 * h)), 0)
					render.SetMaterial(MAT_LUEUR)
				end
				local glisse = (p.res == "partiel" and j == 2) or p.res == "echec"
				if glisse and vis then              -- traînée sombre de la tablette à la pierre, creux si elle s'enfonce
					local bx, by = basePierre(i, j)
					local n = 6
					for k = 1, n do
						local u = k / n
						local tx, ty = bx + (x - bx) * u, by + (y - by) * u
						local rr = math.sqrt(tx * tx + ty * ty)
						render.SetMaterial(MAT_TRACE)
						render.DrawQuadEasy(versMonde(tx, ty, sol(rr, math.atan2(ty, tx)) + 1.2), etat.tete:GetUp(), 10, 10, Color(22, 20, 19, 180 * u), k * 40)
					end
					if p.res == "echec" then
						render.DrawQuadEasy(versMonde(x, y, sol(math.sqrt(x * x + y * y), math.atan2(y, x)) + 1.3), etat.tete:GetUp(), 16, 16, Color(18, 16, 15, 170), 0)
					end
					render.SetMaterial(MAT_LUEUR)
				end
				if vis then
					local l = 150 * lueur
					render.DrawSprite(versMonde(x, y, z + 1), 16 + 18 * lueur, 16 + 18 * lueur, Color(l, l, l * 1.05, 255))
				end
			end
		end
	end
end)

for _, s in ipairs({ "ambient/wind/wind_hit2.wav", "ambient/atmosphere/hole_hit1.wav" }) do
	if not file.Exists("sound/" .. s, "GAME") then print("[a2_sequence] son absent : " .. s) end
end

-- ---------- fil d'Injerto ----------
-- Un fil blanc pâle monte d'au-dessus d'Adler et se perd dans le noir. Au repos on le devine à peine ; à la 2e vague
-- (et aux suivantes) il se tend, s'éclaire un peu et une perle de lumière y remonte, puis il retombe dans le noir.
-- Il suit le joueur donné par a2_adler (sinon le centre de la dalle). Rien hors de la boîte.
local FIL = { SEG = 28, HAUT = 560, Z_TETE = -48.9 + 82, REPOS = 0.06, CALME = 0.04, PIC = 0.38,
	MONTEE = 0.6, TIENT = 3, BAISSE = 6, V_PERLE = 130, BALANCE = 3, TENDU = 0.8 }
local function ancreFil()
	local a = etat.adler
	if IsValid(a) and a:Alive() and A2_SABLE.dansBoite(etat.tete, a:GetPos()) then
		return a:GetPos() + etat.tete:GetUp() * (a:OBBMaxs().z + 10)
	end
	return versMonde(0, 0, FIL.Z_TETE)
end
local function eveilFil(t)                       -- 0 au repos, 1 au plus fort de la 2e vague (ou d'une suivante)
	local v = etat.vagues[#etat.vagues]
	if not v or v.n < 2 then return 0, nil end
	local k = t - v.t0
	return lisse(k / FIL.MONTEE) * (1 - lisse((k - FIL.TIENT) / FIL.BAISSE)), k
end
hook.Add("PostDrawTranslucentRenderables", "a2_seq_fil", function(prof, ciel)
	if prof or ciel or not dedans() then return end
	local t = CurTime()
	local e, k = eveilFil(t)
	local base = etat.n > 0 and FIL.REPOS or FIL.CALME
	local intens = base + (FIL.PIC - base) * e
	if intens <= 0.002 then return end
	local bas = ancreFil()
	local haut = math.min(FIL.HAUT, S.BZ1 - 30 - (etat.tete:WorldToLocal(bas) + TETE).z)
	local up = etat.tete:GetUp()
	local fx, fy = etat.tete:GetForward(), etat.tete:GetRight()
	local balance = FIL.BALANCE * (1 - (1 - FIL.TENDU / FIL.BALANCE) * e)
	local perle = k and (k * FIL.V_PERLE) or -1000
	local c = S.PIERRE_COUL
	render.SetMaterial(MAT_ADD)
	for passe = 1, 2 do                          -- 1 : halo large et très faible ; 2 : le fil lui-même
		local larg, gain = passe == 1 and 4 or 1.3, passe == 1 and 0.22 or 1
		render.StartBeam(FIL.SEG + 1)
		for i = 0, FIL.SEG do
			local u = i / FIL.SEG
			local z = u * haut
			local ox = math.sin(t * 0.7 + u * 3.1) * balance * u
			local oy = math.sin(t * 0.53 + u * 2.3 + 1.7) * balance * u * 0.7
			local p = bas + up * z + fx * ox + fy * oy
			local fond = (1 - u) ^ 0.8 * lisse(u / 0.06)       -- naît juste au-dessus de la tête, se perd en haut
			local b = intens * fond + 0.9 * e * math.exp(-((z - perle) / 26) ^ 2) * (1 - u)
			local l = 255 * math.min(b * gain, 1)
			render.AddBeam(p, larg * (1 - 0.5 * u), u * 4, Color(l * c[1], l * c[2], l * c[3], 255))
		end
		render.EndBeam()
	end
end)

-- ---------- état reçu du serveur ----------
local RESULTATS = A2_SABLE and A2_SABLE.RESULTATS or { "reussite", "crit", "partiel", "echec", "fiasco" }
net.Receive(A2_SABLE.NET, function()
	local n = net.ReadUInt(8)
	local vagues = {}
	for i = 1, net.ReadUInt(2) do
		local t0, num = net.ReadDouble(), net.ReadUInt(8)
		vagues[i] = { t0 = t0, n = num, force = math.min(1 + 0.25 * (num - 1), 1.75) }
	end
	for i = 1, net.ReadUInt(4) do
		local on, res, t0 = net.ReadBool(), RESULTATS[net.ReadUInt(3)] or "reussite", net.ReadDouble()
		local sig = { net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8) }
		if places[i] then places[i].on, places[i].res, places[i].t0, places[i].sig = on, res, t0, sig end
	end
	etat.adler = net.ReadEntity()
	etat.n, etat.vagues = n, vagues
	-- souffle d'Adler : une seule fois par vague, et seulement si elle vient de partir (pas pour qui arrive en retard)
	local v = vagues[#vagues]
	if v and v.n ~= etat.entendu and CurTime() - v.t0 < 1.5 and majTete() then jouerSouffle(v.force) end
	etat.entendu = v and v.n or 0
end)
hook.Add("InitPostEntity", "a2_seq_pret", function()     -- chargement fini : demander l'état en cours
	net.Start(A2_SABLE.NET_PRET) net.SendToServer()
end)

print("[a2_sequence] chargée (livraison)")
