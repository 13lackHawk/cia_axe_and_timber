ProjectileTimberE = ProjectileTimberE or class({}, nil, Projectile)

function ProjectileTimberE:constructor(round, hero, target, ability)
    getbase(ProjectileTimberE).constructor(self, round, {
        ability = ability,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1600,
        graphics = hero:GetMappedParticle("particles/timber_e/timber_e2.vpcf"),
        destroyFunction = function(projectile)
            if projectile.hitSomething then
                projectile:RetractHook()
            else
                ParticleManager:DestroyParticle(projectile.particle, true)
                ParticleManager:ReleaseParticleIndex(projectile.particle)

                projectile.hero:RemoveModifier("modifier_pudge_hook_self")
                projectile.hero:StopSound("Arena.Timber.CastE")

                if projectile.hero:Alive() then
                    projectile.hero:GetUnit():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
                end
            end
        end,
        disablePrediction = true
    })

    hero:GetWearableBySlot("weapon"):AddEffects(EF_NODRAW)

    self.hero = hero
    self.ability = ability
    self.hitSomething = false
    self.goingBack = false
    self.distance = 1450
    self.distancePassed = 0
end

function ProjectileTimberE:CollideWith(target)
    local ally = target.owner.team == self.hero.owner.team

    if self.goingBack then
        return
    end

    self:EffectToTarget(target, {
        ability = self.ability,
        damagesTrees = false,
        damage = function(target)
            if not ally then 
                return 2
            end
        end,
        modifier = function(target)
            if not ally then
                if instanceof(target, Hero) then
                    target:AddNewModifier(self.hero, self.ability, "modifier_timber_e_root", { duration = math.max(self.distancePassed / 483, 0.5) })
                    target:AddNewModifier(self.hero, self.ability, "modifier_stunned", { duration = 0.05 })
                end
            end
        end,
        action = function(target)
            if not instanceof(target, Projectile)  then
                self.hitSomething = true
                target:EmitSound("Arena.Timber.HitE.Voice")

                target.round.spells:InterruptDashes(target)
                DashTimberE(target, self.hero, self.ability, self.particle)

                target:EmitSound("Arena.Timber.HitE")

                if instanceof(target, Hero) and not ally then
                    local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW , target:GetUnit())
                    ParticleManager:SetParticleControlEnt(blood, 0, target:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetPos(), true)

                    ParticleManager:DestroyParticle(blood, false)
                    ParticleManager:ReleaseParticleIndex(blood)
                end

                self:Destroy()
            end
        end,
        notBlockedAction = function(target, blocked)
            if instanceof(target, Obstacle) then
                self.hitSomething = true
                self:Destroy()
                DashTimberE(target, self.hero, self.ability, self.particle)
            end

            if not instanceof(target, Obstacle) and blocked then
                self:RetractHook()
                self.goingBack = true
            end
        end
    })
end

function ProjectileTimberE:CollidesWith(source)
    return source ~= self.hero and not instanceof(source, Projectile)
end

function ProjectileTimberE:SetGraphics(graphics)
    if graphics then
        self.particle = ParticleManager:CreateParticle(graphics, PATTACH_ABSORIGIN_FOLLOW , self.hero:GetUnit())

        ParticleManager:SetParticleControlEnt(self.particle, 0, self.hero:GetUnit(), PATTACH_POINT_FOLLOW, "attach_attack1", self.hero:GetPos(), true)
        ParticleManager:SetParticleControlEnt(self.particle, 3, self:GetUnit(), PATTACH_POINT_FOLLOW, nil, self:GetPos(), true)
    elseif not self.hitSomething then
        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)

        self.hero:StopSound("Arena.Timber.CastE")
    end
end

function ProjectileTimberE:RetractHook()
    self.hero:RemoveModifier("modifier_timber_chain_self")
    self.hero:EmitSound("Arena.Timber.EndE")

    if self.hitSomething == false then
        self.hero:EmitSound("Arena.Timber.MissE.Voice")
    end

    if self.hero:Alive() then
        self.hero:GetUnit():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        self.hero:GetUnit():StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
    end
end

function ProjectileTimberE:Update()
    local prev = self:GetPos()
    getbase(ProjectileTimberE).Update(self)
    local pos = self:GetPos()

    if not self.goingBack then
        if self.distance <= self.distancePassed then
            self.goingBack = true

            self:RetractHook()
        end

        self.distancePassed = self.distancePassed + (prev - pos):Length2D()
    else
        if (self.hero:GetPos() - self:GetPos()):Length2D() <= self:GetRad() then
            self:Destroy()
        end
    end
end

function ProjectileTimberE:GetNextPosition(pos)
    if not self.goingBack then
        return getbase(ProjectileTimberE).GetNextPosition(self, pos)
    else
        return pos + ((self.hero:GetPos() - pos + Vector(0, 0, 64)):Normalized() * (self:GetSpeed() / 30))
    end
end

function ProjectileTimberE:Remove()
    getbase(ProjectileTimberE).Remove(self)

    if not self.hitSomething then
        self.hero:GetWearableBySlot("weapon"):RemoveEffects(EF_NODRAW)
    end
end

DashTimberE = DashTimberE or class({}, nil, Dash)

function DashTimberE:constructor(target, hero, ability, particle)
    getbase(DashTimberE).constructor(self, hero, nil, 2400, {
        modifier = { name = "modifier_timber_e", ability = ability, source = ability:GetCaster() },
        interruptedByStuns = true,
        arrivalFunction = function()
            if instanceof(self.dashTarget, Obstacle) then
                self.dashTarget:DealOneDamage(self.hero)
            end
        end
    })

    self.dashTarget = target
    self.particle = particle

    if not target:Alive() then
        self:End(self.hero:GetPos(), false)
    end 
end

function DashTimberE:PositionFunction(current)
    local diff = self.dashTarget:GetPos() - current
    return current + (diff:Normalized() * self.velocity)
end

function DashTimberE:Update()
    getbase(DashTimberE).Update(self)

    if not self.dashTarget:Alive() then
        self:End(self.hero:GetPos(), false)
    end
end

function DashTimberE:HasEnded()
    return not self.hero:Alive() or (self.dashTarget:GetPos() - self.hero:GetPos()):Length2D() <= self.velocity * 3
end

function DashTimberE:End(...)
    getbase(DashTimberE).End(self, ...)

    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)

    self.dashTarget:StopSound("Arena.Timber.CastE")
    self.hero:GetWearableBySlot("weapon"):RemoveEffects(EF_NODRAW)
end