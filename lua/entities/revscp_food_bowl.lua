if not guthscp then
    error("guthscp999 - fatal error! https://github.com/Guthen/guthscpbase must be installed on le serveur!")
    return
end

if not scp999 then scp999 = {} end
local revscp999 = guthscp.modules.revscp999
local config999 = guthscp.configs.revscp999

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Food Bowl"
ENT.Author = "RevanAngel"
ENT.Category = "GuthSCP"
ENT.Spawnable = true

ENT.MaxScale = 2.5

function ENT:Initialize()
    if SERVER then
        self:SetModel(config999.food_model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then phys:Wake() end

        self.GrowthAmount = config999.growamount
        self.Cooldown = config999.food_cooldown
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if not revscp999.is_scp_999(activator) then return end

    if activator._revscp999_next_use and activator._revscp999_next_use > CurTime() then return end
    activator._revscp999_next_use = CurTime() + (self.Cooldown or 5)

    local currentScale = activator:GetModelScale()
    local newScale = currentScale + (self.GrowthAmount or 0.1)
    if newScale > self.MaxScale then return end

    activator:SetModelScale(newScale, 1)

    if config999.enable_hull_view_update then
        local height = 72 * newScale
        local duckHeight = 36 * newScale
        activator:SetHull(Vector(-16, -16, 0), Vector(16, 16, height))
        activator:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, duckHeight))
        activator:SetViewOffset(Vector(0, 0, height))
        activator:SetViewOffsetDucked(Vector(0, 0, duckHeight))
    end

    guthscp.player_message(activator, config999.translation_2)
    activator:EmitSound("items/battery_pickup.wav", 75, 100)
end

if CLIENT then
    list.Set("SpawnableEntities", "revscp_food_bowl", {
        PrintName = "Food Bowl",
        ClassName = "revscp_food_bowl",
        Category = "GuthSCP"
    })
end