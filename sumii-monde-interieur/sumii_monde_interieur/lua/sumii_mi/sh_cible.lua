-- Choix d'un joueur (pur). joueurs : liste de { nom, sid, dedans, mj }. Rend le joueur, ou nil et le motif.
local K = {}

function K.parTexte(joueurs, texte)
	texte = string.lower(texte or "")
	if texte == "" then return nil, "donne un bout de nom ou un SteamID" end
	local trouves = {}
	for _, j in ipairs(joueurs) do
		if string.lower(j.sid) == texte then return j end
		if string.find(string.lower(j.nom), texte, 1, true) then trouves[#trouves + 1] = j end
	end
	if #trouves == 1 then return trouves[1] end
	if #trouves == 0 then return nil, "aucun joueur ne correspond" end
	return nil, "plusieurs joueurs correspondent, précise le nom"
end

-- sans cible fixée : le seul joueur de la boîte qui n'est ni MJ ni l'Arrancar. Jamais de choix au hasard.
function K.defaut(joueurs, arrancar)
	local restants = {}
	for _, j in ipairs(joueurs) do
		if j.dedans and not j.mj and j ~= arrancar then restants[#restants + 1] = j end
	end
	if #restants == 1 then return restants[1] end
	if #restants == 0 then return nil, "aucun joueur dans la boîte : utilise sumii_cible" end
	return nil, "plusieurs joueurs dans la boîte : utilise sumii_cible"
end

return K
