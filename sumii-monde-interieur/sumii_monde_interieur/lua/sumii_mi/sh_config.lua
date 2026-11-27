-- Réglages de la scène. Aucune coordonnée de map : tout est relatif au repère (plaque centrale du dupe).
return {
	MJ = {},                       -- SteamID autorisés en plus des admins, ex. ["STEAM_0:0:1"] = true
	CONVAR_ACCES = "sumii_mi_acces",   -- 0 : admins et liste MJ ; 1 : tout le monde (banc solo)
	BX = 2400, BZ0 = -200, BZ1 = 1400,
	SOLEIL_AZ = 208, SOLEIL_EL = 6,   -- le soleil couchant de P1 (mêmes valeurs que sa source)
	-- reconnaissance du build à la disposition de ses props (jamais à une couleur)
	REPERE = {
		modele = "models/hunter/plates/plate32x32.mdl", pos = { 0, 0, -1.5 },
		pas = 1518.4, min_voisines = 3,   -- au moins 3 plaques sur les 4 en croix
		tolerance = 8,
		temoins = { modele = "models/propper/rp_seireitei_v1/watcher_skr_treesakura_1.mdl", minimum = 2,   -- au moins 2 cerisiers sur 3 à leur place
			places = { { -585, -749, 30 }, { -788, 616, 30 }, { -1060, -1060, 30 } } },
	},
	RELAIS = 0.5,                  -- secondes entre deux envois de rattrapage
	SONS = {                      -- sons du jeu de base (Half-Life 2) ; jamais de musique
		VENT = "ambient/wind/wind1.wav",
		SOUFFLE_PEUR = "ambient/creatures/town_scared_breathing1.wav",   -- chez la cible seule
		SOUFFLE_GRAVE = "npc/ichthyosaur/water_breath.wav",
		GRONDEMENT = "npc/antlion_guard/growl_idle.wav",
		COUP_GROTTE = "ambient/atmosphere/cave_hit2.wav",
		COUP_SOURD = "physics/body/body_medium_impact_soft3.wav",
		BOUCHEE = "physics/body/body_medium_impact_soft%d.wav",   -- 1 à 7
		RAFALE = "ambient/wind/windgust.wav",
		COEUR = "player/heartbeat1.wav",
		RAFALE_FORTE = "ambient/wind/windgust_strong.wav",
		EBOULIS = "ambient/levels/streetwar/building_rubble%d.wav",   -- 1 à 5
		GRONDEMENT_FINAL = "ambient/atmosphere/terrain_rumble1.wav",
		PLAINTE = "ambient/wind/wind_moan1.wav",
		RACLEMENT = "physics/concrete/rock_scrape_rough_loop1.wav",   -- en boucle : toujours arrêté par le script
		OISEAUX = { "ambient/levels/forest/dist_birds1.wav", "ambient/levels/forest/dist_birds2.wav",
			"ambient/levels/forest/dist_birds3.wav", "ambient/levels/forest/dist_birds4.wav",
			"ambient/levels/forest/dist_birds5.wav", "ambient/levels/forest/dist_birds6.wav" },
		TERRE = { "player/footsteps/dirt1.wav", "player/footsteps/dirt2.wav",
			"player/footsteps/dirt3.wav", "player/footsteps/dirt4.wav" },
	},
	ARRIVEE = { 0, 0, 20 }, SORTIE = { 2600, 0, 20 },
}
