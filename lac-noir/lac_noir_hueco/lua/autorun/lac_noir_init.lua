-- Lac noir de Nobleza : chargeur de l'addon (sv, sh, cl). Ne charge rien hors des maps dont le nom contient « hueco ».
if not string.find(game.GetMap(), "hueco", 1, true) then return end
if SERVER then
  AddCSLuaFile("lac_noir/sh_config.lua")
  AddCSLuaFile("lac_noir/cl_scene.lua")
  include("lac_noir/sh_config.lua")
  include("lac_noir/sv_lancement.lua")
  include("lac_noir/sv_sons.lua")
else
  include("lac_noir/sh_config.lua")
  include("lac_noir/cl_scene.lua")
end
