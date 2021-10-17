
local root = script.Parent

local data = {
	animations = {
	
		viewmodel = {
			idle = root.animations.idle;
			fire = root.animations.fire;
			reload = root.animations.reload;
		};
	
		player = {
			aim = root.serverAnimations.aim;
			aimFire = root.serverAnimations.aimFire;
			idle = root.serverAnimations.idle;
			idleFire = root.serverAnimations.idleFire;
			reload = root.serverAnimations.reload;
		};
	
	};
	
	firing = {
		
		torso = 34;
		head = 100;
		leg = 25;
		arm = 20;
		
		
		rpm = 635;
		burstRPM=780;
		semiRPM = 635;
		
		magCapacity = 30;
		spareMag=5;
		spareAmmo=100;
		
		velocity = 500;
		range = 5500;
		
		--walkSpeed=26;
		stamina=6;
		staminaRecovery=4.78;
		
		adsRange=58;
		adsRange2=15;
		aimSlowDownMultiplier1=6;
		aimSlowDownMultiplier2=3;
		
		--weaponParent="UpperTorso";
		--weaponHold="RightHand";
		
		semiEnabled=true;
		autoEnabled=true;
		
		burstEnabled=true;
		burstCooldown=.5;
		burstAmount=2;
		
		cframe=CFrame.new(-1,0,.55)*CFrame.Angles(math.rad(0), math.rad(0), math.rad(90))*CFrame.fromOrientation(math.rad(0), math.rad(0), math.rad(-45));
		
		recoveryTime=.001;
		recoilTable={[1]=Vector3.new(0.1, 0.05, -.01),
					 [2]=Vector3.new(0.1, -0.05, .012),
			[3]=Vector3.new(0.1, 0.075, .012),
			[4]=Vector3.new(0.1, -0.075, .012),
			[5]=Vector3.new(0.1, 0.1, .012),
			[6]=Vector3.new(0.1, -0.1, .012),
		};
	}
	
}

return data
