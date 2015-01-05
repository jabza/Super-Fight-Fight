local class = require("extlibs.middleclass")
FuzzyLogic = class('FuzzyLogic')

function FuzzyLogic:initialize()
  self.thresh = 0.5
end

--Slope functions.
function FuzzyLogic:upslope(x, left, right)
  return ((x-left)/(right-left))
end

function FuzzyLogic:downslope(x, left, right)
  return ((right-x)/(right-left))
end

--Zadeh operators.
function FuzzyLogic:_not(x)
  return (1 - x)
end

function FuzzyLogic:_and(x, y)
  return math.min(x, y)
end

function FuzzyLogic:_or(x, y)
  return math.max(x, y)
end

function FuzzyLogic:calcHealth(hp)
  if self:hpHigh(hp) > self:hpMedium(hp) then
    return "High"
  elseif self:hpMedium(hp) > self:hpLow(hp) then
    return "Medium"
  else
    return "Low"
  end
end

function FuzzyLogic:calcStamina(sp)
  if self:spHigh(sp) > self:spMedium(sp) then
    return "High"
  elseif self:spMedium(sp) > self:spLow(sp) then
    return "Medium"
  else
    return "Low"
  end
end

function FuzzyLogic:calcRange(dist)
  if self:distFar(dist) > self:distClose(dist) then
    return "Far"
  else
    return "Close"
  end
end

function FuzzyLogic:calcThreat(dist, enemyHp, enemySp)
  --The enemy is a high threat if they are close and have high stamina and high health.
  if self:_and(self:distClose(dist), self:_and(self:spHigh(enemySp), self:hpHigh(enemyHp))) >= self.thresh then
    return "High"
  elseif self:_and(self:_or(self:spMedium(enemySp), self:spHigh(enemySp)), self:_or(self:hpMedium(enemyHp), self:hpHigh(enemyHp))) >= self.thresh then
    return "Medium"
  elseif self:_and(self:distClose(dist), self:_or(self:spMedium(enemySp), self:spHigh(enemySp))) >= self.thresh then
    return "Medium"
  elseif self:_and(self:distFar(dist), self:spHigh(enemySp)) >= self.thresh then
    return "Medium"
  elseif self:_and(self:spLow(enemySp), self:hpLow(enemyHp)) >= self.thresh then
    return "Low"
  elseif self:_or(self:_and(self:distClose(dist), self:spLow(enemySp)), self:_and(self:distFar(dist), self:_or(self:spLow(enemySp), self:_and(self:hpLow(enemyHp), self:spMedium(enemySp))))) >= self.thresh then
    return "Low"
  else
    return "Medium"
  end
end

--Health membership functions.
function FuzzyLogic:hpHigh(x)
  left = 50
  right = 100

  if x <= left then
    return 0
  elseif x >= right then
    return 1.0
  else
    return self:upslope(x, left, right)
  end
end

function FuzzyLogic:hpMedium(x)
  leftBot = 25
  leftTop = 50
  rightTop = 50
  rightBot = 75

  if x <= leftBot or x >= rightBot then
    return 0
  elseif x > leftBot and x < leftTop then
    return self:upslope(x, leftBot, leftTop)
  elseif x > rightTop and x < rightBot then
    return self:downslope(x, rightTop, rightBot)
  else
    return 1.0
  end
end

function FuzzyLogic:hpLow(x)
  left = 10
  right = 50

  if x <= left then
    return 1.0
  elseif x >= right then
    return 0
  else
    return self:downslope(x, left, right)
  end
end

--Stamina membership functions.
function FuzzyLogic:spHigh(x)
  left = 50
  right = 70

  if x <= left then
    return 0
  elseif x >= right then
    return 1.0
  else
    return self:upslope(x, left, right)
  end
end

function FuzzyLogic:spMedium(x)
  leftBot = 20
  leftTop = 40
  rightTop = 50
  rightBot = 60

  if x <= leftBot or x >= rightBot then
    return 0
  elseif x > leftBot and x < leftTop then
    return self:upslope(x, leftBot, leftTop)
  elseif x > rightTop and x < rightBot then
    return self:downslope(x, rightTop, rightBot)
  else
    return 1.0
  end
end

function FuzzyLogic:spLow(x)
  left = 20
  right = 30

  if x <= left then
    return 1.0
  elseif x >= right then
    return 0
  else
    return self:downslope(x, left, right)
  end
end

--Distance membership functions.
function FuzzyLogic:distFar(x)
  left = 15
  right = 600

  if x <= left then
    return 0
  elseif x >= right then
    return 1.0
  else
    return self:upslope(x, left, right)
  end
end

function FuzzyLogic:distClose(x)
  left = 15
  right = 600

  if x <= left then
    return 1.0
  elseif x >= right then
    return 0
  else
    return self:downslope(x, left, right)
  end
end
