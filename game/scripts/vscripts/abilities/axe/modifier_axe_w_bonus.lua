modifier_axe_w_bonus = class({})

function modifier_axe_w_bonus:IsInvulnerable()
    return true
end

function modifier_axe_w_bonus:GetEffectName()
    return "particles/axe_w/axe_w.vpcf"
end

function modifier_axe_w_bonus:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end