local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local ProfileStore = Packages.ProfileStore

export type Session = typeof(require(ProfileStore):StartSessionAsync())

export type Data = typeof(require(script.Parent.Data.Template))

return {}