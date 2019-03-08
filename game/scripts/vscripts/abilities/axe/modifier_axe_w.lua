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
    local caster = self:GetCaster():GetParentEntity()
    
    if data and data.damage then
        local damage = data.damage.count
        caster:AddNewModifier(caster, caster:FindAbility("axe_w"), "modifier_axe_w_dmg", { duration = 2.5 }):GetDmg(source, damage, data.damage.type, ability)
        self.damageReceived = damage
        self:Destroy()

        return false
    end
end

if IsServer() then
    function self:OnDestroy()
        local ability = self:GetAbility()
        local hero = self:GetCaster():GetParentEntity()

        if self.damageReceived then
            local duration = 0.5 + (self.damageReceived / 2)
            self:GetParent():GetParentEntity():EmitSound("Arena.Axe.ProcW")
            hero:AddNewModifier(hero, hero:FindAbility("axe_w"), "modifier_axe_w_bonus", { duration = duration })

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
        else
            self:GetParent():GetParentEntity():EmitSound("Arena.Axe.EndW")
        end
    end
end