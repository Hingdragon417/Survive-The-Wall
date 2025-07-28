local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local player = Players.LocalPlayer

local followDistance = 15
local minZoom, maxZoom = 5, 50
local sensitivity = 0.1
local zoomSpeed = 1

local CameraController = Knit.CreateController({
    Name = "CameraController",
})

local currentAngle = 45
local currentPitch = 0
local connection
local shiftPressed = false
local currentTween
local originalCFrame

function CameraController:UpdateCamera()
    local success, err = pcall(function()
        local character = player.Character
        if not character then return end

        local HRP = character:FindFirstChild("HumanoidRootPart")
        if not HRP then return end

        local yaw = math.rad(currentAngle)
        local pitch = math.rad(math.clamp(currentPitch, -60, 60))

        local direction = Vector3.new(
            math.cos(pitch) * math.sin(yaw),
            math.sin(pitch),
            math.cos(pitch) * math.cos(yaw)
        )

        local cameraHeightOffset = Vector3.new(0, 3, 0)
        local cameraPosition = HRP.Position + cameraHeightOffset + direction * followDistance

        workspace.CurrentCamera.CFrame = CFrame.lookAt(
            cameraPosition,
            HRP.Position + cameraHeightOffset,
            Vector3.new(0, 1, 0)
        )

        HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, yaw, 0)
    end)

    if not success then
        warn("Camera Update Error:", err)
    end
end



function CameraController:EnableCameraControl()
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false

    connection = RunService.RenderStepped:Connect(function()
        local delta = UserInputService:GetMouseDelta()
        currentAngle -= delta.X * sensitivity
        currentPitch -= delta.Y * sensitivity
        currentPitch = math.clamp(currentPitch, -90, 90)

        self:UpdateCamera()
    end)
end

function CameraController:DisableCameraControl()
    if connection then
        connection:Disconnect()
        connection = nil
    end

    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
end

function CameraController:ToggleCamera()
    if not shiftPressed then
        shiftPressed = true
        self:EnableCameraControl()
    else
        shiftPressed = false
        self:DisableCameraControl()
    end
end

function CameraController:KnitStart()
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            self:ToggleCamera()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local scroll = input.Position.Z
            followDistance = math.clamp(followDistance - scroll * zoomSpeed, minZoom, maxZoom)
        end
    end)
end

function CameraController:KnitInit()
    print("CameraController initialized")
end

return CameraController
