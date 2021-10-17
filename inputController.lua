-- input controller
-- modernized 14/09/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


local LocalPlayer = Players.LocalPlayer
local MyMouse = LocalPlayer:GetMouse()
previousMouse=MyMouse.Icon
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() -- 100% defined since localscript is a startercharacterscript
local remotes = ReplicatedStorage:WaitForChild("weaponRemotes")
local equip = remotes.equipE
local unequip = remotes.unequipE
local phy=game:GetService("PhysicsService")
-- translating binds from integer to enum. You don't need to understand that.
local enumBinds = {
	[1] = "One";
	--[2] = "Two";
	--[3] = "Three";
	--[4] = "Four";
	--[5] = "Five";
	--[6] = "Six";
	--[7] = "Seven";
	
}

-- wait for game to load enough
ReplicatedStorage:WaitForChild("modules")
ReplicatedStorage:WaitForChild("weaponRemotes")
ReplicatedStorage.modules:WaitForChild("Velocity")
ReplicatedStorage.weaponRemotes:WaitForChild("fire")

-- The fps module we're about to add
repeat wait() until Character:FindFirstChild("UpperTorso")~=nil or Character:FindFirstChild("Torso")~=nil
game.Players.LocalPlayer.PlayerScripts.equipped.Value=false
game.Players.LocalPlayer.PlayerScripts.fpOn.Value=false

for i, v in pairs(Character:GetDescendants()) do
	if v:IsA("BasePart") then
		phy:SetPartCollisionGroup(v, "player")
	end
	
end
local weaponHandler = require(ReplicatedStorage.modules.fps)

--Custom input service. Do this how you want, i just couldn't ever remember how to use other services consistently.
local velocity = require(ReplicatedStorage.modules.Velocity):Init(true)
local inputs = velocity:GetService("InputService")

-- Server security. We need it this time around.
local weps, ammoData = ReplicatedStorage.weaponRemotes.new:InvokeServer()
local weapon = weaponHandler.new(weps)

-- let's just make it easier on me to not mention another edit
weapon.ammoData = ammoData
-- clearing viewmodels we could have kept in the camera because of script errors and stuff
local viewmodels = workspace.Camera:GetChildren()
if viewmodels then
	for _, v in pairs(viewmodels) do
	
		-- "v" only when v.Name == "viewmodel"
		-- equivalent to if v.Name == "viewmodel" then v:Destroy()
		local viewmodel = v and v.Name == "viewmodel"
		if viewmodel and type(viewmodel) ~= "boolean" then
			viewmodel:Destroy()
		end
	end
end	

local working
-- equip code
function equip2(i)


	-- if cooldown active, then don't execute the function. for less experienced scripters, this is just the equivalent of:
		 --[[
			
			local function brug()
				
				if working == false then
					
					-- do stuff
					
				end
				
			end
		
		 --]]
	local v=weps[i]
	if working then return end 

	working = true

	-- if the current equipped weapon is different from the one we want right now (also applies to the weapon being nil)
	if weapon.curWeapon ~= v then

		if weapon.equipped then
			weapon:remove()
			remotes.unequipE:FireServer()
			--game.StarterPlayer.equipped.Value=false
		end
		weapon:equip(v)
		remotes.equipE:FireServer(weapon.settings.firing.walkSpeed)
		--game.StarterPlayer.equipped.Value=true


	else
		-- if it's the same, just remove it

		spawn(function()
			weapon:remove()
			remotes.unequipE:FireServer()
		end)
		weapon.curWeapon = nil

	end

	working = false
end
function unequip2()
	if weapon.curWeapon then
		weapon:remove()
		--game.StarterPlayer.equipped.Value=false
	end
	if LocalPlayer.PlayerGui:FindFirstChild("WeaponHud")~=nil then
		while LocalPlayer.PlayerGui:FindFirstChild("WeaponHud")~=nil do
			LocalPlayer.PlayerGui:FindFirstChild("WeaponHud"):Destroy()
		end
		
	end
end

remotes.equip1.OnClientEvent:Connect(function(i) 
	equip2(i)
end)
remotes.unequip1.OnClientEvent:Connect(function() 
	if weapon.reloading then return end
	unequip2()
end)


local function update(dt)
	weapon:update(dt)
end





-- PLEASE don't do it like this.
inputs.BindOnBegan("MouseButton1", nil, function() weapon:fire(true) end, "PewPew")
inputs.BindOnEnded("MouseButton1", nil, function() weapon:fire(false) end, "PewPewEnd")

inputs.BindOnBegan("MouseButton2", nil, function() weapon:aim(true) end, "AimPewPew")
inputs.BindOnEnded("MouseButton2", nil, function() weapon:aim(false) end, "AimPewPewEnd")

inputs.BindOnBegan(nil, "R", function() weapon:reload() end, "ReloadPewPew")

inputs.BindOnBegan(nil, "V", function() weapon:modeChange() end, "ChangeMode")

inputs.BindOnBegan(nil, "Y", function() weapon:changeAim() end, "changeOptic")

--inputs.BindOnBegan(nil, "F", function() weapon:holster() end, "holster")
inputs.BindOnBegan(nil, "J", function() weapon:flashlight() end, "flashlight")

inputs.BindOnBegan(nil, "Q", function() weapon:leanLeft(true) end, "leanleftStart")
inputs.BindOnEnded(nil, "Q", function() weapon:leanLeft(false) end, "leanleftEnd")

inputs.BindOnBegan(nil, "E", function() weapon:leanRight(true) end, "leanrightStart")
inputs.BindOnEnded(nil, "E", function() weapon:leanRight(false) end, "leanrightEnd")

inputs.BindOnBegan(nil, "LeftShift", function() weapon:run(true) end, "runStart")
inputs.BindOnEnded(nil, "LeftShift", function() weapon:run(false) end, "runEnd")

inputs.BindOnBegan(nil, "H", function() weapon:laser() end, "laser")

inputs.BindOnBegan(nil, "C", function() weapon:getDown() end, "getDown")

inputs.BindOnBegan(nil, "X", function() weapon:getUp() end, "getUp")

inputs.BindOnBegan(nil, "T", function() weapon:jogging() end, "jog")

inputs.BindOnBegan(nil, "N", function() weapon:nightVision() end, "nightVision")


-- marking the gun as unequippable
Character.Humanoid.Died:Connect(function() 
	--weapon:remove() 
	weapon.viewmodel:Destroy()
	game.StarterPlayer.equipped.Value=false
	game.StarterPlayer.fpOn.Value=false
	weapon.disabled = true 
	
	MyMouse.Icon=previousMouse
	game.Workspace.CurrentCamera.FieldOfView=70
	script.Disabled=true
	wait(3)
	script.Disabled=false
end)
RunService.RenderStepped:Connect(update)
