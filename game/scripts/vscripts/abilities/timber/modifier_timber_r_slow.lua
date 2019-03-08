modifier_timber_r_slow = class({})
local self = modifier_timber_r_slow

if IsServer() then
	function self:OnCreated()
		local index = FX("particles/timber_r/timber_r_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
			cp3 = { ent = self:GetParent() },
			cp2 = { ent = self:GetParent() },
			cp0 = { ent = self:GetParent() }
		})
		self:AddParticle(index, false, false, -1, false, false)
	end
end

function self:GetTexture()
	return "arc_warden_flux"
end

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function self:IsDebuff()
    return true
end

function self:GetModifierMoveSpeedBonus_Percentage(params)
    return -30 - 10 * self:GetStackCount()
end

function self:StatusEffectPriority()
    return 2
end