local class = require("extlibs.middleclass")

Fighter = class('Fighter')

function Fighter:initialize(positionX, positionY, health, stamina)
  self.x = positionX
  self.y = positionY
  self.hp = health
  self.sp = stamina
  self.speed = 200
end

function Fighter:setSprite(sprite)
  self.sprite = sprite
end

function Fighter:update(dt)
  if self.x < 0 then
    self.x = 0
  elseif (self.x + self.sprite:getWidth()) > love.graphics.getWidth() then
    self.x = love.graphics.getWidth()-self.sprite:getWidth()
  end

end

function Fighter:render()
  love.graphics.draw(self.sprite, self.x, self.y)
end
