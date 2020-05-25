-- Get TweenService from game
local TweenService = game:GetService('TweenService')

-- Get StatefulObject base class from ModuleScript
local StatefulObject = require(workspace.Modules.StatefulObjectClass)

-- Make subclass of StatefulObject, setting class variables
local WallSwitch = StatefulObject:subclass({
	-- Time it takes for the switch to move
	FlipTime = 0.2,

	-- Switch State Values
	Up = 1,
	Down = 2,
	MovingUp = 3,
	MovingDown = 4,

	SwitchOrientation = {
		Vector3.new(30, 0, 0),  -- Up
		Vector3.new(-30, 0, 0), -- Down
	}
})

function WallSwitch:new(o)
  -- If passed only a Model, then put into a table.
	if not o then error('WallSwitch requires a Model') end
	if o.IsA and o:IsA('Model') then o = { Model = o } end

  -- Make object table into an instance of WallSwitch
  setmetatable(o, self)
	self.__index = self

  -- Initialize object
  o:init()

  -- Return the object
  return o
end

-- Initialize the WallSwitch by finding the switch part
-- and creating a ClickDetector
function WallSwitch:init()
	if not self.Model
	or not self.Model:IsA('Model')
	then
		error('WallSwitch must define Model')
	end

	self.SwitchPart = self.Model:FindFirstChild('Switch')
	if not self.SwitchPart
	or not self.SwitchPart:IsA('BasePart')
	then
		error('WallSwitch Model must inclue a part named "Switch"')
	end	
	
	self.ClickDetector = Instance.new('ClickDetector', self.SwitchPart)
	self.ClickDetector.MouseClick:Connect(function (player)
		self:FlipSwitch({Player=player})
	end)

	-- Chain to base class init
	StatefulObject.init(self)

  -- Now that initial state is set, make sure light switch position
  -- reflects this
	self:_setSwitchOrientation()
end

function WallSwitch:_setSwitchOrientation()
	local orientation = self.SwitchOrientation[self.State.Value]
	if orientation then
		self.SwitchPart.Orientation = orientation
	end
end

function WallSwitch:FlipSwitch(event)
	if self.State.Value == self.Up then
		self:FlipSwitchDown(event)
	elseif self.State.Value == self.Down then
		self:FlipSwitchUp(event)
	end
end

function WallSwitch:FlipSwitchUp(event)
	if self.State.Value ~= self.Down then return end
	self.State.Value = self.MovingUp
	self.Tween = TweenService:Create(
		self.SwitchPart,
		TweenInfo.new(self.FlipTime),
		{ Orientation = self.SwitchOrientation[self.Up] }
	)
	self.Tween.Completed:Connect(function ()
		self.Tween:Destroy()
		self.Tween = nil
		self.State.Value = self.Up
	end)
	self.Tween:Play()
end

function WallSwitch:FlipSwitchDown(event)
	if self.State.Value ~= self.Up then return end
	self.State.Value = self.MovingDown
	self.Tween = TweenService:Create(
		self.SwitchPart,
		TweenInfo.new(self.FlipTime),
		{ Orientation = self.SwitchOrientation[self.Down] }
	)
	self.Tween.Completed:Connect(function ()
		self.Tween:Destroy()
		self.Tween = nil
		self.State.Value = self.Down
	end)
	self.Tween:Play()	
end

return WallSwitch
