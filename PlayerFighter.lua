local class = require("extlibs.middleclass")
require("Fighter")

PlayerFighter = class('PlayerFighter', Fighter)

function PlayerFighter:initialize(positionX, positionY, health, stamina)
  --Initialize base class.
  Fighter.initialize(self, positionX, positionY, health, stamina)

  --Setup animations
  self.anim["idle"]         = newAnimation(love.graphics.newImage("resources/player/idle.png"), 128, 256, 1, 0)
  self.anim["walk"]         = newAnimation(love.graphics.newImage("resources/player/walk.png"), 128, 256, 0.15, 0)
  self.anim["crouch"]       = newAnimation(love.graphics.newImage("resources/player/crouch.png"), 128, 256, 0.1, 0)
  self.anim["block"]        = newAnimation(love.graphics.newImage("resources/player/block.png"), 128, 256, 1, 0)
  self.anim["crouchBlock"]  = newAnimation(love.graphics.newImage("resources/player/crouchBlock.png"), 128, 256, 1, 0)
  self.anim["jump"]         = newAnimation(love.graphics.newImage("resources/player/jump.png"), 128, 256, 0.25, 0)
  self.anim["jab"]          = newAnimation(love.graphics.newImage("resources/player/jab.png"), 128, 256, 0.15, 0)
  self.anim["crouchJab"]    = newAnimation(love.graphics.newImage("resources/player/crouchJab.png"), 128, 256, 0.15, 0)
  self.anim["hook"]         = newAnimation(love.graphics.newImage("resources/player/hook.png"), 128, 256, 0.2, 0)
  self.anim["crouchHook"]   = newAnimation(love.graphics.newImage("resources/player/crouchHook.png"), 128, 256, 0.15, 0)
  self.anim["strike"]       = newAnimation(love.graphics.newImage("resources/player/strike.png"), 128, 256, 0.15, 0)
  self.anim["crouchStrike"] = newAnimation(love.graphics.newImage("resources/player/crouchStrike.png"), 128, 256, 0.15, 0)
  self.anim["dmg"]          = newAnimation(love.graphics.newImage("resources/player/dmg.png"), 128, 256, 0.1, 0)
  self.anim["crouchDmg"]    = newAnimation(love.graphics.newImage("resources/player/crouchDmg.png"), 128, 256, 0.1, 0)
  self.anim["death"]        = newAnimation(love.graphics.newImage("resources/player/death.png"), 256, 256, 0.1, 0)

  self.anim["jump"]:setMode("once")
  self.anim["jab"]:setMode("once")
  self.anim["hook"]:setMode("once")
  self.anim["strike"]:setMode("once")
  self.anim["dmg"]:setMode("once")
  self.anim["crouchDmg"]:setMode("once")
  self.anim["death"]:setMode("once")
end

function PlayerFighter:update(dt)
  --Call base update.
  Fighter.update(self, dt)

  --Movement.
  if love.keyboard.isDown("left") then
    if self.action == "idle" then
      self.nextAction = "walk"
    end
    self.direction = "left"
  elseif love.keyboard.isDown("right") then
    if self.action == "idle" then
      self.nextAction = "walk"
    end
    self.direction = "right"
  end

  --Crouch and blocking.
  if love.keyboard.isDown("down") and love.keyboard.isDown("lctrl") then
      self.nextAction = "crouchBlock"
  elseif love.keyboard.isDown("lctrl") then
      self.nextAction = "block"
  elseif love.keyboard.isDown("down") then
      self.nextAction = "crouch"
  end
end

function PlayerFighter:keyreleased(key)
  --Stop movement.
  if key == "left" or key == "right" then
    self.nextAction = "idle"
  end

  if key == "-" then
    ai.hp = ai.hp - 5
  elseif key == "=" then
    ai.hp = ai.hp + 5
  end

  if key == "[" then
    ai.sp = ai.sp - 5
  elseif key == "]" then
    ai.sp = ai.sp + 5
  end

  --Stop crouching.
  if key == "down" then
    if love.keyboard.isDown("lctrl") then
      self.nextAction = "block"
    else
      self.nextAction = "idle"
    end
  end

  --Stop blocking.
  if key == "lctrl" then
    if love.keyboard.isDown("down") then
      self.nextAction = "crouch"
    else
      self.nextAction = "idle"
    end
  end

  --Attacks
  if key == "z" then
    self.nextAction = "jab"
  elseif key == "x" then
    self.nextAction = "hook"
  elseif key == "c" then
    self.nextAction = "strike"
  end

  --Jump
  if key == "up" then
    self.nextAction = "jump"
  end
end
