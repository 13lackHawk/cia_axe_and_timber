modifier_timber_w = class({})
local self = modifier_timber_w
self.targets = {}

if IsServer() then
    function self:OnCreated() 
        self.targets[self:GetParent():GetParentEntity()] = true
    end

    function self:OnDestroy()
        local hero = self:GetParent():GetParentEntity()
        hero:FindAbility("timber_a"):SetActivated(true)
        
        self.targets[self:GetParent():GetParentEntity()] = nil
    end
end

function self:GetEffectName()
    return "particles/items_fx/blademail.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

function self:OnDamageReceived(source, hero, amount)
    if not self.soundPlayed then
        hero:EmitSound("Arena.Timber.ProcW")
        self.soundPlayed = true
    end

    if source.hero then source = source.hero end

    if source:FindModifier("modifier_timber_w") then
        if not self.damageSource and source.owner.team ~= hero.owner.team and amount > 0 then
            source:FindModifier("modifier_timber_w").damageSource = true
            source:Damage(hero, amount)
            return amount
        end
    else
        self.damageSource = false
        source:Damage(hero, amount)
        return amount
    end
    
    return amount
end

function self:OnDamageReceivedPriority()
    return PRIORITY_ABSOLUTE_SHIELD
end
