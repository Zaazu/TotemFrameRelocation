local ParentFrameName = "awdaw"        -- Frame for the TotemFrame to attach to.
local ParentAnchorPosition = "BOTTOMRIGHT";  -- Attachment point on the parent frame.
local TotemFrameAnchorPosition = "TOPRIGHT"; -- Attachment point on the TotemFrame.
local UseSquareMask = false;                 -- Apply square mask to totem icons (true or false).
local XOffset = 0;                           -- Horizontal offset from the attachment point.
local YOffset = 0;                           -- Vertical offset from the attachment point.


local MaxParentAttempts = 10;
local ParentAttempt = 0
local Disabled = false;
local Verbose = true

local function Printv(message)
	if(Verbose) then
		print("[TotemFrameRelocation]: " .. message)
	end
end

local function ReparentFrame(self)
	print(ParentAttempt)
	if(Disabled) then
		return
	end

	local ParentFrame = _G[ParentFrameName]

	--Give up if it takes too long to parent
	if(ParentAttempt >= MaxParentAttempts) then
		Printv(ParentFrameName .. " frame does not exist, giving up.")
		
		Disabled = true
		return
	end
	
	--If the frame to parent exists and we're not attached to it yet
	if(ParentFrame and self:GetParent() ~= ParentFrame) then
		Printv("Attached " .. self:GetName() .. " to " .. ParentFrame:GetName() .. ".")

		self:ClearAllPoints()
		self:SetParent(ParentFrame)
		self:SetPoint(TotemFrameAnchorPosition, ParentFrame, ParentAnchorPosition, XOffset, YOffset)
		
		ParentAttempt = 0
	else
		--If we're still not attached, the frame doesn't exist
		if(self:GetParent() ~= ParentFrame) then
			Printv(ParentFrameName .. " frame not found, retrying.")

			ParentAttempt = ParentAttempt + 1
			C_Timer.After(1, function()
				ReparentFrame(self)
			end)
		end
	end
end

-- Register PLAYER_LOGIN event and set OnEvent script
TotemFrame:RegisterEvent("PLAYER_LOGIN")
TotemFrame:HookScript("OnShow", ReparentFrame)
TotemFrame:HookScript("OnEvent", function(self, event)
	if(event == "PLAYER_LOGIN") then
		ReparentFrame(self)
	end
end)
