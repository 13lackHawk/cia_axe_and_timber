modifier_axe_w_dmg= class({})
local self = modifier_axe_w_dmg

function self:GetDmg(source, amount, type)
    self.delayedDamage = { source = source, amount = amount, type = type }
    return amount
end

if IsServer() then
    function self:OnDestroy()
        local hero = self:GetCaster():GetParentEntity()
        hero:Damage(self.delayedDamage.source, self.delayedDamage.amount, self.delayedDamage.type, { ignoreModifiers = { 
            ["modifier_pa_q"] = true, 
            ["modifier_invoker_w"] = true,
            ["modifier_pudge_r"] = true, 
            ["modifier_ta_q"] = true, 
            ["modifier_venge_r_target"] = true, 
            ["modifier_venge_w"] = true,
            ["modifier_axe_w"] = true },
            ignoreInvulnerable = true
        })
    end
end