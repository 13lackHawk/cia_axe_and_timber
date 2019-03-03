modifier_axe_r = class({})

function modifier_axe_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_axe_r:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function modifier_axe_r:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

function modifier_axe_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end