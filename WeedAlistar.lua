require "UOL"
require "VPrediction"

local VP = nil
local predTable = {"None"}
local currentPred = nil
local myHero = GetMyHero()
local ts
local minionmanager = nil
local modeTable = {"None"}

if myHero.charName ~= "Alistar" then return end

function OnLoad()

  minionmanager = minionManager(MINION_ALL, 1500)

  VP = VPrediction()

  if(myHero.charName == "Alistar") then
    PrintChat("Welcome to Weed Alistar. Good Luck, Have Fun!")
  end

  ts = TargetSelector(TARGET_LOW_HP_PRIORITY,1500)

  table.insert(modeTable, "Lasthit")
  table.insert(modeTable, "Push")

  initMenu()

end

function initMenu()

  Config = scriptConfig("Weed Alistar", "weedali")

  Config:addSubMenu("Combo Settings", "settComb")
  Config.settComb:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
  Config.settComb:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)

  Config:addSubMenu("Autoheal Settings", "settHeal")
  Config.settHeal:addParam("active", "Auto Heal Enable", SCRIPT_PARAM_ONOFF, true)
  Config.settHeal:addParam("Blank", "Min Allys to Heal", SCRIPT_PARAM_INFO, "")
  Config.settHeal:addParam("count", "Default value = 1", SCRIPT_PARAM_SLICE, 1, 0, 4, 0)
  Config.settHeal:addParam("Blank", "Min % HP for Autoheal", SCRIPT_PARAM_INFO, "")
  Config.settHeal:addParam("health", "Default value = 75", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
  Config.settHeal:addParam("Blank", "Min Mana for Autoheal", SCRIPT_PARAM_INFO, "")
  Config.settHeal:addParam("mana", "Default value = 25", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
  
  Config:addSubMenu("Anti-Dash Settings", "settDash")
  Config.settDash:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
  Config.settDash:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)

  Config:addSubMenu("Draw Settings", "settDraw")
  Config.settDraw:addParam("qrange", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
  Config.settDraw:addParam("wrange", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
  Config.settDraw:addParam("erange", "Draw E Range", SCRIPT_PARAM_ONOFF, true)

  UOL:AddToMenu(scriptConfig("OrbWalker", "OrbWalker"))

end

function OnTick()

  if myHero.dead then return end

  ts:update()
  minionmanager:update()

  if(UOL:GetOrbWalkMode() == "Combo") then onCombo() end

  autoHeal()
  checkDash()

end

function checkDash()

  for i=1, heroManager.iCount do
    local enemy = heroManager:getHero(i)
    
    if enemy.team ~= myHero.team and enemy.visible == true and not enemy.dead then
      local TargetDashing, CanHit, Position = VP:IsDashing(enemy, 0, 350, math.huge, myHero)
      
      if(TargetDashing and CanHit) then 
      if(myHero:CanUseSpell(_Q) == READY and Config.settDash.useq) then CastSpell(_Q)
      elseif(myHero:CanUseSpell(_W) == READY and Config.settDash.usew) then CastSpell(_W, enemy) end
    end
    end
  end

end

function autoHeal()

  local allycount = 0
  local heal = false
  if not Config.settHeal.active then return end

  for i=1, heroManager.iCount do
    local ally = heroManager:getHero(i)

    if ally.team == myHero.team and not ally == myHero and myHero:CanUseSpell(_E) == READY and ((myHero.mana/myHero.maxMana)*100) > Config.settHeal.mana and ally.bTargetable and ally.visible == true and not ally.dead and ally.type == myHero.type and GetDistance(ally.pos) < 550 then
      allycount = allycount+1
      if(((ally.health/ally.maxHealth)*100) < Config.settHeal.health) then heal = true end
    end

    if(((ally.health/ally.maxHealth)*100) < Config.settHeal.health and ally == myHero) then heal = true end

    if(allycount >= Config.settHeal.count and heal) then CastSpell(_E) end
  end
end


function onCombo()

  if(ts.target ~= nil) then

    local enemy = GetTarget()

    if enemy == nil then return end

    if(myHero:CanUseSpell(_Q) == READY and Config.settComb.useq and GetDistance(enemy.pos) < 350) then
      if enemy.team ~= myHero.team and enemy.bTargetable and enemy.visible == true and not enemy.dead then

        --PrintChat("CoQ")
        CastSpell(_Q)
      end
    end

    if(myHero:CanUseSpell(_W) == READY and Config.settComb.usew and myHero:CanUseSpell(_Q) == READY and GetDistance(enemy.pos) < 640) then

      if enemy.team ~= myHero.team and enemy.bTargetable and enemy.visible == true and not enemy.dead then

        --PrintChat("CoW")
        CastSpell(_W, enemy)
      end
    end
  end

end

function GetTarget()
  if UOL:GetTarget() ~= nil and UOL:GetTarget().type == myHero.type then return UOL:GetTarget() end

  ts:update()
  if ts.target and not ts.target.dead and ts.target.type == myHero.type then
    return ts.target
  else
    return nil
  end
end


function OnDraw()

  if(Config.settDraw.qrange) then
    DrawCircle(myHero.x, myHero.y, myHero.z, 365, 0x111111)
  end

  if(Config.settDraw.wrange) then
    DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x111111)
  end

  if(Config.settDraw.erange) then
    DrawCircle(myHero.x, myHero.y, myHero.z, 575, 0x111111)
  end

end