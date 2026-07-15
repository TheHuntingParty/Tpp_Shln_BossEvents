local this={
	description="Test Area",
	locationName="SHDV",
	locationId=141,
	packs={"/Assets/tpp/pack/location/shdv/shdv.fpk"},
		

	 locationMapParams={
		 stageSize=4092*2,
		 scrollMaxLeftUpPosition=Vector3(-1024,0,-1024),
		 scrollMaxRightDownPosition=Vector3(1024,0,1024),
		 highZoomScale=3, 
		 middleZoomScale=2,
		 lowZoomScale=1,
		 naviHighZoomScale = 3,
		 naviMiddleZoomScale = 2,
		 locationNameLangId="tpp_loc_shdv",
		 stageRotate=0,
		 heightMapTexturePath="/Assets/tpp/ui/texture/map/map_shdv/shdv_idroid_text.ftex",
		 photoRealMapTexturePath="/Assets/tpp/ui/texture/map/map_shdv/shdv_idroid_text.ftex",
	 },
	 globalLocationMapParams={
		sectionFuncRankForDustBox = 4, 
		sectionFuncRankForToilet  = 4, 
		isSpySearchEnable = false,--tex was true
		isHerbSearchEnable = false,--tex was true
		spySearchRadiusMeter = { 40.0, 40.0, 35.0, 30.0, 25.0, 20.0, 15.0, 10.0, },
		spySearchIntervalSec = { 420.0, 420.0, 360.0, 300.0, 240.0, 180.0, 120.0, 60.0, },
		herbSearchRadiusMeter = { 0.0,  0.0,  10.0, 15.0, 20.0, 25.0, 30.0, 35.0, },
	},

}
return this