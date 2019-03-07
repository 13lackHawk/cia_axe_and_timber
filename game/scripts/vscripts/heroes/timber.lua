Timber = class({}, {}, Hero)

LinkLuaModifier("modifier_shield", "abilities/timber/modifier_shield", LUA_MODIFIER_MOTION_NONE)

function Timber:SetOwner(owner)
    getbase(Timber).SetOwner(self, owner)

    self:AddNewModifier(self, self:FindAbility("timber_r"), "modifier_charges", {
    	max_count = 2,
    	replenish_time = 7
    })
end

function Timber:Heal(amount)
    local modifierShield = self.unit:FindModifierByName("modifier_shield")

    if self.unit:IsAlive() then
        if not modifierShield then
            modifierShield = self.unit:AddNewModifier(self.unit, nil, "modifier_shield", {})
        end

        if modifierShield then
            modifierShield:SetStackCount(math.min(modifierShield:GetStackCount() + amount, 10))
            modifierShield:ForceRefresh()
        end

        FX("particles/msg_damage.vpcf", PATTACH_CUSTOMORIGIN, GameRules:GetGameModeEntity(), {
            cp0 = self:GetPos(),
            cp1 = Vector(0, amount, 0),
            cp2 = Vector(math.max(1, amount / 1.5), 1, 0),
            cp3 = Vector(201, 201, 3),
            release = true
        })
    end
end