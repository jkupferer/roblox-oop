local LightClass = require(workspace.Modules.LightClass)

local ColorChangeLight = LightClass:subclass({
	ClassName = 'ColorChangeLight',
})

-- Turn light on by setting state to On
function ColorChangeLight:handleStateChangeForLight(value, light)
	if value == LightClass.On then
		light.Color = Color3.fromRGB(math.random(255), math.random(255), math.random(255))
		if light.Parent.Name == 'Bulb' then
			light.Parent.Color = light.Color
		end
	end
	LightClass.handleStateChangeForLight(self, value, light)
end

return ColorChangeLight
