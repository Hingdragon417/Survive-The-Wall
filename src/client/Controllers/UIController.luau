local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local player = Players.LocalPlayer 
local playerGUI = player:WaitForChild("PlayerGui")
local ScreenGUI = playerGUI:WaitForChild("Main")
local ClickHolderFrame = ScreenGUI:WaitForChild("Click")
local ClickButton = ClickHolderFrame:WaitForChild("Click")

local UIController = Knit.CreateController({
    Name = "UIController",
})

local tweenTime = 0.2 

function UIController:TweenObject(object : GuiObject | Frame, targetScale : number, doWait : boolean?)
    local uiScale = object:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", object)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(uiScale, tweenInfo, {Scale = targetScale})
    tween:Play()
    if doWait then
        tween.Completed:Wait()
    end
    return tween 
end

function UIController:Click()
    
end

function UIController:KnitStart() 
    print("start")
end

function UIController:KnitInit()
    print("init")
end

return UIController