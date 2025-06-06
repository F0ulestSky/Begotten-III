SWEP.Base = "sword_swepbase"
-- WEAPON TYPE: Two Handed (Great Weapon)

SWEP.PrintName = "Darklander Bardiche"
SWEP.Category = "(Begotten) Great Weapon"

SWEP.AdminSpawnable = true
SWEP.Spawnable = true
SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.Weight = 2
SWEP.UseHands = true

SWEP.HoldType = "wos-begotten_2h_great"

SWEP.ViewModel = "models/c_begotten_pulverizer.mdl"
SWEP.ViewModelFOV = 80
SWEP.ViewModelFlip = false

--Anims
SWEP.BlockAnim = "a_heavy_great_block"
SWEP.CriticalAnim = "a_heavy_great_attack_slash_02"
SWEP.ParryAnim = "a_heavy_great_parry"
SWEP.IronSightsPos = Vector(-12.04, -1.407, -0.12)
SWEP.IronSightsAng = Vector(7.738, 0, -27.438)

--For 2h viewmodel
SWEP.CriticalPlaybackRate = 0.9
SWEP.PrimaryPlaybackRate = 0.85
SWEP.PrimaryIdleDelay = 0.9
SWEP.AltPlaybackRate = nil
SWEP.AltIdleDelay = nil
SWEP.PrimarySwingAnim = "a_heavy_great_attack_slash_01"
SWEP.MultiHit = 2;
SWEP.ChoppingAltAttack = true;

--Sounds
SWEP.AttackSoundTable = "HeavyMetalAttackSoundTable"
SWEP.BlockSoundTable = "WoodenBlockSoundTable"
SWEP.SoundMaterial = "Metal" -- Metal, Wooden, MetalPierce, Punch, Default

SWEP.WindUpSound = "draw/skyrim_axe_draw1.mp3" --For 2h weapons only, plays before primarysound

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
SWEP.AttackTable = "DarklanderBardicheAttackTable"
SWEP.BlockTable = "DarklanderBardicheBlockTable"

function SWEP:CriticalAnimation()

	local attacksoundtable = GetSoundTable(self.AttackSoundTable)
	local attacktable = GetTable(self.AttackTable)

	self.Weapon:EmitSound(self.WindUpSound)

	-- Viewmodel attack animation!
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "atk_f" ) )
	self.Owner:GetViewModel():SetPlaybackRate(1)
	self:IdleAnimationDelay( 1, 1 )
	
	if (SERVER) then
	timer.Simple( attacktable["striketime"] - 0.05, function() if self:IsValid() and self.isAttacking then
	self.Weapon:EmitSound(attacksoundtable["criticalswing"][math.random(1, #attacksoundtable["criticalswing"])])
	end end)
	self.Owner:ViewPunch(Angle(10,1,1))
	end
	
end

function SWEP:ParryAnimation()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "brace_out" ) )
	self.Owner:GetViewModel():SetPlaybackRate(1)
	self.Owner:ViewPunch(Angle(-30,0,0))
	self:IdleAnimationDelay( 1.5, 1.5 )
end

function SWEP:HandlePrimaryAttack()

	local attacksoundtable = GetSoundTable(self.AttackSoundTable)
	local attacktable = GetTable(self.AttackTable)

	--Attack animation
	self:TriggerAnim(self.Owner, self.PrimarySwingAnim);

	-- Viewmodel attack animation!
	self.Weapon:EmitSound(self.WindUpSound)
	timer.Simple( attacktable["striketime"] - 0.05, function() if self:IsValid() and self.isAttacking then
	self.Weapon:EmitSound(attacksoundtable["primarysound"][math.random(1, #attacksoundtable["primarysound"])])
	end end)
    
    if (SERVER) then
		local ani = math.random( 1, 2 )
		if ani == 1 and self:IsValid() then
			self.Owner:ViewPunch(Angle(0,6,0))
			local vm = self.Owner:GetViewModel()
			vm:SendViewModelMatchingSequence( vm:LookupSequence( "atk_l" ) )
			self.Owner:GetViewModel():SetPlaybackRate(self.PrimaryPlaybackRate)
			self:IdleAnimationDelay( self.PrimaryIdleDelay, self.PrimaryIdleDelay )

		elseif ani == 2  and self:IsValid() then
			self.Owner:ViewPunch(Angle(6,0,0))
			local vm = self.Owner:GetViewModel()
			vm:SendViewModelMatchingSequence( vm:LookupSequence( "atk_r" ) )
			self.Owner:GetViewModel():SetPlaybackRate(self.PrimaryPlaybackRate)
			self:IdleAnimationDelay( self.PrimaryIdleDelay, self.PrimaryIdleDelay )
		end
	end
end

function SWEP:HandleThrustAttack()
	local attacksoundtable = GetSoundTable(self.AttackSoundTable)
	local attacktable = GetTable(self.AttackTable)

	-- Viewmodel attack animation!
	self.Weapon:EmitSound(self.WindUpSound)
	timer.Simple( attacktable["striketime"] - 0.05, function() if self:IsValid() and self.isAttacking then
	self.Weapon:EmitSound(attacksoundtable["primarysound"][math.random(1, #attacksoundtable["primarysound"])])
	end end)
	
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "atk_f" ) )
	self.Owner:GetViewModel():SetPlaybackRate(1)
	self:IdleAnimationDelay( 1, 1 )
	
	--Attack animation
	self:TriggerAnim(self.Owner, self.CriticalAnim);
	
	self.Owner:ViewPunch(Angle(8,2,2))
	
	if self.Owner.HandleNeed and not self.Owner.opponent and !self.Owner:GetCharmEquipped("warding_talisman") then
		if !self.Owner:GetCharmEquipped("crucifix") then
			self.Owner:HandleNeed("corruption", self.CorruptionGain);
		else
			self.Owner:HandleNeed("corruption", self.CorruptionGain * 0.5);
		end
	end
end

function SWEP:OnDeploy()
	local attacksoundtable = GetSoundTable(self.AttackSoundTable)
	self.Owner:ViewPunch(Angle(5,25,5))
	self:IdleAnimationDelay( 3, 3 )
	if !self.Owner.cwObserverMode then self.Weapon:EmitSound(attacksoundtable["drawsound"][math.random(1, #attacksoundtable["drawsound"])]) end;
end

function SWEP:Deploy()
	if not self.Owner.cwWakingUp and not self.Owner.LoadingText then
		self:OnDeploy()
	end

	self.Owner.gestureweightbegin = 1;
	self.Owner:SetLocalVar("CanBlock", true)
	self.canDeflect = true
	self.Owner:SetNetVar("ThrustStance", false)
	self.Owner:SetLocalVar("ParrySuccess", false) 
	self.Owner:SetLocalVar("Riposting", false)
	self.Owner:SetLocalVar("MelAttacking", false) -- This should fix the bug where you can't block until attacking.

	self:SetNextPrimaryFire(0)
	self:SetNextSecondaryFire(0)
	self:SetHoldType( self.HoldType )	
	self.Primary.Cone = self.DefaultCone
	--self.Weapon:SetNWInt("Reloading", CurTime() + self:SequenceDuration() )
	self.isAttacking = false;
	
	return true
end

function SWEP:IdleAnimationDelay( seconds, index )
	timer.Remove( self.Owner:EntIndex().."IdleAnimation" )
	self.Idling = index
	timer.Create( self.Owner:EntIndex().."IdleAnimation", seconds, 1, function()
		if not self:IsValid() or self.Idling == 0 then return end
		if self.Idling == index then
			local vm = self.Owner:GetViewModel()
			vm:SendViewModelMatchingSequence( vm:LookupSequence( "idle" ) )
			self.Owner:GetViewModel():SetPlaybackRate(1)
		end
	end )
end

/*---------------------------------------------------------
	Bone Mods
---------------------------------------------------------*/

SWEP.ViewModelBoneMods = {
	["RightHandPinky3_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(-0.45, 1.2, 0.349), angle = Angle(0, -58.889, 0) },
	["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, -5, 0), angle = Angle(0, 0, 0) },
	["RightHandMiddle3_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0.1, 0.925, 0), angle = Angle(0, 0, 0) },
	["RightHandIndex3_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0.925, 0), angle = Angle(0, 0, 0) },
	["TrueRoot"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -30, 0) },
	["RightHandRing3_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0.3, 0.55, 0.15), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["v_bardiche"] = { type = "Model", model = "models/demonssouls/weapons/crescent axe.mdl", bone = "RightHand_1stP", rel = "", pos = Vector(-3.491, 10.909, 1.399), angle = Angle(0, 90, -13), size = Vector(0.91, 0.91, 0.91), material = "", skin = 0, bodygroup = {[0] = 3} }
}

SWEP.WElements = {
	["w_bardiche"] = { type = "Model", model = "models/demonssouls/weapons/crescent axe.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(3.2, 0.55, 4.675), angle = Angle(97.013, -155.456, 71.299), size = Vector(0.899, 0.899, 0.899), material = "", skin = 0, bodygroup = {[0] = 3} }
}