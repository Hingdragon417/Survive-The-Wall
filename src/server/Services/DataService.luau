local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Shared = ReplicatedStorage.Shared
local DATA_TEMPLATE = require(Shared.Data.Template)

local IS_STUDIO = RunService:IsStudio()
local STORE_NAME = IS_STUDIO and "TESTSTUDIO111111" or "TESTGAME11111"
local STORE_VERSION = IS_STUDIO and "1.2.7" or "1.1.0"
local METADATA_INDEX_VERSION = IS_STUDIO and "STUDIO_DATA_VERSION" or "GAME_DATA_VERSION"
local SHOULD_SAVE = true

local MAX_RETRIES = 10
local RETRY_DELAY = 1.5

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {
		ReplicateData = Knit.CreateSignal(),
	},
})

function DataService:getNested(data, path)
	for _, key in ipairs(path) do
		data = data and data[key]
	end
	return data
end

function DataService:Replicate(player, index)
	local session = self:getSession(player)
	if not session or not session.Data then return end

	local data = session.Data

	if not index then
		self.Client.ReplicateData:Fire(player, data)
		for key, value in pairs(data.leaderstats or {}) do
			if value ~= nil then
				self.Client.ReplicateData:Fire(player, value, key)
			end
		end
	elseif typeof(index) == "string" then
		local val = data[index] or (data.leaderstats and data.leaderstats[index])
		if val ~= nil then
			self.Client.ReplicateData:Fire(player, val, index)
		end
	elseif typeof(index) == "table" then
		local val = self:getNested(data, index)
		if val ~= nil then
			local key = index[#index]
			self.Client.ReplicateData:Fire(player, val, key)
		end
	end
end

function DataService:createLeaderstats(player, data)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player

	local stats = data.leaderstats or {}

	for key, value in pairs(stats) do
		local val = typeof(value) == "number" and Instance.new("IntValue") or typeof(value) == "string" and Instance.new("StringValue")
		if val then
			val.Name = key
			val.Value = value
			val.Parent = folder

			val:GetPropertyChangedSignal("Value"):Connect(function()
				stats[key] = val.Value
				self:Replicate(player, { "leaderstats", key })
			end)
		end
	end
end

function DataService:setSession(player, session)
	self._cache[player] = session
end

function DataService:getSession(player)
	return self._cache[player]
end

function DataService:clearSession(player)
	self._cache[player] = nil
end

function DataService.waitForSession(player, timeout)
	timeout = timeout or 60
	local start = os.clock()
	local session = DataService:getSession(player)

	while not session and (os.clock() - start < timeout) do
		task.wait()
		session = DataService:getSession(player)
	end

	return session
end

function DataService.onPlayerAdded(player)
	local userId = tostring(player.UserId)
	local session

	for _ = 1, MAX_RETRIES do
		session = DataService._store:StartSessionAsync(userId, {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})

		if session then break end
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

	DataService:setSession(player, session)
	DataService:Replicate(player)
	DataService:createLeaderstats(player, session.Data)
end

function DataService.onPlayerRemoving(player)
	local session = DataService:getSession(player)
	if session then
		DataService._onPlayerRemoving:Fire(player)
		session:EndSession()
		DataService:clearSession(player)
	end
end

function DataService:OnPlayerRemoving(player, callback)
	local connection
	connection = self._onPlayerRemoving:Connect(function(p)
		if p == player then
			callback()
			connection:Disconnect()
		end
	end)
	return connection
end

function DataService:KnitInit()
	self._store = ProfileStore.New(STORE_NAME, DATA_TEMPLATE)
	self._cache = {}
	self._onPlayerRemoving = Signal.new()

	Players.PlayerAdded:Connect(function(player)
		self.onPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.onPlayerRemoving(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(self.onPlayerAdded, player)
	end
end

return DataService
