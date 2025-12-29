--[[
    Tzar UI Library - Animation
    Centralized animation utilities
]]

local TweenService = game:GetService("TweenService")

local Animation = {}

-- Standard TweenInfos
Animation.Tweens = {
	Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Spring = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

function Animation.Play(instance: Instance, tweenInfo: TweenInfo, properties: table)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

function Animation.Color(instance: GuiObject, color: Color3, duration: number?)
	local info = duration and TweenInfo.new(duration) or Animation.Tweens.Fast
	Animation.Play(instance, info, { BackgroundColor3 = color })
end

function Animation.Fade(instance: GuiObject, transparency: number, duration: number?)
	local info = duration and TweenInfo.new(duration) or Animation.Tweens.Fast
	Animation.Play(instance, info, { BackgroundTransparency = transparency })
end

return Animation
