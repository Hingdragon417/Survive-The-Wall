local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local TestService = Knit.CreateService({
    Name = "TestService",
    Client = {}
})



function TestService:KnitStart()

end

function TestService:KnitInit() 

end

return TestService
