ProjectileAxeR = ProjectileAxeR or class({}, nil, DistanceCappedProjectile)

function ProjectileAxeR:constructor(round, hero, target, ability, range)
	getbase(ProjectileAxeR).constructor(self, round, {
		ability = ability,
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
            hero:StopSound("Arena.Axe.CastR")
            hero:StopSound("Arena.Axe.CastR.Loop")
        end,
        hitParams = function(projectile, target)
            return {
                ability = ability,
                action = function(target)
                	if self.heroOverride then return end
                    local mod = hero:FindModifier("modifier_axe_counter")
                    if instanceof(target, Hero) or instanceof(target, Rune) then
		                if mod:GetStackCount() < 3 and not hero:FindModifier("modifier_axe_rage") then
		                    mod:IncrementStackCount()
		                end
		            end
                end,
                modifier = function(target)
                    target:AddNewModifier(hero, ability, "modifier_axe_r", { duration = 3.0 })
                end,
                damage = ability:GetDamage()
            }
        end
	})

	self.range = range
	self.start = self:GetPos()
	self.movedParts = {}
end

function ProjectileAxeR:Update()
	getbase(ProjectileAxeR).Update(self)

	GameRules.GameMode.level:GroundAction(
		function(part)
			if not self.movedParts[part] then
				local isLeft = IsLeft(self:GetPos(), self.start, Vector(part.x, part.y, 0))
	            local leftDir = Vector(-self.vel.y, self.vel.x)
	            local closest = ClosestPointToSegment(self:GetPos(), self.start, Vector(part.x, part.y, 0))

	            local currentLen = (closest - self:GetPos()):Length2D()
	            local closestLen = (closest - Vector(part.x, part.y, 0)):Length2D()

	            if currentLen == 0 or currentLen == (self:GetPos() - self.start):Length2D() or closestLen >= 256 then
	                return
	            end

	            local offset = leftDir * (512 / math.max(math.min(currentLen, 128), 16))

	            if isLeft then
	                offset = -offset
	            end

	            GameRules.GameMode.level:SetPartOffset(part, part.offsetX + offset.x, part.offsetY + offset.y)
	            self.movedParts[part] = true
			end
		end
	)
end

function ProjectileAxeR:Deflect(by, direction)
	getbase(ProjectileAxeR).Deflect(self,by, direction)

	self.movedParts = {}
	self.start = self:GetPos()
end