resistance_of_the_wilderness = class({})

LinkLuaModifier("modifier_resistance_of_the_wilderness", "abilities/night_elves/resistance_of_the_wilderness.lua", LUA_MODIFIER_MOTION_NONE)

function resistance_of_the_wilderness:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self

  local allies = FindOrganicAlliesInRadius(caster, FIND_UNITS_EVERYWHERE)

  local target
  for _,ally in pairs(allies) do
    if not ally:IsRealHero() and not ally:HasModifier("modifier_resistance_of_the_wilderness") then
      target = ally
      break
    end
  end

  if not target then return end

  caster:EmitSound("Hero_Treant.LivingArmor.Cast")
  target:AddNewModifier(caster, ability, "modifier_resistance_of_the_wilderness", {})
end

modifier_resistance_of_the_wilderness = class({})

function modifier_resistance_of_the_wilderness:OnCreated()
  if not IsServer() then return end
  
  local ability = self:GetAbility()

  self.chance = ability:GetSpecialValueFor("chance")
  self.spell_resistance = ability:GetSpecialValueFor("spell_resistance")
  self.attack_damage_reduction = ability:GetSpecialValueFor("attack_damage_reduction")

  local parent = self:GetParent()

  parent.WildernessParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_POINT_FOLLOW, parent)
  ParticleManager:SetParticleControlEnt(parent.WildernessParticle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(parent.WildernessParticle, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
end

function modifier_resistance_of_the_wilderness:OnDestroy()
  if not IsServer() then return end
  if not self:GetParent().WildernessParticle then return end
  ParticleManager:DestroyParticle(self:GetParent().WildernessParticle, true)
end

function modifier_resistance_of_the_wilderness:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
  }
  return funcs
end

function modifier_resistance_of_the_wilderness:GetModifierMagicalResistanceBonus()
  return self.spell_resistance
end

function modifier_resistance_of_the_wilderness:GetModifierPhysical_ConstantBlock(keys)
  if not IsServer() then return end

  if self.chance >= RandomInt(1,100) then
    return self.attack_damage_reduction
  end

  return 0
end