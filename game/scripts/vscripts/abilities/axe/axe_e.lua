axe_e = class({})

LinkLuaModifier("modifier_axe_e_animation", "abilities/axe/modifier_axe_e_animation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_axe_rage", "abilities/axe/modifier_axe_rage", LUA_MODIFIER_MOTION_NONE)

function axe_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600, 200)

    local hit = false
    local hero = self:GetCaster().hero
    local dir = self:GetDirection()
    local target = self:GetCursorPosition() * Vector(1, 1, 0)
    local distance = (target - hero:GetPos()):Length2D()
    hero:GetUnit():Interrupt()
    hero:SetFacing(dir)

    hero:EmitSound("Arena.Axe.CastE")
    local maxHeight = (hero:GetPos() - target + 200 * dir):Length2D() / 4.8

    FunctionDash(hero, target - 200 * dir, 0.35, {
        noFixedDuration = true,
        heightFunction = function(dash, current)
            local d = (dash.from - dash.to):Length2D()
            local x = (dash.from - current):Length2D()

            print(maxHeight)

            return ParabolaZ(maxHeight, d, x)
        end,
        arrivalFunction = function()
            FX("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, hero, {
                cp0 = target,
                cp1 = Vector(300, 1, 1),
                cp2 = target,
                cp3 = target,
                release = true
            })

            hero:AreaEffect({
                ability = self,
                filter = Filters.Area(target, 200),
                damage = self:GetDamage(),
                knockback = { force = 50, decrease = 5 },
                action = function(victim)
                    if instanceof(victim, UnitEntity) then
                        hit = true
                    end
                end
            })
            local mod = hero:FindModifier("modifier_axe_counter")
            if hit then
                if mod:GetStackCount() < 3 and not hero:FindModifier("modifier_axe_rage") then
                    mod:IncrementStackCount()
                end
            end

            hero:EmitSound("Arena.LC.HitQ")

            ScreenShake(target, 45 * 40, 45 * 40, 0.15, 1800, 0, true)
            Spells:GroundDamage(target, 200, hero)
        end,
        modifier = { name = "modifier_axe_e_animation", ability = self },
    })

    hero:Animate(ACT_DOTA_CAST_ABILITY_4, 1.2)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(axe_e)