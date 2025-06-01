if not guthscp then
    error("guthscp999 - fatal error! https://github.com/Guthen/guthscpbase must be installé sur le serveur!")
    return
end

if not scp999 then scp999 = {} end
local revscp999 = guthscp.modules.revscp999
local config999 = guthscp.configs.revscp999

SWEP.Author = "RevanAngel"
SWEP.PrintName = "SCP-999"
SWEP.Instructions = config999.translation_1
SWEP.Category = "GuthSCP"

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.Weight = 1
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = Model("")
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.AdminOnly = false

playerCooldowns = playerCooldowns or {}
playerSoundCooldowns = playerSoundCooldowns or {}

local function HealTarget(self, target)
    if not IsValid(target) then return end
    if not (target:IsPlayer() or target:IsNPC()) then return end
    if not config999.scp999_heal then return end

    if revscp999 and revscp999.is_scp_049_zombie and revscp999.is_scp_049_zombie(target) then
        guthscp.player_message(self.Owner, config999.translation_5)
        return
    end

    local ignoreSCPs = guthscp.configs.revscp999.ignore_scps
    if ignoreSCPs and guthscp.is_scp and guthscp.is_scp(target) then
        return
    end

    local ignoreTeams = guthscp.configs.revscp999.ignore_teams
    local targetTeam = target:Team()
    local teamKeyName = guthscp.get_team_keyname and guthscp.get_team_keyname(targetTeam) or nil
    if teamKeyName and ignoreTeams and ignoreTeams[teamKeyName] then
        return
    end

    if not self.LastHealTime then
        self.LastHealTime = 0
    end

    local healTime = (guthscp and guthscp.configs and guthscp.configs.revscp999 and guthscp.configs.revscp999.heal_time) or 2

    if CurTime() > self.LastHealTime + healTime then
        local maxHealth = target:GetMaxHealth() or 100
        local curHealth = target:Health()

        if curHealth < maxHealth then
            local healAmount = (guthscp and guthscp.configs and guthscp.configs.revscp999 and guthscp.configs.revscp999.heal_number) or 1
            target:SetHealth(math.min(curHealth + healAmount, maxHealth))

            if not self.soundcd then
                self.soundcd = 1
            end

            if self.soundcd <= 0 then
                self.Owner:EmitSound('buttons/blip1.wav', 75, (20 + target:Health() / maxHealth * 105))
                self.soundcd = 2
            else
                self.soundcd = self.soundcd - 1
            end

            self.LastHealTime = CurTime()
        end
    end
end

function SWEP:Initialize()
    self:SetHoldType("none")
end

function SWEP:Think()
    if not IsValid(self.Owner) then return end
    if not self.Owner:Alive() then return end

    if not config999.scp999_heal then return end

    if self.Owner:KeyDown(IN_ATTACK2) then
        local trace = self.Owner:GetEyeTrace()
        local target = trace.Entity
        HealTarget(self, target)
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.5)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if not config999.scp999_heal then return end  -- vérification OK

    local trace = owner:GetEyeTrace()
    local target = trace.Entity
    HealTarget(self, target)
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:Equip(newOwner)
    if not newOwner:IsPlayer() then return end
    newOwner:SetNW2Bool("REVSCP.999", true)

    local sounds = config999.random_sound
    if not sounds or #sounds == 0 then return end

    timer.Create("REVSCP.999Sounds." .. newOwner:SteamID64(), 30, 0, function()
        if IsValid(newOwner) and newOwner:HasWeapon("revscp_999") then
            newOwner:EmitSound(sounds[math.random(#sounds)], 75, 100, 0.5)
        else
            timer.Remove("REVSCP.999Sounds." .. newOwner:SteamID64())
        end
    end)
end

if SERVER then
    hook.Add("PlayerSpawn", "REVSCP.Reset999", function(pPlayer)
        if pPlayer:GetNW2Bool("REVSCP.999") == true then
            pPlayer:SetModelScale(1, 0)
            pPlayer:ResetHull()
        end
    end)
end

hook.Add("PlayerDeath", "REVSCP.Cleanup999", function(victim, _, _)
    if victim:GetNW2Bool("REVSCP.999") == true then
        victim:SetNW2Bool("REVSCP.999", false)

        -- Réinitialise la taille
        victim:SetModelScale(1, 0)

        -- Réinitialise la hull et la vue
        victim:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72))
        victim:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 36))
        victim:SetViewOffset(Vector(0, 0, 64))
        victim:SetViewOffsetDucked(Vector(0, 0, 28))

        -- Nettoie le timer de sons
        timer.Remove("REVSCP.999Sounds." .. victim:SteamID64())

        -- Nettoie les cooldowns
        local sid = victim:SteamID()
        playerCooldowns[sid] = nil
        playerSoundCooldowns[sid] = nil
    end
end)

if CLIENT then
    guthscp.spawnmenu.add_weapon(SWEP, "SCPs")
end