modifier_axe_e_animation = class({})

if IsServer() then
    function modifier_axe_e_animation:OnCreated()
        local index = ParticleManager:CreateParticle("particles/econ/courier/courier_dc/dccourier_devil_flame_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_axe_head", self:GetParent():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

        local index = ParticleManager:CreateParticle("particles/axe_e/axe_e_trail2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_axe_head", self:GetParent():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

    end
end

function modifier_axe_e_animation:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function modifier_axe_e_animation:Airborne()
    return true
end

function modifier_axe_e_animation:IsHidden()
    return true
end
