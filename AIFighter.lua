local class = require("extlibs.middleclass")
require("Fighter")
require("BayesClassifier")

AIFighter = class('AIFighter', Fighter)

function AIFighter:initialize(positionX, positionY, health, stamina)
  Fighter.initialize(self, positionX, positionY, health, stamina)

  self.behaviour = ""
  self.direction = "left"
  self.anim["idle"] = newAnimation(love.graphics.newImage("resources/player/idle.png"), 128, 256, 1, 0)

  --Training data.
  self.train = {}
  self.train["attack"] =  {{"high", "high", "high", "high"},
                          {"high", "low", "high", "low"},
                          {"high", "high", "low", "low"},
                          {"low", "high", "low", "low"}}

  self.train["retreat"] = {{"low", "low", "high", "high"},
                          {"high", "low", "high", "high"},
                          {"low", "low", "high", "low"},
                          {"low", "high", "low", "high"}}

  self.test = {"high", "low", "high", "low"}


  self.nbc = BayesClassifier:new(2.0, 0.5, 4, 2)
end

function AIFighter:update(dt)

  local b = self.nbc:classify(self.train, self.test)
  if self.behaviour ~=  b then
    print("Changing behaviour too - "..b)
    self.behaviour = b
  end

  --Call base update.
  Fighter.update(self, dt)
end
