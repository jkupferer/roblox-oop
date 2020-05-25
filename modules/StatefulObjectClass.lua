-- This class should be saved in Roblox as a ModuleScript

-- The class is implemented as a Lua table
local StatefulObject = {
	-- State is tracked as enumeration.
	-- State 1 is the default initial state.
	InitialState = 1,
}

-- These local (private) variables.
-- They cannot be accessed outside of the Module.
local objectId = 0
local objectRegistry = {}

-- Each object is assigned a unique Id to allow it to be
-- retrieved by Id value.
local function nextObjectId()
	objectId = objectId + 1
	return objectId
end

-- Make a subclass of StatefulObject
function StatefulObject:subclass(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Wait for an object to be initalized and
-- then return the object.
function StatefulObject:WaitForInit(parent)
	local Id = parent:WaitForChild('Id')
	return objectRegistry[Id.Value]
end

-- Object table must have a Folder, Model, or Part
-- Initalized by creating a State IntValue, and
-- assign an Id.
function StatefulObject:init()
	self._parent = self.Folder or self.Model or self.Part
	if not self._parent then
		error('Unable to determine where to track state, no Folder, Model, or Part')
	end

	self.State = Instance.new('IntValue')
	self.State.Name = 'State'
	self.State.Value = self.InitialState

	self.Id = Instance.new('IntValue')
	self.Id.Name = 'Id'
	self.Id.Value = nextObjectId()
	objectRegistry[self.Id.Value] = self

	self.Id.Parent = self._parent
	self.State.Parent = self._parent
end

-- Return the class table from the ModuleScript
return StatefulObject
