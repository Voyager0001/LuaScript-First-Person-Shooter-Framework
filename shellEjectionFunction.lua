function handler:createBullet(part)
	local shell = part.Parent.shell:Clone()
	shell.CFrame = part.CFrame * CFrame.fromEulerAnglesXYZ(1.5,0,0)
	--shell.Size = Vector3.new(1,1,1)
	--shell.BrickColor = BrickColor.new(226)
	shell.Parent = game.Workspace
	shell.CFrame = part.CFrame
	shell.CanCollide = true
	shell.Transparency = 0
	shell.BottomSurface = 0
	shell.TopSurface = 0
	shell.Name = "Shell"
	shell.Velocity = part.CFrame.lookVector * 35 + Vector3.new(math.random(-10,10),20,math.random(-10,20))
	shell.RotVelocity = Vector3.new(0,200,0)

	--PhysicsService:SetPartCollisionGroup(shell, "Obstacles")
	game:GetService("Debris"):AddItem(shell, 30)
	
	--local shellmesh = Instance.new("SpecialMesh")
	--shellmesh.Scale = Vector3.new(.15,.4,.15)
	--shellmesh.Parent = shell
end
