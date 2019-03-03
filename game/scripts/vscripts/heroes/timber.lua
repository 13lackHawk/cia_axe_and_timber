Timber = class({}, {}, Hero)

LinkLuaModifier("modifier_timber_heal_to_shield", "abilities/timber/modifier_timber_heal_to_shield", LUA_MODIFIER_MOTION_NONE)

function Timber:SetOwner(owner)
    getbase(Timber).SetOwner(self, owner)

    self:AddNewModifier(self, nil, "modifier_timber_heal_to_shield", {})
    self:AddNewModifier(self, self:FindAbility("timber_r"), "modifier_charges", {
    	max_count = 2,
    	replenish_time = 7
    })
end