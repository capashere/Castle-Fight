function GameMode:OnScriptReload()
  print("Script Reload")

  -- SpawnTestBuildings()
  -- SpawnRandomBuilding()
  -- KillEverything()
  -- GameMode:StartRound()
  -- GameMode:EndRound()
  -- GiveLumberToAllPlayers(2000)
  -- KillAllUnits()
  -- KillAllBuildings()
  -- GameMode:StartHeroSelection()

  -- print(PlayerResource:GetGold(1))
end

function SpawnTestBuildings()
  -- Only call this on the first script_reload
  if GameRules.SpawnTestBuildings then
    -- return
  else
    GameRules.SpawnTestBuilding = true
  end

  local humanBuildings = {
    "barracks",
    "stronghold",
    "sniper_nest",
    "gunners_hall",
    "marksmens_encampment",
    "weapon_lab",
    "gryphon_rock",
    "chapel",
    "church",
    "hjordhejmen",
    "gjallarhorn",
    "artillery",
    "watch_tower",
    "heroic_shrine",
  }

  for _,building in pairs(humanBuildings) do
    local randomPosition = RandomPositionBetweenBounds(GameRules.rightBaseMinBounds, GameRules.rightBaseMaxBounds)

    BuildingHelper:PlaceBuilding(nil, building, randomPosition, 2, 2, 0, DOTA_TEAM_BADGUYS)
  end

end

function SpawnRandomBuilding()
  local humanBuildings = {
    "barracks",
    "stronghold",
    "sniper_nest",
    "gunners_hall",
    "marksmens_encampment",
    "weapon_lab",
    "gryphon_rock",
    "chapel",
    "church",
    "hjordhejmen",
    "gjallarhorn",
    "artillery",
    "watch_tower",
    "heroic_shrine",
  }

  local building = GetRandomTableElement(humanBuildings)
  local randomPosition = RandomPositionBetweenBounds(GameRules.rightBaseMinBounds, GameRules.rightBaseMaxBounds)

  BuildingHelper:PlaceBuilding(nil, building, randomPosition, 2, 2, 0, DOTA_TEAM_BADGUYS)
end

function KillAllUnits()
  local units = FindAllUnitsInRadius(FIND_UNITS_EVERYWHERE, Vector(0,0,0))

  for _,unit in pairs(units) do
    if not IsCustomBuilding(unit) and not unit:IsHero() then
      unit:ForceKill(false)
    end
  end
end

function KillAllBuildings()
  local units = FindAllUnitsInRadius(FIND_UNITS_EVERYWHERE, Vector(0,0,0))

  for _,unit in pairs(units) do
    if IsCustomBuilding(unit) and unit:GetUnitName() ~= "castle" then
      unit:ForceKill(false)
    end
  end
end

function KillEverything()
  local allUnits = FindAllUnitsInRadius(FIND_UNITS_EVERYWHERE, Vector(0,0,0))

  for _,unit in pairs(allUnits) do
    if not unit:IsHero() then
      unit:ForceKill(false)
    end
  end
end

function GiveLumberToAllPlayers(value)
  for _,hero in pairs(HeroList:GetAllHeroes()) do
    hero:GiveLumber(value)
  end
end

function GameMode:GreedIsGood(playerID, value)
  value = tonumber(value) or 500
  for _,hero in pairs(HeroList:GetAllHeroes()) do
    if hero:IsAlive() then
      hero:GiveLumber(value)
      hero:ModifyCustomGold(value)
      -- hero:ModifyGold(value, false, DOTA_ModifyGold_CheatCommand)
    end
  end
end

function GameMode:LumberCheat(playerID, value)
  PlayerResource:GetSelectedHeroEntity(playerID):GiveLumber(tonumber(value))
end

function GameMode:SetLumberCheat(playerID, value)
  PlayerResource:GetSelectedHeroEntity(playerID):SetLumber(tonumber(value))
end

function GameMode:SetCheeseCheat(playerID, value)
  PlayerResource:GetSelectedHeroEntity(playerID):SetCheese(tonumber(value))
end

function GameMode:SpawnUnits(playerID, unitname, count)
  local position = Vector(0,0,0)
  local team = PlayerResource:GetTeam(playerID)

  count = tonumber(count) or 1

  if count < 0 then
    count = count * -1
    team = GetOpposingTeam(team)
  end

  for i=1,count do
    CreateUnitByName(unitname, position, true, nil, nil, team)
  end
end

function GameMode:Reset()
  GameRules.leftRoundsWon = 0
  GameRules.rightRoundsWon = 0
  GameRules.roundCount = 0
  GameMode:EndRound(DOTA_TEAM_NEUTRALS)
end

    
CHEAT_CODES = {
  ["lumber"] = function(...) GameMode:LumberCheat(...) end,                -- "Gives you X lumber"
  ["setlumber"] = function(...) GameMode:SetLumberCheat(...) end,          -- "Gives you X lumber"
  ["setcheese"] = function(...) GameMode:SetCheeseCheat(...) end,          -- "Sets your cheese to X"
  ["greedisgood"] = function(...) GameMode:GreedIsGood(...) end,           -- "Gives you X gold and lumber" 
  ["killallunits"] = function(...) KillAllUnits() end,                     -- "Kills all units"    
  ["killallbuildings"] = function(...) KillAllBuildings() end,             -- "Kills all buildings"    
  ["reset"] = function(...) GameMode:Reset() end,                          -- "Restarts the round"    
  ["nextround"] = function(...) GameMode:StartRound(...) end,              -- "Calls start round"      
  ["endround"] = function(...) GameMode:EndRound(...) end,                 -- "Calls end round"
  ["spawn"] = function(...) GameMode:SpawnUnits(...) end,                  -- "Spawns some units."
}

function GameMode:OnPlayerChat(keys)
  local text = keys.text
  local userID = keys.userid
  local playerID = self.vUserIds[userID] and self.vUserIds[userID]:GetPlayerID()
  if not playerID then return end

  -- Cheats are only available in the tools
  if not GameRules:IsCheatMode() then return end

  -- Handle '-command'
  if StringStartsWith(text, "-") then
      text = string.sub(text, 2, string.len(text))
  end

  local input = split(text)
  local command = input[1]
  if CHEAT_CODES[command] then
    CHEAT_CODES[command](playerID, input[2], input[3])
  end
end