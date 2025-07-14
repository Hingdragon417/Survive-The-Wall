local Module = {}

function Module.DeepCopy<T>(t: T): T
	local copy = table.clone(t)
	for k, v in copy do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		end
	end
	return copy
end
deepCopy = Module.DeepCopy

function Module.DeepReverse<T>(t: { T }): { T }
	local n = #t
	local div = n / 2
	for i = 1, div do
		if type(t[i]) == "table" then
			deepReverse(t[i])
		end
		if type(t[n]) == "table" then
			deepReverse(t[n])
		end
		t[i], t[n] = t[n], t[i]
		n -= 1
	end

	if #t % 2 ~= 0 then
		local val = t[math.ceil(div)]
		if type(val) == "table" then
			deepReverse(val)
		end
	end
	return t
end
deepReverse = Module.DeepReverse

function Module.Reverse<T>(t: { T }): { T }
	local last = #t
	for i = 1, #t / 2 do
		t[i], t[last] = t[last], t[i]
		last -= 1
	end
	return t
end

function Module.Shuffle(t: table): table
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function Module.StringToArray(s: string): { string }
	local t = table.create(#s)
	for i = 1, #s do
		t[i] = string.sub(s, i, i)
	end
	return t
end

function Module.Swappop(t: { any }, index: number)
	t[index], t[#t] = t[#t], nil
end

function Module.IpairsLength(t: { any }): number
	local length = 0
	for _ in ipairs(t) do
		length += 1
	end
	return length
end

function Module.PairsFind(t: table, value: any): any?
	for i, v in pairs(t) do
		if v == value then
			return i
		end
	end
end

return Module
