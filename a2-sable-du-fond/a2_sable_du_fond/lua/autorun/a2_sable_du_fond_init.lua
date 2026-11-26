-- A2 « Le Sable du Fond » : chargeur. Rien ne charge sur une map absente de CARTES (sh_config.lua) et de data/a2_sable_du_fond_cartes.txt.
AddCSLuaFile()
AddCSLuaFile("a2_sable_du_fond/sh_config.lua")
include("a2_sable_du_fond/sh_config.lua")
if not A2_SABLE.carteOk() then return end

local CLIENT_FICHIERS = { "cl_fermeture.lua", "cl_sequence.lua", "cl_dunes.lua", "cl_sable.lua" }   -- ordre du banc
AddCSLuaFile("a2_sable_du_fond/sh_gravure.lua")
AddCSLuaFile("a2_sable_du_fond/sh_ancre.lua")
include("a2_sable_du_fond/sh_ancre.lua")
if SERVER then
  for _, f in ipairs(CLIENT_FICHIERS) do AddCSLuaFile("a2_sable_du_fond/" .. f) end
  include("a2_sable_du_fond/sv_scene.lua")
  include("a2_sable_du_fond/sv_retirer.lua")
else
  for _, f in ipairs(CLIENT_FICHIERS) do include("a2_sable_du_fond/" .. f) end
end
