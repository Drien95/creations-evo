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
-- Repère du dupe : le prop de tête (modèle) et sa place dans le build, reconnu par le motif de sh_ancre.lua. Aucune coordonnée de la map.
C.MODELE_TETE = "models/hunter/plates/plate5x5.mdl"
-- Gravure d'usine « A2 v15 » (claude-skills, outils/gravure.py) : 3 marques invisibles posées sur la tête, relatives à elle.
C.GRAVURE = {
  { modele = "models/hunter/plates/plate025x025.mdl", pos = Vector(56.1, -37.1, 3.5), lacet = 56.1, couleur = { 158, 94, 236 } },
  { modele = "models/hunter/plates/plate025x025.mdl", pos = Vector(-41.8, -17.7, 3.5), lacet = 64.7, couleur = { 169, 26, 21 } },
  { modele = "models/hunter/plates/plate025x025.mdl", pos = Vector(4.1, -79.3, 3.5), lacet = 12.0, couleur = { 147, 41, 17 } },
}
C.GRAVURE_MIN = 2                                -- marques à retrouver pour reconnaître le build (sinon : motif en secours)
C.TETE = Vector(-226, -226, -61.5)
-- Boîte de la scène, relative au build (centre de la dalle en 0, 0) : mêmes valeurs que les scripts client.
C.BX, C.BZ0, C.BZ1 = 1800, -200, 700
C.NB_PLACES = 4
C.RESULTATS = { "reussite", "crit", "partiel", "echec", "fiasco" }   -- l'ordre sert au message réseau
C.SIGS = { { 240, 125, 50 }, { 175, 95, 235 }, { 60, 215, 135 }, { 235, 70, 110 } }   -- signatures par défaut

-- Maps en plus, pour un serveur de test : un mot par ligne dans garrysmod/data/a2_sable_du_fond_cartes.txt (serveur).
C.FICHIER_CARTES = "a2_sable_du_fond_cartes.txt"
function C.carteOk()
  if CLIENT then                                 -- le client suit le serveur : il a reçu le script client ou non
    return file.Exists("a2_sable_du_fond/cl_sequence.lua", "LUA")
  end
  local mots = table.Copy(C.CARTES)
  for ligne in string.gmatch(file.Read(C.FICHIER_CARTES, "DATA") or "", "[^\r\n]+") do
    local m = string.Trim(string.lower(ligne))
    if m ~= "" and #mots < 32 then mots[#mots + 1] = m end
  end
  local carte = string.lower(game.GetMap())
  for _, mot in ipairs(mots) do if string.find(carte, mot, 1, true) then return true end end
  print("[A2] addon non chargé : la map " .. carte .. " n'est pas dans CARTES ni dans data/" .. C.FICHIER_CARTES)
  return false
end

-- point (monde) dans la boîte de la scène posée autour de ce prop de tête ?
function C.dansBoite(tete, pos)
  local p = tete:WorldToLocal(pos) + C.TETE
  return math.abs(p.x) <= C.BX and math.abs(p.y) <= C.BX and p.z >= C.BZ0 and p.z <= C.BZ1
end
