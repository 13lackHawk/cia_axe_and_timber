axe_r = class({})

LinkLuaModifier("modifier_axe_r", "abilities/axe/modifier_axe_r", LUA_MODIFIER_MOTION_NONE)

function axe_r:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.WK.PreR")

    --if RandomInt(1, 100) == 1 then
        --self:GetCaster().hero:EmitSound("Arena.Axe.CastR.Voice.Rare")
    --else
        self:GetCaster().hero:EmitSound("Arena.Axe.CastR.Voice")
    --end

    return true
end

function axe_r:OnChannelThink(interval)
    self.time = (self.time or 0) + interval

    local hero = self:GetCaster():GetParentEntity()
    local pos = hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, math.sin(self.time / 0.5 * 3.14) * 250) --interval * Vector(0, 0, self.speed)
    pos.z = math.max(pos.z, 32)
    hero:SetPos(pos)
end

function axe_r:OnChannelFinish(interrupted)
    self.time = nil

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local hitSomething = false

    hero:SetPos(hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, 32))
    TimedEntity(0.01, function()
        hero:SetPos(hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, 0))
    end):Activate()

    if interrupted then
        hero:StopSound("Arena.WK.PreR")
        return
    end

    local direction = (target - hero:GetPos() ) * Vector(1,1,0)

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    direction = direction:Normalized()

    local casterPos = hero:GetPos()
    local target = casterPos + direction:Normalized() * 2500
    local len = (target - casterPos):Length2D()
    local start = hero:GetPos() + direction:Normalized() * 64

    local currentLen = 128
    local previousPoint = casterPos

    while (currentLen < len) do
        local point = start + direction * currentLen

        if not Spells.TestCircle(point, 64) then
            target = previousPoint
            break
        end

        previousPoint = point
        currentLen = currentLen + 64
    end

    local len = (target - start):Length2D()
    local stopTimer = 0

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 1250,
        graphics = "particles/axe_r/axe_r.vpcf",
        distance = 1500,
        hitSound = "Arena.Axe.HitR",
        continueOnHit = true,
        damagesTrees = true,
        radius = 150,
        considersGround = true,
        ignoreProjectiles = true,
        goesThroughTrees = true,
        destroyFunction = function()
            stopTimer = 1
            hero:StopSound("Arena.Axe.CastR")
            hero:StopSound("Arena.Axe.CastR.Loop")
            if hitSomething == true then
                local mod = hero:FindModifier("modifier_axe_counter")
                if mod:GetStackCount() < 3 and not hero:FindModifier("modifier_axe_rage") then
                    mod:IncrementStackCount()
                end
            end
        end,
        hitParams = function(projectile, target)
            return {
                ability = self,
                action = function(target) 
                    if not instanceof(target, Obstacle) then
                        hitSomething = true
                    end
                end,
                modifier = function(target)
                    if instanceof(target, Hero) then
                        target:AddNewModifier(hero, self, "modifier_axe_r", { duration = 3.0 })
                    end
                end,
                damage = self:GetDamage()
            }
        end
    }):Activate()

    currentLen = 128
    target = casterPos
    local stop = 0

    Timers:CreateTimer(function()
       GameRules.GameMode.level:GroundAction(
        function(part)
            local isLeft = IsLeft(start, target, Vector(part.x, part.y, 0))
            local leftDir = Vector(direction.y, -direction.x)
            local closest = ClosestPointToSegment(start, target, Vector(part.x, part.y, 0))

            local currentLen = (closest - start):Length2D()
            local closestLen = (closest - Vector(part.x, part.y, 0)):Length2D()

            if currentLen == 0 or currentLen == len or closestLen >= 256 then
                return
            end

            local offset = leftDir * (128 * (currentLen / len))

            if isLeft then
                offset = -offset
            end

            GameRules.GameMode.level:SetPartOffset(part, part.offsetX + offset.x, part.offsetY + offset.y)
        end
    )

        if not Spells.TestCircle(target, 64) then
            Timers:RemoveTimer()
        end

        currentLen = currentLen + 64
        start = target
        target = start + direction * currentLen
        stop = stop + 1

        if stopTimer == 1 or stop == 6 then
            Timers:RemoveTimer()
        end
      return 0.250
    end
  )

    hero:EmitSound("Arena.Axe.CastR")
    hero:EmitSound("Arena.Axe.CastR.Loop")
end

function axe_r:GetChannelTime()
    return 0.5
end

function axe_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function axe_r:GetPlaybackRateOverride()
    return 1.2
end

if IsServer() then
    Wrappers.GuidedAbility(axe_r, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(axe_r)