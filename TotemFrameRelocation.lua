local ParentFrameName = "PlayerFrame"       -- Frame for the TotemFrame to attach to.
local ParentAnchorPosition = "BOTTOMRIGHT"  -- Attachment point on the parent frame.
local TotemFrameAnchorPosition = "TOPRIGHT" -- Attachment point on the TotemFrame.
local UseSquareMask = true                  -- Apply square mask to totem icons (true or false).
local XOffset = 0                           -- Horizontal offset from the attachment point.
local YOffset = 0                           -- Vertical offset from the attachment point.

local MaxParentAttempts = 10				-- Max number of parent attempts before giving up until reload
local ParentAttempt = 0						-- Current number of attempts
local Disabled = false						-- Disable parenting
local Verbose = true						-- Display debug messages

local AddonName = ...

--If the player is not a shaman, disable the addon
if(UnitClassBase("player") ~= "SHAMAN") then
	C_AddOns.DisableAddOn(AddonName, UnitName("player"))
	return
end

local function Printv(message)
	if (Verbose) then
		print( "[".. AddonName .."]: " .. message)
	end
end

local function ResetParentAttempts()
	Disabled = false
	ParentAttempt = 0
end

local function ReparentFrame(self)
	if (Disabled) then
		return
	end

	local ParentFrame = _G[ParentFrameName]

	-- Give up if it takes too long to parent
	if (ParentAttempt >= MaxParentAttempts) then
		Printv(ParentFrameName .. " frame does not exist, giving up.")

		Disabled = true
		return
	end

	-- If the frame to parent exists and we're not attached to it yet
	if (ParentFrame and self:GetParent() ~= ParentFrame) then
		Printv("Attached " .. self:GetName() .. " to " .. ParentFrame:GetName() .. ".")

		self:ClearAllPoints()
		self:SetParent(ParentFrame)
		self:SetPoint(TotemFrameAnchorPosition, ParentFrame, ParentAnchorPosition, XOffset, YOffset)

		ResetParentAttempts()
	else
		-- If we're still not attached, the frame doesn't exist
		if (self:GetParent() ~= ParentFrame) then
			Printv(ParentFrameName .. " frame not found, retrying.")

			ParentAttempt = ParentAttempt + 1
			C_Timer.After(1, function()
				ReparentFrame(self)
			end)
		end
	end
end

-- Function to modify the totem button on load
local function ModifyTotemButton(self)
	-- Hide the border
	self.Border:Hide()

	-- Get atlas information for square mask
	local squareMaskAtlas = C_Texture.GetAtlasInfo("SquareMask")
	local left, right, top, bottom = squareMaskAtlas.leftTexCoord, squareMaskAtlas.rightTexCoord,
		squareMaskAtlas.topTexCoord, squareMaskAtlas.bottomTexCoord

	-- Set icon texture and coordinates
	self.Icon.TextureMask:SetTexture(squareMaskAtlas.file or squareMaskAtlas.filename)
	self.Icon.TextureMask:SetTexCoord(left, right, top, bottom)

	-- Set swipe texture and coordinates
	local lowTexCoords = { x = left, y = top }
	local highTexCoords = { x = right, y = bottom }
	self.Icon.Cooldown:SetSwipeTexture(squareMaskAtlas.file or squareMaskAtlas.filename)
	self.Icon.Cooldown:SetTexCoordRange(lowTexCoords, highTexCoords)

	self.Duration:Hide()
end

if (UseSquareMask) then
	-- Hook the OnLoad function to modify totem buttons
	hooksecurefunc(TotemButtonMixin, "OnLoad", ModifyTotemButton)
	-- Modify existing totem buttons
	for button in TotemFrame.totemPool:EnumerateActive() do
		ModifyTotemButton(button)
	end
end

-- Register PLAYER_LOGIN event and set OnEvent script
TotemFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
TotemFrame:HookScript("OnShow", ReparentFrame)
TotemFrame:HookScript("OnEvent", function(self, event)
	if (event == "PLAYER_ENTERING_WORLD") then
		ReparentFrame(self)
	end
end)
