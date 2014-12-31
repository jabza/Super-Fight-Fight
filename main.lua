require("PlayerFighter")
require("AIFighter")

debugWorldDraw = require("extlibs.debugWorldDraw")

function love.load()
  --Create global physics world.
  love.physics.setMeter(128)
  world = love.physics.newWorld(0, 9.81*love.physics.getMeter(), true)

  --Create the ground layer, settings its centre position.
  ground = {}
  ground.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()-50, "static")
  ground.shape = love.physics.newRectangleShape(love.graphics.getWidth(), 100)
  ground.fixture = love.physics.newFixture(ground.body, ground.shape)

  --Create the player fighter.
  player = PlayerFighter:new(100, 0, 100, 100)

  --Create the AI fighter.
  ai = AIFighter:new(400, 0, 100, 100)

end

function love.update(dt)
  world:update(dt)
  
  player:update(dt)
  ai:update(dt)
end

function love.keyreleased(key)
  player:keyreleased(key)
end

function love.draw()
  --debugWorldDraw(world,0,0,love.graphics.getWidth(), love.graphics.getHeight())

  player:render()
  ai:render()

  renderUI()
end

function renderUI()
  love.graphics.print("Player", 0, 0)
  love.graphics.print("Health: "..player.hp, 0, 12)
  love.graphics.print("Stamina: "..player.sp, 0, 24)

  love.graphics.print("AI", love.graphics.getWidth()-100, 0)
  love.graphics.print("Health: "..ai.hp, love.graphics.getWidth()-100, 12)
  love.graphics.print("Stamina: "..ai.sp, love.graphics.getWidth()-100, 24)
end
