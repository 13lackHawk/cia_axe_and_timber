axe_q = class({})

LinkLuaModifier("modifier_axe_q", "abilities/axe/modifier_axe_q", LUA_MODIFIER_MOTION_NONE)

function axe_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local hitSomething = false
    local damage = self:GetDamage()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1250,
        graphics = "particles/axe_q/axe_q.vpcf",
        distance = 950,
        damagesTrees = true,
        hitSound = "Arena.Axe.HitQ",
        hitParams = function(projectile, victim)
            return {
                ability = self,
                modifier = function(victim)
                    if instanceof(victim, Hero) then
                        victim:AddNewModifier(projectile:GetTrueHero(), self, "modifier_axe_q", { duration = 1.5 })
                    end
                end,
                damage = self:GetDamage(),
                action = function(victim)
                    if projectile.heroOverride or instanceof(victim, Projectile) then return end
                    local mod = hero:FindModifier("modifier_axe_counter")
                    if mod:GetStackCount() < 3 and not hero:FindModifier("modifier_axe_rage") then
                        mod:IncrementStackCount()
                    end
                end
            }
        end
    }):Activate()

    hero:EmitSound("Arena.Axe.CastQ")
end

function axe_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function axe_q:GetPlaybackRateOverride()
    return 1.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(axe_q)