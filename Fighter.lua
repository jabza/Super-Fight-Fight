require("extlibs.anim")
local class = require("extlibs.middleclass")

Fighter = class('Fighter')

function Fighter:initialize(positionX, positionY, health, stamina)
  self.hp = health
  self.sp = stamina
  self.regenTimer = 0
  self.speed = 128
  self.action = "idle"
  self.direction = "right"
  self.anim = {}

  self.body = love.physics.newBody(world, positionX, positionY, "dynamic")
  self.body:setFixedRotation(true)
  self.shape = love.physics.newRectangleShape(64, 160)
  self.fixture = love.physics.newFixture(self.body, self.shape, 10)
end

function Fighter:update(dt)
  
  --Regenerate stamina.
  if self.sp < 100 then
    self.regenTimer = self.regenTimer + dt

    if self.regenTimer >= 1 then
      self.sp = self.sp + 5
      self.regenTimer = 0
    end
  else
    self.regenTimer = 0
  end

  --Process movement.
  if self.action == "walk" then
    if self.direction == "left" then
      self.body:setX(self.body:getX() - (self.speed*dt))
    elseif self.direction == "right" then
      self.body:setX(self.body:getX() + (self.speed*dt))
    end
  end

  --Process jump.
  if self.action == "jump" then
    if self.anim["jump"]:getCurrentFrame() == 4 then
      self.anim["jump"]:reset()
      self.action = "idle"
    end
  end

  --Process jab.
  if self.action == "jab" then
    if self.anim["jab"]:getCurrentFrame() == 3 then
      self.anim["jab"]:reset()
      self.action = "idle"
    end
  end

  --Process hook.
  if self.action == "hook" then
    if self.anim["hook"]:getCurrentFrame() == 4 then
      self.anim["hook"]:reset()
      self.action = "idle"
    end
  end

  --Process strike.
  if self.action == "strike" then
    if self.anim["strike"]:getCurrentFrame() == 5 then
      self.anim["strike"]:reset()
      self.action = "idle"
    end
  end

  --Bounds checking.
  if self.body:getX()-32 < 0 then
    self.body:setX(32)
  elseif (self.body:getX()+32) > love.graphics.getWidth() then
    self.body:setX(love.graphics.getWidth()-32)
  end

  self.anim[self.action]:update(dt)
end

function Fighter:render()
  if self.direction == "right" then
    self.anim[self.action]:draw(self.body:getX()-60, self.body:getY()-175)
  elseif self.direction == "left" then --Flip image.
    self.anim[self.action]:draw((self.body:getX()-60)+self.anim[self.action]:getWidth(), self.body:getY()-175, 0, -1, 1)
  end
end
