modifier_axe_rage = class({})

function modifier_axe_rage:GetTexture()
    return "axe_berserkers_call"
end

function modifier_axe_rage:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_axe_rage:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_axe_rage:StatusEffectPriority()
    return 2
end

function modifier_axe_rage:GetStatusEffectName()
    return "particles/status_fx/status_effect_overpower.vpcf"
end

function modifier_axe_rage:OnDamageReceived(source, _, amount)
    if amount > 1 then
        amount = amount - 1
    end
    return amount
end

function modifier_axe_rage:OnDamageReceivedPriority()
    return PRIORITY_POST_SHIELD_ACTION
end