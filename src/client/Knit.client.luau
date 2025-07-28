local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

do
    Knit.AddControllersDeep(script.Parent.Controllers)

    Knit.Start()
        :andThen(function()
            print("Client has started!")
        end)
        :catch(warn)
end