require("extlibs.anim")
local class = require("extlibs.middleclass")

Fighter = class('Fighter')

function Fighter:initialize(positionX, positionY, health, stamina)
  --Core attributes.
  self.hp = health
  self.sp = stamina
  self.speed = 128

  --Stamina regeneration timer.
  self.regenTimer = 0

  --Cost of attacks in stamina.
  self.jabCost      = 10
  self.hookCost     = 20
  self.strikeCost   = 60

  --Damage of attacks in health.
  self.jabDmg       = 10
  self.hookDmg      = 20
  self.strikeDmg    = 40

  --Range of attacks in pixels.
  self.jabRange     = 15
  self.hookRange    = 15
  self.strikeRange  = 15

  --Current and next action.
  self.action = "idle"
  self.nextAction = ""

  --Movement variables.
  self.direction = "right"
  self.facing = "right"
  self.falling = false

  --Animation container.
  self.anim = {}

  --Physics properties.
  self.body = love.physics.newBody(world, positionX, positionY, "dynamic")
  self.body:setFixedRotation(true)
  self.shape = love.physics.newRectangleShape(50, 130)
  self.fixture = love.physics.newFixture(self.body, self.shape, 10)
end

--Update the Fighter.
function Fighter:update(dt)
  self:healthCheck()
  self:physicsCheck()
  self:regenStamina(dt)
  self:faceOpponent()

  --Update actions.
  self:updateMovementActions(dt)
  self:updateAttackActions()
  self:updateDamageActions()

  --Update animation.
  self.anim[self.action]:update(dt)

  --Process next action.
  self:processNextAction()
end

function Fighter:healthCheck()
  --Check health.
  if self.hp <= 0 then
    self.nextAction = "death"
  end
end

function Fighter:physicsCheck()
  --Bounds checking, keep fighters on screen.
  if self.body:getX()-32 < 0 then
    self.body:setX(32)
  elseif (self.body:getX()+32) > love.graphics.getWidth() then
    self.body:setX(love.graphics.getWidth()-32)
  end

  --Check falling.
  x, y = self.body:getLinearVelocity()
  if y == 0 then
    self.falling = false
  else
    self.falling = true
  end
end

--Make fighters always face each other.
function Fighter:faceOpponent()
  if player.body:getX() < ai.body:getX() then
    player.facing = "right"
    ai.facing = "left"
  else
    player.facing = "left"
    ai.facing = "right"
  end
end

--Regenerate stamina.
function Fighter:regenStamina(dt)
  if self.sp < 100 then
    self.regenTimer = self.regenTimer + dt
    if self.regenTimer >= 1 then
      self.sp = self.sp + 5
      self.regenTimer = 0
    end
  else
    self.regenTimer = 0
  end
end

--Asses the nextAction proposed.
function Fighter:processNextAction()
  --If there is a next action to be processed.
  if self.nextAction ~= "" and self.nextAction ~= self.action then
    --Actions that can't be interrupted.
    if self.action == "dmg" or self.action == "crouchDmg" then
      self.nextAction = ""
      return
    end
    --Actions that can't be interrupted.
    if self.action == "jab" or self.action == "hook" or self.action == "strike" or
       self.action == "crouchJab" or self.action == "crouchHook" or self.action == "crouchStrike" then
      self.nextAction = ""
      return
    end

    --Death action.
    if self.nextAction == "death" then
      self.action = self.nextAction
      self.body:applyLinearImpulse(0, -2000)
      state = "gameover"
      return
    end

    if not self.falling then
      if self.nextAction == "idle" then
        self.action = self.nextAction
      elseif self.nextAction == "walk" and (self.action == "idle" or self.action == "block")  then
        self.action = self.nextAction
      elseif self.nextAction == "crouch" then
        self.action = self.nextAction
      end
    end

    --Apply jump velocity based on direction.
    if self.nextAction == "jump" and self.action ~="jump" then
      if self.action == "walk" and self.direction == "right" then
        self.body:applyLinearImpulse(1000, -3000)
        self.action = self.nextAction
      elseif self.action == "walk" and self.direction == "left" then
        self.body:applyLinearImpulse(-1000, -3000)
        self.action = self.nextAction
      elseif self.action == "idle" then
        self.body:applyLinearImpulse(0, -3000)
        self.action = self.nextAction
      end
      self.anim[self.nextAction]:reset()
    end

    --Block actions.
    if self.nextAction == "block" then
      self.action = self.nextAction
    elseif self.nextAction == "crouchBlock" and y == 0 then
      self.action = self.nextAction
    end

    --Combat actions.
    if self.nextAction == "jab" and self.sp >= self.jabCost then
      self.sp = self.sp - self.jabCost
      if self.action == "crouch" or self.action == "crouchBlock" then
        self.action = "crouchJab"
      else
        self.action = self.nextAction
      end
      self.anim[self.action]:reset()
    end

    if self.nextAction == "hook" and self.sp >= self.hookCost then
      self.sp = self.sp - self.hookCost
      if self.action == "crouch" or self.action == "crouchBlock" then
        self.action = "crouchHook"
      else
        self.action = self.nextAction
      end
      self.anim[self.action]:reset()
    end

    if self.nextAction == "strike" and self.sp >= self.strikeCost then
      self.sp = self.sp - self.strikeCost
      if self.action == "crouch" or self.action == "crouchBlock" then
        self.action = "crouchStrike"
      else
        self.action = self.nextAction
      end
      self.anim[self.action]:reset()
    end

    --If this is the PlayerFighter update, pass the Expert System the player's action.
    if self:isInstanceOf(PlayerFighter) then
      ai.expert:assessAction(self.action)
    end
  end
  --Reset the nextAction.
  self.nextAction = ""
end

function Fighter:updateMovementActions(dt)
  --Process movement.
  if self.action == "walk" then
    if self.direction == "left" then
      self.body:setX(self.body:getX() - (self.speed*dt))
      if self.facing == "right" then
        self.anim[self.action]:setMode("reverse")
      else
        self.anim[self.action]:setMode("loop")
      end
    elseif self.direction == "right" then
      self.body:setX(self.body:getX() + (self.speed*dt))
      if self.facing == "left" then
        self.anim[self.action]:setMode("reverse")
      else
        self.anim[self.action]:setMode("loop")
      end
    end
  end

  --Process jump.
  if self.action == "jump" then
    if self.anim[self.action]:getCurrentFrame() == 4 then
      --Hold at frame 4 whilst falling.
      self.anim[self.action]:seek(4)
      self.nextAction = "idle"
    end
  end
end

function Fighter:updateAttackActions()
  --Get distance.
  local dist = love.physics.getDistance(player.fixture, ai.fixture)
  local hitAction = ""

  --Process jab.
  if self.action == "jab" or self.action == "crouchJab" then
    if self.anim[self.action]:getCurrentFrame() == 3 then

      if dist <= self.jabRange then
        hitAction = self.action
      end

      if self.action == "jab" then
        self.action = "idle"
      else
        self.action = "crouch"
      end
    end
  end

  --Process hook.
  if self.action == "hook" or self.action == "crouchHook" then
    if self.anim[self.action]:getCurrentFrame() == 4 then

      if dist <= self.hookRange then
        hitAction = self.action
      end

      if self.action == "hook" then
        self.action = "idle"
      else
        self.action = "crouch"
      end
    end
  end

  --Process strike.
  if self.action == "strike" or self.action == "crouchStrike" then
    if self.anim[self.action]:getCurrentFrame() == 5 then

      if dist <= self.strikeRange then
        hitAction = self.action
      end

      if self.action == "strike" then
        self.action = "idle"
      else
        self.action = "crouch"
      end
    end
  end

  --Process hit.
  if hitAction ~= "" then
    if self:isInstanceOf(PlayerFighter) then
        ai:dealDamage(hitAction)
    else
        player:dealDamage(hitAction)
    end
  end
end

function Fighter:updateDamageActions()
  --Process dmg and crouchDmg.
  if self.action == "dmg" or self.action == "crouchDmg" then
    if self.anim[self.action]:getCurrentFrame() == 3 then
      self.anim[self.action]:reset()
      self.action = "idle"
    end
  end
end

--Determine if fighter gets hit.
function Fighter:dealDamage(action)
  local hit = false

  if action == "jab" and self.action ~= "block" and not string.match(self.action, "crouch") then
    self.hp = self.hp - self.jabDmg
    hit = true
  elseif action == "hook" and self.action ~= "block" and not string.match(self.action, "crouch") then
    self.hp = self.hp - self.hookDmg
    hit = true
  elseif action == "strike" and self.action ~= "block" and not string.match(self.action, "crouch") then
    self.hp = self.hp - self.strikeDmg
    hit = true
  end

  if action == "crouchJab" and self.action ~= "crouchBlock" then
    self.hp = self.hp - self.jabDmg
    hit = true
  elseif action == "crouchHook" and self.action ~= "crouchBlock" then
    self.hp = self.hp - self.hookDmg
    hit = true
  elseif action == "crouchStrike" and self.action ~= "crouchBlock" then
    self.hp = self.hp - self.strikeDmg
    hit = true
  end

  if hit then
    if string.match(self.action, "crouch") then
      self.action = "crouchDmg"
    else
      self.action = "dmg"
    end

    if string.match(action, "strike") or string.match(action, "Strike") then
      if self.facing == "right" then
        self.body:applyLinearImpulse(-1800, 0)
      else
        self.body:applyLinearImpulse(1800, 0)
      end
    end
  end

end

function Fighter:render()
  if self.facing == "right" then
    self.anim[self.action]:draw(self.body:getX()-60, self.body:getY()-175)
  elseif self.facing == "left" then --Flip image.
    self.anim[self.action]:draw((self.body:getX()-60)+self.anim[self.action]:getWidth(), self.body:getY()-175, 0, -1, 1)
  end
end
