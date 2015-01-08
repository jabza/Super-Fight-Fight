local class = require("extlibs.middleclass")
BayesClassifier = class('BayesClassifier')

function BayesClassifier:initialize(attrCount, classCount)
  self.attrCount = attrCount
  self.classCount = classCount
  self.m = 2.0
  self.p = 0.5
end

function BayesClassifier:classify(trainingData, testData)

  local probabilities = {}

  --Calculate the probability for each classification in the training data.
  for classification, trainSet in pairs(trainingData) do
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
    end
  end

  --Pick the best probability.
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
