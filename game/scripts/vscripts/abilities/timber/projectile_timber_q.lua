ProjectileTimberQ = ProjectileTimberQ or class({}, nil, Projectile)

function ProjectileTimberQ:constructor(round, hero, target, damage, ability)
    getbase(ProjectileTimberQ).constructor(self, round, {
        owner = hero,
        from = hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, 100),
        to = target * Vector(1, 1, 0) + Vector(0, 0, 100),
        speed = 2250,
        radius = 200,
        graphics = "particles/timber_q/timber_q.vpcf",
        damagesTrees = true,
        disablePrediction = true,
        ability = ability,
        continueOnHit = true,
        goesThroughTrees = true
    })

    self.initialVel = Vector(self.vel.x, self.vel.y)
    self.startTime = GameRules:GetGameTime()

    self.collisionType = COLLISION_TYPE_INFLICTOR

    self.ability = ability
    self.goingBack = false
    self.distance = (target - hero:GetPos()):Length2D()
    self.distancePassed = 0
    self.ticksPassed = 0
    self.nextDamageAt = GameRules:GetGameTime() + 0.75
    self.isAlreadyHit = false
    self.soundIsPlayed = false
    --self.recastCheck = false
    self.removeOnDeath = true
    self.direction = (target * Vector(1, 1, 0) - hero:GetPos() * Vector(1, 1, 0))

    --self.vel = self.vel
    self.hitGroup[hero] = self.gracePeriod
    self.hitFunction = function(self, target)
        if target ~= self.hero then
            target:Damage(self, damage)
            target:EmitSound("Arena.PA.HitQ")

            local direction = (target:GetPos() - self:GetPos()):Normalized()
            local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(blood, 0, target:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetPos(), true)
            ParticleManager:SetParticleControlForward(blood, 0, direction)
            ParticleManager:SetParticleControl(blood, 2, direction * 1000)
        end
    end
end

function ProjectileTimberQ:Update()
    local prev = self:GetPos()
    getbase(ProjectileTimberQ).Update(self)
    local pos = self:GetPos()

    if not self.goingBack then
        if self.distance <= self.distancePassed then
            self.vel = Vector()
            --if self.hero:HasModifier("modifier_timber_q_recast") and self.recastCheck == false then -- stupid try to fix wrong recast duration
                --self.recastCheck = true
                --self.hero:RemoveModifier("modifier_timber_q_recast")
                --self.hero:AddNewModifier(hero, self.ability, "modifier_timber_q_recast", { duration = 2.25 })
            --end
            if self.soundIsPlayed == false then
                self:EmitSound("Arena.Timber.LoopQ")
                self.soundIsPlayed = true
            end
        end

        self.distancePassed = self.distancePassed + (prev - pos):Length2D()

        if GameRules:GetGameTime() >= self.nextDamageAt and self.distance <= self.distancePassed then
            if self.ticksPassed == 3 and not self.goingBack then
                self.hero:SwapAbilities("timber_q_sub", "timber_q")
                self.hero:FindAbility("timber_q"):StartCooldown(self.hero:FindAbility("timber_q"):GetCooldown(1))
                self:Retract()
            else
                self:AreaEffect({
                    ability = self.ability,
                    filter = Filters.Area(self:GetPos(), 200),
                    damage = self.ability:GetDamage()
                })

                self.nextDamageAt = self.nextDamageAt + 0.75
                self.ticksPassed = self.ticksPassed + 1
            end
        end
    else
        if (self.hero:GetPos() - self:GetPos()):Length2D() <= self:GetRad() then
            self.radius = 75
            if (self.hero:GetPos() - self:GetPos()):Length2D() <= self:GetRad() then
                self:Destroy()
            end
        end
    end
end

function ProjectileTimberQ:Retract()
    if self.hero:HasModifier("modifier_timber_q_recast") then
        self.hero:RemoveModifier("modifier_timber_q_recast")
    end
    self:StopSound("Arena.Timber.LoopQ")
    self.hero:EmitSound("Arena.Timber.EndQ")
    self.isAlreadyHit = false
    self.hitGroup = {}
    self.vel = self.initialVel * self:GetSpeed()
    self.goingBack = true
end

function ProjectileTimberQ:Deflect(by, direction)
    if not self.goingBack then
        self.hero:SwapAbilities("timber_q_sub", "timber_q")
        self.hero:FindAbility("timber_q"):StartCooldown(self.hero:FindAbility("timber_q"):GetCooldown(1))
        direction.z = 0
        self.direction = direction:Normalized()
        self.owner = by.owner
        self:Retract()
    end
end

function ProjectileTimberQ:GetNextPosition(pos)
    if not self.goingBack then
        return self.position + self.vel * (self:GetSpeed() / 45)
    else
        return pos + ((self.hero:GetPos() - pos):Normalized() * (self:GetSpeed() / 45))
    end
end