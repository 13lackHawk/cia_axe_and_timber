COLLISION_TYPE_NONE = 0
COLLISION_TYPE_INFLICTOR = 1
COLLISION_TYPE_RECEIVER = 2

DynamicEntity = DynamicEntity or class({})

function DynamicEntity:constructor(round)
    self.round = round or GameRules.GameMode.round
    self.size = 64
    self.position = Vector(0, 0, 0)
    self.destroyed = false
    self.invulnerable = false
    self.collisionType = COLLISION_TYPE_NONE
    self.collisionConsiderOwner = true
    self.falling = false
    self.fallingSpeed = 0
end

function DynamicEntity:AddComponent(component)
    if component.Activate then
        component.Activate(self)
    end

    for key, value in pairs(component) do
        if key ~= "Activate" then
            if self[key] ~= nil then
                print("Warning! Colliding key", key)
            end

            self[key] = value
        end
    end

    return self
end

function DynamicEntity:MakeFall(horizontalVelocity)
    self.falling = true
    self.fallingHorizontalVelocity = horizontalVelocity or Vector()
end

function DynamicEntity:CanFall()
    return true
end

function DynamicEntity:GetPos()
    return self.position
end

function DynamicEntity:SetPos(position)
    self.position = position

    return self
end

function DynamicEntity:GetRad()
    return self.size
end

function DynamicEntity:Destroy()
    self.destroyed = true
end

function DynamicEntity:EmitSound(sound)
    EmitSoundOnLocationWithCaster(self.position, sound, nil)
end

function DynamicEntity:Alive()
    return not self.destroyed
end

function DynamicEntity:CollidesWith(target)
    return true
end

function DynamicEntity:SetInvulnerable(value)
    self.invulnerable = value
end

function DynamicEntity:IsInvulnerable(value)
    return self.invulnerable
end

function DynamicEntity:Update()
    Spells.SystemCallSingle(self, "Update")

    if self.falling then
        self.fallingSpeed = self.fallingSpeed + 10
        local pos = self:GetPos()

        local t = pos - Vector(0, 0, self.fallingSpeed / 3)

        if self.fallingHorizontalVelocity then
            if pos.z > -100 then
                local hit = Spells.TestCircle(pos + self.fallingHorizontalVelocity * 0.5, self:GetRad())

                if hit then
                    self.fallingHorizontalVelocity = -self.fallingHorizontalVelocity * 0.5
                end
            end

            t = t + self.fallingHorizontalVelocity
        end

        self:SetPos(t)

        if pos.z <= -MAP_HEIGHT then
            self:Destroy()

            if self.SetHidden then
                self:SetHidden(true)
            end
        end
    end
end

function DynamicEntity:TestFalling()
    return Spells.TestCircle(self:GetPos(), self:GetRad())
end


function DynamicEntity:Damage(source, amount, isPhysical, amplifies)
    Spells.SystemCallSingle(self, "Damage", source, self:CalculateDamage(source, amount, isPhysical, amplifies), isPhysical)
end

function DynamicEntity:Heal() end

function DynamicEntity:Remove()
    Spells.SystemCallSingle(self, "Remove")
end

function DynamicEntity:CollideWith(target) end

function DynamicEntity:HasModifier() return false end
function DynamicEntity:FindModifier() end
function DynamicEntity:AddNewModifier() end
function DynamicEntity:RemoveModifier() end
function DynamicEntity:IsAirborne()
    return false
end
function DynamicEntity:AllModifiers()
    return {}
end

function DynamicEntity:AllowAbilityEffect(source, ability, data)
    if not self:Alive() then
        return true
    end

    local valid = true
    if not data then data = {} end
    local Effect = vlua.clone(data)

    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.AllowAbilityEffect then
            local val = modifier:AllowAbilityEffect(source, ability, Effect)

            if val == false then
                Effect = {}
                valid = false
            elseif type(val) == "table" and not valid == false then
                Effect = val
            end
        end
    end

    return valid, Effect
end

function DynamicEntity:CalculateDamage(source, damage, physical, amplifies)
    if amplifies == false then
        return damage
    end

    local modifiers = {
        damageChange = {},
        damageDealtChange = {}
    }

    for _,  modifier in pairs(self:AllModifiers()) do
        if modifier.GetDamageChange then
            table.insert(modifiers.damageChange, modifier)
        end
    end

    for _,  modifier in pairs(source:AllModifiers()) do
        if modifier.GetDamageDealtChange then
            table.insert(modifiers.damageDealtChange, modifier)
        end
    end

    table.sort(modifiers.damageChange, function(a, b)
        local ap = a.GetDamageChangePriority and a:GetDamageChangePriority() or 0
        local bp = b.GetDamageChangePriority and b:GetDamageChangePriority() or 0

        return ap > bp
    end)

    table.sort(modifiers.damageDealtChange, function(a, b)
        local ap = a.GetDamageDealtChangePriority and a:GetDamageDealtChangePriority() or 0
        local bp = b.GetDamageDealtChangePriority and b:GetDamageDealtChangePriority() or 0

        return ap > bp
    end)

    for _, modifier in pairs(modifiers.damageChange) do
        local change = modifier:GetDamageChange(source, self, damage, physical)

        if type(change) == "number" then
            damage = damage + change
        elseif change == false then
            return false
        end
    end

    for _, modifier in pairs(modifiers.damageDealtChange) do
        if modifier.GetDamageDealtChange then
            local change = modifier:GetDamageDealtChange(source, self, damage, physical)

            if type(change) == "number" then
                damage = damage + change
            elseif change == false then
                return false
            end
        end
    end

    return damage
end

function DynamicEntity:OnBlockedAbilityDamage(source, ability, damage, isPhysical)
    if not self:Alive() then
        return
    end

    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.OnBlockedAbilityDamage then
            modifier:OnBlockedAbilityDamage(source, ability, damage, isPhysical)
        end
    end
end

function DynamicEntity:Activate()
    self.round.spells:AddDynamicEntity(self)

    return self
end

function DynamicEntity:EffectToTarget(target, params)
    local resultAction = {}
    local isTree = instanceof(target, Obstacle)
    local invulnerableTarget = target:IsInvulnerable()
    local blocked = false

    local hero = self

    if self.hero then
        hero = self.hero
    end

    if self.heroOverride then
        hero = self.heroOverride
    end

    if isTree and ((params.damage ~= nil and params.damagesTrees ~= false) or params.damagesTrees) and not params.damagesTreesx2 then
        target:DealOneDamage(self)
    elseif isTree and params.damagesTreesx2 then
        target:DealOneDamage(self)
        target:DealOneDamage(self)
    end

    if params.modifier then
        if type(params.modifier) == "table" then
            resultAction.modifier = function(target)
                local m = params.modifier

                target:AddNewModifier(hero, m.ability, m.name, { duration = m.duration })
            end
        elseif type(params.modifier) == "function" then
            resultAction.modifier = params.modifier
        end
    end

    if params.damage then
        local damage = params.damage
        if type(params.damage) == "function" then
            damage = params.damage(target)
        end

        local resultDmg = target:CalculateDamage(hero, damage, params.isPhysical, params.damageAmplifies)

        if type(resultDmg) == "number" and resultDmg > 0 then
            resultAction.damage = {}
            resultAction.damage.count = resultDmg
            resultAction.damage.real = damage
            resultAction.damage.type = params.isPhysical
        end
    end

    if params.knockback then
        if type(params.knockback) == "table" then
            resultAction.knockback = function(target)
                local direction 
                if params.knockback.direction then
                    if type(params.knockback.direction) == "function" then
                        direction = params.knockback.direction(target)
                    else
                        direction = params.knockback.direction
                    end
                else direction = (target:GetPos() - self:GetPos()) end

                local force = params.knockback.force
                local decrease = params.knockback.decrease

                if type(force) == "function" then
                    force = force(target)
                end

                if type(decrease) == "function" then
                    decrease = decrease(target)
                end

                SoftKnockback(target, self, direction, force or 20, {
                    decrease = decrease,
                    knockup = params.knockback.knockup
                })
            end
        elseif type(params.knockback) == "function" then
            resultAction.knockback = params.knockback
        end
    end

    if params.action then
        resultAction.action = function(target, data)
            params.action(target, data)
        end
    end

    local valid = true
    if (resultAction.action or resultAction.damage or resultAction.knockback or resultAction.modifier) and params.ignoreAllowAbilityCheck ~= true then
        if params.ability then
            valid, resultAction = target:AllowAbilityEffect(self, params.ability, resultAction)
        end
    end

    if params.notBlockedAction then
        resultAction.notBlockedAction = function(target, blocked, data)
            params.notBlockedAction(target, blocked, data)
        end
    end

    if params.sound and not soundPlayed then
        if type(params.sound) == "table" then
            for _, sound in pairs(params.sound) do
                self:EmitSound(sound, target:GetPos())
            end
        else
            self:EmitSound(params.sound, target:GetPos())
        end

        soundPlayed = true
    end

    if not (invulnerableTarget or isTree) then
        if resultAction.damage and params.dealDamage ~= false then
            target:Damage(hero, resultAction.damage.count, resultAction.damage.type, false)
        end

        if resultAction.modifier and params.createModifier ~= false then
            resultAction.modifier(target)
        end

        if resultAction.knockback and params.doKnockback ~= false then
            resultAction.knockback(target)
        end

        if resultAction.action then
            resultAction.action(target, resultAction)
        end
    end

    if resultAction.notBlockedAction then
        resultAction.notBlockedAction(target, not valid, resultAction)
    end
end

function DynamicEntity:AreaEffect(params)
    local hurt

    if params.damage == true then
        params.damage = 3
    end

    local soundPlayed = false

    for _, target in pairs(self.round.spells:GetValidTargets()) do
        local passes = not instanceof(target, Projectile) or ((IsAttackAbility(params.ability) and IsAttackAbility(target.ability)) or params.targetProjectiles)
        local heroPasses = not params.onlyHeroes or instanceof(target, Hero)
        local allyFilter = false

        if target.owner then
            allyFilter = target.owner.team ~= self.owner.team or (params.hitAllies and (target ~= self or params.hitSelf))
        end

        if allyFilter and passes and heroPasses and params.filter(target) then
            self:EffectToTarget(target, params)

            if not hurt then
                hurt = {}
            end

            table.insert(hurt, target)
        end
    end

    return hurt
end