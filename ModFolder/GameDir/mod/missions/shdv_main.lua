local this={	
	missionCode=13050,
	location="SHDV",
	packs=function(missionCode)
		TppPackList.AddMissionPack("/Assets/tpp/pack/location/shdv/pack_common/shdv_script.fpk")
		TppPackList.AddMissionPack("/Assets/tpp/pack/mission2/shln/dev/sh_dev.fpk") --The mission's core "area" pack
	end,
	enableOOB=true,
	missionMapParams={
		missionArea2 = {
			{ 
				name="trig_innerZone", 
				vertices={ 
					Vector3(370,1000,370),
					Vector3(370,1000,-370),
					Vector3(-370,1000,-370),
					Vector3(-370,1000,370),
				},  
			},
			{
				name="trig_outerZone",
				vertices={ 
					Vector3(386,1000,386),
					Vector3(386,1000,-386),
					Vector3(-386,1000,-386),
					Vector3(-386,1000,386),
				},  
			},
			
        },
        safetyArea2 = {
			{ 
				name="trig_hotZone", 
				vertices={ 
					Vector3(370,1000,370),
					Vector3(370,1000,-370),
					Vector3(-370,1000,-370),
					Vector3(-370,1000,370),
				},  
			},
		},
        missionStartPoint = {
		},
	},
	startPos={0,1000.05,0},
}

return this