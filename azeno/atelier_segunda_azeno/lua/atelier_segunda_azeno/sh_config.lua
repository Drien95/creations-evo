-- Atelier : config de la scène « atelier_segunda_azeno » (partagée serveur et clients).
-- Qui peut lancer la scène (+ et -, atelier_etape, atelier_seq_stop, atelier_wipe) : les admins du serveur si admins = true,
-- et les joueurs listés par SteamID (format STEAM_0:x:y ou SteamID64). Les autres joueurs voient et entendent seulement.
ATELIER_SCENES = ATELIER_SCENES or {}
ATELIER_SCENES["atelier_segunda_azeno"] = {
  admins = true,
  steamid = {
    ["STEAM_0:1:105073580"] = true,
    ["76561198170412889"] = true,
  },
}
