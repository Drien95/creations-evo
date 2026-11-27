-- Écriture et lecture de l'état partagé, octet par octet (pas de WriteTable). Q = séquenceur, n = librairie net.
local N = {}
local MODES = { "vide", "bruit", "rien" }
local CODE = { vide = 1, bruit = 2, rien = 3 }

function N.ecrire(n, Q, S)
	n.WriteUInt(S.v, 32)
	n.WriteUInt(S.i, 8)
	for k = 0, #Q.SEQ do                                     -- 0 : instant de la reconstruction
		local t = S.inst[k == 0 and "reconstruire" or Q.SEQ[k].cle]
		n.WriteBool(t ~= nil)
		if t then n.WriteFloat(t) end
	end
	n.WriteUInt(S.revele or 0, 4)
	n.WriteBool(S.lieu ~= nil)                               -- où elle était à la détresse (repère du build)
	if S.lieu then for k = 1, 3 do n.WriteFloat(S.lieu[k]) end end
	for k = 1, Q.NB_TERRIERS do
		local f = S.terriers[k]
		n.WriteUInt(f and CODE[f.mode] or 0, 2)
		if f then n.WriteFloat(f.t0) end
	end
end

function N.lire(n, Q)
	local S = Q.neuf(n.ReadUInt(32))
	S.i = n.ReadUInt(8)
	for k = 0, #Q.SEQ do
		if n.ReadBool() then S.inst[k == 0 and "reconstruire" or Q.SEQ[k].cle] = n.ReadFloat() end
	end
	local r = n.ReadUInt(4)
	S.revele = r > 0 and r or nil
	if n.ReadBool() then S.lieu = { n.ReadFloat(), n.ReadFloat(), n.ReadFloat() } end
	for k = 1, Q.NB_TERRIERS do
		local m = n.ReadUInt(2)
		if m > 0 then S.terriers[k] = { mode = MODES[m], t0 = n.ReadFloat() } end
	end
	return S
end

return N
