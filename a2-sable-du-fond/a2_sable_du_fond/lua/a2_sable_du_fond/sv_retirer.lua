-- A2 « Le Sable du Fond » : a2_tout_effacer (alias a2_retirer), tapée deux fois en 10 s.
-- Efface TOUT : les props du build repéré (les 79 du dupe, gravure comprise), l'état du serveur, son relais et son hook,
-- et chez tous les joueurs les effets, modèles, maillages, brouillard, éclairage de nuit et hooks de dessin.
-- Seuls les props à LEUR place dans le dupe (modèle + position relative à la tête, sv_plan.lua) sont retirés :
-- jamais ceux d'un autre build, même posé dans la boîte. Avec un prop protect (CPPI) : les props du joueur qui
-- efface, ou n'importe lesquels pour un admin. Après : l'addon dort ; recoller le build puis taper une commande a2_*
-- (a2_etat suffit) le réveille.
local C = A2_SABLE
local PLAN = include("a2_sable_du_fond/sv_plan.lua")
local TOL = 4                                    -- écart toléré entre le prop et sa place dans le dupe (u)
local MARQUE = "models/hunter/plates/plate025x025.mdl"
local demande = setmetatable({}, { __mode = "k" })  -- confirmation par joueur (10 s) ; la console confirme aussi en 2 fois

local function proprioOk(e, ply)
  if not e.CPPIGetOwner or not IsValid(ply) then return true end   -- pas de prop protect, ou console du serveur
  return e:CPPIGetOwner() == ply or ply:IsAdmin()
end

-- les props du dupe à leur place autour de cette tête ; borné par la taille du plan
local function propsDuBuild(tete)
  local l, pris, tol2 = {}, {}, TOL * TOL
  for _, p in ipairs(PLAN) do
    local pos = tete:LocalToWorld(p.pos)
    for _, e in ipairs(ents.FindInSphere(pos, TOL + 8)) do
      if not pris[e] and C.reel(e) and e:GetClass() == "prop_physics"
        and string.lower(e:GetModel() or "") == p.modele and e:GetPos():DistToSqr(pos) <= tol2 then
        pris[e] = true; l[#l + 1] = e
        break
      end
    end
  end
  return l
end

local function toutEffacer(ply)
  local tete = C.teteProche()
  local l = IsValid(tete) and propsDuBuild(tete) or {}
  local n, marques, gardes = 0, 0, 0
  for _, e in ipairs(l) do
    if proprioOk(e, ply) then
      if string.lower(e:GetModel() or "") == MARQUE then marques = marques + 1 end
      e:Remove(); n = n + 1
    else
      gardes = gardes + 1
    end
  end
  C.endormir()                                   -- état, ancre, relais et hook du serveur
  net.Start(C.NET_TOUT)                          -- tous les joueurs, dans la boîte ou non
  net.Broadcast()
  return IsValid(tete), n, marques, gardes
end

local function commande(ply)
  if not C.autorise(ply) then return end
  local cle = IsValid(ply) and ply or game.GetWorld()
  local d = demande[cle]
  if not (d and d > CurTime()) then
    demande[cle] = CurTime() + 10
    C.dire(ply, "[A2] a2_tout_effacer : retape-la dans les 10 s pour confirmer. Le build et toute la scène seront effacés pour tout le monde.")
    return
  end
  demande[cle] = nil
  local trouve, n, marques, gardes = toutEffacer(ply)
  if not trouve then
    C.dire(ply, "[A2] aucun build repéré : aucun prop retiré ; scène éteinte et vidée chez tous")
    return
  end
  C.dire(ply, string.format("[A2] tout effacé : %d/%d props du build retirés (dont %d/%d marques de gravure)%s ; scène éteinte et vidée chez tous. Recoller le build puis taper a2_etat la rallume.",
    n, #PLAN, marques, #C.GRAVURE, gardes > 0 and (", " .. gardes .. " gardés (prop protect)") or ""))
end
concommand.Add("a2_tout_effacer", commande)
concommand.Add("a2_retirer", commande)           -- ancien nom, même effet
