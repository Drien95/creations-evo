-- A2 « Le Sable du Fond » : données communes au serveur et au client.
A2_SABLE = A2_SABLE or {}
local C = A2_SABLE
-- Qui mène la scène (commandes a2_*) : les admins du serveur si ADMINS = true, et les SteamID listés
-- (STEAM_0:x:y ou SteamID64). Les autres joueurs voient et entendent seulement.
C.ADMINS = true
C.AUTORISES = {
  ["STEAM_0:1:105073580"] = true,                -- Adrien
  ["76561198170412889"] = true,
}
-- L'addon ne charge rien sur une map dont le nom ne contient aucun de ces mots.
C.CARTES = { "hueco" }
C.NET = "a2_sable_etat"                          -- serveur -> clients de la boîte : l'état complet de la scène
C.NET_PRET = "a2_sable_pret"                     -- client -> serveur : « j'ai chargé, envoie-moi l'état »
-- Repère du dupe : le prop de tête (modèle et teinte), et sa place dans le build. Aucune coordonnée de la map.
C.MODELE_TETE = "models/hunter/plates/plate5x5.mdl"
C.TEINTE_TETE = { 75, 70, 64 }
C.TETE = Vector(-226, -226, -61.5)
-- Boîte de la scène, relative au build (centre de la dalle en 0, 0) : mêmes valeurs que les scripts client.
C.BX, C.BZ0, C.BZ1 = 1800, -200, 700
C.NB_PLACES = 4
C.RESULTATS = { "reussite", "crit", "partiel", "echec", "fiasco" }   -- l'ordre sert au message réseau
C.SIGS = { { 240, 125, 50 }, { 175, 95, 235 }, { 60, 215, 135 }, { 235, 70, 110 } }   -- signatures par défaut

function C.carteOk()
  local carte = string.lower(game.GetMap())
  for _, mot in ipairs(C.CARTES) do if string.find(carte, mot, 1, true) then return true end end
  return false
end

-- point (monde) dans la boîte de la scène posée autour de ce prop de tête ?
function C.dansBoite(tete, pos)
  local p = tete:WorldToLocal(pos) + C.TETE
  return math.abs(p.x) <= C.BX and math.abs(p.y) <= C.BX and p.z >= C.BZ0 and p.z <= C.BZ1
end

function C.estTete(e)
  local c = IsValid(e) and e:GetColor()
  if not c then return false end
  local t = C.TEINTE_TETE
  return math.abs(c.r - t[1]) <= 1 and math.abs(c.g - t[2]) <= 1 and math.abs(c.b - t[3]) <= 1
end
