local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local TestController = Knit.CreateController({
    Name = "TestController",
})

function TestController:KnitStart() 
    print("start")
end

function TestController:KnitInit()
    print("init")
end

return TestController