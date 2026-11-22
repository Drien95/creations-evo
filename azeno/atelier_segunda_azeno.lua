-- Atelier : film de « Segunda d'Azeno v14 », généré le 20/11/2026 18:01 (66 plans, 27.5 s).
-- Pour GMod en solo (ou un serveur avec sv_allowcslua 1). Pas pour EVO : le Lua client y est bloqué.
-- 1. Copie ce fichier dans garrysmod/lua/ et colle le dupe.
-- 2. Console : lua_openscript_cl atelier_segunda_azeno.lua
-- 3. Vise le prop de tête (sol) et tape : atelier_film_origine
-- 4. atelier_film_jouer pour lancer, atelier_film_stop pour arrêter. Le HUD est masqué pendant le film.
local PLANS = {
  {nom = "Le néant", pos = Vector(-520.00, 1500.00, 72.00), cible = Vector(0.00, 0.00, 120.00), fov = 74, duree = 2.56, glisse = true, doux = true, etape = 1},
  {nom = "Le néant ·", pos = Vector(-170.00, 520.00, 62.00), cible = Vector(0.00, 0.00, 130.00), fov = 78, duree = 0.04, glisse = false, doux = true, etape = 1},
  {nom = "Les voix", pos = Vector(-41.60, -195.60, 58.00), cible = Vector(158.00, 743.40, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-70.70, -187.10, 58.00), cible = Vector(268.60, 710.90, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-98.20, -174.20, 58.00), cible = Vector(373.10, 662.10, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-123.40, -157.40, 58.00), cible = Vector(468.90, 598.10, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-145.80, -136.90, 58.00), cible = Vector(554.00, 520.30, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-164.80, -113.30, 58.00), cible = Vector(626.30, 430.50, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-180.10, -87.00, 58.00), cible = Vector(684.20, 330.80, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-191.20, -58.80, 58.00), cible = Vector(726.40, 223.50, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-197.90, -29.20, 58.00), cible = Vector(751.80, 111.00, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-200.00, 1.00, 58.00), cible = Vector(760.00, -4.00, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-197.50, 31.30, 58.00), cible = Vector(750.60, -118.90, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-190.50, 60.80, 58.00), cible = Vector(724.00, -231.10, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-179.10, 88.90, 58.00), cible = Vector(680.70, -337.90, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-163.60, 115.00, 58.00), cible = Vector(621.80, -437.00, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-144.40, 138.40, 58.00), cible = Vector(548.50, -526.00, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-121.80, 158.70, 58.00), cible = Vector(462.70, -602.90, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-96.40, 175.30, 58.00), cible = Vector(366.10, -666.00, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-68.70, 187.80, 58.00), cible = Vector(261.20, -713.70, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-39.50, 196.10, 58.00), cible = Vector(150.20, -745.00, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(-9.40, 199.80, 58.00), cible = Vector(35.80, -759.20, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(20.90, 198.90, 58.00), cible = Vector(-79.40, -755.80, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(50.80, 193.50, 58.00), cible = Vector(-192.90, -735.10, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(79.40, 183.60, 58.00), cible = Vector(-301.80, -697.50, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(106.30, 169.40, 58.00), cible = Vector(-403.90, -643.80, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(130.70, 151.40, 58.00), cible = Vector(-496.60, -575.30, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(152.10, 129.90, 58.00), cible = Vector(-577.90, -493.60, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(170.00, 105.40, 58.00), cible = Vector(-645.90, -400.50, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(184.00, 78.50, 58.00), cible = Vector(-699.10, -298.20, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(193.70, 49.70, 58.00), cible = Vector(-736.10, -189.00, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(199.00, 19.90, 58.00), cible = Vector(-756.20, -75.50, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(199.70, -10.50, 58.00), cible = Vector(-759.00, 39.80, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(195.80, -40.60, 58.00), cible = Vector(-744.20, 154.10, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(187.50, -69.70, 58.00), cible = Vector(-712.30, 264.90, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(174.80, -97.30, 58.00), cible = Vector(-664.10, 369.60, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(158.00, -122.60, 58.00), cible = Vector(-600.50, 465.80, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(137.70, -145.10, 58.00), cible = Vector(-523.10, 551.30, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(114.10, -164.20, 58.00), cible = Vector(-433.70, 624.10, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(88.00, -179.60, 58.00), cible = Vector(-334.40, 682.50, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(59.80, -190.80, 58.00), cible = Vector(-227.30, 725.20, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "Les voix ·", pos = Vector(30.30, -197.70, 58.00), cible = Vector(-115.00, 751.30, 170.00), fov = 86, duree = 0.145, glisse = true, doux = false, etape = 2},
  {nom = "El Que Queda", pos = Vector(0.00, -200.00, 58.00), cible = Vector(0.00, 760.00, 170.00), fov = 86, duree = 1.86, glisse = true, doux = true, etape = 2},
  {nom = "El Que Queda ·", pos = Vector(0.00, 80.00, 52.00), cible = Vector(0.00, 760.00, 200.00), fov = 80, duree = 0.04, glisse = false, doux = true, etape = 2},
  {nom = "L’œil rouge", pos = Vector(-488.60, -177.90, 55.00), cible = Vector(-768.20, 135.40, 230.00), fov = 75, duree = 0.512, glisse = true, doux = false, etape = 3},
  {nom = "L’œil rouge ·", pos = Vector(-466.40, -230.00, 55.00), cible = Vector(-778.30, 51.00, 230.00), fov = 75, duree = 0.513, glisse = true, doux = false, etape = 3},
  {nom = "L’œil rouge ·", pos = Vector(-438.60, -279.40, 55.00), cible = Vector(-779.30, -34.00, 230.00), fov = 75, duree = 0.512, glisse = true, doux = false, etape = 3},
  {nom = "L’œil rouge ·", pos = Vector(-405.50, -325.50, 55.00), cible = Vector(-770.90, -118.70, 230.00), fov = 75, duree = 0.513, glisse = true, doux = false, etape = 3},
  {nom = "L’œil rouge ·", pos = Vector(-367.70, -367.70, 55.00), cible = Vector(-753.40, -201.90, 230.00), fov = 75, duree = 0.512, glisse = true, doux = false, etape = 3},
  {nom = "L’œil rouge ·", pos = Vector(-325.50, -405.50, 55.00), cible = Vector(-727.00, -282.70, 230.00), fov = 75, duree = 0.512, glisse = true, doux = false, etape = 3},
  {nom = "L’œil rouge ·", pos = Vector(-279.40, -438.60, 55.00), cible = Vector(-691.90, -360.20, 230.00), fov = 75, duree = 0.512, glisse = true, doux = false, etape = 3},
  {nom = "L’œil rouge ·", pos = Vector(-230.00, -466.40, 55.00), cible = Vector(-648.50, -433.30, 230.00), fov = 75, duree = 0.513, glisse = true, doux = false, etape = 3},
  {nom = "L’œil rouge ·", pos = Vector(-177.90, -488.60, 55.00), cible = Vector(-597.50, -501.40, 230.00), fov = 75, duree = 0.9, glisse = false, doux = false, etape = 3},
  {nom = "L’œil bleu", pos = Vector(488.60, -177.90, 55.00), cible = Vector(501.40, -597.50, 230.00), fov = 75, duree = 0.537, glisse = true, doux = false, etape = 4},
  {nom = "L’œil bleu ·", pos = Vector(463.80, -235.10, 55.00), cible = Vector(426.20, -653.20, 230.00), fov = 75, duree = 0.537, glisse = true, doux = false, etape = 4},
  {nom = "L’œil bleu ·", pos = Vector(432.40, -288.90, 55.00), cible = Vector(345.00, -699.60, 230.00), fov = 75, duree = 0.538, glisse = true, doux = false, etape = 4},
  {nom = "L’œil bleu ·", pos = Vector(394.70, -338.60, 55.00), cible = Vector(258.80, -735.80, 230.00), fov = 75, duree = 0.538, glisse = true, doux = false, etape = 4},
  {nom = "L’œil bleu ·", pos = Vector(351.30, -383.40, 55.00), cible = Vector(168.80, -761.50, 230.00), fov = 75, duree = 0.537, glisse = true, doux = false, etape = 4},
  {nom = "L’œil bleu ·", pos = Vector(302.90, -422.70, 55.00), cible = Vector(76.50, -776.20, 230.00), fov = 75, duree = 0.538, glisse = true, doux = false, etape = 4},
  {nom = "L’œil bleu ·", pos = Vector(250.10, -455.90, 55.00), cible = Vector(-17.00, -779.80, 230.00), fov = 75, duree = 0.537, glisse = true, doux = false, etape = 4},
  {nom = "L’œil bleu ·", pos = Vector(193.70, -482.60, 55.00), cible = Vector(-110.20, -772.20, 230.00), fov = 75, duree = 0.538, glisse = true, doux = false, etape = 4},
  {nom = "L’œil bleu ·", pos = Vector(134.60, -502.30, 55.00), cible = Vector(-201.90, -753.40, 230.00), fov = 75, duree = 0.5, glisse = false, doux = false, etape = 4},
  {nom = "Les deux regards", pos = Vector(0.00, -560.00, 90.00), cible = Vector(0.00, 60.00, 1500.00), fov = 72, duree = 3.26, glisse = true, doux = true, etape = 5},
  {nom = "Les deux regards ·", pos = Vector(0.00, -420.00, 110.00), cible = Vector(0.00, 60.00, 1650.00), fov = 66, duree = 0.04, glisse = false, doux = true, etape = 5},
  {nom = "Le recul", pos = Vector(-330.00, 1250.00, 85.00), cible = Vector(0.00, 0.00, 260.00), fov = 80, duree = 4.06, glisse = true, doux = true, etape = 5},
  {nom = "Le recul ·", pos = Vector(-520.00, 1780.00, 105.00), cible = Vector(0.00, 0.00, 230.00), fov = 76, duree = 0.04, glisse = false, doux = true, etape = 5}
}
local SONS = {
  {t = 0, son = "ambient/levels/citadel/citadel_drone_loop1.wav", volume = 0.55, ton = 55, duree = 3},
  {t = 3, son = "ambient/levels/citadel/citadel_drone_loop1.wav", volume = 0.55, ton = 62, duree = 8.2},
  {t = 3, son = "ambient/levels/citadel/strange_talk1.wav", volume = 0.9, ton = 75, duree = 0},
  {t = 3.6, son = "ambient/levels/citadel/strange_talk2.wav", volume = 0.9, ton = 75, duree = 0},
  {t = 4.2, son = "ambient/levels/citadel/strange_talk3.wav", volume = 0.9, ton = 75, duree = 0},
  {t = 4.8, son = "ambient/wind/wind_snippet2.wav", volume = 0.6, ton = 60, duree = 0},
  {t = 5.4, son = "ambient/levels/citadel/strange_talk5.wav", volume = 0.9, ton = 75, duree = 0},
  {t = 6, son = "ambient/levels/citadel/strange_talk6.wav", volume = 0.9, ton = 75, duree = 0},
  {t = 6.6, son = "ambient/wind/wind_snippet2.wav", volume = 0.6, ton = 60, duree = 0},
  {t = 7.2, son = "ambient/wind/wind_snippet2.wav", volume = 0.6, ton = 60, duree = 0},
  {t = 7.8, son = "ambient/wind/wind_snippet2.wav", volume = 0.6, ton = 60, duree = 0},
  {t = 8.4, son = "ambient/levels/citadel/strange_talk11.wav", volume = 0.9, ton = 55, duree = 0},
  {t = 9.4, son = "ambient/levels/labs/teleport_preblast_suckin1.wav", volume = 1, ton = 100, duree = 0},
  {t = 11.2, son = "ambient/levels/citadel/citadel_drone_loop1.wav", volume = 0.55, ton = 70, duree = 5},
  {t = 11.2, son = "ambient/levels/labs/teleport_postblast_thunder1.wav", volume = 1, ton = 100, duree = 0},
  {t = 12.03, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 12.87, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 13.7, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 14.4, son = "ambient/levels/labs/teleport_preblast_suckin1.wav", volume = 1, ton = 100, duree = 0},
  {t = 16.2, son = "ambient/levels/citadel/citadel_drone_loop1.wav", volume = 0.55, ton = 76, duree = 5.4},
  {t = 16.2, son = "ambient/levels/labs/teleport_postblast_thunder1.wav", volume = 1, ton = 100, duree = 0},
  {t = 16.87, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 17.53, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 18.2, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 18.6, son = "ambient/levels/labs/teleport_preblast_suckin1.wav", volume = 1, ton = 100, duree = 0},
  {t = 21.6, son = "ambient/levels/citadel/citadel_drone_loop1.wav", volume = 0.55, ton = 84, duree = 5.9},
  {t = 21.6, son = "ambient/levels/labs/teleport_postblast_thunder1.wav", volume = 1, ton = 100, duree = 0},
  {t = 21.6, son = "ambient/levels/citadel/portal_open1_adpcm.wav", volume = 1, ton = 80, duree = 0},
  {t = 22.1, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 22.6, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 23.1, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 23.6, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 24.1, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 24.6, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 25.1, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 25.6, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 26.1, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 26.6, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0},
  {t = 27.1, son = "player/heartbeat1.wav", volume = 0.9, ton = 90, duree = 0}
}
local ETAPES = {
  [1] = "Collage : Coller segunda-azeno-final.txt (276 props). Ne rien poser d'autre, sauf le portail : particule Trou noir (le petit) à 1,5 m du sol, particule Portail au pied, lueur Violet dessus. Vitrine : azeno_suivant / azeno_precedent, azeno_stop.",
  [2] = "Le néant : Temps 1. Noir total, aucun son. Rien n'est posé. (Vitrine : fondu depuis le noir.)",
  [3] = "Les voix : Temps 2. Pose rapide des voix 6, 5, 3, 2, 1, puis El Que Queda. Courte pause aux sièges brisés 4, 7, 8, 9 : le silence de ceux qui ne sont pas revenus. Brume : 8 grandes fumées noires au ras du sol, cercle de 1 050 u. (Vitrine : cœur à 48.)",
  [4] = "L'œil rouge : Temps 3. (Vitrine : noir 1,8 s, aspiration, puis tonnerre et secousse ; cœur à 72.) Vraie lumière et lueur Rouge sous l'œil rouge ; vraie lumière et lueur Rouge au centre ; Aura rouge et Braises au centre.",
  [5] = "L'œil bleu : Temps 4. (Vitrine : noir 1,8 s, tonnerre, secousse ; cœur à 90.) Retirer le rouge du centre, l'aura, les braises et l'œil rouge. Vraie lumière et lueur Bleu reiatsu sous l'œil bleu et au centre ; Aura bleue au sol.",
  [6] = "Les deux regards : Temps 5. (Vitrine : noir 3 s, puis le portail s'ouvre, secousse forte ; cœur à 120 puis 70.) Retirer le bleu du centre et l'aura bleue, garder l'œil bleu, reposer l'œil rouge. Vraie lumière, lueur et Lueur magique Violet au centre ; Galaxie sous la voûte ; Feu violet au pied des voix 1, 2, 3, 5, 6. La voûte de stalactites et les fragments sortent du noir.",
  [7] = "Le silence : Temps 6. Le cœur s'arrête, retombée ; 6 s plus tard, tous les sons de la scène sont coupés. Fin de la Segunda."
}
local function ease(u) return u * u * (3 - 2 * u) end
local ANIMS = {
  {groupe = "la première voix", type = "apparait", t = 3, duree = 0.3},
  {groupe = "la deuxième voix", type = "apparait", t = 3.6, duree = 0.3},
  {groupe = "la troisième voix", type = "apparait", t = 4.2, duree = 0.3},
  {groupe = "la cinquième voix", type = "apparait", t = 5.4, duree = 0.3},
  {groupe = "la sixième voix", type = "apparait", t = 6, duree = 0.3},
  {groupe = "El Que Queda", type = "apparait", t = 8.4, duree = 0.3},
  {groupe = "brume", type = "apparait", t = 3, duree = 1.5},
  {groupe = "l’œil rouge", type = "apparait", t = 11.2, duree = 0.1},
  {groupe = "le rouge au centre", type = "apparait", t = 11.2, duree = 0.1},
  {groupe = "le cœur rouge", type = "apparait", t = 11.2, duree = 0.1},
  {groupe = "l’œil rouge", type = "disparait", t = 14.4, duree = 0.1},
  {groupe = "le rouge au centre", type = "disparait", t = 14.4, duree = 0.1},
  {groupe = "le cœur rouge", type = "disparait", t = 14.4, duree = 0.1},
  {groupe = "l’œil bleu", type = "apparait", t = 16.2, duree = 0.1},
  {groupe = "le bleu au centre", type = "apparait", t = 16.2, duree = 0.1},
  {groupe = "le cœur bleu", type = "apparait", t = 16.2, duree = 0.1},
  {groupe = "le bleu au centre", type = "disparait", t = 18.6, duree = 0.1},
  {groupe = "le cœur bleu", type = "disparait", t = 18.6, duree = 0.1},
  {groupe = "l’œil rouge revient", type = "apparait", t = 21.6, duree = 0.1},
  {groupe = "le violet au centre", type = "apparait", t = 21.6, duree = 0.1},
  {groupe = "le cœur violet", type = "apparait", t = 21.6, duree = 0.1},
  {groupe = "la galaxie", type = "apparait", t = 21.6, duree = 0.1},
  {groupe = "les feux violets", type = "apparait", t = 21.6, duree = 0.1},
  {groupe = "le cœur rouge", type = "pouls", t = 11.2, duree = 3.2, amplitude = 0.6, periode = 0.833333},
  {groupe = "le cœur bleu", type = "pouls", t = 16.2, duree = 2.4, amplitude = 0.6, periode = 0.666667},
  {groupe = "le cœur violet", type = "pouls", t = 21.6, duree = 5.9, amplitude = 0.6, periode = 0.5},
  {groupe = "voûte suspendue", type = "apparait", t = 20.1, duree = 0.1},
  {groupe = "fragment", type = "pivote", t = 0, duree = 0, axe = Vector(0.00, 0.00, 1.00), vitesse = 5, depart = 37},
  {groupe = "cristal", type = "teinte", t = 0, duree = 0, r = 14, g = 8, b = 26, plein = false},
  {groupe = "cristal", type = "teinte", t = 3, duree = 0, r = 34, g = 20, b = 60, plein = false},
  {groupe = "cristal", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = false},
  {groupe = "cristal", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = false},
  {groupe = "cristal", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = false},
  {groupe = "fragment", type = "teinte", t = 0, duree = 0, r = 14, g = 8, b = 26, plein = false},
  {groupe = "fragment", type = "teinte", t = 3, duree = 0, r = 34, g = 20, b = 60, plein = false},
  {groupe = "fragment", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = false},
  {groupe = "fragment", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = false},
  {groupe = "fragment", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = false},
  {groupe = "voûte suspendue", type = "teinte", t = 0, duree = 0, r = 14, g = 8, b = 26, plein = false},
  {groupe = "voûte suspendue", type = "teinte", t = 3, duree = 0, r = 34, g = 20, b = 60, plein = false},
  {groupe = "voûte suspendue", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = false},
  {groupe = "voûte suspendue", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = false},
  {groupe = "voûte suspendue", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = false},
  {groupe = "métal", type = "teinte", t = 0, duree = 0, r = 16, g = 8, b = 28, plein = false},
  {groupe = "métal", type = "teinte", t = 3, duree = 0, r = 40, g = 20, b = 70, plein = false},
  {groupe = "métal", type = "teinte", t = 11.2, duree = 0, r = 120, g = 60, b = 210, plein = false},
  {groupe = "lignes d’El Que Queda", type = "teinte", t = 0, duree = 0, r = 18, g = 10, b = 30, plein = false},
  {groupe = "lignes d’El Que Queda", type = "teinte", t = 8.4, duree = 0, r = 200, g = 30, b = 45, plein = true},
  {groupe = "lignes d’El Que Queda", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = true},
  {groupe = "lignes d’El Que Queda", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = true},
  {groupe = "lignes d’El Que Queda", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = true},
  {groupe = "lignes de la première voix", type = "teinte", t = 0, duree = 0, r = 18, g = 10, b = 30, plein = false},
  {groupe = "lignes de la première voix", type = "teinte", t = 3, duree = 0, r = 164, g = 107, b = 255, plein = true},
  {groupe = "lignes de la première voix", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = true},
  {groupe = "lignes de la première voix", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = true},
  {groupe = "lignes de la première voix", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = true},
  {groupe = "lignes de la deuxième voix", type = "teinte", t = 0, duree = 0, r = 18, g = 10, b = 30, plein = false},
  {groupe = "lignes de la deuxième voix", type = "teinte", t = 3.6, duree = 0, r = 164, g = 107, b = 255, plein = true},
  {groupe = "lignes de la deuxième voix", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = true},
  {groupe = "lignes de la deuxième voix", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = true},
  {groupe = "lignes de la deuxième voix", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = true},
  {groupe = "lignes de la troisième voix", type = "teinte", t = 0, duree = 0, r = 18, g = 10, b = 30, plein = false},
  {groupe = "lignes de la troisième voix", type = "teinte", t = 4.2, duree = 0, r = 164, g = 107, b = 255, plein = true},
  {groupe = "lignes de la troisième voix", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = true},
  {groupe = "lignes de la troisième voix", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = true},
  {groupe = "lignes de la troisième voix", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = true},
  {groupe = "lignes de la cinquième voix", type = "teinte", t = 0, duree = 0, r = 18, g = 10, b = 30, plein = false},
  {groupe = "lignes de la cinquième voix", type = "teinte", t = 5.4, duree = 0, r = 164, g = 107, b = 255, plein = true},
  {groupe = "lignes de la cinquième voix", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = true},
  {groupe = "lignes de la cinquième voix", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = true},
  {groupe = "lignes de la cinquième voix", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = true},
  {groupe = "lignes de la sixième voix", type = "teinte", t = 0, duree = 0, r = 18, g = 10, b = 30, plein = false},
  {groupe = "lignes de la sixième voix", type = "teinte", t = 6, duree = 0, r = 164, g = 107, b = 255, plein = true},
  {groupe = "lignes de la sixième voix", type = "teinte", t = 11.2, duree = 0, r = 255, g = 50, b = 70, plein = true},
  {groupe = "lignes de la sixième voix", type = "teinte", t = 16.2, duree = 0, r = 80, g = 150, b = 255, plein = true},
  {groupe = "lignes de la sixième voix", type = "teinte", t = 21.6, duree = 0, r = 190, g = 110, b = 255, plein = true},
  {groupe = "lignes des sièges vides", type = "teinte", t = 0, duree = 0, r = 18, g = 10, b = 30, plein = false},
  {groupe = "œil rouge", type = "teinte", t = 0, duree = 0, r = 0, g = 0, b = 0, plein = false},
  {groupe = "œil rouge", type = "teinte", t = 3, duree = 0, r = 0, g = 0, b = 0, plein = false},
  {groupe = "œil rouge", type = "teinte", t = 11.2, duree = 0, r = 201, g = 31, b = 47, plein = false},
  {groupe = "œil rouge", type = "teinte", t = 16.2, duree = 0, r = 0, g = 0, b = 0, plein = false},
  {groupe = "œil rouge", type = "teinte", t = 21.6, duree = 0, r = 201, g = 31, b = 47, plein = false},
  {groupe = "œil bleu", type = "teinte", t = 0, duree = 0, r = 0, g = 0, b = 0, plein = false},
  {groupe = "œil bleu", type = "teinte", t = 3, duree = 0, r = 0, g = 0, b = 0, plein = false},
  {groupe = "œil bleu", type = "teinte", t = 11.2, duree = 0, r = 0, g = 0, b = 0, plein = false},
  {groupe = "œil bleu", type = "teinte", t = 16.2, duree = 0, r = 41, g = 97, b = 203, plein = false},
  {groupe = "œil bleu", type = "teinte", t = 21.6, duree = 0, r = 41, g = 97, b = 203, plein = false}
}
local ECRAN = {
  {type = "flash", t = 0, duree = 1.5, force = 8, r = 0, g = 0, b = 0},
  {type = "brouillard", t = 0, duree = 1, force = 8, r = 2, g = 1, b = 5, debut = 40, fin = 1300, densite = 0.97},
  {type = "etalonnage", t = 0, duree = 1, force = 8, r = 0, g = 0, b = 0, ar = 0, ag = 0, ab = 0.01, lum = -0.04, contraste = 1.1, saturation = 0.15},
  {type = "brouillard", t = 3, duree = 1, force = 8, r = 7, g = 3, b = 14, debut = 250, fin = 2400, densite = 0.8},
  {type = "etalonnage", t = 3, duree = 1, force = 8, r = 0, g = 0, b = 0, ar = 0, ag = 0, ab = 0.02, lum = -0.02, contraste = 1.1, saturation = 0.9},
  {type = "noir", t = 9.4, duree = 1.8, force = 8, r = 0, g = 0, b = 0},
  {type = "brouillard", t = 11.2, duree = 1, force = 8, r = 26, g = 3, b = 8, debut = 250, fin = 2800, densite = 0.8},
  {type = "etalonnage", t = 11.2, duree = 1, force = 8, r = 0, g = 0, b = 0, ar = 0.05, ag = 0, ab = 0, lum = 0, contraste = 1.18, saturation = 0.7},
  {type = "flash", t = 11.2, duree = 0.6, force = 8, r = 255, g = 255, b = 255},
  {type = "secousse", t = 11.2, duree = 1.5, force = 6, r = 0, g = 0, b = 0},
  {type = "noir", t = 14.4, duree = 1.8, force = 8, r = 0, g = 0, b = 0},
  {type = "flash", t = 16.2, duree = 0.6, force = 8, r = 255, g = 255, b = 255},
  {type = "secousse", t = 16.2, duree = 1.5, force = 8, r = 0, g = 0, b = 0},
  {type = "brouillard", t = 16.2, duree = 1, force = 8, r = 3, g = 9, b = 26, debut = 250, fin = 2800, densite = 0.8},
  {type = "etalonnage", t = 16.2, duree = 1, force = 8, r = 0, g = 0, b = 0, ar = 0, ag = 0.01, ab = 0.06, lum = 0, contraste = 1.15, saturation = 0.7},
  {type = "noir", t = 18.6, duree = 3, force = 8, r = 0, g = 0, b = 0},
  {type = "flash", t = 21.6, duree = 0.6, force = 8, r = 255, g = 255, b = 255},
  {type = "secousse", t = 21.6, duree = 1.5, force = 14, r = 0, g = 0, b = 0},
  {type = "brouillard", t = 21.6, duree = 1, force = 8, r = 16, g = 7, b = 30, debut = 250, fin = 4200, densite = 0.8},
  {type = "etalonnage", t = 21.6, duree = 1, force = 8, r = 0, g = 0, b = 0, ar = 0.03, ag = 0, ab = 0.05, lum = 0, contraste = 1.22, saturation = 1.1},
  {type = "fondu", t = 25.5, duree = 5.3, force = 8, r = 0, g = 0, b = 0}
}
local PROPS = {   -- les props animés, retrouvés dans le dupe collé par leur modèle et leur place
  {groupe = "El Que Queda", idx = 0, model = "models/hunter/blocks/cube2x8x1.mdl", pos = Vector(0.00, 760.00, 273.22), ang = Angle(0.000, 0.000, 90.000)},
  {groupe = "lignes d’El Que Queda", idx = 0, model = "models/hunter/plates/plate025x7.mdl", pos = Vector(0.00, 723.68, 296.00), ang = Angle(0.000, 0.000, 90.000)},
  {groupe = "lignes d’El Que Queda", idx = 1, model = "models/hunter/tubes/circle4x4.mdl", pos = Vector(0.00, 760.00, 10.00), ang = Angle(0.000, 0.000, 0.000)},
  {groupe = "métal", idx = 0, model = "models/hunter/blocks/cube1x6x1.mdl", pos = Vector(446.72, 614.85, 206.79), ang = Angle(0.000, -36.000, 90.000)},
  {groupe = "lignes de la première voix", idx = 0, model = "models/hunter/plates/plate025x5.mdl", pos = Vector(425.37, 585.47, 229.57), ang = Angle(0.000, -36.000, 90.000)},
  {groupe = "lignes de la première voix", idx = 1, model = "models/hunter/tubes/circle2x2.mdl", pos = Vector(446.72, 614.85, 10.00), ang = Angle(0.000, 0.000, 0.000)},
  {groupe = "métal", idx = 1, model = "models/hunter/blocks/cube1x6x1.mdl", pos = Vector(722.80, 234.85, 206.79), ang = Angle(0.000, -72.000, 90.000)},
  {groupe = "lignes de la deuxième voix", idx = 0, model = "models/hunter/plates/plate025x5.mdl", pos = Vector(688.26, 223.63, 229.57), ang = Angle(0.000, -72.000, 90.000)},
  {groupe = "lignes de la deuxième voix", idx = 1, model = "models/hunter/tubes/circle2x2.mdl", pos = Vector(722.80, 234.85, 10.00), ang = Angle(0.000, 0.000, 0.000)},
  {groupe = "métal", idx = 2, model = "models/hunter/blocks/cube1x6x1.mdl", pos = Vector(722.80, -234.85, 206.79), ang = Angle(0.000, -108.000, 90.000)},
  {groupe = "lignes de la troisième voix", idx = 0, model = "models/hunter/plates/plate025x5.mdl", pos = Vector(688.26, -223.63, 229.57), ang = Angle(0.000, -108.000, 90.000)},
  {groupe = "lignes de la troisième voix", idx = 1, model = "models/hunter/tubes/circle2x2.mdl", pos = Vector(722.80, -234.85, 10.00), ang = Angle(0.000, 0.000, 0.000)},
  {groupe = "métal", idx = 3, model = "models/hunter/blocks/cube1x2x1.mdl", pos = Vector(446.72, -614.85, 73.93), ang = Angle(0.000, -144.000, 90.000)},
  {groupe = "métal", idx = 4, model = "models/hunter/blocks/cube1x4x1.mdl", pos = Vector(526.67, -792.95, 41.22), ang = Angle(0.000, -163.885, 0.000)},
  {groupe = "métal", idx = 5, model = "models/hunter/blocks/cube1x1x1.mdl", pos = Vector(620.97, -599.50, 41.22), ang = Angle(0.000, 60.941, 0.000)},
  {groupe = "métal", idx = 6, model = "models/hunter/blocks/cube1x6x1.mdl", pos = Vector(0.00, -760.00, 206.79), ang = Angle(0.000, -180.000, 90.000)},
  {groupe = "lignes de la cinquième voix", idx = 0, model = "models/hunter/plates/plate025x5.mdl", pos = Vector(0.00, -723.68, 229.57), ang = Angle(0.000, -180.000, 90.000)},
  {groupe = "lignes de la cinquième voix", idx = 1, model = "models/hunter/tubes/circle2x2.mdl", pos = Vector(0.00, -760.00, 10.00), ang = Angle(0.000, 0.000, 0.000)},
  {groupe = "métal", idx = 7, model = "models/hunter/blocks/cube1x6x1.mdl", pos = Vector(-446.72, -614.85, 206.79), ang = Angle(0.000, 144.000, 90.000)},
  {groupe = "lignes de la sixième voix", idx = 0, model = "models/hunter/plates/plate025x5.mdl", pos = Vector(-425.37, -585.47, 229.57), ang = Angle(0.000, 144.000, 90.000)},
  {groupe = "lignes de la sixième voix", idx = 1, model = "models/hunter/tubes/circle2x2.mdl", pos = Vector(-446.72, -614.85, 10.00), ang = Angle(0.000, 0.000, 0.000)},
  {groupe = "métal", idx = 8, model = "models/hunter/blocks/cube1x2x1.mdl", pos = Vector(-722.80, -234.85, 73.93), ang = Angle(0.000, 108.000, 90.000)},
  {groupe = "métal", idx = 9, model = "models/hunter/blocks/cube1x4x1.mdl", pos = Vector(-892.16, -331.94, 41.22), ang = Angle(0.000, 127.885, 0.000)},
  {groupe = "métal", idx = 10, model = "models/hunter/blocks/cube1x1x1.mdl", pos = Vector(-854.75, -120.01, 41.22), ang = Angle(0.000, 70.642, 0.000)},
  {groupe = "métal", idx = 11, model = "models/hunter/blocks/cube1x2x1.mdl", pos = Vector(-722.80, 234.85, 73.93), ang = Angle(0.000, 72.000, 90.000)},
  {groupe = "métal", idx = 12, model = "models/hunter/blocks/cube1x4x1.mdl", pos = Vector(-892.16, 331.94, 41.22), ang = Angle(0.000, 52.115, 0.000)},
  {groupe = "métal", idx = 13, model = "models/hunter/blocks/cube1x1x1.mdl", pos = Vector(-854.75, 120.01, 41.22), ang = Angle(0.000, 46.842, 0.000)},
  {groupe = "métal", idx = 14, model = "models/hunter/blocks/cube1x2x1.mdl", pos = Vector(-446.72, 614.85, 73.93), ang = Angle(0.000, 36.000, 90.000)},
  {groupe = "métal", idx = 15, model = "models/hunter/blocks/cube1x4x1.mdl", pos = Vector(-591.39, 745.92, 41.22), ang = Angle(0.000, 55.885, 0.000)},
  {groupe = "métal", idx = 16, model = "models/hunter/blocks/cube1x1x1.mdl", pos = Vector(-378.26, 775.83, 41.22), ang = Angle(0.000, 46.034, 0.000)},
  {groupe = "lignes d’El Que Queda", idx = 2, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-560.70, 513.04, 10.60), ang = Angle(0.000, -222.458, 0.000)},
  {groupe = "lignes d’El Que Queda", idx = 3, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-662.28, 372.80, 10.90), ang = Angle(0.000, -209.375, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 2, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-729.48, 213.20, 10.60), ang = Angle(0.000, -196.292, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 3, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-758.81, 42.53, 10.90), ang = Angle(0.000, -183.208, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 4, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-748.74, -130.34, 10.60), ang = Angle(0.000, -170.125, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 5, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-699.80, -296.45, 10.90), ang = Angle(0.000, -157.042, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 6, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-614.53, -447.16, 10.60), ang = Angle(0.000, -143.958, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 7, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-497.35, -574.67, 10.90), ang = Angle(0.000, -130.875, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 8, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-354.36, -672.33, 10.60), ang = Angle(0.000, -117.792, 0.000)},
  {groupe = "lignes de la cinquième voix", idx = 2, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-192.96, -735.10, 10.90), ang = Angle(0.000, -104.708, 0.000)},
  {groupe = "lignes de la cinquième voix", idx = 3, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(-21.55, -759.69, 10.60), ang = Angle(0.000, -91.625, 0.000)},
  {groupe = "lignes de la cinquième voix", idx = 4, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(150.98, -744.85, 10.90), ang = Angle(0.000, -78.542, 0.000)},
  {groupe = "lignes de la cinquième voix", idx = 5, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(315.67, -691.34, 10.60), ang = Angle(0.000, -65.458, 0.000)},
  {groupe = "lignes de la troisième voix", idx = 2, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(463.97, -601.94, 10.90), ang = Angle(0.000, -52.375, 0.000)},
  {groupe = "lignes de la troisième voix", idx = 3, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(588.19, -481.28, 10.60), ang = Angle(0.000, -39.292, 0.000)},
  {groupe = "lignes de la troisième voix", idx = 4, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(681.87, -335.64, 10.90), ang = Angle(0.000, -26.208, 0.000)},
  {groupe = "lignes de la troisième voix", idx = 5, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(740.15, -172.58, 10.60), ang = Angle(0.000, -13.125, 0.000)},
  {groupe = "lignes de la troisième voix", idx = 6, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(760.00, -0.55, 10.90), ang = Angle(0.000, -0.042, 0.000)},
  {groupe = "lignes de la deuxième voix", idx = 2, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(740.40, 171.50, 10.60), ang = Angle(0.000, 13.042, 0.000)},
  {groupe = "lignes de la deuxième voix", idx = 3, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(682.36, 334.65, 10.90), ang = Angle(0.000, 26.125, 0.000)},
  {groupe = "lignes de la première voix", idx = 2, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(588.89, 480.43, 10.60), ang = Angle(0.000, 39.208, 0.000)},
  {groupe = "lignes de la première voix", idx = 3, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(464.85, 601.26, 10.90), ang = Angle(0.000, 52.292, 0.000)},
  {groupe = "lignes de la première voix", idx = 4, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(316.68, 690.88, 10.60), ang = Angle(0.000, 65.375, 0.000)},
  {groupe = "lignes d’El Que Queda", idx = 4, model = "models/hunter/plates/plate025x4.mdl", pos = Vector(152.06, 744.63, 10.90), ang = Angle(0.000, 78.458, 0.000)},
  {groupe = "lignes d’El Que Queda", idx = 5, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(17.90, 1605.10, 10.20), ang = Angle(0.000, -0.639, 0.000)},
  {groupe = "lignes d’El Que Queda", idx = 6, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(-166.45, 2016.35, 10.50), ang = Angle(0.000, 29.208, 0.000)},
  {groupe = "lignes d’El Que Queda", idx = 7, model = "models/hunter/plates/plate025x24.mdl", pos = Vector(15.75, 2925.55, 10.50), ang = Angle(0.000, 1.071, 0.000)},
  {groupe = "lignes de la première voix", idx = 5, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(955.46, 1289.87, 10.20), ang = Angle(0.000, -36.529, 0.000)},
  {groupe = "lignes de la première voix", idx = 6, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(1030.72, 1732.68, 10.50), ang = Angle(0.000, -4.184, 0.000)},
  {groupe = "lignes de la première voix", idx = 7, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(1800.79, 2539.88, 10.50), ang = Angle(0.000, -31.609, 0.000)},
  {groupe = "lignes de la première voix", idx = 8, model = "models/hunter/plates/plate025x8.mdl", pos = Vector(2273.54, 3352.16, 10.80), ang = Angle(0.000, -24.460, 0.000)},
  {groupe = "lignes de la deuxième voix", idx = 4, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(1520.41, 514.80, 10.20), ang = Angle(0.000, -71.294, 0.000)},
  {groupe = "lignes de la deuxième voix", idx = 5, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(1963.62, 445.39, 10.50), ang = Angle(0.000, -104.498, 0.000)},
  {groupe = "lignes de la deuxième voix", idx = 6, model = "models/hunter/plates/plate025x24.mdl", pos = Vector(2789.26, 872.19, 10.50), ang = Angle(0.000, -78.244, 0.000)},
  {groupe = "lignes de la troisième voix", idx = 7, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(1544.53, -437.16, 10.20), ang = Angle(0.000, -105.803, 0.000)},
  {groupe = "lignes de la troisième voix", idx = 8, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(1876.24, -740.28, 10.50), ang = Angle(0.000, -137.834, 0.000)},
  {groupe = "lignes de la troisième voix", idx = 9, model = "models/hunter/plates/plate025x24.mdl", pos = Vector(2810.88, -811.37, 10.50), ang = Angle(0.000, -107.344, 0.000)},
  {groupe = "lignes des sièges vides", idx = 0, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(974.25, -1275.74, 10.20), ang = Angle(0.000, -142.632, 0.000)},
  {groupe = "lignes des sièges vides", idx = 1, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(1368.91, -1495.04, 10.50), ang = Angle(0.000, -114.229, 0.000)},
  {groupe = "lignes des sièges vides", idx = 2, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(1977.44, -2398.89, 10.50), ang = Angle(0.000, -133.826, 0.000)},
  {groupe = "lignes des sièges vides", idx = 3, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(2798.96, -3175.86, 10.80), ang = Angle(0.000, -132.553, 0.000)},
  {groupe = "lignes de la cinquième voix", idx = 6, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(-57.39, -1604.17, 10.20), ang = Angle(0.000, -182.049, 0.000)},
  {groupe = "lignes de la cinquième voix", idx = 7, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(95.84, -2030.07, 10.50), ang = Angle(0.000, -155.720, 0.000)},
  {groupe = "lignes de la cinquième voix", idx = 8, model = "models/hunter/plates/plate025x24.mdl", pos = Vector(-96.57, -2924.16, 10.50), ang = Angle(0.000, -181.234, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 9, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(-902.05, -1327.77, 10.20), ang = Angle(0.000, -214.191, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 10, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(-1001.60, -1769.52, 10.50), ang = Angle(0.000, -188.276, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 11, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(-1819.58, -2524.41, 10.50), ang = Angle(0.000, -220.767, 0.000)},
  {groupe = "lignes de la sixième voix", idx = 12, model = "models/hunter/plates/plate025x8.mdl", pos = Vector(-2434.34, -3236.84, 10.80), ang = Angle(0.000, -220.888, 0.000)},
  {groupe = "lignes des sièges vides", idx = 4, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(-1528.80, -489.33, 10.20), ang = Angle(0.000, -252.252, 0.000)},
  {groupe = "lignes des sièges vides", idx = 5, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(-1844.80, -807.89, 10.50), ang = Angle(0.000, -219.192, 0.000)},
  {groupe = "lignes des sièges vides", idx = 6, model = "models/hunter/plates/plate025x24.mdl", pos = Vector(-2781.21, -907.74, 10.50), ang = Angle(0.000, -250.557, 0.000)},
  {groupe = "lignes des sièges vides", idx = 7, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(-1542.61, 443.87, 10.20), ang = Angle(0.000, 73.948, 0.000)},
  {groupe = "lignes des sièges vides", idx = 8, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(-1991.21, 389.39, 10.50), ang = Angle(0.000, -258.362, 0.000)},
  {groupe = "lignes des sièges vides", idx = 9, model = "models/hunter/plates/plate025x24.mdl", pos = Vector(-2826.93, 740.36, 10.50), ang = Angle(0.000, 81.080, 0.000)},
  {groupe = "lignes des sièges vides", idx = 10, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(-995.82, 1258.97, 10.20), ang = Angle(0.000, 38.343, 0.000)},
  {groupe = "lignes des sièges vides", idx = 11, model = "models/hunter/plates/plate025x16.mdl", pos = Vector(-1133.55, 1690.88, 10.50), ang = Angle(0.000, 13.428, 0.000)},
  {groupe = "lignes des sièges vides", idx = 12, model = "models/hunter/plates/plate025x32.mdl", pos = Vector(-1926.47, 2448.57, 10.50), ang = Angle(0.000, 37.731, 0.000)},
  {groupe = "lignes des sièges vides", idx = 13, model = "models/hunter/plates/plate025x8.mdl", pos = Vector(-2500.08, 3194.50, 10.80), ang = Angle(0.000, 36.863, 0.000)},
  {groupe = "cristal", idx = 0, model = "models/propper/hueco_mundo_v1/huecomundosetails128.mdl", pos = Vector(-2179.04, -2122.32, 883.20), ang = Angle(0.000, 339.280, 0.000)},
  {groupe = "cristal", idx = 1, model = "models/propper/hueco_mundo_v1/huecomundosetails128.mdl", pos = Vector(2719.82, 501.24, 896.91), ang = Angle(0.000, 233.630, 0.000)},
  {groupe = "cristal", idx = 2, model = "models/propper/hueco_mundo_v1/huecomundosetails129.mdl", pos = Vector(-2194.84, 2285.11, 827.86), ang = Angle(0.000, 36.710, 0.000)},
  {groupe = "cristal", idx = 3, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(487.09, 2296.07, 1.50), ang = Angle(180.000, 275.660, 0.000)},
  {groupe = "cristal", idx = 4, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(1858.01, 2210.86, 1.50), ang = Angle(180.000, 0.640, 0.000)},
  {groupe = "cristal", idx = 5, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(1203.30, 2078.68, 1.50), ang = Angle(180.000, 315.400, 0.000)},
  {groupe = "cristal", idx = 6, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(2800.73, -1089.07, 1.50), ang = Angle(180.000, 321.750, 0.000)},
  {groupe = "cristal", idx = 7, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(-2183.74, 1221.56, 1.50), ang = Angle(180.000, 163.020, 0.000)},
  {groupe = "cristal", idx = 8, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(2127.20, -615.40, 1.50), ang = Angle(180.000, 334.680, 0.000)},
  {groupe = "cristal", idx = 9, model = "models/propper/hueco_mundo_v1/huecomundosetails173.mdl", pos = Vector(-3207.70, -252.37, 627.01), ang = Angle(26.260, 166.630, 0.000)},
  {groupe = "cristal", idx = 10, model = "models/propper/hueco_mundo_v1/huecomundosetails173.mdl", pos = Vector(449.70, -2280.49, 578.13), ang = Angle(31.700, 155.870, 0.000)},
  {groupe = "cristal", idx = 11, model = "models/propper/hueco_mundo_v1/huecomundosetails197_2.mdl", pos = Vector(834.32, -2636.72, 673.17), ang = Angle(24.770, 111.350, 0.000)},
  {groupe = "cristal", idx = 12, model = "models/propper/hueco_mundo_v1/huecomundosetails197_2.mdl", pos = Vector(-342.88, -1805.36, 718.91), ang = Angle(18.450, 332.500, 0.000)},
  {groupe = "cristal", idx = 13, model = "models/propper/hueco_mundo_v1/huecomundosetails160.mdl", pos = Vector(-2343.54, -730.66, 567.18), ang = Angle(12.270, 286.250, 0.000)},
  {groupe = "cristal", idx = 14, model = "models/propper/hueco_mundo_v1/huecomundosetails160.mdl", pos = Vector(2041.87, -1694.01, 639.67), ang = Angle(9.200, 167.610, 0.000)},
  {groupe = "cristal", idx = 15, model = "models/propper/hueco_mundo_v1/huecomundosetails176.mdl", pos = Vector(-963.87, -2796.53, 760.19), ang = Angle(11.310, 239.870, 0.000)},
  {groupe = "cristal", idx = 16, model = "models/propper/hueco_mundo_v1/huecomundosetails176.mdl", pos = Vector(-3079.23, 349.86, 678.46), ang = Angle(11.320, 77.620, 0.000)},
  {groupe = "cristal", idx = 17, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(2932.49, 1818.16, 11.55), ang = Angle(0.000, 126.500, 0.000)},
  {groupe = "cristal", idx = 18, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(1373.10, 3068.55, 11.80), ang = Angle(0.000, 208.950, 0.000)},
  {groupe = "cristal", idx = 19, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-3067.93, 1388.75, 11.26), ang = Angle(0.000, 293.640, 0.000)},
  {groupe = "cristal", idx = 20, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-6.81, 3086.48, 12.02), ang = Angle(0.000, 69.150, 0.000)},
  {groupe = "cristal", idx = 21, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-915.27, 1029.93, 9.76), ang = Angle(0.000, 130.460, 0.000)},
  {groupe = "cristal", idx = 22, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-1386.84, 171.89, 9.64), ang = Angle(0.000, 279.540, 0.000)},
  {groupe = "cristal", idx = 23, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-1042.84, -1767.78, 9.12), ang = Angle(0.000, 262.890, 0.000)},
  {groupe = "cristal", idx = 24, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-1349.92, 1848.26, 9.05), ang = Angle(0.000, 226.610, 0.000)},
  {groupe = "cristal", idx = 25, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(1121.61, -1058.51, 9.38), ang = Angle(0.000, 152.710, 0.000)},
  {groupe = "cristal", idx = 26, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(1492.46, -689.33, 9.12), ang = Angle(0.000, 124.480, 0.000)},
  {groupe = "cristal", idx = 27, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(1341.28, 1026.11, 10.04), ang = Angle(0.000, 178.750, 0.000)},
  {groupe = "cristal", idx = 28, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-1508.39, 669.67, 9.87), ang = Angle(0.000, 190.090, 0.000)},
  {groupe = "cristal", idx = 29, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(1327.52, -1747.10, 207.09), ang = Angle(23.550, 305.100, 0.000)},
  {groupe = "cristal", idx = 30, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-1026.58, 1617.67, 160.43), ang = Angle(28.990, 144.710, 0.000)},
  {groupe = "cristal", idx = 31, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(1416.56, 1511.74, 208.78), ang = Angle(25.560, 164.780, 0.000)},
  {groupe = "cristal", idx = 32, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(1502.06, -937.62, 172.50), ang = Angle(23.880, 136.140, 0.000)},
  {groupe = "cristal", idx = 33, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-766.74, -1191.40, 181.32), ang = Angle(30.070, 209.130, 0.000)},
  {groupe = "cristal", idx = 34, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(732.48, 1314.65, 1.50), ang = Angle(180.000, 63.160, 0.000)},
  {groupe = "cristal", idx = 35, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(93.50, -2513.33, 1.50), ang = Angle(180.000, 239.450, 0.000)},
  {groupe = "cristal", idx = 36, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-1243.48, -730.35, 1.50), ang = Angle(180.000, 108.740, 0.000)},
  {groupe = "cristal", idx = 37, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-1534.26, 1389.31, 1.50), ang = Angle(180.000, 302.980, 0.000)},
  {groupe = "cristal", idx = 38, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(1476.24, 292.24, 1.50), ang = Angle(180.000, 144.070, 0.000)},
  {groupe = "cristal", idx = 39, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(576.19, -1565.42, 1.50), ang = Angle(180.000, 24.220, 0.000)},
  {groupe = "cristal", idx = 40, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-810.62, 3400.93, 206.35), ang = Angle(25.000, 20.000, 0.000)},
  {groupe = "cristal", idx = 41, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-1100.10, 3385.76, 206.35), ang = Angle(25.000, 80.000, 0.000)},
  {groupe = "cristal", idx = 42, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-1343.21, 3227.88, 206.35), ang = Angle(25.000, 140.000, 0.000)},
  {groupe = "cristal", idx = 43, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(1566.79, -3032.61, 10.40), ang = Angle(0.000, 203.770, 0.000)},
  {groupe = "cristal", idx = 44, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-3246.31, -827.39, 10.32), ang = Angle(0.000, 52.790, 0.000)},
  {groupe = "cristal", idx = 45, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(3333.04, -778.02, 9.60), ang = Angle(0.000, 157.300, 0.000)},
  {groupe = "cristal", idx = 46, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(2330.59, 2611.69, 10.33), ang = Angle(0.000, 173.780, 0.000)},
  {groupe = "cristal", idx = 47, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(584.47, -3414.40, 9.78), ang = Angle(0.000, 189.170, 0.000)},
  {groupe = "cristal", idx = 48, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(679.25, 3473.84, 9.48), ang = Angle(0.000, 209.070, 0.000)},
  {groupe = "cristal", idx = 49, model = "models/propper/hueco_mundo_v1/huecomundosetails160.mdl", pos = Vector(2024.66, 1509.94, 357.65), ang = Angle(13.770, 251.940, 0.000)},
  {groupe = "cristal", idx = 50, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(2976.83, -1836.62, 1.50), ang = Angle(180.000, 275.580, 0.000)},
  {groupe = "cristal", idx = 51, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(2109.19, -2573.51, 1.50), ang = Angle(180.000, 329.500, 0.000)},
  {groupe = "cristal", idx = 52, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-3039.43, -1413.64, 1.50), ang = Angle(180.000, 166.580, 0.000)},
  {groupe = "cristal", idx = 53, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-2334.05, 70.03, 1.50), ang = Angle(180.000, 10.670, 0.000)},
  {groupe = "voûte suspendue", idx = 0, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(-1154.63, 639.47, 1890.50), ang = Angle(0.000, 154.710, 0.000)},
  {groupe = "voûte suspendue", idx = 1, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(-2684.72, 864.19, 1890.50), ang = Angle(0.000, 117.160, 0.000)},
  {groupe = "voûte suspendue", idx = 2, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(-1054.07, 3177.60, 1890.50), ang = Angle(0.000, 12.280, 0.000)},
  {groupe = "voûte suspendue", idx = 3, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(-191.20, -2356.43, 1890.50), ang = Angle(0.000, 312.760, 0.000)},
  {groupe = "voûte suspendue", idx = 4, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(904.55, -589.82, 1890.50), ang = Angle(0.000, 133.740, 0.000)},
  {groupe = "voûte suspendue", idx = 5, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(-391.63, 1356.08, 1890.50), ang = Angle(0.000, 303.300, 0.000)},
  {groupe = "voûte suspendue", idx = 6, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(1500.33, -79.83, 1890.50), ang = Angle(0.000, 126.150, 0.000)},
  {groupe = "voûte suspendue", idx = 7, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(1746.81, 1281.48, 1890.50), ang = Angle(0.000, 1.880, 0.000)},
  {groupe = "voûte suspendue", idx = 8, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(3240.96, 179.91, 1890.50), ang = Angle(0.000, 34.920, 0.000)},
  {groupe = "voûte suspendue", idx = 9, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(2297.32, -948.66, 1890.50), ang = Angle(0.000, 285.760, 0.000)},
  {groupe = "voûte suspendue", idx = 10, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(216.50, 1112.69, 1890.50), ang = Angle(0.000, 196.040, 0.000)},
  {groupe = "voûte suspendue", idx = 11, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(2382.09, -126.49, 1890.50), ang = Angle(0.000, 202.920, 0.000)},
  {groupe = "voûte suspendue", idx = 12, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(-1457.56, 2160.25, 1890.50), ang = Angle(0.000, 165.370, 0.000)},
  {groupe = "voûte suspendue", idx = 13, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(460.48, 2792.13, 1890.50), ang = Angle(0.000, 39.780, 0.000)},
  {groupe = "voûte suspendue", idx = 14, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(1010.54, 659.64, 1890.50), ang = Angle(0.000, 113.240, 0.000)},
  {groupe = "voûte suspendue", idx = 15, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(-1267.79, -1851.50, 1890.50), ang = Angle(0.000, 289.950, 0.000)},
  {groupe = "voûte suspendue", idx = 16, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(2112.95, 448.79, 1890.50), ang = Angle(0.000, 86.220, 0.000)},
  {groupe = "voûte suspendue", idx = 17, model = "models/props_mining/stalactite_static04.mdl", pos = Vector(462.00, 1661.00, 1890.50), ang = Angle(0.000, 230.910, 0.000)},
  {groupe = "voûte suspendue", idx = 18, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(1461.15, -2025.05, 1890.50), ang = Angle(0.000, 244.920, 0.000)},
  {groupe = "voûte suspendue", idx = 19, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-2191.56, -1205.41, 1890.50), ang = Angle(0.000, 77.340, 0.000)},
  {groupe = "voûte suspendue", idx = 20, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-346.61, 2405.90, 1890.50), ang = Angle(0.000, 102.900, 0.000)},
  {groupe = "voûte suspendue", idx = 21, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(2830.81, 1362.80, 1890.50), ang = Angle(0.000, 285.970, 0.000)},
  {groupe = "voûte suspendue", idx = 22, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(529.56, -3027.30, 1890.50), ang = Angle(0.000, 141.280, 0.000)},
  {groupe = "voûte suspendue", idx = 23, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-1819.78, 40.14, 1890.50), ang = Angle(0.000, 333.290, 0.000)},
  {groupe = "voûte suspendue", idx = 24, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-890.84, -839.17, 1890.50), ang = Angle(0.000, 330.090, 0.000)},
  {groupe = "voûte suspendue", idx = 25, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-2807.19, 1900.19, 1890.50), ang = Angle(0.000, 347.230, 0.000)},
  {groupe = "voûte suspendue", idx = 26, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(76.93, -1461.59, 1890.50), ang = Angle(0.000, 41.550, 0.000)},
  {groupe = "voûte suspendue", idx = 27, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(1941.61, 2717.04, 1890.50), ang = Angle(0.000, 212.450, 0.000)},
  {groupe = "voûte suspendue", idx = 28, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-2735.43, -350.21, 1890.50), ang = Angle(0.000, 49.490, 0.000)},
  {groupe = "voûte suspendue", idx = 29, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(2510.10, -2317.48, 1890.50), ang = Angle(0.000, 243.120, 0.000)},
  {groupe = "voûte suspendue", idx = 30, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(3262.75, -1118.95, 1890.50), ang = Angle(0.000, 270.420, 0.000)},
  {groupe = "voûte suspendue", idx = 31, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-477.98, -3208.20, 1890.50), ang = Angle(0.000, 11.440, 0.000)},
  {groupe = "œil rouge", idx = 0, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(-540.00, 60.00, 1883.90), ang = Angle(180.000, 78.000, 0.000)},
  {groupe = "œil bleu", idx = 0, model = "models/fallenlogic_environment/rocks/bigformation_05.mdl", pos = Vector(540.00, 60.00, 1883.90), ang = Angle(180.000, 102.000, 0.000)},
  {groupe = "fragment", idx = 0, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-240.19, 464.84, 266.92), ang = Angle(63.400, 359.900, -31.500)},
  {groupe = "fragment", idx = 1, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-192.46, -308.05, 121.13), ang = Angle(64.000, 62.200, 37.600)},
  {groupe = "fragment", idx = 2, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(172.08, -288.09, 200.83), ang = Angle(7.100, 93.700, -3.600)},
  {groupe = "fragment", idx = 3, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(187.15, 90.79, 396.62), ang = Angle(-8.700, 253.500, -50.800)},
  {groupe = "fragment", idx = 4, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(549.53, -62.12, 591.73), ang = Angle(-57.700, 207.700, 39.300)},
  {groupe = "fragment", idx = 5, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(130.57, -598.49, 792.82), ang = Angle(38.800, 198.700, -45.400)},
  {groupe = "fragment", idx = 6, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(589.42, 218.06, 714.91), ang = Angle(62.400, 191.100, -33.700)},
  {groupe = "fragment", idx = 7, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-23.55, -315.70, 446.56), ang = Angle(67.900, 18.800, 15.900)},
  {groupe = "fragment", idx = 8, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(30.95, -484.27, 369.61), ang = Angle(56.700, 247.800, -53.300)},
  {groupe = "fragment", idx = 9, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-112.77, -295.38, 160.41), ang = Angle(-67.600, 174.800, -17.600)},
  {groupe = "fragment", idx = 10, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-461.37, 270.99, 120.44), ang = Angle(46.000, 325.800, 24.100)},
  {groupe = "fragment", idx = 11, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-106.61, -184.37, 274.65), ang = Angle(-55.600, 307.900, -31.300)},
  {groupe = "fragment", idx = 12, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(175.53, 57.67, 385.63), ang = Angle(-16.900, 353.400, 25.400)},
  {groupe = "fragment", idx = 13, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-389.47, 25.68, 251.57), ang = Angle(-11.900, 194.700, -25.500)},
  {groupe = "fragment", idx = 14, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(575.30, 66.45, 441.69), ang = Angle(-50.200, 32.400, 45.400)},
  {groupe = "fragment", idx = 15, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-146.03, -304.03, 465.55), ang = Angle(23.000, 102.200, 45.300)},
  {groupe = "fragment", idx = 16, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(144.71, -318.40, 302.93), ang = Angle(-34.900, 311.100, 44.600)},
  {groupe = "fragment", idx = 17, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-252.55, 507.64, 714.29), ang = Angle(35.700, 359.900, -2.600)},
  {groupe = "fragment", idx = 18, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(94.95, -478.31, 423.57), ang = Angle(65.700, 91.800, 56.500)},
  {groupe = "fragment", idx = 19, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(321.47, -483.07, 556.23), ang = Angle(-55.600, 49.500, 51.500)},
  {groupe = "fragment", idx = 20, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(106.39, 438.49, 570.11), ang = Angle(24.800, 20.500, -57.300)},
  {groupe = "fragment", idx = 21, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-400.37, -241.97, 478.76), ang = Angle(-47.500, 348.800, -52.700)},
  {groupe = "fragment", idx = 22, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-242.12, -238.99, 546.16), ang = Angle(-27.900, 129.400, 17.700)},
  {groupe = "fragment", idx = 23, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(478.77, 15.30, 376.91), ang = Angle(40.400, 191.900, 38.400)},
  {groupe = "fragment", idx = 24, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(227.57, 187.23, 272.31), ang = Angle(39.900, 290.700, 38.100)},
  {groupe = "fragment", idx = 25, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-420.90, -466.51, 702.02), ang = Angle(-57.700, 16.200, 59.900)},
  {groupe = "fragment", idx = 26, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(-472.79, -34.57, 160.54), ang = Angle(5.800, 277.000, -21.300)},
  {groupe = "fragment", idx = 27, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(116.06, 292.54, 364.39), ang = Angle(22.300, 200.400, -36.500)},
  {groupe = "fragment", idx = 28, model = "models/props_mining/stalactite_static03.mdl", pos = Vector(107.60, 438.43, 455.36), ang = Angle(23.600, 122.200, 17.300)},
  {groupe = "fragment", idx = 29, model = "models/propper/hueco_mundo_v1/huecomundosetails170.mdl", pos = Vector(-196.88, -0.84, 368.98), ang = Angle(41.500, 337.900, -18.600)}
}
local TETE = Vector(-1895.00, -1895.00, 3.75)
local origine, debut, plan_aff, son_i, silence
local film_t = 0

-- ---- animations : même règle que moteur/anim.py et l'éditeur
local function clamp(u) if u < 0 then return 0 elseif u > 1 then return 1 end return u end
local function rot(v, axe, deg)                 -- Rodrigues
  local n = math.sqrt(axe.x * axe.x + axe.y * axe.y + axe.z * axe.z); if n == 0 then n = 1 end
  local kx, ky, kz = axe.x / n, axe.y / n, axe.z / n
  local a = math.rad(deg); local c, s = math.cos(a), math.sin(a)
  local kv = kx * v.x + ky * v.y + kz * v.z
  local cx, cy, cz = ky * v.z - kz * v.y, kz * v.x - kx * v.z, kx * v.y - ky * v.x
  return Vector(v.x * c + cx * s + kx * kv * (1 - c), v.y * c + cy * s + ky * kv * (1 - c), v.z * c + cz * s + kz * kv * (1 - c))
end
local ASP = Vector(0.3, 0.5, 0.81)
local function pose(groupe, idx, pos, t)
  local p = Vector(pos.x, pos.y, pos.z); local rots = {}; local ech, alpha = 1, 1
  for _, a in ipairs(ANIMS) do
    if a.groupe == groupe then
      local t0, d = a.t, a.duree
      if a.type == "apparait" then
        if d > 0 then alpha = alpha * clamp((t - t0) / d) elseif t < t0 then alpha = 0 end
      elseif a.type == "pouls" then
        if t >= t0 + a.periode and not (d > 0 and t > t0 + d) then
          ech = ech * (1 + a.amplitude * math.max(0, 1 - ((t - t0) % a.periode) / 0.18))
        end
      elseif a.type == "grandit" then
        local u = d > 0 and clamp((t - t0) / d) or (t >= t0 and 1 or 0)
        local k = a.de + (a.a - a.de) * ((a.doux == false) and u or ease(u))
        p = Vector(a.centre.x + (p.x - a.centre.x) * k, a.centre.y + (p.y - a.centre.y) * k, a.centre.z + (p.z - a.centre.z) * k)
        if a.echelle ~= false then ech = ech * k end
      elseif t >= t0 then
        local u = d > 0 and clamp((t - t0) / d) or 1
        if a.type == "tourne" then
          local g = a.degres * (a.doux and ease(u) or u)
          p = a.centre + rot(p - a.centre, a.axe, g); rots[#rots + 1] = {a.axe, g}
        elseif a.type == "deplace" then
          local e = (a.doux == false) and u or ease(u)
          p = Vector(p.x + a.vers.x * e, p.y + a.vers.y * e, p.z + a.vers.z * e)
        elseif a.type == "flotte" then
          if not (d > 0 and t > t0 + d) then p = Vector(p.x, p.y, p.z + a.amplitude * math.sin(2 * math.pi * (t - t0) / a.periode + idx * 1.7)) end
        elseif a.type == "tremble" then
          if not (d > 0 and t > t0 + d) then
            local A = a.amplitude
            p = Vector(p.x + A * math.sin(37 * t + idx), p.y + A * math.sin(41 * t + 2 * idx), p.z + A * math.sin(43 * t + 3 * idx))
          end
        elseif a.type == "pivote" then
          local fin = d > 0 and (t0 + d) or t
          rots[#rots + 1] = {a.axe or Vector(math.sin(idx * 12.9898), math.sin(idx * 78.233), math.cos(idx * 37.719)),
                             a.vitesse * (0.5 + (idx * 0.618) % 1) * (math.min(t, fin) - t0) + (a.depart or 0) * idx}
        elseif a.type == "disparait" then
          alpha = alpha * (1 - u)
        elseif a.type == "aspire" then
          local dv = p - a.vers; local t1 = t0 + math.sqrt(dv.x * dv.x + dv.y * dv.y + dv.z * dv.z) / a.vitesse
          if t >= t1 then
            local v = d > 0 and clamp((t - t1) / d) or 1; local e = v * v
            p = Vector(p.x + (a.vers.x - p.x) * e, p.y + (a.vers.y - p.y) * e, p.z + (a.vers.z - p.z) * e)
            rots[#rots + 1] = {ASP, 540 * v}; ech = ech * (1 - 0.9 * e)
            if v >= 1 then alpha = 0 end
          end
        end
      end
    end
  end
  return p, rots, ech, alpha
end
local TEINTES = {}                              -- par groupe, triées par début
for _, a in ipairs(ANIMS) do if a.type == "teinte" then TEINTES[a.groupe] = TEINTES[a.groupe] or {}; table.insert(TEINTES[a.groupe], a) end end
for _, l in pairs(TEINTES) do table.sort(l, function(x, y) return x.t < y.t end) end
local function teinte(groupe, base, t)          -- même règle que moteur/anim.py (teinte)
  local l = TEINTES[groupe]; if not l then return nil end
  local r, g, b, plein = base.r, base.g, base.b, false
  for _, a in ipairs(l) do
    if t < a.t then break end
    local u = a.duree > 0 and clamp((t - a.t) / a.duree) or 1
    r, g, b, plein = r + (a.r - r) * u, g + (a.g - g) * u, b + (a.b - b) * u, a.plein
  end
  return Color(math.Round(r), math.Round(g), math.Round(b)), plein
end
local function ecran(t)
  local r, g, b, al, sec, vol = 0, 0, 0, 0, 0, 1
  for _, e in ipairs(ECRAN) do
    local u = (t - e.t) / e.duree
    if u >= 0 and u <= 1 and e.type ~= "brouillard" and e.type ~= "etalonnage" then
      if e.type == "secousse" then sec = sec + e.force * (1 - u)
      elseif e.type == "silence" then vol = math.min(vol, math.max(0, 1 - math.min(u * e.duree, (1 - u) * e.duree) / 0.3))
      else
        local a = 1
        if e.type == "flash" then a = (1 - u) ^ 2 elseif e.type == "fondu" then
          if u < 0.3 then a = u / 0.3 elseif u >= 0.7 then a = (1 - u) / 0.3 end
        end
        if a >= al then r, g, b, al = e.r, e.g, e.b, a end
      end
    end
  end
  return r, g, b, al, sec, vol
end
local function brouillard_actif()              -- même règle que moteur/anim.py (brouillard)
  if not debut then return nil end
  local b
  for _, e in ipairs(ECRAN) do if e.type == "brouillard" and e.t <= film_t then b = e end end
  if b and b.densite > 0 then return b end
end
local function brouillard(echelle)
  local b = brouillard_actif(); if not b then return end
  echelle = echelle or 1
  render.FogMode(MATERIAL_FOG_LINEAR); render.FogStart(b.debut * echelle); render.FogEnd(b.fin * echelle)
  render.FogMaxDensity(b.densite); render.FogColor(b.r, b.g, b.b)
  return true
end
hook.Add("SetupWorldFog", "atelier_film", function() return brouillard(1) end)
hook.Add("SetupSkyboxFog", "atelier_film", function(s) return brouillard(s) end)
hook.Add("PostDrawSkyBox", "atelier_film", function()
  local b = brouillard_actif(); if b then render.Clear(b.r, b.g, b.b, 255, true, false) end
end)
local function dessiner(self)
  local q = self.atelier; if not q then return self:DrawModel() end
  local p, rots, ech, alpha = pose(q.groupe, q.idx, q.pos, film_t)
  if alpha <= 0 then return end
  local A = Angle(q.ang.p, q.ang.y, q.ang.r)
  for _, r in ipairs(rots) do A:RotateAroundAxis(r[1]:GetNormalized(), r[2]) end
  self:SetRenderOrigin(origine + (p - TETE)); self:SetRenderAngles(A)
  if ech ~= 1 then local m = Matrix(); m:Scale(Vector(ech, ech, ech)); self:EnableMatrix("RenderMultiply", m) end
  local tc, plein = teinte(q.groupe, self.atelier_col or color_white, film_t)
  if tc then local c = self:GetColor(); if c.r ~= tc.r or c.g ~= tc.g or c.b ~= tc.b then self:SetColor(Color(tc.r, tc.g, tc.b, c.a)) end end
  if plein then render.SuppressEngineLighting(true) end
  if alpha < 1 then render.SetBlend(alpha) end
  self:DrawModel()
  if plein then render.SuppressEngineLighting(false) end
  if alpha < 1 then render.SetBlend(1) end
  if ech ~= 1 then self:DisableMatrix("RenderMultiply") end
  self:SetRenderOrigin(); self:SetRenderAngles()
end
local animes = {}
local function lier()                            -- retrouve chaque prop animé dans le dupe collé
  animes = {}; local n = 0
  for _, q in ipairs(PROPS) do
    local ou = origine + (q.pos - TETE)
    for _, e in ipairs(ents.FindInSphere(ou, 6)) do
      if IsValid(e) and not e.atelier and string.lower(e:GetModel() or "") == q.model then
        e.atelier = q; e.atelier_col = e:GetColor(); e.RenderOverride = dessiner; animes[#animes + 1] = e; n = n + 1; break
      end
    end
  end
  if #PROPS > 0 then print(("[Atelier] %d / %d props animés retrouvés dans le dupe"):format(n, #PROPS)) end
end
local function delier()
  for _, e in ipairs(animes) do if IsValid(e) then
    if e.atelier_col then e:SetColor(e.atelier_col) end
    e.RenderOverride = nil; e.atelier = nil; e.atelier_col = nil
  end end
  animes = {}
end

local function couper()
  for i = 1, (son_i or 1) - 1 do LocalPlayer():StopSound(SONS[i].son) end
  debut = nil; delier()
end
local function etat(t)          -- même règle que moteur/film.py et l'éditeur
  local d0 = 0
  for i, p in ipairs(PLANS) do
    local d = math.max(0, p.duree)
    if t < d0 + d then
      local u = d > 0 and (t - d0) / d or 1
      local q = p.glisse and PLANS[i + 1] or nil
      if not q then return p.pos, p.cible, p.fov, i end
      local e = p.doux and ease(u) or u
      return LerpVector(e, p.pos, q.pos), LerpVector(e, p.cible, q.cible), Lerp(e, p.fov, q.fov), i
    end
    d0 = d0 + d
  end
end

concommand.Add("atelier_film_origine", function(ply)
  local tr = ply:GetEyeTrace()
  if not IsValid(tr.Entity) then print("[Atelier] vise le prop de tête (sol) puis recommence") return end
  origine = tr.Entity:GetPos()
  print("[Atelier] origine posée sur " .. tr.Entity:GetModel())
end)
concommand.Add("atelier_film_jouer", function()
  if not origine then print("[Atelier] d'abord : atelier_film_origine en visant le prop de tête") return end
  debut = RealTime(); plan_aff = nil; son_i = 1; film_t = 0
  for _, x in ipairs(SONS) do x.fini = nil end
  if #PROPS > 0 then lier() end
end)
concommand.Add("atelier_film_stop", couper)

hook.Add("CalcView", "atelier_film", function(ply, p, a, fov)
  if not debut then return end
  local t = RealTime() - debut
  film_t = t
  local _, _, _, _, sec, vol = ecran(t)
  if vol < 0.5 and not silence then silence = true; for k = 1, son_i - 1 do LocalPlayer():StopSound(SONS[k].son) end end
  if vol >= 0.5 then silence = false end
  for k = 1, son_i - 1 do                         -- un son à durée s'arrête à son heure (avant les départs : même fichier relancé)
    local x = SONS[k]
    if x.duree > 0 and not x.fini and t >= x.t + x.duree then x.fini = true; LocalPlayer():StopSound(x.son) end
  end
  while SONS[son_i] and SONS[son_i].t <= t do      -- les sons partent à leur heure, joués partout (niveau 0), sauf pendant un silence
    if not silence then LocalPlayer():EmitSound(SONS[son_i].son, 0, SONS[son_i].ton or 100, SONS[son_i].volume, CHAN_STATIC) end
    son_i = son_i + 1
  end
  local pos, cible, f, i = etat(t)
  if not pos then debut = nil delier() print("[Atelier] fin du film") return end
  if sec > 0 then pos = pos + Vector(sec * math.sin(t * 53), sec * math.sin(t * 61), sec * math.sin(t * 47)) end
  if i ~= plan_aff then
    plan_aff = i
    local e = PLANS[i].etape
    print(("[Atelier] plan %d : %s (étape %d)%s"):format(i, PLANS[i].nom, e, ETAPES[e] and (" : " .. ETAPES[e]) or ""))
  end
  return {origin = origine + (pos - TETE), angles = (cible - pos):Angle(), fov = f, drawviewer = true}
end)
hook.Add("DrawOverlay", "atelier_film", function()
  if not debut then return end
  local r, g, b, al = ecran(film_t)
  if al > 0 then surface.SetDrawColor(r, g, b, al * 255); surface.DrawRect(0, 0, ScrW(), ScrH()) end
end)
hook.Add("RenderScreenspaceEffects", "atelier_film", function()
  if not debut then return end
  local c
  for _, e in ipairs(ECRAN) do if e.type == "etalonnage" and e.t <= film_t then c = e end end
  if not c then return end
  DrawColorModify({["$pp_colour_addr"] = c.ar, ["$pp_colour_addg"] = c.ag, ["$pp_colour_addb"] = c.ab,
    ["$pp_colour_brightness"] = c.lum, ["$pp_colour_contrast"] = c.contraste, ["$pp_colour_colour"] = c.saturation,
    ["$pp_colour_mulr"] = 0, ["$pp_colour_mulg"] = 0, ["$pp_colour_mulb"] = 0})
end)
hook.Add("HUDShouldDraw", "atelier_film", function() if debut then return false end end)
hook.Add("PreDrawViewModel", "atelier_film", function() if debut then return true end end)
print("[Atelier] film de « Segunda d'Azeno v14 » chargé : atelier_film_origine, puis atelier_film_jouer")
