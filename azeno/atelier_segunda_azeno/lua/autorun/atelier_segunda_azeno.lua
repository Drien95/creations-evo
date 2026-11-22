-- Atelier : chargement de la scène « atelier_segunda_azeno » (serveur et clients)
if SERVER then
  AddCSLuaFile("atelier_segunda_azeno/sh_config.lua")
  AddCSLuaFile("atelier_segunda_azeno/cl_scene.lua")
  include("atelier_segunda_azeno/sh_config.lua")
  include("atelier_segunda_azeno/sv_scene.lua")
else
  include("atelier_segunda_azeno/sh_config.lua")
  include("atelier_segunda_azeno/cl_scene.lua")
end
