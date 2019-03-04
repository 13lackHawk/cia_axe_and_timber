modifier_axe_w_dmg= class({})
local self = modifier_axe_w_dmg

function self:GetDmg(source, amount, type, ability)
    self.delayedDamage = { source = source, amount = amount, type = type, ability = ability }
    return amount
end

if IsServer() then
    function self:OnDestroy()
        local hero = self:GetCaster():GetParentEntity()
        self.delayedDamage.source:EffectToTarget(hero, {
            ability = self.delayedDamage.ability,
            damage = self.delayedDamage.amount,
            isPhysical = self.delayedDamage.type,
            damageAmplifies = false
        })
    end
end