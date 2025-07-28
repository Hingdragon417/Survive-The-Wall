local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

do
    Knit.AddServicesDeep(script.Parent.Services)

    Knit.Start()
        :andThen(function()
            print("Server has started!")
        end)
        :catch(warn)
end