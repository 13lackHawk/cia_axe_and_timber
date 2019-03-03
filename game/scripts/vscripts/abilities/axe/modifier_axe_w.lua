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

function self:OnDamageReceived(source, hero, amount, type)
    local caster = self:GetCaster():GetParentEntity()
    caster:AddNewModifier(caster, caster:FindAbility("axe_w"), "modifier_axe_w_dmg", { duration = 2.5 }):GetDmg(source, amount, type)
    self.damageReceived = amount
    self:Destroy()
    return false
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
        else
            self:GetParent():GetParentEntity():EmitSound("Arena.Axe.EndW")
            local mod = hero:FindModifier("modifier_axe_counter")
            if mod:GetStackCount() < 3 and not hero:FindModifier("modifier_axe_rage") then
                mod:IncrementStackCount()
            end
        end
    end
end