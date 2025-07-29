local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local player = Players.LocalPlayer
local ScreenGUI = player:WaitForChild("PlayerGui"):WaitForChild("MainUI")
local buttonsFrame = ScreenGUI:WaitForChild("Buttons")
local currencyFrame = ScreenGUI:WaitForChild("Currency")
local currencyLabel = currencyFrame:WaitForChild("Amount")
local timeLabel = ScreenGUI:WaitForChild("Time"):WaitForChild("TimeLabel")

local UIController = Knit.CreateController({
	Name = "UIController",
})

local HOVER_SCALE = 1.1
local CLICK_SCALE = 0.9
local DEFAULT_SCALE = 1
local TWEEN_TIME = 0.15

local currentStatus = "Waiting"
local currentTime = nil

local function tweenUIScale(uiScale, targetScale)
	local tween = TweenService:Create(uiScale, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = targetScale
	})
	tween:Play()
end

local function setupButtonTweens(button)
	local uiScale = button:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Scale = DEFAULT_SCALE
	uiScale.Parent = button

	button.MouseEnter:Connect(function()
		tweenUIScale(uiScale, HOVER_SCALE)
	end)

	button.MouseLeave:Connect(function()
		tweenUIScale(uiScale, DEFAULT_SCALE)
	end)

	button.MouseButton1Down:Connect(function()
		tweenUIScale(uiScale, CLICK_SCALE)
	end)

	button.MouseButton1Up:Connect(function()
		tweenUIScale(uiScale, HOVER_SCALE)
	end)
end

local function updateTimeLabel()
	if currentTime == nil then
		timeLabel.Text = currentStatus
	else
		local minutes = math.floor(currentTime / 60)
		local seconds = currentTime % 60
		timeLabel.Text = currentStatus .. " | " .. string.format("%02d:%02d", minutes, seconds)
	end
end

function UIController:KnitStart()
	local DataService = Knit.GetService("DataService")
	local RoundService = Knit.GetService("RoundService")

	DataService.ReplicateData:Connect(function(data, index)
		if index == "Coins" and typeof(data) == "number" then
			currencyLabel.Text = "C: " .. tostring(data)
		end
	end)

	RoundService.TimeUpdated:Connect(function(secondsLeft)
		currentTime = secondsLeft
		updateTimeLabel()
	end)

	RoundService.StatusUpdated:Connect(function(status)
		currentStatus = status
		updateTimeLabel()
	end)

	for _, child in ipairs(buttonsFrame:GetDescendants()) do
		if child:IsA("TextButton") or child:IsA("ImageButton") then
			setupButtonTweens(child)
		end
	end
end

function UIController:KnitInit()
end

return UIController
