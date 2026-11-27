-- Repère du dupe en jeu (même règle serveur et client) et boîte relative. Cherché au plus une fois par seconde.
local C, R = SumiiMI.config, SumiiMI.repere
local A = {}
local tete, prochaine = nil, 0
local TETE = Vector(C.REPERE.pos[1], C.REPERE.pos[2], C.REPERE.pos[3])

local function situe(a, b, dx, dy, dz, tolerance)
	local p = a.e:WorldToLocal(b.e:GetPos())
	return math.abs(p.x - dx) < tolerance and math.abs(p.y - dy) < tolerance and math.abs(p.z - dz) < tolerance
end

local function chercher()
	local props = {}
	for _, e in ipairs(ents.FindByClass("prop_physics")) do
		local modele = string.lower(e:GetModel() or "")
		-- seuls les deux modèles du motif comptent : la recherche reste courte même sur une carte chargée
		if modele == C.REPERE.modele or modele == C.REPERE.temoins.modele then props[#props + 1] = { e = e, modele = modele } end
	end
	local trouve = R.choisir(C.REPERE, props, situe)
	return trouve and trouve.e
end

-- secours : la plaque que le MJ a désignée avec sumii_ancre, partagée à tous par le serveur
function A.designee()
	local e = GetGlobalEntity("sumii_mi_ancre")
	if IsValid(e) then return e end
end
function A.tete()
	local forcee = A.designee()
	if forcee then
		tete = forcee
		return forcee
	end
	if IsValid(tete) then return tete end
	if CurTime() < prochaine then return nil end
	prochaine = CurTime() + 1
	tete = chercher()
	return tete
end
function A.oublier() tete, prochaine = nil, 0 end
function A.versMonde(p) return tete:LocalToWorld(p - TETE) end
function A.versBuild(p) return tete:WorldToLocal(p) + TETE end
function A.dedans(pos)
	if not A.tete() then return false end
	local p = A.versBuild(pos)
	return p.x * p.x + p.y * p.y <= C.BX * C.BX and p.z >= C.BZ0 and p.z <= C.BZ1
end

SumiiAncre = A
