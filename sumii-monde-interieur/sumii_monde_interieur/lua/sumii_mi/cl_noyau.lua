-- Registre des effets côté client : tout hook et tout nettoyage passent par ici, pour que l'effacement total ne laisse rien.
local K = { hooks = {}, nettoyages = {}, actif = true }
local CV_BANC = CreateClientConVar("sumii_mi_banc", "0", true, false, "commandes de banc des pièces", 0, 1)

-- dans la boîte blanche (fin du temps 8), plus rien de la scène ne se dessine : une seule garde pour tous les modules
local DESSINS = { PostDrawOpaqueRenderables = true, PostDrawTranslucentRenderables = true }
local function saufDansLeBlanc(fn)
	return function(...)
		if SumiiScene and SumiiScene.blanc and SumiiScene.blanc() >= 1 then return end
		return fn(...)
	end
end
-- coût de tout le script, additionné par image : chaque hook du registre est chronométré
local mesure = { image = -1, ici = 0, images = 0, total = 0, pic = 0, par = {} }
local function compter(ms, nom)
	mesure.par[nom] = (mesure.par[nom] or 0) + ms
	local image = FrameNumber()
	if image ~= mesure.image then
		if mesure.image >= 0 then
			mesure.images, mesure.total = mesure.images + 1, mesure.total + mesure.ici
			mesure.pic = math.max(mesure.pic, mesure.ici)
		end
		mesure.image, mesure.ici = image, 0
	end
	mesure.ici = mesure.ici + ms
end
local function rendre(debut, nom, ...)
	compter((SysTime() - debut) * 1000, nom)
	return ...
end
local function chronometre(fn, nom)
	return function(...) return rendre(SysTime(), nom, fn(...)) end
end
local function detail()
	local liste = {}
	for nom, ms in pairs(mesure.par) do liste[#liste + 1] = { nom = nom, ms = ms / mesure.images } end
	table.sort(liste, function(a, b) return a.ms > b.ms end)
	local morceaux = {}
	for i = 1, math.min(#liste, 6) do morceaux[i] = string.format("%s %.2f", (string.gsub(liste[i].nom, "^sumii_", "")), liste[i].ms) end
	return table.concat(morceaux, " · ")
end

-- tape-la une fois pour remettre à zéro, joue un temps, puis tape-la pour lire
concommand.Add("sumii_mesure", function()
	if mesure.images == 0 then print("[sumii] mesure : aucune image comptée pour l'instant") return end
	print(string.format("[sumii] mesure : %.2f ms en moyenne, pic %.2f ms, sur %d images (objectif : moyenne sous 1 ms, pic sous 5 ms)",
		mesure.total / mesure.images, mesure.pic, mesure.images))
	print("[sumii] mesure, les plus chers : " .. detail())
	mesure.image, mesure.ici, mesure.images, mesure.total, mesure.pic, mesure.par = -1, 0, 0, 0, 0, {}
end)

function K.hook(ev, nom, fn)
	if DESSINS[ev] then fn = saufDansLeBlanc(fn) end
	fn = chronometre(fn, nom)
	K.hooks[#K.hooks + 1] = { ev = ev, nom = nom, fn = fn }
	if K.actif then hook.Add(ev, nom, fn) end
end
function K.surExtinction(fn) K.nettoyages[#K.nettoyages + 1] = fn end
-- anciennes commandes de banc des pièces : absentes chez les joueurs (convar à 1 avant le chargement pour les avoir)
function K.banc(nom, fn)
	if CV_BANC:GetBool() then concommand.Add(nom, fn) end
end

function K.eteindreTout()
	if not K.actif then return end
	K.actif = false
	for _, h in ipairs(K.hooks) do hook.Remove(h.ev, h.nom) end
	for _, fn in ipairs(K.nettoyages) do
		local bon, motif = pcall(fn)                          -- un nettoyage en erreur ne doit pas bloquer les autres
		if not bon then print("[sumii] nettoyage en erreur : " .. tostring(motif)) end
	end
end
function K.rallumer()
	if K.actif then return end
	K.actif = true
	for _, h in ipairs(K.hooks) do hook.Add(h.ev, h.nom, h.fn) end
end

function K.hooksActifs()
	local table_, n = hook.GetTable(), 0
	for _, h in ipairs(K.hooks) do
		if table_[h.ev] and table_[h.ev][h.nom] then n = n + 1 end
	end
	return n, #K.hooks
end

SumiiNoyau = K
