axe_r = class({})

LinkLuaModifier("modifier_axe_r", "abilities/axe/modifier_axe_r", LUA_MODIFIER_MOTION_NONE)

require("abilities/axe/projectile_axe_r")

function axe_r:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.WK.PreR")
    self:GetCaster().hero:EmitSound("Arena.Axe.CastR.Voice")

    return true
end

function axe_r:OnChannelThink(interval)
    self.time = (self.time or 0) + interval

    local hero = self:GetCaster():GetParentEntity()
    local pos = hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, math.sin(self.time / 0.5 * 3.14) * 250) --interval * Vector(0, 0, self.speed)
    hero:SetPos(pos)
end

function axe_r:OnChannelFinish(interrupted)
    self.time = nil

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:SetPos(hero:GetPos() * Vector(1, 1, 0))

    if interrupted then
        hero:StopSound("Arena.WK.PreR")
        return
    end

    local direction = ((target - hero:GetPos()) * Vector(1,1,0)):Normalized()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    ProjectileAxeR(hero.round, hero, target, self, 256):Activate()

    hero:EmitSound("Arena.Axe.CastR")
    hero:EmitSound("Arena.Axe.CastR.Loop")
end

function axe_r:GetChannelTime()
    return 0.5
end

function axe_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function axe_r:GetPlaybackRateOverride()
    return 0.8
end

if IsServer() then
    Wrappers.GuidedAbility(axe_r, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(axe_r)