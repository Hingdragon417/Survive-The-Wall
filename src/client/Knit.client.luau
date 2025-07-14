local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local success = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, "All")

while not success do
    success = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, "All", false)
    task.wait()
end

do
    Knit.AddControllersDeep(script.Parent.Controllers)

    Knit.Start()
        :andThen(function()
            print("Client has started!")
        end)
        :catch(warn)
end