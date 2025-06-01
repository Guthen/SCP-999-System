local revscp999 = guthscp.modules.revscp999
local config999 = guthscp.configs.revscp999

hook.Add("SetupMove", "revscp999:no_move", function(ply, mv, cmd)
    if not revscp999.is_scp_999(ply) then return end
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return end

    if guthscp.configs.revscp999.disable_jump then
        mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
    end
end)

-- Hook pour gérer les dégâts des SCP-999
hook.Add("PlayerShouldTakeDamage", "revscp999:no_damage", function(ply)
    if config999.scp999_immortal and revscp999.is_scp_999(ply) then
        return false
    end
end)