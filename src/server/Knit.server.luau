local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local StarterGui = game:GetService("StarterGui")
local MainMenuUI = StarterGui:WaitForChild("Main Menu")
local LoadingScreenUI = MainMenuUI:WaitForChild("Loading Screen")
LoadingScreenUI.Visible = true -- Show the loading screen UI initially

do
    Knit.AddServicesDeep(script.Parent.Services)

    Knit.Start()
        :andThen(function()
            print("Server has started!")
        end)
        :catch(warn)
end