cm_a = class({})

LinkLuaModifier("modifier_cm_a", "abilities/cm/modifier_cm_a", LUA_MODIFIER_MOTION_NONE)

function cm_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local mod = hero:FindModifier("modifier_cm_a")
    local graphics = "particles/cm_a/cm_a.vpcf"
    local empowered

    if mod and mod:GetStackCount() == 3 then
        graphics = "particles/cm_a/cm_a_empowered.vpcf"
        empowered = true

        mod:Destroy()
    end

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 96),
        to = target + Vector(0, 0, 96),
        damage = self:GetDamage(),
        speed = 1250,
        radius = 48,
        graphics = graphics,
        distance = 900,
        hitParams = function(projectile, target)
            local modifier

            if empowered then
                modifier = function(target)
                    if CMUtil.IsFrozen(target) then
                        CMUtil.Stun(projectile:GetTrueHero(), target, self)
                    end

                    CMUtil.Freeze(projectile:GetTrueHero(), target, self)
                end
            end

            return {
                damage = self:GetDamage(),
                modifier = modifier
            }
        end,
        hitSound = "Arena.CM.HitA",
        isPhysical = true
    }):Activate()

    hero:EmitSound("Arena.CM.CastA")
end

function cm_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function cm_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(cm_a)