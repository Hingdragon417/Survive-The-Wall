local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local INTERMISSION_TIME = 15
local ROUND_TIME = 5 * 60

local RoundService = Knit.CreateService({
	Name = "RoundService",
	Client = {
		TimeUpdated = Knit.CreateSignal(),
		StatusUpdated = Knit.CreateSignal(),
	},
})

function RoundService:waitForEnoughPlayers()
	while #Players:GetPlayers() < 0 do
		self.Client.StatusUpdated:FireAll("Waiting for players...")
		self.Client.TimeUpdated:FireAll(nil)
		task.wait(1)
	end
end

function RoundService:removePlayerFromRound(player)
	for i, p in ipairs(self.roundPlayers) do
		if p == player then
			table.remove(self.roundPlayers, i)
			break
		end
	end
end

function RoundService:startRoundLoop()
	while true do
		self:waitForEnoughPlayers()

		self.Client.StatusUpdated:FireAll("Intermission")
		for t = INTERMISSION_TIME, 0, -1 do
			self.Client.TimeUpdated:FireAll(t)
			task.wait(1)
		end

		self.roundPlayers = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				table.insert(self.roundPlayers, player)

				local humanoid = player.Character:FindFirstChild("Humanoid")
				local connection
				connection = humanoid.Died:Connect(function()
					self:removePlayerFromRound(player)
					connection:Disconnect()
				end)
			end
		end

		self.Client.StatusUpdated:FireAll("Game Started")
		local roundStart = tick()

		while tick() - roundStart < ROUND_TIME and #self.roundPlayers > 0 do
			local remaining = math.max(0, math.floor(ROUND_TIME - (tick() - roundStart)))
			self.Client.TimeUpdated:FireAll(remaining)
			task.wait(1)
		end

		self.Client.StatusUpdated:FireAll("Game Over")
		self.Client.TimeUpdated:FireAll(0)

		task.wait(3)
	end
end

function RoundService:KnitStart()
	task.spawn(function()
		self:startRoundLoop()
	end)
end

function RoundService:KnitInit()
	self.roundPlayers = {}
end

return RoundService
