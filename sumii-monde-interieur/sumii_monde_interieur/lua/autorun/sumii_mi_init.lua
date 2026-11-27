-- Monde intérieur de Sumii : chargement. L'ordre des fichiers compte (P2 crée la table de l'herbe lue par P1).
SumiiMI = {}
local DOSSIER = "sumii_mi/"
local PARTAGES = { config = "sh_config", sequence = "sh_sequence", cible = "sh_cible", repere = "sh_repere",
	reseau = "sh_reseau", terriers = "sh_terriers", ciel = "sh_ciel", monde = "sh_monde",
	apparition = "sh_apparition", souvenirs = "sh_souvenirs",
	arrancar = "sh_arrancar", plaquage = "sh_plaquage",
	perte = "sh_perte", effondrement = "sh_effondrement" }
local CLIENT_ORDRE = { "cl_noyau", "cl_p2", "cl_p3", "cl_p1", "cl_p4", "cl_etat", "cl_cylindre", "cl_temps", "cl_apparition", "cl_souvenirs",
	"cl_arrancar", "cl_ecran",
	"cl_plaquage", "cl_pov", "cl_perte",
	"cl_effondrement" }

for champ, nom in pairs(PARTAGES) do                        -- aucun de ces modules ne dépend d'un autre au chargement
	local chemin = DOSSIER .. nom .. ".lua"
	if SERVER then AddCSLuaFile(chemin) end
	SumiiMI[champ] = include(chemin)
end
if SERVER then AddCSLuaFile(DOSSIER .. "sh_ancre.lua") end
include(DOSSIER .. "sh_ancre.lua")

if SERVER then
	for _, nom in ipairs(CLIENT_ORDRE) do AddCSLuaFile(DOSSIER .. nom .. ".lua") end
	include(DOSSIER .. "sv_scene.lua")
else
	for _, nom in ipairs(CLIENT_ORDRE) do include(DOSSIER .. nom .. ".lua") end
end
