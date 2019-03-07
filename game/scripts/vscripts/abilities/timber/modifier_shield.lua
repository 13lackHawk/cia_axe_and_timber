modifier_shield = class({})

local self = modifier_shield

function self:GetTexture()
    return "rattletrap_power_cogs"
end

function self:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function self:OnDamageReceived(_, _, amount)
    self:SetStackCount(self:GetStackCount() - amount)

    if self:GetStackCount() <= 0 then
        self:Destroy()
    end

    if self:GetStackCount() < 0 then
        return -self:GetStackCount()
    end

    return false
end

function self:OnDamageReceivedPriority()
    return PRIORITY_SHIELD
end

if IsServer() then
    function self:OnCreated()
        self:StartIntervalThink(0.01)
    end

    function self:OnIntervalThink()
        local hero = self:GetParent():GetParentEntity()
        local particle

        if self:GetStackCount() <= 2 then
            particle = "particles/timber_shield/shredder_armor_lyr1.vpcf"
        end

        if self:GetStackCount() > 2 then
            particle = "particles/timber_shield/shredder_armor_2.vpcf"
        end

        if self:GetStackCount() > 3 then
            particle = "particles/timber_shield/shredder_armor_3.vpcf"
        end

        if self:GetStackCount() > 4 then
            particle = "particles/timber_shield/shredder_armor_4.vpcf"
        end

        if self.index ~= nil and self.cached ~= particle then
            ParticleManager:DestroyParticle(self.index, false)
            ParticleManager:ReleaseParticleIndex(self.index)
            self.index = nil
            self.cached = nil
        end

        if particle and not self.cached then
            self.index = FX(particle, PATTACH_ABSORIGIN_FOLLOW, hero, {
                cp0 = { ent = hero:GetUnit(), point = "attach_armor" },
                cp1 = { ent = hero:GetUnit(), point = "attach_chimmney" }
            })
            self.cached = particle
        end
    end

    function self:OnDestroy()
        if self.index then
            ParticleManager:DestroyParticle(self.index, false)
            ParticleManager:ReleaseParticleIndex(self.index)
        end
    end
end
