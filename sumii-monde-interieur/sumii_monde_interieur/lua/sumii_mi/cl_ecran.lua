-- Effets « écran » : ce que la cible (Sumii) perçoit seule, le flash blanc de tous, et l'aperçu du MJ.
-- Chargé après cl_souvenirs. Ajouter un effet = ajouter une entrée à APERCUS.
local C, M, V, R = SumiiMI.config, SumiiMI.monde, SumiiMI.souvenirs, SumiiMI.arrancar
local K, SC = SumiiNoyau, SumiiScene

local DSP_ACOUPHENE = 35                         -- [à prouver au banc] effet sonore du moteur
local apercu = nil                               -- { cle, t0 } : rejoué chez le MJ seul, sans appel au serveur

local function enApercu(cle) return apercu ~= nil and apercu.cle == cle end
local function estCible() return LocalPlayer():EntIndex() == SC.cible end

local function souffleDePeur() SC.jouerBorne("peur", nil, C.SONS.SOUFFLE_PEUR, 0.8, 100, 6) end
local function battement() SC.jouerBorne("coeur", nil, C.SONS.COEUR, 0.9, 100, 0.9) end
-- cœur en aperçu : le vrai calendrier, rejoué sur un temps fictif
local function coeurApercu(cle, place, avant, maintenant)
	return R.battementEchu({ i = place, inst = { [cle] = apercu.t0 } }, avant, maintenant)
end
-- ce que sumii_apercu sait jouer
local APERCUS = {
	regard = { duree = 8, coeur = R.REGARD },
	course = { duree = R.DUREE_COURSE, coeur = R.COURSE },
	detresse = { duree = 6, entree = souffleDePeur },
	souvenirs = { duree = 8 },                   -- l'acouphène, en continu (voir le Think)
	flash3 = { duree = 1.2 },                    -- le blanc (voir voileEcran)
	plaquage = { duree = 6 },                    -- vue et écran : cl_plaquage
	perte = { duree = 12 },                      -- le vertige : cl_perte
}

-- appelé par P1 après son étalonnage, pour les joueurs dans la boîte
local function blancPlein(maintenant)
	local blanc = V.blanc(SC.S, maintenant)
	if enApercu("flash3") then blanc = math.max(blanc, V.blanc({ inst = { flash3 = apercu.t0 } }, maintenant)) end
	return blanc
end
function SC.voileEcran()
	if SC.povEnCours then return end             -- la petite fenêtre du MJ peint elle-même les effets de Sumii
	local blanc = math.max(blancPlein(CurTime()), SC.voileDeLaBoite and SC.voileDeLaBoite() or 0)
	local plaquee = SC.plaquageIci and SC.plaquageIci()
	if blanc <= 0 and not plaquee then return end
	cam.Start2D()
	if plaquee then SC.dessinerPlaquage(plaquee, ScrW(), ScrH()) end
	if blanc > 0 then
		surface.SetDrawColor(255, 255, 255, 255 * blanc)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end
	cam.End2D()
end
function SC.apercuDe(cle) return enApercu(cle) and apercu.t0 or nil end

local avant, dsp = nil, false
local function reglerAcouphene(voulu)
	if voulu == dsp then return end
	dsp = voulu
	LocalPlayer():SetDSP(voulu and DSP_ACOUPHENE or 0, false)
end
K.hook("Think", "sumii_mi_ecran", function()
	local maintenant = CurTime()
	local t0 = SC.S.inst.detresse
	if avant and t0 and estCible() and M.echu(t0, 0, avant, maintenant) then souffleDePeur() end
	if apercu and maintenant - apercu.t0 > APERCUS[apercu.cle].duree then apercu = nil end
	if avant then
		local place = apercu and APERCUS[apercu.cle].coeur
		if (estCible() and R.battementEchu(SC.S, avant, maintenant)) or (place and coeurApercu(apercu.cle, place, avant, maintenant)) then
			battement()
		end
	end
	reglerAcouphene((estCible() and V.acouphene(SC.S, maintenant)) or enApercu("souvenirs"))
	avant = maintenant
end)

concommand.Add("sumii_apercu", function(_, _, args)
	if not SC.mj then print("[sumii] réservé au MJ (tape d'abord sumii_etat)") return end
	local cle = args[1] or ""
	local effet = APERCUS[cle]
	if not effet then
		local noms = table.GetKeys(APERCUS)
		table.sort(noms)
		print("[sumii] usage : sumii_apercu <" .. table.concat(noms, " | ") .. ">")
		return
	end
	apercu = { cle = cle, t0 = CurTime() }
	if effet.entree then effet.entree() end
	print("[sumii] aperçu de « " .. cle .. " » chez toi seul (dans la boîte)")
end)

K.surExtinction(function()
	apercu, avant = nil, nil
	reglerAcouphene(false)
end)
