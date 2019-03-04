gyro_a = class({})
local self = gyro_a

LinkLuaModifier("modifier_gyro_a_slow", "abilities/gyro/modifier_gyro_a_slow", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1500,
        graphics = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile.vpcf",
        distance = 750,
        hitSound = "Arena.Gyro.HitA",
        damagesTrees = true,
        screenShake = { 5, 150, 0.25, 1500, 0, true },
        hitParams = function(projectile, victim)
            return {
                damage = function(target)
                    local mod = target:FindModifier("modifier_gyro_a_slow")
                    local stacks = 0
                    if mod then stacks = mod:GetStackCount() end

                    if stacks >= 2 then 
                        return self:GetDamage() * 2 
                    else return self:GetDamage() end
                end,
                modifier = function(victim)
                    local modifier = victim:FindModifier("modifier_gyro_a_slow")
                    if not modifier then
                        modifier = victim:AddNewModifier(projectile:GetTrueHero(), self, "modifier_gyro_a_slow", { duration = 3 })

                        if modifier then
                            modifier:SetStackCount(1)
                        end
                    else
                        modifier:IncrementStackCount()
                        modifier:ForceRefresh()

                        if modifier:GetStackCount() == 3 then
                            victim:EmitSound("Arena.Gyro.HitA2")
                            modifier:Destroy()
                        end
                    end
                end,
                notBlockedAction = function(target)
                    FX("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN, victim, {
                        cp0 = projectile:GetPos(),
                        release = true
                    })
                end
            }
        end
    }):Activate()

    --SoftKnockback(hero, hero, (hero:GetPos() - target):Normalized(), 20, { decrease = 2 })
    hero:EmitSound("Arena.Gyro.CastA")
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function self:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(self)