local guis = {}
function findPlr(v)
	for i,c in pairs(guis) do
		if c.UserId == v then
			return c
		end
	end
end
function deletePlr(v)
	for i,c in pairs(guis) do
		if c.UserId == v then
			table.remove(guis,i)
		end
	end
end
function SetUpVPF(cplr)
    if findPlr(cplr.UserId) then findPlr(cplr.UserId).Gui:Destroy() deletePlr(cplr.UserId) end
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = cplr.Name
	ScreenGui.DisplayOrder = 9999
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	--syn.protect_gui(ScreenGui) sadly if you add protection to vpf esp it breaks and wont render most of added parts
	ScreenGui.Parent = game:GetService("CoreGui")
	local vpf = Instance.new("ViewportFrame",ScreenGui)
	vpf.Active = false
	vpf.CurrentCamera = workspace.CurrentCamera
	vpf.Size = UDim2.new(1,0,1,0)
	vpf.Position = UDim2.new(0,0,0,0)
	vpf.Visible = true
	vpf.BackgroundTransparency = 1
	table.insert(guis,{Gui = ScreenGui,UserId = cplr.UserId})
	local real = cplr.Character
	local copy,MainParts = Instance.new("Model"),{}
	copy.Name = real.Name
	copy.Parent = vpf
	function addtoVPF(part)
		--ScreenGui.Enabled = false
		local arch = part.Archivable
		part.Archivable = true
		MainParts[part] = part:Clone()
		MainParts[part].Parent = copy
		part.Archivable = arch
		part.DescendantAdded:Connect(function(c)
			if MainParts[c] == nil and MainParts[c.Parent] then
				local arch = c.Archivable
				c.Archivable = true
				MainParts[c] = c:Clone()
				if MainParts[c] then MainParts[c].Parent = MainParts[c.Parent] end
				c.Archivable = arch
			end
		end)
		part.DescendantRemoving:Connect(function(c)
			if MainParts[c] then
				game:GetService("Debris"):AddItem(MainParts[c],0.5)
				MainParts[c]:Destroy()
				MainParts[c] = nil
			elseif copy:FindFirstChild(c.Name) then
				game:GetService("Debris"):AddItem(copy:FindFirstChild(c.Name),0.5)
				copy:FindFirstChild(c.Name):Destroy()
			end
		end)
		part.AncestryChanged:Connect(function()
			if part == nil or part.Parent == nil or part:FindFirstAncestorOfClass("Model") == nil then
				if MainParts[part] then MainParts[part]:Destroy() MainParts[part] = nil end
			end
		end)
		for i,v in pairs(MainParts[part]:GetDescendants()) do
			MainParts[part:GetDescendants()[i]] = v
			--[[for i,c in pairs(part:GetDescendants()) do
				if v.Name == c.Name then
					MainParts[c] = v
					break
				end
			end]]
		end
		--[[task.wait(0.1)
		ScreenGui.Enabled = true]]
	end
	real.ChildAdded:Connect(function(v)
		addtoVPF(v)
	end)
	real.DescendantRemoving:Connect(function(c)
		if MainParts[c] then
			game:GetService("Debris"):AddItem(MainParts[c],0.5)
			MainParts[c]:Destroy()
			MainParts[c] = nil
		elseif copy:FindFirstChild(c.Name) then
			game:GetService("Debris"):AddItem(copy:FindFirstChild(c.Name),0.5)
			copy:FindFirstChild(c.Name):Destroy()
		end
	end)
	real.AncestryChanged:Connect(function()
		if real == nil or real.Parent == nil or real:FindFirstAncestorOfClass("Workspace") == nil then
			pcall(function() copy:Destroy() end)
			pcall(function() vpf:Destroy() end)
			pcall(function() ScreenGui:Destroy() end)
			pcall(function() game:GetService("Debris"):AddItem(ScreenGui,0) end)
			deletePlr(cplr.UserId)
		end
	end)
	for i,v in pairs(real:GetChildren()) do
		addtoVPF(v)
	end
	while task.wait() do
		if ScreenGui == nil or ScreenGui:FindFirstAncestorOfClass("DataModel") == nil then break end
		if real == nil or real:FindFirstAncestorOfClass("Workspace") == nil or real:FindFirstChildOfClass("Humanoid") == nil or real:FindFirstChildOfClass("Humanoid").Health == 0 then copy:ClearAllChildren() copy:Destroy() game:GetService("Debris"):AddItem(ScreenGui,0) ScreenGui:Destroy() break end
		(copy:FindFirstChildOfClass("Humanoid") or Instance.new("Humanoid")).MaxHealth = (real:FindFirstChildOfClass("Humanoid") and real:FindFirstChildOfClass("Humanoid").MaxHealth or 100)
		;(copy:FindFirstChildOfClass("Humanoid") or Instance.new("Humanoid")).Health = (real:FindFirstChildOfClass("Humanoid") and real:FindFirstChildOfClass("Humanoid").Health or 100)
		;(copy:FindFirstChildOfClass("Humanoid") or Instance.new("Humanoid")).HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
		for i,v in pairs(MainParts) do
			if ScreenGui == nil or ScreenGui:FindFirstAncestorOfClass("DataModel") == nil then break end
			if real == nil or real:FindFirstAncestorOfClass("Workspace") == nil or real:FindFirstChildOfClass("Humanoid") == nil or real:FindFirstChildOfClass("Humanoid").Health == 0 then break end
			if v:IsA("BasePart") and i:IsA("BasePart") then
				v.CFrame = i.CFrame
			elseif i == nil or i.Parent == nil or i:FindFirstAncestorOfClass("Workspace") == nil then
				v:Destroy()
			    MainParts[i] = nil
			end
		end
	end
end
function ForVPFSetup(v)
	--ScreenGui.Enabled = false
	if v == game:GetService("Players").LocalPlayer then return end
	if v.Character ~= nil and v.Character:FindFirstAncestorOfClass("Workspace") ~= nil and v.Character:FindFirstChildOfClass("Humanoid") ~= nil and v.Character:FindFirstChildOfClass("Humanoid").Health ~= 0 then 
		task.spawn(SetUpVPF,v) 
	end
	--[[task.wait(0.1)
	ScreenGui.Enabled = true]]
end
game:GetService("Players").ChildAdded:Connect(function(v)
	if v:IsA("Player") then
		v.CharacterAdded:Connect(function()
			repeat task.wait() until v.Character ~= nil and v.Character:FindFirstAncestorOfClass("Workspace") ~= nil and v.Character:FindFirstChildOfClass("Humanoid") ~= nil and v.Character:FindFirstChildOfClass("Humanoid").Health ~= 0
			ForVPFSetup(v)
		end)
		ForVPFSetup(v)
	end
end)
for i,v in pairs(game:GetService("Players"):GetPlayers()) do
	v.CharacterAdded:Connect(function()
		repeat task.wait() until v.Character ~= nil and v.Character:FindFirstAncestorOfClass("Workspace") ~= nil and v.Character:FindFirstChildOfClass("Humanoid") ~= nil and v.Character:FindFirstChildOfClass("Humanoid").Health ~= 0
        ForVPFSetup(v)
	end)
	ForVPFSetup(v)
end
