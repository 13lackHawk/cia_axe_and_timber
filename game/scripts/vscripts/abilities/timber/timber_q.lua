timber_q = class({})
local self = timber_q

require("abilities/timber/projectile_timber_q")

function timber_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 900)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.Timber.CastQ")
    self.chakram = ProjectileTimberQ(hero.round, hero, target, self:GetDamage(), self):Activate()

    hero:SwapAbilities("timber_q", "timber_q_sub")
    hero:FindAbility("timber_q_sub"):StartCooldown(0.5)
end

function timber_q:GetChakram()
    return self.chakram
end

function timber_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function timber_q:GetPlaybackRateOverride()
    return 1.33
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(timber_q)