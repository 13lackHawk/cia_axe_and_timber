axe_a = class({})

LinkLuaModifier("modifier_axe_counter", "abilities/axe/modifier_axe_counter", LUA_MODIFIER_MOTION_NONE)

function axe_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.Axe.CastA")

    return true
end

function axe_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local forward = self:GetDirection()
    local damage = self:GetDamage()
    local fukkenRage = hero:FindModifier("modifier_axe_rage")

    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(hero:GetPos(), 300),
        sound = "Arena.Axe.HitA",
        damagesTrees = true,
        action = function(target)
            local dmg = damage

            if fukkenRage then
                dmg = dmg * 2
            end

            target:Damage(hero, dmg, true)
        end,
        knockback = { force = 20, decrease = 3 },
        isPhysical = true
    })
end

function axe_a:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function axe_a:GetIntrinsicModifierName()
    return "modifier_axe_counter"
end

function axe_a:GetPlaybackRateOverride()
    return 1.75
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(axe_a, nil, "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf")