local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local player = Players.LocalPlayer 
local playerGUI = player:WaitForChild("PlayerGui")
local ScreenGUI = playerGUI:WaitForChild("UI")
local ClickHolderFrame = ScreenGUI:WaitForChild("Click")
local ClickButton = ClickHolderFrame:WaitForChild("Click")

local UIController = Knit.CreateController({
    Name = "UIController",
})

local tweenTime = 0.2 

function UIController:TweenObject(object : GuiObject | Frame, targetScale : number, doWait : boolean?)
    local buttonOrginalSize = object.Size
    local uiScale = object:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", object)
    local tween = TweenService:Create(uiScale, self._tweenInfo, {Scale = targetScale})

    tween:Play()

    if doWait then
        tween.Completed:Wait()
    end 
    return tween 
end

function UIController:Click(button : GuiButton | Frame)
    if button.Parent.Name == button.Name then 
        button = button.Parent
    end
    local tween = self:TweenObject(button, 0.9, true)
    task.spawn(function()
        self:TweenObject(button, 1, true)
    end)
end

function UIController:KnitStart() 
    for _, button in ScreenGUI:GetDescendants() do
        if button:IsA("GuiButton") then
            button.MouseButton1Click:Connect(function()
                self:Click(button)
            end)
        end
    end
end

function UIController:KnitInit()
    self._tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

return UIController