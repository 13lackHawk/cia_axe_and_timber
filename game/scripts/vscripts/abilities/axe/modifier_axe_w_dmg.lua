modifier_axe_w_dmg = class({})
local self = modifier_axe_w_dmg

if IsServer() then
    function self:OnDestroy()
        local hero = self:GetCaster():GetParentEntity()
        local hp = hero:GetHealth()

        if self.damage >= hp then
            self.damage = 0
        end

        self.damageSource:EffectToTarget(hero, {
            ability = self.sourceAbility,
            damage = self.damage,
            isPhysical = self.isPhysical,
            damageAmplifies = false
        })
    end
end