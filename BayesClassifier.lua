local class = require("extlibs.middleclass")
BayesClassifier = class('BayesClassifier')

function BayesClassifier:initialize(m, p, attrCount, classCount)
  self.m = m
  self.p = p
  self.attrCount = attrCount
  self.classCount = classCount
end

function BayesClassifier:classify(trainingData, testData)

  local probabilities = {}

  --Calculate the probability for each classification in the training data.
  for classification, trainSet in pairs(trainingData) do
    --print("Calculating "..classification.." probability.")

    probabilities[classification] = 1.0
    local matches = {}

    for attr=1, self.attrCount, 1 do
      matches[attr] = 0

      for i=1, table.getn(trainSet), 1 do
          if testData[attr] == trainSet[i][attr] then
            matches[attr] = matches[attr] + 1
          end
      end

      probabilities[classification] =
      probabilities[classification] * ((matches[attr] + (self.m * self.p))/(self.classCount + self.m))

      --print("attr = "..testData[attr]..", matches = "..matches[attr]..", probability = "..(matches[attr] + (self.m * self.p))/(self.classCount + self.m))
    end
  end

  result = ""
  maxProb = 0
  for classification, probability in pairs(probabilities) do
    if probability > maxProb then
      maxProb = probability
      result = classification
    end
  end

  return result
end
