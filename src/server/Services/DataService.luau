--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Signal = require(ReplicatedStorage.Packages.Signal)

--// Shared
local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local DATA_TEMPLATE = require(Shared.Data.Template)

--// Constants
local IS_STUDIO = RunService:IsStudio()
local STORE_NAME = if IS_STUDIO then "TESTSTUDIO11111" else "TESTGAME11111"
local STORE_VERSION = if IS_STUDIO then "1.2.7" else "1.1.0"
local METADATA_INDEX_VERSION = if IS_STUDIO then "STUDIO_DATA_VERSION" else "GAME_DATA_VERSION"
local SHOULD_SAVE = true

local MAX_RETRIES = 10
local RETRY_DELAY = 1.5

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {
		ReplicateData = Knit.CreateSignal(),
	},
})

function DataService.clearSession(player: Player)
	DataService._cache[player] = nil
end

function DataService.setSession(player: Player, session: Types.Session)
	DataService._cache[player] = session
end

function DataService.getSession(player: Player)
	return DataService._cache[player]
end

function DataService.waitForSession(player: Player, timeout: number?)
	timeout = timeout or 60

	local start = os.clock()
	local session = DataService.getSession(player)

	while not session and (os.clock() - start < timeout) do
		task.wait()
		session = DataService.getSession(player)
	end

	return session
end

function DataService.onPlayerAdded(player: Player)
	local userId = tostring(player.UserId)
	local session

	for _ = 1, MAX_RETRIES do
		session = DataService._store:StartSessionAsync(userId, {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})

		if session then
			break
		end

		task.wait(RETRY_DELAY)
	end

	if not session then
		return player:Kick("Issue with loading data, please rejoin.")
	end

	session:AddUserId(player.UserId)

	session.OnSessionEnd:Connect(function()
		DataService.onPlayerRemoving(player)
	end)

	if player.Parent ~= Players then
		return session:EndSession()
	end

	if session.RobloxMetaData[METADATA_INDEX_VERSION] ~= STORE_VERSION or not SHOULD_SAVE then
		session.RobloxMetaData[METADATA_INDEX_VERSION] = STORE_VERSION
		session.Data = TableUtil.DeepCopy(DATA_TEMPLATE)
	end

	session:Reconcile()

	DataService._cache[player] = session

	DataService:Replicate(player)
end

function DataService:Replicate(player: Player, index: (string | { string })?)
	local currentSession = self.getSession(player)

	if currentSession then
		local data = currentSession.Data

		if data then
			if index then
				if type(index) == "string" then
					self.Client.ReplicateData:Fire(player, data[index], index)
				elseif type(index) == "table" then
					for _, idx in index do
						self.Client.ReplicateData:Fire(player, data[idx], idx)
					end
				end
			else
				self.Client.ReplicateData:Fire(player, data)
			end
		end
	end
end

function DataService.onPlayerRemoving(player: Player)
	local currentSession = DataService.getSession(player)

	if currentSession then
		DataService._onPlayerRemoving:Fire(player)

		currentSession:EndSession()

		DataService.clearSession(player)
	end
end

function DataService:OnPlayerRemoving(player: Player, callback: () -> nil)
	local connection

	connection = self._onPlayerRemoving:Connect(function(_player: Player)
		if player == _player then
			callback()

			connection:Disconnect()
			connection = nil
		end
	end)

	return connection
end

function DataService:KnitInit()
	self._store = ProfileStore.New(STORE_NAME, DATA_TEMPLATE)
	self._cache = {}
	self._onPlayerRemoving = Signal.new()

	Players.PlayerAdded:Connect(self.onPlayerAdded)
	Players.PlayerRemoving:Connect(self.onPlayerRemoving)

	for _, player in Players:GetPlayers() do
		task.spawn(self.onPlayerAdded, player)
	end

end

return DataService