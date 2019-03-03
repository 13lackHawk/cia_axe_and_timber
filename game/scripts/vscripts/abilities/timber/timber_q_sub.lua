timber_q_sub = class({})
local self = timber_q_sub

function timber_q_sub:OnSpellStart()
    self.hero = self:GetCaster().hero

    self.chakram = self.hero:FindAbility("timber_q"):GetChakram()
    self.chakram:Retract()
    self.hero:SwapAbilities("timber_q_sub", "timber_q")
    self.hero:FindAbility("timber_q"):StartCooldown(self.hero:FindAbility("timber_q"):GetCooldown(1))
    if self.hero:HasModifier("modifier_timber_q_recast") then
        self.hero:RemoveModifier("modifier_timber_q_recast")
    end
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(timber_q_sub)