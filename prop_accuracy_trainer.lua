local pat_respawntime = CreateClientConVar("pat_respawntime",15,true,false,"Time before the target automatically respawns",0)
local pat_spheresize = CreateClientConVar("pat_spheresize",40,true,false,"Target size",0,100)
local pat_wallcompensation = CreateClientConVar("pat_wallcompensation",32,true,false,"Maximum distance to a wall to reverse direction",0)
local pat_spherespeed = CreateClientConVar("pat_spherespeed",4,true,false,"Target speed",0)
local pat_maxheadingdiff = CreateClientConVar("pat_maxheadingdiff",10,true,false,"Max angle change per frame",0,360)
local pat_skybox = CreateClientConVar("pat_skybox",1,true,false,"Make skybox gray",0,1)
local pat_showscore = CreateClientConVar("pat_showscore",1,true,false,"Show score on the right side of the screen",0,1)

surface.CreateFont("PAT_HUDFont", {
	font = "Arial",
	extended = false,
	size = 20,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

hook.Remove("HUDPaint","PAT_PointVisualizer")
hook.Remove("PreDrawEffects","PAT_SeedVisualizer")

local pointfield = {}
local validpoints = {}
local seeds = {}

local hits = 0
local nearmisses = 0
local misses = 0

local origSize = 0
local iterPtr = 1

local function CastRays(sVec,rayAmt)
	for i=1,rayAmt do
		local rAng = Angle()

		rAng:Random()

		local Trace = util.QuickTrace(sVec,rAng:Forward()*2048,{LocalPlayer()},player.GetAll())

		pointfield[#pointfield+1] = Trace.HitPos+(Trace.HitNormal*pat_wallcompensation:GetFloat())
	end
end

local function LerpPoints()
	for i=1,#pointfield-1 do
		local rand = math.random(1,#pointfield)
		if rand == i then rand = rand+1 end

		local lerped = LerpVector(math.Rand(0.333,0.666),pointfield[i],pointfield[rand])

		if not (util.QuickTrace(pointfield[i],lerped-pointfield[i]).Hit or util.QuickTrace(pointfield[rand],lerped-pointfield[rand]).Hit) then
			validpoints[#validpoints+1] = lerped
		end
	end
end

local function Iterator(mode)
	iterPtr = iterPtr + 1

	CastRays(pointfield[iterPtr],4)

	if iterPtr-1 >= origSize then 
		origSize = #pointfield

		if mode then
			LerpPoints()
		end

		return
	end

	if (iterPtr-1)%16384 == 0 then
		return timer.Simple(0.5,function()Iterator(mode)end)
	else
		return Iterator(mode)
	end
end

local LocalProp = nil

hook.Add("DrawPhysgunBeam","PhysgunOverwrite",function(ply, physgun, enabled, target, physBone, hitPos)
	if ply == LocalPlayer() then
		LocalProp = target
	end
end)


concommand.Add("pat_createseed",function()
	seeds[#seeds+1] = LocalPlayer():EyePos()
end)

concommand.Add("pat_createpoints",function()
	for _,p in pairs(seeds) do
		CastRays(p,4)
	end

	origSize = #pointfield

	for i=1,6 do
		Iterator()
	end

	Iterator(true)
end)

concommand.Add("pat_clearpoints",function()
	table.Empty(pointfield)
	table.Empty(validpoints)
	table.Empty(seeds)

	iterPtr = 1
end)

local pointESPEnabled = false

concommand.Add("pat_pointesp",function()
	if not pointESPEnabled then
		local visualizedpoints = {}
		local visualizedvalidpoints = {}

		for i=1,2048 do
			visualizedpoints[#visualizedpoints+1] = pointfield[math.random(1,#pointfield)]
		end

		for i=1,2048 do
			visualizedvalidpoints[#visualizedvalidpoints+1] = validpoints[math.random(1,#validpoints)]
		end

		hook.Add("HUDPaint","PAT_PointVisualizer",function()
			for _,p in pairs(visualizedpoints) do
				local data2D = p:ToScreen()
				if not data2D.visible then continue end

				surface.DrawCircle(data2D.x,data2D.y,2,Color(255,0,0))
			end

			for _,p in pairs(visualizedvalidpoints) do
				local data2D = p:ToScreen()
				if not data2D.visible then continue end

				surface.DrawCircle(data2D.x,data2D.y,2,Color(0,0,255))
			end
		end)
	else
		hook.Remove("HUDPaint","PAT_PointVisualizer")
	end

	pointESPEnabled = not pointESPEnabled
end)

local seedESPEnabled = false

concommand.Add("pat_seedesp",function()
	if not seedESPEnabled then
		hook.Add("PreDrawEffects","PAT_SeedVisualizer",function()
			for _,p in pairs(seeds) do
				render.SetColorMaterialIgnoreZ()
				render.DrawWireframeSphere(p,25,10,10,Color(0,255,0))
			end
		end)
	else
		hook.Remove("PreDrawEffects","PAT_SeedVisualizer")
	end

	seedESPEnabled = not seedESPEnabled
end)

local CanMiss = true
local HitSphere = false
local SphereCoordinate = nil
local SphereHeading = Angle()
SphereHeading:Random()

local function MissSound()
	if CanMiss then
		CanMiss = false
		sound.Play("buttons/blip1.wav",SphereCoordinate,100,50,1) 
		timer.Simple(0.2,function()CanMiss = true end)
		nearmisses = nearmisses + 1
	end
end

timer.Create("PAT_SphereSpawner",1,0,function()
	if #validpoints > 0 then
		SphereCoordinate = validpoints[math.random(1,#validpoints)]
		if HitSphere then
			hits = hits + 1
			sound.Play("physics/glass/glass_bottle_break2.wav",SphereCoordinate,100,100,1)
		else
			sound.Play("buttons/blip1.wav",SphereCoordinate,100,100,1)
			misses = misses + 1
		end
		timer.Adjust("PAT_SphereSpawner",pat_respawntime:GetFloat())

		HitSphere = false
	else
		SphereCoordinate = nil
	end
end)

hook.Add("Think","PAT_SphereLogic",function()
	if SphereCoordinate then
		for _,prop in pairs(ents.FindByClass("prop_physics")) do
			local Trace = util.QuickTrace(SphereCoordinate,(prop:LocalToWorld(prop:OBBCenter()))-SphereCoordinate,function(p)
				if p:GetClass() == "prop_physics" then return true end
			end)

			if Trace.HitNonWorld and SphereCoordinate:Distance(Trace.HitPos) <= pat_spheresize:GetFloat() then
				if not LocalProp:IsValid() then
					timer.Adjust("PAT_SphereSpawner",0)
					timer.Start("PAT_SphereSpawner")
					HitSphere = true
				else
					MissSound()
				end
			end
		end

		local Offset = Angle()
		Offset:Random(-pat_maxheadingdiff:GetFloat(),pat_maxheadingdiff:GetFloat())

		local HeadingTrace = util.QuickTrace(SphereCoordinate,SphereHeading:Forward()*pat_wallcompensation:GetFloat())
		if HeadingTrace.HitWorld then
			SphereHeading = (HeadingTrace.HitNormal):Angle()
		end

		SphereHeading = SphereHeading + Offset
		SphereCoordinate = SphereCoordinate + (SphereHeading:Forward()*pat_spherespeed:GetFloat())

		LocalProp = nil
	end
end)

hook.Add("PreDrawEffects","PAT_SphereVisualizer",function()
	if SphereCoordinate then
		render.SetColorMaterialIgnoreZ()
		render.DrawSphere(SphereCoordinate,pat_spheresize:GetFloat()-1,10,10,Color(0,0,0))
		render.DrawWireframeSphere(SphereCoordinate,pat_spheresize:GetFloat(),10,10,Color(255,255,255))
	end
end)

hook.Add("PostDrawSkyBox","PAT_SkyBox",function()
	if pat_skybox:GetInt() ~= 0 then
		render.Clear(25,25,25,255)
	end
end)

concommand.Add("pat_resetscore",function()
	misses = 0
	nearmisses = 0
	hits = 0
end)

hook.Add("HUDPaint","PAT_HudData",function()
	if pat_showscore:GetInt() ~= 0 then
		surface.SetFont("PAT_HUDFont")
		local x1,y1 = surface.GetTextSize(tostring(misses))
		local x2,y2 = surface.GetTextSize(tostring(nearmisses))
		local x3,y3 = surface.GetTextSize(tostring(hits))
		local dx,dy = surface.GetTextSize("/")

		draw.SimpleTextOutlined(tostring(misses),"PAT_HUDFont",ScrW()-10,ScrH()/2+10,Color(255,120,100,255),2,3,2,Color(0,0,0,255))
		draw.SimpleTextOutlined("/","PAT_HUDFont",(ScrW()-10)-x1-5,ScrH()/2+10,Color(255,255,255,255),2,3,2,Color(0,0,0,255))
		draw.SimpleTextOutlined(tostring(nearmisses),"PAT_HUDFont",((ScrW()-10)-x1-5)-dx-5,ScrH()/2+10,Color(100,120,255,255),2,3,2,Color(0,0,0,255))
		draw.SimpleTextOutlined("/","PAT_HUDFont",(((ScrW()-10)-x1-5)-dx-5)-x2-5,ScrH()/2+10,Color(255,255,255,255),2,3,2,Color(0,0,0,255))
		draw.SimpleTextOutlined(tostring(hits),"PAT_HUDFont",((((ScrW()-10)-x1-5)-dx-5)-x2-5)-x3,ScrH()/2+10,Color(100,255,120,255),2,3,2,Color(0,0,0,255))

		local ratio = hits/(hits+misses)
		draw.SimpleTextOutlined(string.format("%.2f",tostring((ratio == ratio and ratio or 0))),"PAT_HUDFont",ScrW()-10,ScrH()/2-10,Color(255,255,255,255),2,3,2,Color(0,0,0,255))
	end
end)