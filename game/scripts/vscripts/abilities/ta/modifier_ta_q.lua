modifier_ta_q = class({})

function modifier_ta_q:IsDebuff()
    return true
end

function modifier_ta_q:GetEffectName()
    return "particles/ta_w/ta_w_debuff.vpcf"
end

function modifier_ta_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ta_q:GetDamageChange(_, _, amount, isPhysical)
    if isPhysical then
        return 1
    end
end

function modifier_ta_q:GetDamageChangePriority()
    return PRIORITY_AMPLIFY_DAMAGE
end