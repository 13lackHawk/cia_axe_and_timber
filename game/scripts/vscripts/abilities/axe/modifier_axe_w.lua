modifier_axe_w = class({})
local self = modifier_axe_w

function self:GetEffectName()
    return "particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function self:StatusEffectPriority()
    return 1
end

function self:GetStatusEffectName()
    return "particles/status_fx/status_effect_battle_hunger.vpcf"
end

function self:AllowAbilityEffect(source, ability, data)
    local hero = self:GetParent():GetParentEntity()
    
    if data and data.damage then
        local damage = data.damage.count
        if damage > 0 then
            local invulDuration = 0.5 + (damage / 2)
            local modifier = hero:AddNewModifier(hero, hero:FindAbility("axe_w"), "modifier_axe_w_dmg", { duration = math.max(2.5, invulDuration)})
            modifier.damageSource = source
            modifier.isPhysical = data.damage.type
            modifier.damage = damage
            modifier.sourceAbility = ability

            hero:EmitSound("Arena.Axe.ProcW")
            hero:AddNewModifier(hero, hero:FindAbility("axe_w"), "modifier_axe_w_bonus", { duration = invulDuration })

            FX("particles/axe_w/axe_w_explosion.vpcf", PATTACH_WORLDORIGIN, hero, {
                cp0 = self:GetParent():GetAbsOrigin(),
                cp1 = Vector(300, 1, 1),
                cp0 = self:GetParent():GetAbsOrigin(),
                release = true
            })

            local mod = hero:FindModifier("modifier_axe_counter")
            if mod:GetStackCount() < 3 and not hero:FindModifier("modifier_axe_rage") then
                mod:IncrementStackCount()
            end

            self.activated = true
            self:Destroy()

            return false
        end
    end
end

if IsServer() then
    function self:OnDestroy()
        if not self.activated then
            self:GetParent():GetParentEntity():EmitSound("Arena.Axe.EndW")
        end
    end
end