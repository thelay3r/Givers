-- // rename to GuiUtilities

local camera = workspace.CurrentCamera

local Utilities = {}

function Utilities:AutoScaleStroke(object: GuiObject)
    for _, object: UIStroke in pairs(object:GetDescendants()) do
        if (not object:IsA('UIStroke')) then continue end

        local defaultThickness = object.Thickness
        local scaleFactor = camera.ViewportSize.X / 1920

        object.Thickness = defaultThickness * scaleFactor
    end
end

return Utilities