modifier_axe_counter = class({})

function modifier_axe_counter:GetTexture()
    return "axe_berserkers_call"
end

if IsServer() then
    function modifier_axe_counter:OnCreated()
    	local hero = self:GetParent()
    	self:StartIntervalThink(0.01)
        self:OnIntervalThink()
    end

    function modifier_axe_counter:OnIntervalThink()
    	local hero = self:GetParent()
        if self:GetStackCount() == 3 then
        	hero:EmitSound("Arena.Axe.Rage.Voice")
            hero:AddNewModifier(hero, self, "modifier_axe_rage", { duration = 5 })
            self:SetStackCount(0)
        end
    end
end