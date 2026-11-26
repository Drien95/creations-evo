-- Lac noir de Nobleza : la scène jouée séquence par séquence, comme un scénario (25/11/2026).
-- lac_noir_suite : séquence suivante (la première au départ). lac_noir_precedente : séquence précédente.
-- lac_noir_sequence N : saute à la séquence N.
-- lac_noir_arreter : coupe la scène pour tous. Réservé à qui est listé dans sh_config.lua (et aux admins), et à la console du serveur.
-- Chaque séquence joue puis tient sa dernière image jusqu'à la suivante. Un joueur qui arrive reprend au bon instant.
util.AddNetworkString(LAC_NOIR.NET)

local SEQ = LAC_NOIR.SEQ
local k, depart = 0, 0

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
  if cible then net.Send(cible) else net.Broadcast() end
end

local function aller(ply, n)
  if not autorise(ply) then return end
  if n < 1 or n > #SEQ then dire(ply, "[Lac noir] séquence " .. n .. " inconnue (1 à " .. #SEQ .. ")") return end
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

function LAC_NOIR.arreter() k, depart = 0, 0; envoyer() end
LAC_NOIR.autorise, LAC_NOIR.dire = autorise, dire        -- pour sv_effacer.lua

concommand.Add("lac_noir_arreter", function(ply)
  if not autorise(ply) then return end
  LAC_NOIR.arreter()
  dire(ply, "[Lac noir] scène arrêtée pour tous")
end)

-- Arrivée en cours de scène : on envoie la séquence en cours après le chargement du joueur.
hook.Add("PlayerInitialSpawn", "lac_noir_lancement", function(ply)
  if k == 0 then return end
  timer.Simple(5, function() if IsValid(ply) and k > 0 then envoyer(ply) end end)
end)
