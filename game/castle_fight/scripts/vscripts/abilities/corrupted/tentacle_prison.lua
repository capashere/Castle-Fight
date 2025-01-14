tentacle_prison = class({})

function tentacle_prison:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self

  local target = GetRandomVisibleEnemy(caster:GetTeam())
  if not target then return end

  local unitName = "tentacle_prison_tentacle"
  local team = caster:GetTeam()
  local playerID = caster:GetPlayerOwnerID()
  local position = target:GetAbsOrigin()
  local angle = math.pi/4
  local radius = 60

  Timers:CreateTimer(function() 
    for i=1,6 do
      local position = Vector(position.x+radius*math.sin(angle), position.y+radius*math.cos(angle), position.z)
      local tentacle = CreateLaneUnit(unitName, position, team, playerID)
      tentacle:AddNewModifier(caster, ability, "modifier_kill", {duration = 10})

      angle = angle + math.pi/3
    end
  end)
end