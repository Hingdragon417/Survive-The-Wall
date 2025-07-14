local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)

local Types = require(Shared.Types)

local DataService

local DataController = Knit.CreateController({
	Name = "DataController",
})

function DataController.waitForData(): Types.Data
	while not DataController.getData() do
		task.wait()
	end

	return DataController.getData()
end

function DataController.getData(): Types.Data?
	return DataController._cache
end

function DataController.reconcileTables(target, template)
	for key in target do
		if template[key] == nil then
			target[key] = nil
		end
	end

	for key, value in template do
		local targetValue = target[key]

		if type(value) == "table" then
			if type(targetValue) ~= "table" then
				target[key] = {}
			end

			DataController.reconcileTables(target[key], value)
		else
			if targetValue ~= value then
				target[key] = value
			end
		end
	end

	return target
end

function DataController.onReplicated(checkIndex: string | { string })
	return {
		Connect = function(_, callback: () -> any)
			return DataController._onReplicate:Connect(function(index: string?)
				local valid = if type(checkIndex) == "table" then table.find(checkIndex, index) else index == checkIndex

				if valid then
					callback()
				end
			end)
		end,
	}
end

function DataController.onReplicate(data: { [string]: any }, index: string?)
	if DataController._cache then
		if index then
			if type(data) == "table" then
				DataController.reconcileTables(DataController._cache[index], data)
			else
				DataController._cache[index] = data
			end
		else
			DataController.reconcileTables(DataController._cache, data)
		end

		print("Data reconciled", DataController._cache, index, data)

		if index then
			DataController._onReplicate:Fire(index)
		end
	else
		DataController._cache = data

		print("Initial data received", data)
	end
end

function DataController:KnitStart()
	DataService.ReplicateData:Connect(self.onReplicate)
end

function DataController:KnitInit()
	self._cache = nil
	self._onReplicate = Signal.new()

	DataService = Knit.GetService("DataService")
end

return DataController