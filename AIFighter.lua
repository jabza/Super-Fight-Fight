local class = require("extlibs.middleclass")
require("Fighter")
require("FuzzyLogic")
require("BayesClassifier")
require("ExpertSystem")

AIFighter = class('AIFighter', Fighter)

function AIFighter:initialize(positionX, positionY, health, stamina)
  --Initialize base class.
  Fighter.initialize(self, positionX, positionY, health, stamina)

  --Setup animations
  self.anim["idle"]         = newAnimation(love.graphics.newImage("resources/ai/idle.png"), 128, 256, 1, 0)
  self.anim["walk"]         = newAnimation(love.graphics.newImage("resources/ai/walk.png"), 128, 256, 0.15, 0)
  self.anim["crouch"]       = newAnimation(love.graphics.newImage("resources/ai/crouch.png"), 128, 256, 0.1, 0)
  self.anim["block"]        = newAnimation(love.graphics.newImage("resources/ai/block.png"), 128, 256, 1, 0)
  self.anim["crouchBlock"]  = newAnimation(love.graphics.newImage("resources/ai/crouchBlock.png"), 128, 256, 1, 0)
  self.anim["jump"]         = newAnimation(love.graphics.newImage("resources/ai/jump.png"), 128, 256, 0.25, 0)
  self.anim["jab"]          = newAnimation(love.graphics.newImage("resources/ai/jab.png"), 128, 256, 0.15, 0)
  self.anim["crouchJab"]    = newAnimation(love.graphics.newImage("resources/ai/crouchJab.png"), 128, 256, 0.15, 0)
  self.anim["hook"]         = newAnimation(love.graphics.newImage("resources/ai/hook.png"), 128, 256, 0.2, 0)
  self.anim["crouchHook"]   = newAnimation(love.graphics.newImage("resources/ai/crouchHook.png"), 128, 256, 0.15, 0)
  self.anim["strike"]       = newAnimation(love.graphics.newImage("resources/ai/strike.png"), 128, 256, 0.15, 0)
  self.anim["crouchStrike"] = newAnimation(love.graphics.newImage("resources/ai/crouchStrike.png"), 128, 256, 0.15, 0)
  self.anim["dmg"]          = newAnimation(love.graphics.newImage("resources/ai/dmg.png"), 128, 256, 0.1, 0)
  self.anim["crouchDmg"]    = newAnimation(love.graphics.newImage("resources/ai/crouchDmg.png"), 128, 256, 0.1, 0)
  self.anim["death"]        = newAnimation(love.graphics.newImage("resources/ai/death.png"), 256, 256, 0.1, 0)

  self.anim["jump"]:setMode("once")
  self.anim["jab"]:setMode("once")
  self.anim["hook"]:setMode("once")
  self.anim["strike"]:setMode("once")
  self.anim["dmg"]:setMode("once")
  self.anim["crouchDmg"]:setMode("once")
  self.anim["death"]:setMode("once")

  self.behaviour = "Offence"

  --Naive Bayes Classifier Training data.
  self.train = {}         --Health, Stamina, Threat, Range
  self.train["Offence"] = {{"High", "High", "High", "Close"},
                          {"Low", "High", "Medium", "Close"},
                          {"Medium", "High", "High", "Close"},
                          {"High", "High", "Low", "Far"},
                          {"High", "Low", "Medium", "Close"},
                          {"Low", "Medium", "Medium", "Close"}}

  self.train["Defence"] = {{"High", "Low", "High", "Close"},
                          {"Medium", "Low", "High", "Close"},
                          {"Low", "Medium", "High", "Close"},
                          {"Low", "Low", "High", "Close"},
                          {"Medium", "Low", "High", "Close"},
                          {"Low", "Low", "Medium", "Close"}}

  self.train["Retreat"] = {{"Low", "Low", "High", "Far"},
                          {"Low", "Low", "Medium", "Far"},
                          {"Low", "Low", "Low", "Far"},
                          {"Low", "Low", "Low", "Close"}}

  --Naive Bayes Classifier Input Data.
  self.input = {"High", "High", "Medium", "Far"}

  --Create the Fuzzy Logic system.
  self.fuzzy  = FuzzyLogic:new()

  --Create the Naive Bayes Classifier, with 4 attributes and 3 classes.
  self.nbc    = BayesClassifier:new(4, 3)

  --Create the rules-based Expert System. NOTE: This system is updated in the Fighter class - processNextAction().
  self.expert = ExpertSystem:new()

  --Used to stop the AI idling in offence mode.
  self.offenceCombatTimer = 0
  self.offenceBlockThresh = 1
end

function AIFighter:update(dt)
  --Call base update.
  Fighter.update(self, dt)

  --Calculate distance from player to AI.
  local dist = love.physics.getDistance(player.fixture, ai.fixture)

  --Update fuzzy logic.
  self.input[1] = self.fuzzy:calcHealth(self.hp)
  self.input[2] = self.fuzzy:calcStamina(self.sp)
  self.input[3] = self.fuzzy:calcThreat(dist, player.hp, player.sp)
  self.input[4] = self.fuzzy:calcRange(dist)

  --Classify the behaviour based on fuzzy logic input.
  self.behaviour = self.nbc:classify(self.train, self.input)

  --Perform the correct behaviour.
  if self.behaviour == "Offence" then
    self:offensiveBehaviour(dt)
  elseif self.behaviour == "Defence" then
    self:defensiveBehaviour()
  elseif self.behaviour == "Retreat" then
    self:retreatBehaviour()
  end
end

function AIFighter:offensiveBehaviour(dt)
  --Calculate distance from player to AI.
  local dist = love.physics.getDistance(player.fixture, ai.fixture)

  --If the AI is out of range.
  if dist > self.jabRange then
    --Stand up to walk if crouching.
    if string.match(self.action, "crouch") then
      self.nextAction = "block"
      return
    end

    --Persue player.
    self.nextAction = "walk"
    if player.body:getX() < self.body:getX() then
      self.direction = "left"
    else
      self.direction = "right"
    end
  else
    --Use the Expert System to counter the player if possible.
    if self.expert:getPrediction() ~= nil then
      if self.expert:getPrediction() == "attack" and self.offenceCombatTimer < self.offenceBlockThresh then
        self.nextAction = "crouchBlock"
        self.offenceCombatTimer = self.offenceCombatTimer + dt
      elseif self.expert:getPrediction() == "crouchAttack" and self.offenceCombatTimer < self.offenceBlockThresh then
        self.nextAction = "crouchBlock"
        self.offenceCombatTimer = self.offenceCombatTimer + dt
      elseif self.expert:getPrediction() == "stand" or self.offenceCombatTimer >= self.offenceBlockThresh then
        self:useBestAttack()
      elseif self.expert:getPrediction() == "crouch" or self.offenceCombatTimer >= self.offenceBlockThresh then
        --First crouch, before attacking.
        if self.action == "idle" or self.action == "block" then
          self.nextAction = "crouchBlock"
        else
          self:useBestAttack()
        end
      end
    else
      self:useBestAttack()
    end
  end
end

function AIFighter:defensiveBehaviour()
  --Counter the player if possible.
  if self.expert:getPrediction()~= nil then
    if self.expert:getPrediction() == "attack" then
      self.nextAction = "block"
    elseif self.expert:getPrediction() == "crouchAttack" then
      self.nextAction = "crouchBlock"
    else
      self.nextAction = "block"
    end
  else
    self.nextAction = "block"
  end
end

function AIFighter:retreatBehaviour()
  --Stand up to walk if crouching.
  if string.match(self.action, "crouch") then
    self.nextAction = "block"
    return
  end

  if player.body:getX() < self.body:getX() and self.body:getX() < love.graphics.getWidth()-32 then
    self.nextAction = "walk"
    self.direction = "right"
  elseif player.body:getX() > self.body:getX() and self.body:getX() > 32 then
    self.nextAction = "walk"
    self.direction = "left"
  else
    self.nextAction = "block"
  end
end

function AIFighter:useBestAttack()
  self.offenceCombatTimer = 0

  if self.sp >= self.strikeCost then
    self.nextAction = "strike"
  elseif self.sp >= self.hookCost then
    self.nextAction = "hook"
  elseif self.sp >= self.jabCost then
    self.nextAction = "jab"
  end
end
