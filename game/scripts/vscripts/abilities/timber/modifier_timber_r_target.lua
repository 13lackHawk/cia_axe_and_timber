modifier_timber_r_target = class({})
local self = modifier_timber_r_target

if IsServer() then
    function self:OnCreated()
        self:CreateParticle()
        self:StartIntervalThink(1.0)
    end

    function self:OnIntervalThink()
        self:CreateParticle()

        local parent = self:GetParent():GetParentEntity()
        local caster = self:GetCaster():GetParentEntity()
        
        self:GetCaster():GetParentEntity():EffectToTarget(parent, {
            ability = self:GetAbility(),
            damage = 1,
            modifier = function(target)
                local mod = target:FindModifier("modifier_timber_r_slow")

                if not mod then
                    mod = parent:AddNewModifier(caster, ability, "modifier_timber_r_slow", { duration = 1.5 })
                    if mod then mod:SetStackCount(1) end
                else
                    mod:SetStackCount(math.min(mod:GetStackCount() + 1, 3))
                    mod:SetDuration(1.5, true)
                end
            end,
            notBlockedAction = function(target)
                FX("particles/timber_r/timber_r_hit.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster(), {
                    cp0 = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 100),
                    cp1 = { ent = self:GetParent(), point = "attach_hitloc" },
                    release = true
                })
                self:GetParent():EmitSound("Arena.Timber.HitR")
            end
        })
    end

    function self:CreateParticle()
        local scale = 1
        if self:GetParent():GetParentEntity():FindModifier(self:GetName()) ~= self then
            scale = 1.25
        end
        self.particle = FX("particles/timber_r/timber_r_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), { cp1 = Vector(scale,1,1) })
        self:AddParticle(self.particle, false, false, -1, false, false)
    end
end

function self:IsDebuff()
    return true
end

function self:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function self:IsHidden()
    return true
end