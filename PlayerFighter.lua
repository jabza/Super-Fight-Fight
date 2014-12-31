local class = require("extlibs.middleclass")
require("Fighter")

PlayerFighter = class('PlayerFighter', Fighter)

function PlayerFighter:initialize(positionX, positionY, health, stamina)
  Fighter.initialize(self, positionX, positionY, health, stamina)

  self.direction = "right"

  self.anim["idle"] = newAnimation(love.graphics.newImage("resources/player/idle.png"), 128, 256, 1, 0)
  self.anim["walk"] = newAnimation(love.graphics.newImage("resources/player/walk.png"), 128, 256, 0.15, 0)
  self.anim["crouch"] = newAnimation(love.graphics.newImage("resources/player/crouch.png"), 128, 256, 0.1, 0)

  self.anim["block"] = newAnimation(love.graphics.newImage("resources/player/block.png"), 128, 256, 1, 0)
  self.anim["blockLow"] = newAnimation(love.graphics.newImage("resources/player/blockLow.png"), 128, 256, 1, 0)

  self.anim["jump"] = newAnimation(love.graphics.newImage("resources/player/jump.png"), 128, 256, 0.25, 0)
  self.anim["jump"]:setMode("once")

  self.anim["jab"] = newAnimation(love.graphics.newImage("resources/player/jab.png"), 128, 256, 0.15, 0)
  self.anim["jab"]:setMode("once")

  self.anim["hook"] = newAnimation(love.graphics.newImage("resources/player/hook.png"), 128, 256, 0.15, 0)
  self.anim["hook"]:setMode("once")

  self.anim["strike"] = newAnimation(love.graphics.newImage("resources/player/strike.png"), 128, 256, 0.15, 0)
  self.anim["strike"]:setMode("once")
end

function PlayerFighter:update(dt)
  --Movement.
  if love.keyboard.isDown("left") then
    if self.action == "idle" then
      self.action = "walk"
      self.direction = "left"
    elseif self.action ~= "walk" then
      self.direction = "left"
    end
  elseif love.keyboard.isDown("right") then
    if self.action == "idle" then
      self.action = "walk"
      self.direction = "right"
    elseif self.action ~= "walk" then
      self.direction = "right"
    end
  end

  --Crouch and blocking.
  if love.keyboard.isDown("down") and love.keyboard.isDown("lctrl") then
    if self.action == "idle" or self.action == "crouch" or self.action == "block" then
      self.action = "blockLow"
    end
  elseif love.keyboard.isDown("lctrl") then
    if self.action == "idle" or self.action == "crouch" or self.action == "blockLow" then
      self.action = "block"
    end
  elseif love.keyboard.isDown("down") then
    if self.action == "idle" or self.action == "block" or self.action == "blockLow" then
      self.action = "crouch"
    end
  elseif self.action == "crouch" or self.action == "block" or self.action == "blockLow" then
    self.action = "idle"
  end

  Fighter.update(self, dt)
end

function PlayerFighter:keyreleased(key)
  if key == "left" or key == "right" then
    if self.action == "walk" then
      self.action = "idle"
    end
  end

  if key == "a" and self.action ~= "hook" and self.action ~= "strike" and self.sp >= 10 then
    self.sp = self.sp - 10
    self.action = "jab"
  elseif key == "s" and self.action ~= "jab" and self.action ~= "strike" and self.sp >= 30 then
    self.sp = self.sp - 20
    self.action = "hook"
  elseif key == "d" and self.action ~= "jab" and self.action ~= "hook" and self.sp >= 60 then
    self.sp = self.sp - 40
    self.action = "strike"
  end

  if key == "up" then
    if self.action ~= "jump" and self.action ~= "jab" and self.action ~= "hook" and self.action ~= "strike" then
      if self.action == "walk" and self.direction == "right" then
        self.body:applyLinearImpulse(1000, -3000)
      elseif self.action == "walk" and self.direction == "left" then
        self.body:applyLinearImpulse(-1000, -3000)
      else
        self.body:applyLinearImpulse(0, -3000)
      end
      self.action = "jump"
    end
  end
end
