-- Reconnaître le build à la DISPOSITION de ses props (calcul pur), jamais à une couleur ni à « le seul prop de ce
-- modèle » : la plaque centrale, ses voisines en croix et des arbres témoins, mesurés dans son propre repère
-- (le build marche donc tourné et collé n'importe où).
local R = {}

local function existe(props, tete, modele, situe, dx, dy, dz, tolerance)
	for _, p in ipairs(props) do
		if p ~= tete and p.modele == modele and situe(tete, p, dx, dy, dz, tolerance) then return true end
	end
	return false
end

local function voisines(motif, props, tete, situe)
	local n = 0
	for _, d in ipairs({ { motif.pas, 0 }, { -motif.pas, 0 }, { 0, motif.pas }, { 0, -motif.pas } }) do
		if existe(props, tete, motif.modele, situe, d[1], d[2], 0, motif.tolerance) then n = n + 1 end
	end
	return n
end

local function temoins(motif, props, tete, situe)
	local n = 0
	for _, place in ipairs(motif.temoins.places) do
		-- places données dans le repère du dupe : on les ramène par rapport à la plaque centrale
		if existe(props, tete, motif.temoins.modele, situe, place[1] - motif.pos[1], place[2] - motif.pos[2],
			place[3] - motif.pos[3], motif.tolerance) then n = n + 1 end
	end
	return n
end

-- props : liste de { modele, ... } ; situe(a, b, dx, dy, dz, tolerance) dit si b est à ce décalage dans le repère de a
function R.choisir(motif, props, situe)
	for _, p in ipairs(props) do
		if p.modele == motif.modele and voisines(motif, props, p, situe) >= motif.min_voisines
			and temoins(motif, props, p, situe) >= motif.temoins.minimum then
			return p
		end
	end
	return nil
end

return R
