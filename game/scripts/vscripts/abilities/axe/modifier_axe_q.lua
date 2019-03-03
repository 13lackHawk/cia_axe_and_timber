modifier_axe_q = class({})

if IsServer() then
    function modifier_axe_q:OnCreated()
        self:GetParent():Interrupt()
        self:StartIntervalThink(0.1)
        self:OnIntervalThink()
    end

    function modifier_axe_q:OnIntervalThink()
        self:GetParent():MoveToNPC(self:GetCaster())

        local hero = self:GetCaster().hero
        --local victim = self:GetParent().hero

        for _, target in pairs(hero.round.spells:GetHeroTargets()) do
            local distance = (target:GetPos() - hero:GetPos()):Length2D()

            if target.owner.team ~= hero.owner.team and distance <= 200 then
                target:RemoveModifier("modifier_axe_q")
                break
            end
        end
    end

    function modifier_axe_q:OnDestroy()
        self:GetParent():Interrupt()
    end
end

function modifier_axe_q:GetEffectName()
    return "particles/axe_q/axe_q_overhead.vpcf"
end
 
function modifier_axe_q:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
 
function modifier_axe_q:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
 
    return state
end