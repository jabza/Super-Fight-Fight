local class = require("extlibs.middleclass")
require("Fighter")

PlayerFighter = class('PlayerFighter', Fighter)

function PlayerFighter:initialize(positionX, positionY, health, stamina)
  Fighter.initialize(self, positionX, positionY, health, stamina)
end

function PlayerFighter:update(dt)
  if love.keyboard.isDown("left") then
    self.x = self.x - (self.speed*dt)
  end

  if love.keyboard.isDown("right") then
    self.x = self.x + (self.speed*dt)
  end

  Fighter.update(self, dt)
end
