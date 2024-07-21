local ParentFrameName = "TargetFrame"        -- Frame for the TotemFrame to attach to.
local ParentAnchorPosition = "BOTTOMRIGHT";  -- Attachment point on the parent frame.
local TotemFrameAnchorPosition = "TOPRIGHT"; -- Attachment point on the TotemFrame.
local UseSquareMask = false;                 -- Apply square mask to totem icons (true or false).
local XOffset = 0;                           -- Horizontal offset from the attachment point.
local YOffset = 0;                           -- Vertical offset from the attachment point.

local verbose = true

local function Printv(message)
	if(verbose) then
		print(message)
	end
end

local function ReparentFrame(self)
	local ParentFrame = _G[ParentFrameName]
	
	if(ParentFrame and self:GetParent() ~= ParentFrame) then
		self:ClearAllPoints()
		self:SetParent(ParentFrame)
		self:SetPoint(TotemFrameAnchorPosition, ParentFrame, ParentAnchorPosition, XOffset, YOffset)
		
		Printv("Attached " .. self:GetName() .. " to " .. ParentFrame:GetName())
	else
		if(self:GetParent() ~= ParentFrame) then
			C_Timer.After(1, ReparentFrame)
			
			Printv("frame not found")
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
