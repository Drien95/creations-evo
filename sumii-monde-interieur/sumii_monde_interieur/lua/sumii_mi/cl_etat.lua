-- Réception de l'état et aides du MJ côté client (numéros des terriers, diagnostic). Aucun message à l'écran.
local C, Q, N, T = SumiiMI.config, SumiiMI.sequence, SumiiMI.reseau, SumiiMI.terriers
local A, K = SumiiAncre, SumiiNoyau
local etat = { S = Q.neuf(0), mj = false, cible = 0, arrancar = 0, numeros = false }
SumiiScene = etat

net.Receive("sumii_mi_etat", function()
	etat.S = N.lire(net, Q)
	etat.cible, etat.arrancar, etat.mj = net.ReadUInt(16), net.ReadUInt(16), net.ReadBool()
	K.rallumer()
end)
net.Receive("sumii_mi_tout", function()
	etat.S, etat.numeros = Q.neuf(0), false
	hook.Remove("HUDPaint", "sumii_mi_numeros")
	K.eteindreTout()
	A.oublier()
end)
hook.Add("InitPostEntity", "sumii_mi_demande", function()
	net.Start("sumii_mi_demande")
	net.SendToServer()
end)

local function bouche(t) return A.versMonde(Vector(t.x + t.fx * 26, t.y + t.fy * 26, 60)) end
local function dessinerNumeros()
	if not etat.mj or not A.tete() then return end
	for n, t in ipairs(T) do
		local e = bouche(t):ToScreen()
		if e.visible then draw.SimpleTextOutlined(tostring(n), "DermaLarge", e.x, e.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black) end
	end
end
-- visibles du seul MJ qui l'a tapée
concommand.Add("sumii_numeros", function()
	if not etat.mj then print("[sumii] réservé au MJ (tape d'abord sumii_etat)") return end
	etat.numeros = not etat.numeros
	if etat.numeros then hook.Add("HUDPaint", "sumii_mi_numeros", dessinerNumeros)
	else hook.Remove("HUDPaint", "sumii_mi_numeros") end
	print("[sumii] numéros " .. (etat.numeros and "affichés" or "masqués"))
end)
concommand.Add("sumii_diag", function()
	local n, total = K.hooksActifs()
	if not A.tete() then print("[sumii] aucun build, " .. (n == 0 and "rien d'actif" or (n .. " hooks encore actifs"))) return end
	print(string.format("[sumii] repère trouvé · hooks %d/%d · temps %d · version %d · dans la boîte : %s",
		n, total, etat.S.i, etat.S.v, tostring(A.dedans(EyePos()))))
end)
