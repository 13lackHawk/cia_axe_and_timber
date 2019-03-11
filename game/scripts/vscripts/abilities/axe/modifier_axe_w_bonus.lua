modifier_axe_w_bonus = class({})

function modifier_axe_w_bonus:AllowAbilityEffect(source)
    return source.owner.team == self:GetParent():GetParentEntity().owner.team
end

function modifier_axe_w_bonus:GetEffectName()
    return "particles/axe_w/axe_w.vpcf"
end

function modifier_axe_w_bonus:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end