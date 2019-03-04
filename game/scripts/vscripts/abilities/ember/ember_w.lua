ember_w = class({})
LinkLuaModifier("modifier_ember_w", "abilities/ember/modifier_ember_w", LUA_MODIFIER_MOTION_NONE)

function ember_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local trueHero = hero.hero or hero
    local ability = trueHero:FindAbility("ember_w")
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = ability,
        owner = trueHero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/ember_w/ember_w.vpcf",
        distance = 1050,
        hitSound = "Arena.Ember.HitW",
        hitParams = function(projectile, target)
            return {
                damage = function(target)
                    if EmberUtil.IsBurning(target) then
                        target:Damage(projectile, ability:GetDamage())
                    end
                end,
                modifier = function(target)
                    EmberUtil.Burn(projectile:GetTrueHero(), target, ability)

                    target:AddNewModifier(projectile:GetTrueHero(), ability, "modifier_ember_w", { duration = 1.0 })
                end
            }
        end,
        destroyFunction = function()
            hero:StopSound("Arena.Ember.CastW")
        end
    }):Activate()

    hero:EmitSound("Arena.Ember.CastW")
end

function ember_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function ember_w:GetPlaybackRateOverride()
    return 1.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ember_w)