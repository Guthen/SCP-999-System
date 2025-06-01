local revscp999 = guthscp.modules.revscp999
local config999 = guthscp.configs.revscp999
scp999 = scp999 or {}

function revscp999.is_scp_999(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    return ply:GetNW2Bool("REVSCP.999", false)
end

revscp999.filter = guthscp.players_filter:new("revscp999")

if SERVER then
    revscp999.filter:listen_disconnect()
    revscp999.filter:listen_weapon_users("revscp999")

    revscp999.filter.event_removed:add_listener("revscp999:reset", function(ply)
    end)
end

function revscp999.get_scps_999()
    return revscp999.filter:get_entities()
end