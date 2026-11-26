-- Lac noir de Nobleza : la scène jouée séquence par séquence, comme un scénario (25/11/2026).
-- lac_noir_suite : séquence suivante (la première au départ). lac_noir_precedente : séquence précédente.
-- lac_noir_sequence N : saute à la séquence N.
-- lac_noir_arreter : coupe la scène pour tous. Réservé à qui est listé dans sh_config.lua (et aux admins), et à la console du serveur.
-- lac_noir_ancre : en secours, fixe le repère à la main (viser le dossier du trône).
-- Chaque séquence joue puis tient sa dernière image jusqu'à la suivante. Un joueur qui arrive reprend au bon instant.
-- Repère (26/11, v87) : c'est le serveur qui trouve le build (il voit toute la map) et envoie sa position aux joueurs avec
-- la séquence. Sans build trouvé, la scène ne se lance pas et le MJ est prévenu.
util.AddNetworkString(LAC_NOIR.NET)

local SEQ = LAC_NOIR.SEQ
local k, depart, off = 0, 0, nil

-- Le build se reconnaît à son motif : la plaque 8x8 ET les deux moitiés du dossier du trône à leur place exacte autour
-- (20 u près). Une plaque 8x8 d'un autre build n'est jamais prise pour la nôtre. Le dupe doit être collé sans rotation.
local REF, SOL = "models/hunter/plates/plate8x8.mdl", Vector(0, 2600, 1.0)   -- plaque repère et sa place dans le build
local MOITIE = "models/hunter/blocks/cube1x2x025.mdl"
local MOIT = { Vector(-30.521, -2317.987, 327.428), Vector(30.521, -2317.987, 327.428) }
LAC_NOIR.SOL = SOL

local function motif(p, liste)
  for _, v in ipairs(MOIT) do
    local cible, ok = p + v, false
    for _, e in ipairs(liste) do if IsValid(e) and e:GetPos():DistToSqr(cible) < 400 then ok = true break end end
    if not ok then return false end
  end
  return true
end

-- Gravure d'usine (26/11, v88) : 3 marques dédiées noyées dans la dalle du lac, sur la plaque repère, à des écarts, des
-- angles et des couleurs improbables tirés de « Lac noir de Nobleza v1 » (outils/gravure.py de claude-skills).
local G = include("lac_noir/sh_gravure.lua")
local GRAVURE = {
  { modele = "models/hunter/plates/plate025x025.mdl", pos = Vector(-76.9, -38.7, 2.625), lacet = 37.0, couleur = { 123, 31, 233 } },
  { modele = "models/hunter/plates/plate025x025.mdl", pos = Vector(44.5, 68.9, 2.625), lacet = 77.2, couleur = { 22, 152, 231 } },
  { modele = "models/hunter/plates/plate025x025.mdl", pos = Vector(-60.1, -4.2, 2.625), lacet = 64.7, couleur = { 27, 42, 28 } },
}

local function plus_proche(liste, o)             -- liste d'entités repères : la plus proche de o (ou la première)
  local pres, meilleur = nil, math.huge
  for _, e in ipairs(liste) do
    local d = o and e:GetPos():DistToSqr(o) or 0
    if d < meilleur then pres, meilleur = e, d end
  end
  return pres
end

-- Repère du build (position de son origine), dans l'ordre : l'ancre posée à la main, la gravure d'usine (dupe v98 et
-- plus), le motif du trône (dupes plus anciens). Rend aussi le nombre de builds reconnus et la méthode.
function LAC_NOIR.trouver(ply)
  if LAC_NOIR.ancre_pos then return LAC_NOIR.ancre_pos, 1, "ancre" end
  local o = IsValid(ply) and ply:GetPos() or nil
  local graves = {}
  for _, c in ipairs(G.chercher(REF, GRAVURE, #GRAVURE)) do graves[#graves + 1] = c.repere end
  if #graves > 0 then return plus_proche(graves, o):GetPos() - SOL, #graves, "gravure" end
  local pres, meilleur, n = nil, math.huge, 0
  local liste = ents.FindByModel(MOITIE)
  for _, e in ipairs(ents.FindByModel(REF)) do
    if IsValid(e) and motif(e:GetPos(), liste) then
      n = n + 1
      local d = o and e:GetPos():DistToSqr(o) or 0
      if d < meilleur then pres, meilleur = e, d end
    end
  end
  return pres and (pres:GetPos() - SOL) or nil, n, "motif"
end

local function autorise(ply)                     -- joueur invalide = console du serveur
  if not IsValid(ply) then return true end
  local c = LAC_NOIR
  return (c.ADMINS and ply:IsAdmin()) or c.AUTORISES[ply:SteamID()] == true or c.AUTORISES[ply:SteamID64()] == true
end

local function dire(ply, texte)
  if IsValid(ply) then ply:PrintMessage(HUD_PRINTTALK, texte) end
  print(texte)
end

local function envoyer(cible)
  net.Start(LAC_NOIR.NET)
  net.WriteUInt(k, 8)
  net.WriteDouble(depart)
  net.WriteBool(k > 0 and off ~= nil)
  if k > 0 and off then net.WriteVector(off) end
  if cible then net.Send(cible) else net.Broadcast() end
end

local function aller(ply, n)
  if not autorise(ply) then return end
  if n < 1 or n > #SEQ then dire(ply, "[Lac noir] séquence " .. n .. " inconnue (1 à " .. #SEQ .. ")") return end
  local o, nb, comment = LAC_NOIR.trouver(ply)
  if not o then
    dire(ply, "[Lac noir] build introuvable : scène non lancée. Le dupe est-il collé en entier et sans rotation ? "
      .. "En secours : vise le dossier du trône et tape lac_noir_ancre.")
    return
  end
  if k == 0 or not off or o ~= off then
    dire(ply, string.format("[Lac noir] build trouvé (%s) en (%.0f, %.0f, %.0f)%s", comment, o.x, o.y, o.z,
      nb > 1 and (" ; " .. nb .. " builds reconnus, le plus proche de toi est pris") or ""))
  end
  off = o
  k, depart = n, CurTime()
  envoyer()
  dire(ply, string.format("[Lac noir] séquence %d/%d : %s%s", k, #SEQ, SEQ[k],
    SEQ[k + 1] and (" ; ensuite : " .. SEQ[k + 1]) or " ; dernière, elle tient jusqu'à lac_noir_arreter"))
end

concommand.Add("lac_noir_suite", function(ply)
  if k >= #SEQ then if autorise(ply) then dire(ply, "[Lac noir] déjà à la dernière séquence") end return end
  aller(ply, k + 1)
end)

concommand.Add("lac_noir_precedente", function(ply)
  if k <= 1 then if autorise(ply) then dire(ply, "[Lac noir] déjà à la première séquence") end return end
  aller(ply, k - 1)
end)

concommand.Add("lac_noir_sequence", function(ply, _, args)
  aller(ply, math.floor(tonumber(args[1] or "") or 0))
end)

concommand.Add("lac_noir_ancre", function(ply)  -- secours : le dossier du trône visé fixe le repère
  if not autorise(ply) or not IsValid(ply) then return end
  local e = ply:GetEyeTrace().Entity
  local m = IsValid(e) and string.lower(e:GetModel() or "") or ""
  local o
  if m == REF then
    o = e:GetPos() - SOL
  elseif m == MOITIE then                          -- une des deux moitiés : celle dont la sœur est à sa place
    local liste = ents.FindByModel(MOITIE)
    for _, v in ipairs(MOIT) do
      local essai = e:GetPos() - v                 -- position de la plaque si e est cette moitié-là
      if motif(essai, liste) then o = essai - SOL break end
    end
  end
  if not o then
    dire(ply, "[Lac noir] vise le dossier du trône (une des deux moitiés noires), puis retape lac_noir_ancre")
    return
  end
  LAC_NOIR.ancre_pos = o
  dire(ply, string.format("[Lac noir] ancre posée : build en (%.0f, %.0f, %.0f)", o.x, o.y, o.z))
end)

function LAC_NOIR.arreter() k, depart, off = 0, 0, nil; envoyer() end
LAC_NOIR.autorise, LAC_NOIR.dire = autorise, dire        -- pour sv_effacer.lua

concommand.Add("lac_noir_arreter", function(ply)
  if not autorise(ply) then return end
  LAC_NOIR.arreter()
  dire(ply, "[Lac noir] scène arrêtée pour tous")
end)

-- Arrivée en cours de scène : on envoie la séquence en cours (et le repère) après le chargement du joueur.
hook.Add("PlayerInitialSpawn", "lac_noir_lancement", function(ply)
  if k == 0 then return end
  timer.Simple(5, function() if IsValid(ply) and k > 0 then envoyer(ply) end end)
end)
