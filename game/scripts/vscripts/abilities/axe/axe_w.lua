axe_w = class({})
local self = axe_w

LinkLuaModifier("modifier_axe_w", "abilities/axe/modifier_axe_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_axe_w_bonus", "abilities/axe/modifier_axe_w_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_axe_w_dmg", "abilities/axe/modifier_axe_w_dmg", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_axe_w", { duration = 0.8 })
    hero:EmitSound("Arena.AM.CastW")
    hero:EmitSound("Arena.Axe.CastW.Voice")
end

function self:GetCastAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_1
end

function self:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(axe_w)