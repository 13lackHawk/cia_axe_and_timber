EntitySniperW = EntitySniperW or class({}, nil, UnitEntity)

function EntitySniperW:constructor(round, owner, position, ability)
    getbase(EntitySniperW).constructor(self, round, "npc_dota_techies_stasis_trap", position, owner:GetUnit():GetTeamNumber())

    self.hero = owner
    self.owner = owner.owner
    self.ability = ability
    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.invulnerable = true
    self.removeOnDeath = false

    self:AddComponent(PlayerCircleComponent(64, true, 0.5))
    self:AddNewModifier(self, ability, "modifier_sniper_w_trap", {})
    self:EmitSound("Arena.Sniper.CastW")

    self.startTime = GameRules:GetGameTime()
end

function EntitySniperW:Update()
    getbase(EntitySniperW).Update(self)

    if GameRules:GetGameTime() - (self.startTime or 0) > 8 then
        self:Destroy()
    end
end

function EntitySniperW:CollidesWith(target)
    return self.owner.team ~= target.owner.team and instanceof(target, Hero) and not target:IsAirborne()
end

function EntitySniperW:CollideWith(target)
    self:EffectToTarget(target, {
        modifier = { ability = self.ability, name = "modifier_sniper_w", duration = 2.5 },
        sound = "Arena.Sniper.HitW",
        notBlockedAction = function(target)
            FX("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_WORLDORIGIN, GameRules:GetGameModeEntity(), {
                cp0 = self:GetPos(),
                release = true
            })

            self:Destroy()
        end
    })
end