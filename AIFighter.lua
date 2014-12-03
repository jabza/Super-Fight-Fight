local class = require("extlibs.middleclass")
require("Fighter")

AIFighter = class('AIFighter', Fighter)

function AIFighter:initialize(positionX, positionY, health, stamina)
  Fighter.initialize(self, positionX, positionY, health, stamina)
end
