require("PlayerFighter")
require("AIFighter")

local player = PlayerFighter:new(0, love.graphics.getHeight()/2, 100, 100)
local ai = AIFighter:new(love.graphics.getWidth(), love.graphics.getHeight()/2, 100, 100)

function love.load()
  player:setSprite(love.graphics.newImage("resources/player.png"))
  ai:setSprite(love.graphics.newImage("resources/enemy.png"))

  ai.x = ai.x - ai.sprite:getWidth()
end

function love.update(dt)
  player:update(dt)
  ai:update(dt)
end

function love.draw()
  player:render()
  ai:render()

  renderUI()
end

function renderUI()
  love.graphics.print("Player", 0, 0)
  love.graphics.print("HP: "..player.hp, 0, 12)
  love.graphics.print("SP: "..player.sp, 0, 24)

  love.graphics.print("AI", love.graphics.getWidth()-50, 0)
  love.graphics.print("HP: "..ai.hp, love.graphics.getWidth()-50, 12)
  love.graphics.print("SP: "..ai.sp, love.graphics.getWidth()-50, 24)
end
