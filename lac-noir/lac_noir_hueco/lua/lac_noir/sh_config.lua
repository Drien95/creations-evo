-- Lac noir de Nobleza : données communes au serveur et au client.
LAC_NOIR = LAC_NOIR or {}
-- Qui mène la scène (lac_noir_suite, precedente, sequence, arreter) : les admins du serveur si
-- ADMINS = true, et les SteamID listés (STEAM_0:x:y ou SteamID64). Les autres joueurs voient et entendent seulement.
LAC_NOIR.ADMINS = true
LAC_NOIR.AUTORISES = {
  ["STEAM_0:1:105073580"] = true,                -- Adrien
  ["76561198170412889"] = true,
}
LAC_NOIR.NET = "lac_noir_seq"                    -- message réseau : (UInt8 séquence, Double départ CurTime) ; 0 = arrêt
LAC_NOIR.SEQ = { "Le lac dort", "Cloche 1", "Cloche 2", "Cloche 3", "Cloche 4, éclipse totale", "Le boum, l'éveil",
  "Plein feu", "Le siège, l'extinction", "La flamme bleue" }   -- mêmes séquences que SC.SEQ de cl_scene.lua
