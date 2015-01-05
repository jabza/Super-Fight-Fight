require("PlayerFighter")
require("AIFighter")

function love.load()
  --Create global physics world.
  love.physics.setMeter(128)
  world = love.physics.newWorld(0, 9.81*love.physics.getMeter(), true)

  --Create the ground layer, settings its centre position.
  ground = {}
  ground.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()-50, "static")
  ground.shape = love.physics.newRectangleShape(love.graphics.getWidth(), 100)
  ground.fixture = love.physics.newFixture(ground.body, ground.shape)

  --Create the background image.
  background = love.graphics.newImage("resources/bg.png")

  --Create the player fighter.
  player = PlayerFighter:new(100, 0, 100 , 100)

  --Create the AI fighter.
  ai = AIFighter:new(900, 0, 100, 100)

  --Set the state to playing.
  state = "playing"
end

function love.update(dt)
  --Physics update.
  world:update(dt)

  --If the game is in play.
  if state == "playing" then
    player:update(dt)
    ai:update(dt)
  end
end

function love.keyreleased(key)
  if state == "playing" then
    player:keyreleased(key)
  end

  --Reload the game.
  if key == "r" then
    love.load()
  end
end

function love.draw()
  --Render the background.
  love.graphics.draw(background)

  --Render the fighters.
  player:render()
  ai:render()

  --Render the UI.
  renderUI()
end

function renderUI()
  if state == "gameover" then
    love.graphics.print("KO! - Again? (R)", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
  end

  love.graphics.print("Player", 0, 0)
  love.graphics.print("Threat of player: "..ai.input[3], 0, 60)

  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.rectangle("fill", 0, 20, ((love.graphics.getWidth()/2)-5)*(player.hp/100), 20)
  love.graphics.setColor(255, 255, 0, 255)
  love.graphics.rectangle("fill", 0, 45, ((love.graphics.getWidth()/2)-5)*(player.sp/100), 10)
  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.print("AI", love.graphics.getWidth()-130, 0)
  love.graphics.print("Behaviour: "..ai.behaviour, love.graphics.getWidth()-130, 60)
  love.graphics.print("FuzzyHP: "..ai.input[1], love.graphics.getWidth()-130, 75)
  love.graphics.print("FuzzySP: "..ai.input[2], love.graphics.getWidth()-130, 90)
  love.graphics.print("FuzzyRa: "..ai.input[4], love.graphics.getWidth()-130, 105)

  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.rectangle("fill", love.graphics.getWidth()+5, 20, -(love.graphics.getWidth()/2)*(ai.hp/100), 20)
  love.graphics.setColor(255, 255, 0, 255)
  love.graphics.rectangle("fill", love.graphics.getWidth()+5, 45, -(love.graphics.getWidth()/2)*(ai.sp/100), 10)
  love.graphics.setColor(255, 255, 255, 255)

end
