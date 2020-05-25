-- Load StatefulObject base class
local StatefulObject = require(workspace.Modules.StatefulObjectClass)

-- Create subclass of Light with class variables
local Light = StatefulObject:subclass({
	-- Light State Values
	On = 1,
	Off = 2,

	LightMaterial = {
		Enum.Material.Neon,  -- On
		Enum.Material.Glass, -- Off
	},
})

-- Make a new Light
function Light:new(o)
  -- Get light model, switch to table structure if needed.
	if not o then error('Light requires a Model') end
	if o.IsA and o:IsA('Model') then o = { Model = o } end

	-- Make table into an object
	setmetatable(o, self)
	self.__index = self

	-- Initialize the new object
	o:init()

	-- Return the object
	return o
end

function Light:init()
	-- Check that we really have a Model for the Light
	if not self.Model
	or not self.Model:IsA('Model')
	then
		error('Light must define Model')
	end

	-- Chain to base class init
	StatefulObject.init(self)

	-- Light responds to state change...
	self.State.Changed:Connect(function (value)
		self:_handleStateChange(value)
	end)
end

function Light:_handleStateChange(value)
	-- Recurse through object structure, enabling or disabling
	-- all Light objects. Also set material of Light source
	-- parent object to match light state.
	local function setLightSourcesEnabled(parent, enabled)
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA('Light') then
				child.Enabled = enabled
				child.Parent.Material = self.LightMaterial[value]
			else
				setLightSourcesEnabled(child, enabled)
			end
		end
	end
	setLightSourcesEnabled(self.Model, value == self.On)
end

-- Turn light on by setting state to On
function Light:TurnOn()
	self.State.Value = self.On	
end

-- Turn light on by setting state to Off
function Light:TurnOff()
	self.State.Value = self.Off
end

-- Turn light on if off or off if on
function Light:ToggleLightState()
	if self.State.Value == self.On then
		self:TurnOff()
	elseif self.State.Value == self.Off then
		self:TurnOn()
	end
end

return Light
