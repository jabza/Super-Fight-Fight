local class = require("extlibs.middleclass")
ActionRule = class('ActionRule')

function ActionRule:initialize(a, b, c)
  self.antecedentA = a
  self.antecedentB = b
  self.consequentC = c

  self.matched = false
  self.weight = 0
end

function ActionRule:setRule(a, b, c)
  self.antecedentA = a
  self.antecedentB = b
  self.consequentC = b
end

ActionMemory = class('ActionMemory')
function ActionMemory:initialize()
  self.actionA = nil
  self.actionB = nil
  self.actionC = nil
end

--The purpose of this system to to predict if the player will perform
--a standing attack, crouching attack or no attack.

--stand = block or idle.
--crouch = crouchBlock or crouch.
--attack = jab, hook or strike.
--crouchAttack = crouchJab, crouchHook or crouchStrike.
ExpertSystem = class('ExpertSystem')
function ExpertSystem:initialize()
  self.actionMemory = ActionMemory:new()

  self.prediction = nil
  self.prevRuleTriggered = -1
  self.prevAction = ""

  self.predictionCount = 0
  self.predictionSuccess = 0

  self.ruleCount = 24

  self.ruleSet = {}
  self.ruleSet[1] = ActionRule:new("stand", "crouch", "stand")
  self.ruleSet[2] = ActionRule:new("stand", "crouch", "crouchAttack")
  self.ruleSet[3] = ActionRule:new("stand", "attack", "stand")
  self.ruleSet[4] = ActionRule:new("stand", "attack", "crouch")
  self.ruleSet[5] = ActionRule:new("stand", "attack", "attack")
  self.ruleSet[6] = ActionRule:new("crouch", "stand", "crouch")
  self.ruleSet[7] = ActionRule:new("crouch", "stand", "attack")
  self.ruleSet[8] = ActionRule:new("crouch", "crouchAttack", "stand")
  self.ruleSet[9] = ActionRule:new("crouch", "crouchAttack", "crouch")
  self.ruleSet[10] = ActionRule:new("crouch", "crouchAttack", "crouchAttack")
  self.ruleSet[11] = ActionRule:new("attack", "stand", "crouch")
  self.ruleSet[12] = ActionRule:new("attack", "stand", "attack")
  self.ruleSet[13] = ActionRule:new("attack", "crouch", "stand")
  self.ruleSet[14] = ActionRule:new("attack", "crouch", "crouchAttack")
  self.ruleSet[15] = ActionRule:new("attack", "attack", "stand")
  self.ruleSet[16] = ActionRule:new("attack", "attack", "crouch")
  self.ruleSet[17] = ActionRule:new("attack", "attack", "attack")
  self.ruleSet[18] = ActionRule:new("crouchAttack", "stand", "crouch")
  self.ruleSet[19] = ActionRule:new("crouchAttack", "stand", "attack")
  self.ruleSet[20] = ActionRule:new("crouchAttack", "crouch", "stand")
  self.ruleSet[21] = ActionRule:new("crouchAttack", "crouch", "crouchAttack")
  self.ruleSet[22] = ActionRule:new("crouchAttack", "crouchAttack", "stand")
  self.ruleSet[23] = ActionRule:new("crouchAttack", "crouchAttack", "crouch")
  self.ruleSet[24] = ActionRule:new("crouchAttack", "crouchAttack", "crouchAttack")
end

function ExpertSystem:getPrediction()
  return self.actionMemory.actionC 
end

function ExpertSystem:assessAction(action)
  local chosenRule = -1

  --Simplify the actions into one of four for the system.
  if action == "idle" or action == "block" or action == "jump" then
    action = "stand"
  elseif action == "crouch" or action == "crouchBlock" then
    action = "crouch"
  elseif action == "jab" or action == "hook" or action == "strike" then
    action = "attack"
  elseif string.match(action, "crouch") then
    action = "crouchAttack"
  else
    return nil
  end

  --Only attacks can be repeated. E.G, Cannot stand, stand or crouch, crouch.
  if (action == "stand" or action == "crouch") and action == self.prevAction then
    self.prevAction = action
    return nil
  else
    self.prevAction = action
  end

  if self.actionMemory.actionA == nil then
    self.actionMemory.actionA = action
    self.prediction = nil
    return nil
  end

  if self.actionMemory.actionB == nil then
    self.actionMemory.actionB = action
    self.prediction = nil
    return nil
  end

  self.predictionCount = self.predictionCount + 1

  print("A is: "..self.actionMemory.actionA)
  print("B is: "..self.actionMemory.actionB)
  print("Curr: "..action)

  --Forward chaining.
  for r = 1, self.ruleCount, 1 do
    if self.ruleSet[r].antecedentA == self.actionMemory.actionA and
       self.ruleSet[r].antecedentB == self.actionMemory.actionB then
      self.ruleSet[r].matched = true
    else
      self.ruleSet[r].matched = false
    end
  end

  --Select correct rule, based on weights.
  for r = 1, self.ruleCount, 1 do
    if self.ruleSet[r].matched then
      if chosenRule == -1 then
        chosenRule = r
      elseif self.ruleSet[r].weight > self.ruleSet[chosenRule].weight then
        chosenRule = r
      end
    end
  end

  --Trigger the rule.
  if chosenRule ~= -1 then
    self.actionMemory.actionC = self.ruleSet[chosenRule].consequentC
    self.prediction = self.actionMemory.actionC
    self.prevRuleTriggered = chosenRule
  else
    self.actionMemory.actionC = nil
    self.prevRuleTriggered = -1
  end

  print("Prediction: "..self.prediction)

  if action == self.prediction then
    self.predictionSuccess = self.predictionSuccess + 1
    if self.prevRuleTriggered ~= -1 then
      self.ruleSet[self.prevRuleTriggered].weight = self.ruleSet[self.prevRuleTriggered].weight + 1
    end
  else
    if self.prevRuleTriggered ~= -1 then
      self.ruleSet[self.prevRuleTriggered].weight = self.ruleSet[self.prevRuleTriggered].weight - 1
    end

    --Backward chaining.
    for r = 1, self.ruleCount, 1 do
      if self.ruleSet[r].matched and (self.ruleSet[r].consequentC == action) then
        self.ruleSet[r].weight = self.ruleSet[r].weight + 1
        break
      end
    end
  end

  self.actionMemory.actionA = self.actionMemory.actionB
  self.actionMemory.actionB = action
end
