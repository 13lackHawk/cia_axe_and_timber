modifier_timber_w = class({})
local self = modifier_timber_w

if IsServer() then

    function self:OnDestroy()
        local hero = self:GetParent():GetParentEntity()
        hero:FindAbility("timber_a"):SetActivated(true)
    end
end

function self:GetEffectName()
    return "particles/items_fx/blademail.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

function self:AllowAbilityEffect(source, ability, data)
    local damage = 0
    local phys
    local hero = self:GetParent():GetParentEntity()

    if data and data.damage then 
        damage = data.damage.count 
        phys = data.damage.type
    end

    if source.owner.team == hero.owner.team or damage <= 0 then return end

    hero:EffectToTarget(source, {
        ability = self:GetAbility(),
        damage = damage,
        isPhysical = phys,
        dealDamage = false,
        ignoreAllowAbilityCheck = true,
        action = function(target)
            local target = target.hero or target
            local amplifiedDamage = target:CalculateDamage(hero, damage, phys)
            local resultAction = { damage = { count = amplifiedDamage, type = phys, real = damage }, action = function() end }

            for _, modifier in pairs(target:AllModifiers()) do
                if modifier.AllowAbilityEffect and modifier:GetName() ~= self:GetName() then
                    local val = modifier:AllowAbilityEffect(hero, self:GetAbility(), resultAction)

                    if val == false then
                        resultAction = {}
                    elseif type(val) == "table" then
                        resultAction = val
                    end
                end
            end

            if resultAction.damage and resultAction.damage.count > 0 and not target:IsInvulnerable() then
                target:Damage(hero, amplifiedDamage, resultAction.damage.type, false)
            end
        end
    })
end