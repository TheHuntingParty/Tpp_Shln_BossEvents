local this={}
local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId
local GetGameObjectIdByIndex = GameObject.GetGameObjectIdByIndex
local SendCommand = GameObject.SendCommand

local PlayerIsDetected = false
local SAHELAN_WEAKENING_COUNT = 2 
local CPPhaseSwitchCount = 0
local DidSahelanAISwitch = false
local DidSahelanUseRailgun = false
local WeakpointHitCounts = 0
local ActiveAreaRandomID = 0
local TotalBrokenParts = 0
local HasSahelanBeenBeaten = false



this.SahelanCounter = 0


this.registerMenus={
  "SahelanFreeRoamMenu",
}

this.registerIvars={
  "IsSahelanActiveIvar",
  "IsSahelanActiveArea",
  "IsSahelanPatrolRandomArea",
  "IsSahelanCurrentModel",
  "isLoadSahelanHealthBar",
  "IsSahelanDominionDifficulty",
  "IsSahelanTimer",
  "IsSahelanTimerLow", 
  "IsSahelanTimerHigh",     
}

this.SahelanFreeRoamMenu={
  parentRefs={"InfMenuDefs.safeSpaceMenu"},
  options={
    "Ivars.IsSahelanActiveIvar",
    "Ivars.IsSahelanActiveArea",
    "Ivars.IsSahelanPatrolRandomArea",
    "Ivars.IsSahelanCurrentModel",
    "Ivars.isLoadSahelanHealthBar",
    "Ivars.IsSahelanDominionDifficulty",
    "Ivars.IsSahelanTimer",	
	"Ivars.IsSahelanTimerLow", 
	"Ivars.IsSahelanTimerHigh", 	
  }
}

this.IsSahelanActiveIvar={
    save=IvarProc.CATEGORY_EXTERNAL,
    range=Ivars.switchRange,
    settingNames="set_switch",
    default=1,
}

this.IsSahelanActiveArea={
  save=IvarProc.CATEGORY_EXTERNAL,
  default=0,
  settings={0,1,2,3,4,5,6,7,8,9},
  settingNames="SahelanActiveAreaOptions",
  OnChange=function(self,settings)
    InfCore.Log(settings)
  end,
}

this.IsSahelanPatrolRandomArea={
    save=IvarProc.CATEGORY_EXTERNAL,
    range=Ivars.switchRange,
    settingNames="set_switch",
    default=0,
}

this.IsSahelanCurrentModel={
  save=IvarProc.CATEGORY_EXTERNAL,
  default=0,
  settings={0,1,2,3,4,5},
  settingNames="SahelanSkinOptions",
}

this.isLoadSahelanHealthBar={
  save=IvarProc.CATEGORY_EXTERNAL,
  default=1,
  settings={0,1},
  settingNames="SahelanHealthBarOptions",
}

this.IsSahelanDominionDifficulty={
  save=IvarProc.CATEGORY_EXTERNAL,
  default=1,
  settings={0,1,2,3},
  settingNames="SahelanDifficultyOptions",
}

this.IsSahelanTimer={
  save=IvarProc.CATEGORY_EXTERNAL,
  default=0,
  settings={0,1},
  settingNames="SahelanTimerOptions",
}

this.IsSahelanTimerLow={
  default=15,
  range={max=10000,min=0,increment=1},
}  

this.IsSahelanTimerHigh={
  default=60,
  range={max=10000,min=0,increment=1},
}  

this.langStrings={
  eng={
      SahelanFreeRoamMenu="Sahelanthropus Boss Events",
      IsSahelanActiveIvar="Sahelanthropus In Free Roam:",
      IsSahelanActiveArea="Current Active Area:",
      IsSahelanPatrolRandomArea="Randomize Active Area:",
      SahelanActiveAreaOptions={"Northern Area","Outpost 04","Yakho Oboo","Lamar Khaate","Shago Kallai","Wakh Barracks","Da wiallo Kallai","Da Ghwandai Khar","Qaria Sakhra Ee","Mountain Relay Base"},
      SahelanSkinOptions={"Default","Black","Red","GZ","Black Sky","Shagohod"},
      IsSahelanCurrentModel="Sahelanthropus Model: ",
      isLoadSahelanHealthBar="Health bar:",
      SahelanHealthBarOptions = {"Hide health bar","Show health bar"},
      IsSahelanDominionDifficulty = "Boss Fight Difficulty:",
      SahelanDifficultyOptions= {"Easy","Normal","Hard","Extreme"},
      IsSahelanTimer = "Start Condition:",
      SahelanTimerOptions= {"Alert","Random"},
      IsSahelanTimerLow = "Random Range Low:",
      IsSahelanTimerHigh = "Random Range High:",	  
    },
  help={
    eng={
      SahelanFreeRoamMenu="Options menu for Sahelanthropus Boss Events",
      IsSahelanActiveIvar="Controls if Sahelanthropus is either active or not during free roam play",
      IsSahelanActiveArea="Choose what area Sahelanthropus will roam during free roam if random area is set to false, does not affect Dominion AI mode",
      IsSahelanPatrolRandomArea="Randomizes the current active area",
      IsSahelanCurrentModel="Select what model is used by Sahelanthropus",
      isLoadSahelanHealthBar="Shows or hides the health bar, only affects Dominion AI mode",
      IsSahelanDominionDifficulty="Select the difficulty of the boss fight, does not affect Hellbound AI",
      IsSahelanTimer="Select if the fight starts on alert, or randomly within a time range",
      IsSahelanTimerLow = "Set the lowest number in the random time range in minutes",
      IsSahelanTimerHigh = "Set the Highest number in the random time range in minutes",		  
    },
  },
}

this.SahelanRouteListForAfgh = {
  [0]={
    trap_shln_area0020 = { "rts_shln_s_0020", "rts_shln_c_0020" },
    trap_shln_area0030 = { "rts_shln_s_0030", "rts_shln_c_0030" },
    trap_shln_area0040 = { "rts_shln_s_0040", "rts_shln_c_0040" },
    trap_shln_area1010 = { "rts_shln_s_1010", "rts_shln_c_1010" },
    trap_shln_area1020 = { "rts_shln_s_1020", "rts_shln_c_1020" },
    trap_shln_area1030 = { "rts_shln_s_1030", "rts_shln_c_1030" },
    trap_shln_area2010 = { "rts_shln_s_2010", "rts_shln_c_2010" },
    trap_shln_area2020 = { "rts_shln_s_2020", "rts_shln_c_2020" },
    trap_shln_area2030 = { "rts_shln_s_2030", "rts_shln_c_2030" },
    trap_shln_area2040 = { "rts_shln_s_2040", "rts_shln_c_2040" },
    trap_shln_area2050 = { "rts_shln_s_2050", "rts_shln_c_2050" },
    trap_shln_area2060 = { "rts_shln_s_2060", "rts_shln_c_2060" },
    trap_shln_area3010 = { "rts_shln_s_3010", "rts_shln_c_3010" },
    trap_shln_area3020 = { "rts_shln_s_3020", "rts_shln_c_3020" },
    trap_shln_area3030 = { "rts_shln_s_3030", "rts_shln_c_3030" },
    trap_shln_area3040 = { "rts_shln_s_3040", "rts_shln_c_3040" },
    trap_shln_area3050 = { "rts_shln_s_3050", "rts_shln_c_3050" },
    trap_shln_area3060 = { "rts_shln_s_3060", "rts_shln_c_0033" },    
    trap_shln_area3070 = { "rts_shln_s_3070", "rts_shln_c_3070" },
    trap_shln_area4010 = { "rts_shln_s_4010", "rts_shln_c_0034" },    
    trap_shln_area4020 = { "rts_shln_s_4020", "rts_shln_c_4020" },
    trap_shln_area5010 = { "rts_shln_s_5010", "rts_shln_c_5010" },
    trap_shln_area5020 = { "rts_shln_s_5020", "rts_shln_c_5020" },
    trap_shln_area5030 = { "rts_shln_s_5030", "rts_shln_c_5030" },
    trap_shln_area6010 = { "rts_shln_s_6010", "rts_shln_c_6010" },
    trap_shln_area6020 = { "rts_shln_s_6020", "rts_shln_c_0032" },    
    trap_shln_area6030 = { "rts_shln_s_6030", "rts_shln_c_6030" },
    trap_shln_area7000 = { "rts_shln_s_7000", "rts_shln_c_7000" },
    trap_shln_dummy02 = { "rts_shln_s_7000", "rts_shln_c_0023" },
    trap_shln_dummy03 = { "rts_shln_s_7000", "rts_shln_c_0031" },
    trap_shln_RoadToOKB0000 = { "rt_shln_SBtoOKB_s_0013", "rt_shln_Null", },
    trap_shln_RoadToOKB0001 = { "rt_shln_SBtoOKB_s_0015", "rt_shln_Null", },
    trap_shln_RoadToOKB0002 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0020", },
    trap_shln_RoadToOKB0003 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0021", },
    trap_shln_RoadToOKB0004 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0022", },
    trap_shln_RoadToOKB0005 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0025", },
    trap_shln_RoadToOKB0006 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0029", },
    trap_shln_RoadToOKB0007 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0026", },
    trap_shln_RoadToOKB0008 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0027", },
    trap_shln_RoadToOKB0009 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0030", },
    trap_shln_RoadToOKB0010 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0031", },
    trap_shln_RoadToOKB0011 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0024", },
    trap_shln_RoadToOKB0012 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0023", },
    trap_shln_RoadToOKB0013 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0033", },
    trap_shln_RoadToOKB0014 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0032", },
    trap_shln_RoadToOKB0015 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0034", },
    trap_shln_RoadToOKB0016 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0036", },
    trap_shln_RoadToOKB0017 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0035", },
    trap_shln_RoadToOKB0018 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0037", },
    trap_shln_RoadToOKB0019 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0038", },
    trap_shln_RoadToOKB0020 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0015", },
    trap_shln_RoadToOKB0021 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0017", },
    trap_shln_RoadToOKB0022 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0041", },
    trap_shln_RoadToOKB0023 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0039", },
    trap_shln_RoadToOKB0024 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0040", },
    trap_shln_RoadToOKB0025 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0039", },
    trap_shln_RoadToOKB0026 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0042", },
    trap_shln_RoadToOKB0027 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0044", },
    trap_shln_RoadToOKB0028 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0045", },
    trap_shln_RoadToOKB0029 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0047", },
    trap_shln_RoadToOKB0030 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0048", },
    trap_shln_RoadToOKB0031 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0049", },
    trap_shln_RoadToOKB0032 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0050", },
    trap_shln_RoadToOKB0033 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0051", },
    trap_shln_RoadToOKB0034 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0052", },
    trap_shln_RoadToOKB0035 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0056", },
    trap_shln_RoadToOKB0036 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0002", },
    trap_shln_RoadToOKB0037 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0046", },
    trap_shln_RoadToOKB0038 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0053", },
    trap_shln_RoadToOKB0039 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0054", },
    trap_shln_RoadToOKB0040 = { "rt_shln_Null", "rt_shln_SBtoOKB_c_0055", },
  },
  [1]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
  [2]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
  [3]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
  [4]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
  [5]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
  [6]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
  [7]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
  [8]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
  [9]={
    trapexample = {"rt_shln_Null","rt_shln_Null"},
  },
}

this.setOnBootSneakRoutesAfgh = {
  [0]="rt_shln_SBtoOKB_s_0015",
  [1]="rt_shln_Null",
  [2]="rt_shln_Null",
  [3]="rt_shln_Null",
  [4]="rt_shln_Null",
  [5]="rt_shln_Null",
  [6]="rt_shln_Null",
  [7]="rt_shln_Null",
  [8]="rt_shln_Null",
  [9]="rt_shlnArea9_s_0000",
}

this.setOnBootCautionRoutesAfgh = {
  [0]="rt_shln_SBtoOKB_c_0055",
  [1]="rt_shln_Null",
  [2]="rt_shln_Null",
  [3]="rt_shln_Null",
  [4]="rt_shln_Null",
  [5]="rt_shln_Null",
  [6]="rt_shln_Null",
  [7]="rt_shln_Null",
  [8]="rt_shln_Null",
  [9]="rt_shlnArea9_c_0000",
}

this.SahelanAreasAfghBaseRoutes = {
  [0]= "rts_shln_b_0000",
  [1]= "rt_shln_Null",
  [2]= "rt_shln_Null",
  [3]= "rt_shln_Null",
  [4]= "rt_shln_Null",
  [5]= "rt_shln_Null",
  [6]= "rt_shln_Null",
  [7]= "rt_shln_Null",
  [8]= "rt_shln_Null",
  [9]= "rt_shlnArea9_b_0000",
}

this.SetCautionRouteAlertAfgh = {
  [0]={
    "rts_shln_c_0020",
    "rts_shln_c_0030",
    "rts_shln_c_0040",
    "rts_shln_c_1010",
    "rts_shln_c_1020",
    "rts_shln_c_1030",
    "rts_shln_c_2010",
    "rts_shln_c_2020",
    "rts_shln_c_2030",
    "rts_shln_c_2040",
    "rts_shln_c_2050",
    "rts_shln_c_2060",
    "rts_shln_c_3010",
    "rts_shln_c_3020",
    "rts_shln_c_3030",
    "rts_shln_c_3040",
    "rts_shln_c_3050",
    "rts_shln_c_0033",
    "rts_shln_c_3070",
    "rts_shln_c_0034",
    "rts_shln_c_4020",
    "rts_shln_c_5010",
    "rts_shln_c_5020",
    "rts_shln_c_5030",
    "rts_shln_c_6010",
    "rts_shln_c_0032",
    "rts_shln_c_6030",
    "rts_shln_c_7000",
    "rts_shln_c_0023",
    "rts_shln_c_0031",
    "rt_shln_SBtoOKB_c_0020",
    "rt_shln_SBtoOKB_c_0021",
    "rt_shln_SBtoOKB_c_0022",
    "rt_shln_SBtoOKB_c_0025",
    "rt_shln_SBtoOKB_c_0029",
    "rt_shln_SBtoOKB_c_0026",
    "rt_shln_SBtoOKB_c_0027",
    "rt_shln_SBtoOKB_c_0030",
    "rt_shln_SBtoOKB_c_0031",
    "rt_shln_SBtoOKB_c_0024",
    "rt_shln_SBtoOKB_c_0023",
    "rt_shln_SBtoOKB_c_0033",
    "rt_shln_SBtoOKB_c_0032",
    "rt_shln_SBtoOKB_c_0034",
    "rt_shln_SBtoOKB_c_0036",
    "rt_shln_SBtoOKB_c_0035",
    "rt_shln_SBtoOKB_c_0037",
    "rt_shln_SBtoOKB_c_0038",
    "rt_shln_SBtoOKB_c_0015",
    "rt_shln_SBtoOKB_c_0017",
    "rt_shln_SBtoOKB_c_0041",
    "rt_shln_SBtoOKB_c_0039",
    "rt_shln_SBtoOKB_c_0040",
    "rt_shln_SBtoOKB_c_0039",
    "rt_shln_SBtoOKB_c_0042",
    "rt_shln_SBtoOKB_c_0044",
    "rt_shln_SBtoOKB_c_0045",
    "rt_shln_SBtoOKB_c_0047",
    "rt_shln_SBtoOKB_c_0048",
    "rt_shln_SBtoOKB_c_0049",
    "rt_shln_SBtoOKB_c_0050",
    "rt_shln_SBtoOKB_c_0051",
    "rt_shln_SBtoOKB_c_0052",
    "rt_shln_SBtoOKB_c_0056",
    "rt_shln_SBtoOKB_c_0002",
    "rt_shln_SBtoOKB_c_0046",
    "rt_shln_SBtoOKB_c_0053",
    "rt_shln_SBtoOKB_c_0054",
    "rt_shln_SBtoOKB_c_0055",
  },
  [1]={
    "rt_shln_Null",
  },
  [2]={
    "rt_shln_Null",
  },
  [3]={
    "rt_shln_Null",
  },
  [4]={
    "rt_shln_Null",
  },
  [5]={
    "rt_shln_Null",
  },
  [6]={
    "rt_shln_Null",
  },
  [7]={
    "rt_shln_Null",
  },
  [8]={
    "rt_shln_Null",
  },
  [9]={
    "rt_shlnArea9_nn_0000",
    "rt_shlnArea9_nn_0001",
    "rt_shlnArea9_nn_0002",
    "rt_shlnArea9_nn_0003",
    "rt_shlnArea9_nn_0004",
    "rt_shlnArea9_nn_0005",
    "rt_shlnArea9_nn_0006",
    "rt_shlnArea9_nn_0007",
    "rt_shlnArea9_nn_0008",
    "rt_shlnArea9_nn_0009",
    "rt_shlnArea9_nn_0010",
  },
}


this.sahelanLinkRouteTable = {
  
  { { "rts_shln_s_5020", 3, }, { "rts_shln_c_5010", 2 }, }, 

  --new route links here

  --{ { "", 0, }, { "", 0 }, }, 


}

this.ignoreTrapList = {}

this.MissileRouteListForAfgh = {
  [0]={
    "rts_SearchMissile0000",
    "rts_SearchMissile0001",
    "rts_SearchMissile0002",
    "rts_SearchMissile0003",
    "rts_SearchMissile0004",
    "rts_SearchMissile0005",
    "rts_SearchMissile0006",
    "rts_SearchMissile0007",
    "rts_SearchMissile0008",
    "rts_SearchMissile0009",
    "rts_SearchMissile0010",
    "rts_SearchMissile0011",
    "rts_SearchMissile0012",
    "rts_SearchMissile0013",
    "rts_SearchMissile0014",
    "rts_SearchMissile0015",
    "rts_SearchMissile0016",
    "rts_SearchMissile0017",
    "rts_SearchMissile0018",
    "rts_SearchMissile0019",
    "rts_SearchMissile0020",
    "rts_SearchMissile0021",
    "rts_SearchMissile0022",
    "rts_SearchMissile0023",
    "rts_SearchMissile0024",
    "rts_SearchMissile0025",
    "rts_SearchMissile0026",
    "rts_SearchMissile0027",
    "rts_SearchMissile0028",
    "rts_SearchMissile0029",
    "rts_SearchMissile0030",
    "rts_SearchMissile0031",
    "rts_SearchMissile0032",
    "rts_SearchMissile0033",
    "rts_SearchMissile0034",
    "rts_SearchMissile0035",
    "rts_SearchMissile0036",
    "rts_SearchMissile0037",
    "rts_SearchMissile0038",
    "rts_SearchMissile0039",
    "rts_SearchMissile0040",
    "rts_SearchMissile0041",
    "rt_SearchMissile_SVtoOKB_0000",
    "rt_SearchMissile_SVtoOKB_0001",
    "rt_SearchMissile_SVtoOKB_0002",
    "rt_SearchMissile_SVtoOKB_0003",
    "rt_SearchMissile_SVtoOKB_0004",
    "rt_SearchMissile_SVtoOKB_0005",
    "rt_SearchMissile_SVtoOKB_0006",
    "rt_SearchMissile_SVtoOKB_0007",
    "rt_SearchMissile_SVtoOKB_0008",
    "rt_SearchMissile_SVtoOKB_0009",
    "rt_SearchMissile_SVtoOKB_0010",
    "rt_SearchMissile_SVtoOKB_0011",
    "rt_SearchMissile_SVtoOKB_0012",
    "rt_SearchMissile_SVtoOKB_0013",
    "rt_SearchMissile_SVtoOKB_0014",
    "rt_SearchMissile_SVtoOKB_0015",
    "rt_SearchMissile_SVtoOKB_0016",
    "rt_SearchMissile_SVtoOKB_0017",
    "rt_SearchMissile_SVtoOKB_0018",
    "rt_SearchMissile_SVtoOKB_0019",
    "rt_SearchMissile_SVtoOKB_0020",
    "rt_SearchMissile_SVtoOKB_0021",
  },
  [1]={
    "rt_shln_Null",
  },
  [2]={
    "rt_shln_Null",
  },
  [3]={
    "rt_shln_Null",
  },
  [4]={
    "rt_shln_Null",
  },
  [5]={
    "rt_shln_Null",
  },
  [6]={
    "rt_shln_Null",
  },
  [7]={
    "rt_shln_Null",
  },
  [8]={
    "rt_shln_Null",
  },
  [9]={
    "rt_SearchMissileArea9_0000",
    "rt_SearchMissileArea9_0001",
    "rt_SearchMissileArea9_0002",
    "rt_SearchMissileArea9_0003",
    "rt_SearchMissileArea9_0004",
    "rt_SearchMissileArea9_0005",
    "rt_SearchMissileArea9_0006",
    "rt_SearchMissileArea9_0007",
    "rt_SearchMissileArea9_0008",
  },
}

this.SahelanLifePartsTable = {
  [0]={Body=12000,Bp=900,Head=3500,ArmR=900,ArmL=900,ThighR=900,ThighL=900,LegR=900,LegL=900,RGun=1400,Ldr=900,Tnk=900,Shield=22000,PTLF=260,PTRF=260,PTLB=260,PTRB=260},
  [1]={Body=12000,Bp=1200,Head=4500,ArmR=1200,ArmL=1200,ThighR=1200,ThighL=1200,LegR=1200,LegL=1200,RGun=1400,Ldr=1200,Tnk=1200,Shield=25000,PTLF=560,PTRF=560,PTLB=560,PTRB=560},
  [2]={Body=16500,Bp=3500,Head=4500,ArmR=2500,ArmL=2500,ThighR=2500,ThighL=2500,LegR=2500,LegL=2500,RGun=4400,Ldr=3500,Tnk=4000,Shield=30000,PTLF=1200,PTRF=1200,PTLB=1200,PTRB=1200},
  [3]={Body=18000,Bp=5500,Head=6500,ArmR=3500,ArmL=3500,ThighR=3500,ThighL=3500,LegR=3500,LegL=3500,RGun=5500,Ldr=5500,Tnk=5500,Shield=35000,PTLF=2200,PTRF=2200,PTLB=2200,PTRB=2200},
  [4]={Body=30000,Bp=30000,Head=30000,ArmR=30000,ArmL=30000,ThighR=30000,ThighL=30000,LegR=30000,LegL=30000,Tnk=30000,Shield=30000,PTLF=30000,PTRF=30000,PTLB=30000,PTRB=30000},
}

this.SahelanMainLifeTable = {
  [0]=31000,
  [1]=45000,
  [2]=65000,
  [3]=90000,
  [4]=500000,
}


this.SetSahelanLife = function(slife)
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local cmdSetLife = { id = "SetMaxLife", life = slife } 
  local cmdStopLife = { id = "SetStopLife", life = 10 } 
  GameObject.SendCommand( gameObjectId, cmdSetLife )
  GameObject.SendCommand( gameObjectId, cmdStopLife )
end

this.SetSahelanPartsLife =function(sahelanLifeTable)
  for partsName,partsLife in pairs ( sahelanLifeTable ) do
    local gameObjectId = {type="TppSahelan2", group=0, index=0}
    local command = { id = "SetMaxPartsLife", parts = partsName, life = partsLife }
    GameObject.SendCommand( gameObjectId, command )
  end
end

this.SetSahelanTypeHellboundAI = function()
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command = {id="SetStageType", index = 0, }  
  GameObject.SendCommand(gameObjectId, command)
end

this.SetSahelanTypeDominionAIExtreme = function()
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command = {id="SetStageType", index = 2, }  
  GameObject.SendCommand(gameObjectId, command)
end

this.SetSahelanTypeDominionAINormal = function()
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command = {id="SetStageType", index = 1, }  
  GameObject.SendCommand(gameObjectId, command)
end

this.SetDominionModeStageTypes = function()
  local gameObjectId = {type="TppSahelan2", group=0, index=0}

  if Ivars.IsSahelanDominionDifficulty:Get() == 0 then
    local command = {id="SetStageType", index = 1, }  
    GameObject.SendCommand(gameObjectId, command)    
  else
    local command = {id="SetStageType", index = 2, }  
    GameObject.SendCommand(gameObjectId, command)
  end

end


this.UpdateSahelanBaseRoute = function( baseRouteName )
  --InfCore.Log("Sally: Base Route Updated to: "..baseRouteName)
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command = {id="SetBaseRoute", route=baseRouteName}
  GameObject.SendCommand(gameObjectId, command)

end

this.SetSahelanCautionRoute = function( cautionRouteName)
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command1 = {id="SetCautionRoute", route=cautionRouteName}
  GameObject.SendCommand(gameObjectId, command1)
end

this.SetSahelanSneakRoute = function( sneakRouteName)
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command1 = {id="SetSneakRoute", route=sneakRouteName}
  GameObject.SendCommand(gameObjectId, command1)
end


this.SetSahelanRoute = function( sneakRouteName, cautionRouteName )
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command1 = {id="SetSneakRoute", route=sneakRouteName}
  local command2 = {id="SetCautionRoute", route=cautionRouteName}

  GameObject.SendCommand(gameObjectId, command1)
  GameObject.SendCommand(gameObjectId, command2)
end

--no idea what this does 
this.ResetSahelanCounter = function()
  this.SahelanCounter = 0
end
this.CountSahelanCounter = function()
  this.SahelanCounter = this.SahelanCounter + 1
end


this.SetSahelanMissileRouteList = function(CurrentSearchMissilerouteList)

  local routeList = CurrentSearchMissilerouteList
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local indexNum = 0

  for k, routeName in pairs(routeList) do
    local command = {id="SetSearchMissileRouteAll", route= routeName, index=indexNum }
    GameObject.SendCommand(gameObjectId, command)
    indexNum = indexNum + 1
  end
end

this.SetSahelanSearchRouteList = function()

  local sahelanRouteTableAlert = this.SetCautionRouteAlertAfgh[Ivars.IsSahelanActiveArea:Get()]
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local indexNum = 0

  
  for k, routeName in pairs(sahelanRouteTableAlert) do
    local command = {id="SetCautionRouteAll", route= routeName, index=indexNum }
    GameObject.SendCommand(gameObjectId, command)
    indexNum = indexNum + 1
  end
end

this.SetSahelanRouteLink = function()

  local routeLinkTable = this.sahelanLinkRouteTable
  local gameObjectId = {type="TppSahelan2", group=0, index=0}

  for setNum, linkSet in pairs(routeLinkTable) do
    local routeName = {}
    local indexNum = {}
    for k, routeInfo in pairs(linkSet) do
      routeName[k] = routeInfo[1]
      indexNum[k] = routeInfo[2]
    end
    local command = {id="SetRelativeRouteNode", route0= routeName[1], index0=indexNum[1], route1= routeName[2], index1=indexNum[2], }
    GameObject.SendCommand(gameObjectId, command)
  end
end

this.UpdateSahelanRoute = function( trapName )
  local sahelanRouteTable = this.SahelanRouteListForAfgh[Ivars.IsSahelanActiveArea:Get()]
  local ignoreTrapList = this.ignoreTrapList

  for k, ignoreTrap in pairs(ignoreTrapList) do
    if trapName == ignoreTrap and this.SahelanCounter > SAHELAN_WEAKENING_COUNT then
      return
    end
  end

  for k, v in pairs(sahelanRouteTable) do
    --if none are are null, means both have routes assigned, both routes are updated
    if v[1] ~= "rt_shln_Null" and v[2] ~= "rt_shln_Null" and v[1] ~= "rt_shln_Null0001" and v[2] ~= "rt_shln_Null0001" then 
        if k == trapName then   
          this.SetSahelanRoute( v[1], v[2] )
          InfCore.Log("UpdateSahelanRoute: "..trapName.." Activated Routes updated to: Sneak Route: "..v[1].." Caution Route: "..v[2]) 
          return  
        end
    elseif v[1] == "rt_shln_Null" and v[2] == "rt_shln_Null" then 
        if k == trapName then 
          InfCore.Log("UpdateSahelanRoute: No Routes assigned to: "..trapName.." No updates done !")
          return  
        end
    elseif v[1] ~= "rt_shln_Null" and v[2] == "rt_shln_Null" then 
      if k == trapName then 
          this.SetSahelanSneakRoute(v[1])
          InfCore.Log("UpdateSahelanRoute: "..trapName.." Only Sneak route assigned. Sneak route updated to: "..v[1])  
          return  
      end
    elseif v[1] == "rt_shln_Null" and v[2] ~= "rt_shln_Null" then 
      if k == trapName then 
          this.SetSahelanCautionRoute(v[2])
          InfCore.Log("UpdateSahelanRoute: "..trapName.." Only Caution route assigned. Caution route updated to: "..v[2])  
          return  
      end
    elseif v[1] == "rt_shln_Null0001" and v[2] ~= "rt_shln_Null0001" then 
      if k == trapName then 
          this.UpdateSahelanBaseRoute(v[2])
          InfCore.Log("UpdateSahelanRoute: "..trapName.." Base route assigned. base route updated to: "..v[2]) 
          return  
      end
    elseif v[1] ~= "rt_shln_Null0001" and v[2] == "rt_shln_Null0001" then 
      if k == trapName then 
          this.UpdateSahelanBaseRoute(v[1])
          InfCore.Log("UpdateSahelanRoute: "..trapName.." Base route assigned. base route updated to: "..v[1]) 
          return  
      end
    else
      InfCore.Log("this should not happen")  
    end 
  end 
end

this.StartRedStrom = function(stormTime)
    -- Triggers the red storm
    WeatherManager.RequestTag("Sahelan_RedFog",7) 
    -- Makes the support heli leave the AO
    GameObject.SendCommand( { type="TppHeli2", index=0, }, { id="PullOut" } )
    -- ???   
    TppSoundDaemon.PostEvent("env_para_storm")
    -- Starts the timer that disables the red storm when finished
    GkEventTimerManager.Start( "RedStromTimer", stormTime )

    -- Activates something, unknow what it does
    local gameObjectId = {type="TppSahelan2", group=0, index=0}
    local command = { id = "SetParasiteEffect" }
    GameObject.SendCommand(gameObjectId, command)

end


this.StopRedStorm = function()
    --Enables the sahelan fog tag
    WeatherManager.RequestTag("Sahelan_fog", 3 ) 
    -- ???
    TppSoundDaemon.PostEvent("env_para_storm_end")
  
    -- Checks if sahelan has used the railgun, if not, spawn the support heli
    if DidSahelanUseRailgun == false then
      this.StartHeliAntiSahelan()
    end
    
    -- Unknown what it does
    local gameObjectId = {type="TppSahelan2", group=0, index=0}
    local command = { id = "ResetParasiteEffect" }
    GameObject.SendCommand(gameObjectId, command)
end

this.CallSupportAttack = function()
  -- Gets sahelan position
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command = { id = "GetPosition" }
  local position = GameObject.SendCommand( gameObjectId, command )

  -- calls a air strike in sahelan
  TppSupportRequest.RequestSupportAttack{ attackType="BOMBARDMENT_TO_SAHELAN", pos=Vector3(position), attackLevel=5, waitTime=0.0 ,isIgnoreSectionFunc = true }
end

this.StartHeliAntiSahelan = function()
  -- Calls in the support heli with a special command, sets a point to spawn and a point to despawn isntead of a route
  local SupportgameObjectId = GameObject.GetGameObjectId("SupportHeli")
  GameObject.SendCommand(SupportgameObjectId, { id="StartAntiSahelan", startPosition=Vector3(vars.playerPosX + 350, vars.playerPosY + 160, vars.playerPosZ + 350) , pullOutPosition=Vector3(vars.playerPosX + 350, vars.playerPosY + 160, vars.playerPosZ + 350)} )
  InfCore.Log("SahelanBossEvents: StartHeliAntiSahelan called")
end

this.KeepCommandPostAlert = function ()
  local command = { id = "SetKeepAlert", enable=true }
  local gameObjectId = { type="TppCommandPost2" }
  GameObject.SendCommand( gameObjectId, command )
end

this.DisableKeepCommandPostAlert = function ()
  local gameObjectId = { type="TppCommandPost2" }
  local command = { id = "SetKeepAlert", enable=false }
  GameObject.SendCommand( gameObjectId, command )
end

this.SetUpSupportHeli = function()
  local gameObjectId = GameObject.GetGameObjectId("SupportHeli")
  GameObject.SendCommand(gameObjectId, { id="SetAntiSahelanEnabled", enabled=true  })
end

this.DisableSetUpSupportHeli = function()
  local gameObjectId = GameObject.GetGameObjectId("SupportHeli")
  GameObject.SendCommand(gameObjectId, { id="SetAntiSahelanEnabled", enabled=false  })
end

this.RewardPlayerAfterDefeatSally = function()
  
  local CurrentDifficulty = Ivars.IsSahelanDominionDifficulty:Get()
  

  if CurrentDifficulty == 0 then
    
    InfCore.Log("Sahelan beaten on Easy")

    TppMotherBaseManagement.AddHeroicPoint{heroicPoint=1300}
    TppMotherBaseManagement.AddTempResource{resourceId=0,count=150000}
    TppMotherBaseManagement.AddTempResource{resourceId=1,count=110000}
    TppMotherBaseManagement.AddTempResource{resourceId=2,count=85000}
    TppMotherBaseManagement.AddTempResource{resourceId=3,count=60000}
    TppMotherBaseManagement.AddTempResource{resourceId=4,count=8000}
    TppMotherBaseManagement.AddGmp{gmp=500000}

    TppCheckPoint.Update{safetyCurrentPosition=true}

    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_fuel", 150000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_bio", 110000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_c_metal", 85000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_m_metal", 60000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_p_metal", 8000 )

    TppUiCommand.AnnounceLogViewLangId("announce_fame_up", 1300)
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_gmp", 500000)

    --HasSahelanBeenBeaten = true
  elseif CurrentDifficulty == 1 then
    InfCore.Log("Sahelan beaten on Normal")

    local TotalParasites = 2 * TotalBrokenParts

    TppMotherBaseManagement.AddHeroicPoint{heroicPoint=2500}
    TppMotherBaseManagement.AddTempResource{resourceId=0,count=280000}
    TppMotherBaseManagement.AddTempResource{resourceId=1,count=180000}
    TppMotherBaseManagement.AddTempResource{resourceId=2,count=165000}
    TppMotherBaseManagement.AddTempResource{resourceId=3,count=90000}
    TppMotherBaseManagement.AddTempResource{resourceId=4,count=18000}
    TppMotherBaseManagement.AddTempResource{resourceId=30,count=TotalParasites}
    TppMotherBaseManagement.AddTempResource{resourceId=31,count=TotalParasites}
    TppMotherBaseManagement.AddTempResource{resourceId=32,count=TotalParasites}
    TppMotherBaseManagement.AddGmp{gmp=450000 }
    TppMotherBaseManagement.AddTempResource{resourceId=29,count=1}

    TppCheckPoint.Update{safetyCurrentPosition=true}

    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_fuel", 280000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_bio", 180000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_c_metal", 165000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_m_metal", 90000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_p_metal", 18000 )

    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_type_parasite", TotalParasites )

    TppUiCommand.AnnounceLogViewLangId("announce_fame_up", 2500)
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_gmp", 450000 )

  elseif CurrentDifficulty == 2 then
    InfCore.Log("Sahelan beaten on Hard")

    local TotalParasites = 4 * TotalBrokenParts

    TppMotherBaseManagement.AddHeroicPoint{heroicPoint=4500}
    TppMotherBaseManagement.AddTempResource{resourceId=0,count=450000}
    TppMotherBaseManagement.AddTempResource{resourceId=1,count=300000}
    TppMotherBaseManagement.AddTempResource{resourceId=2,count=250000}
    TppMotherBaseManagement.AddTempResource{resourceId=3,count=180000}
    TppMotherBaseManagement.AddTempResource{resourceId=4,count=35000}
    TppMotherBaseManagement.AddTempResource{resourceId=30,count=TotalParasites}
    TppMotherBaseManagement.AddTempResource{resourceId=31,count=TotalParasites}
    TppMotherBaseManagement.AddTempResource{resourceId=32,count=TotalParasites}
    TppMotherBaseManagement.AddGmp{gmp=800000 }
    TppMotherBaseManagement.AddTempResource{resourceId=29,count=1}

    TppCheckPoint.Update{safetyCurrentPosition=true}

    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_fuel", 450000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_bio", 300000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_c_metal", 250000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_m_metal", 180000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_p_metal", 35000 )

    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_type_parasite", TotalParasites )

    TppUiCommand.AnnounceLogViewLangId("announce_fame_up", 4500)
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_gmp", 800000 )

  elseif CurrentDifficulty == 3 then
    InfCore.Log("Sahelan beaten on Extreme")

    local TotalParasites = 8 * TotalBrokenParts

    TppMotherBaseManagement.AddHeroicPoint{heroicPoint=8000}
    TppMotherBaseManagement.AddTempResource{resourceId=0,count=1000000}
    TppMotherBaseManagement.AddTempResource{resourceId=1,count=750000}
    TppMotherBaseManagement.AddTempResource{resourceId=2,count=650000}
    TppMotherBaseManagement.AddTempResource{resourceId=3,count=350000}
    TppMotherBaseManagement.AddTempResource{resourceId=4,count=65000}
    TppMotherBaseManagement.AddTempResource{resourceId=30,count=TotalParasites}
    TppMotherBaseManagement.AddTempResource{resourceId=31,count=TotalParasites}
    TppMotherBaseManagement.AddTempResource{resourceId=32,count=TotalParasites}
    TppMotherBaseManagement.AddGmp{gmp=3500000 }
    TppMotherBaseManagement.AddTempResource{resourceId=29,count=2}

    TppCheckPoint.Update{safetyCurrentPosition=true}

    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_fuel", 1000000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_bio", 750000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_c_metal", 650000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_m_metal", 350000 )
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_p_metal", 65000 )

    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_resource", "resource_type_parasite", TotalParasites )

    TppUiCommand.AnnounceLogViewLangId("announce_fame_up", 8000)
    TppUiCommand.AnnounceLogViewLangId("announce_ops_get_gmp", 3500000 )

  else
    return
  end

end

this.DisableDDSupport = function()

  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP_BULLET, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP_WEAPON, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP_LOADOUT, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP_VEHICLE, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_ARTILLERY, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_SMOKE, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_SLEEP, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_SMOKE, false)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_CHAFF, false)
  
end

this.ResetDisableDDSupport = function()
  
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP_BULLET, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP_WEAPON, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP_LOADOUT, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_DROP_VEHICLE, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_ARTILLERY, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_SMOKE, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_SLEEP, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_SMOKE, true)
  TppUiCommand.SetMbTopMenuItemActive( TppTerminal.MBDVCMENU.MSN_ATTACK_CHAFF, true)

end


-- ### Setup func for both hellbound AI and hybrid AI
this.SetUpSahelanAfghHellboundAI = function()

  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local CombatGradecommand = { id = "SetCombatGrade", defenseValue=60000, defenseValueForWeakPoint=20000, offenseGrade=15, defenseGrade=15 }

  local CurrentBaseRoute = this.SahelanAreasAfghBaseRoutes[Ivars.IsSahelanActiveArea:Get()]

  this.SetSahelanSneakRoute(this.setOnBootSneakRoutesAfgh[Ivars.IsSahelanActiveArea:Get()])
  this.SetSahelanCautionRoute(this.setOnBootCautionRoutesAfgh[Ivars.IsSahelanActiveArea:Get()])
  
  GameObject.SendCommand(gameObjectId, CombatGradecommand)
  this.UpdateSahelanBaseRoute( CurrentBaseRoute )
  -- Sally wont move on alert without routes here
  --this.SetSahelanSearchRouteList()
  --this.SetSahelanRouteLink()
  this.SetSahelanMissileRouteList(this.MissileRouteListForAfgh[Ivars.IsSahelanActiveArea:Get()])
  this.SetSahelanLife(this.SahelanMainLifeTable[4])
  this.SetSahelanPartsLife(this.SahelanLifePartsTable[4])

end


this.SetUpSahelanAfghDominionAI = function()

  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local CombatGradecommand = { id = "SetCombatGrade", defenseValue=60000, defenseValueForWeakPoint=20000, offenseGrade=15, defenseGrade=15 }
  GameObject.SendCommand(gameObjectId, CombatGradecommand)
  this.UpdateSahelanBaseRoute( "rt_shlnArea9_b_DominionOutOfBounds" )
  this.SetSahelanLife(this.SahelanMainLifeTable[Ivars.IsSahelanDominionDifficulty:Get()])
  this.SetSahelanPartsLife(this.SahelanLifePartsTable[Ivars.IsSahelanDominionDifficulty:Get()])

end

this.ChangeCommandPostPhase = function (Phase)
  local gameObjectId = { type="TppCommandPost2" }
  local command = { id = "SetPhase", phase=Phase }
  GameObject.SendCommand( gameObjectId, command )
end


function this.AddMissionPacks(missionCode,packPaths)

  local SahelanAreasAfghPacks = {
  [0]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_0.fpk",
  },
  [1]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_1.fpk",
  },
  [2]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_2.fpk",
  },
  [3]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_3.fpk",
  },
  [4]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_4.fpk",
  },
  [5]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_5.fpk",
  },
  [6]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_6.fpk",
  },
  [7]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_7.fpk",
  },
  [8]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_8.fpk",
  },
  [9]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_dominion_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_9.fpk",
  },
}

  if Ivars.IsSahelanActiveIvar:Is(1) then
    if vars.missionCode==30010 then
      if Ivars.IsSahelanPatrolRandomArea:Is(1) then
        ActiveAreaRandomID = math.random(0,9)
        for i,packagePath in ipairs(SahelanAreasAfghPacks[ActiveAreaRandomID])do
          packPaths[#packPaths+1]=packagePath
        end
      else
        for i,packagePath in ipairs(SahelanAreasAfghPacks[Ivars.IsSahelanActiveArea:Get()])do
          packPaths[#packPaths+1]=packagePath
        end
      end
    elseif vars.missionCode==30020 then
      --for i,packagePath in ipairs(this.packages.sally_stuffMafr)do
      --  packPaths[#packPaths+1]=packagePath
      --end
      return
    end
  end
end
  

-- ### MESSAGE TABLES ###

-- ### Message table used for Hellbound AI only ###
function this.MessagesForHellboundAI()
    return
      StrCode32Table {
        Trap=this.sahelanTraps,
        GameObject={    
                      { 
                        msg = "ChangePhase",
                        func = function( cpId, phase )
                          if phase == TppGameObject.PHASE_ALERT or phase == TppGameObject.PHASE_CAUTION then
                            if PlayerIsDetected == false then
                              this.SetSahelanTypeHellboundAI()
                              TppMission.StartBossBattle()
                              PlayerIsDetected = true
                            end 
                          end         
                        end
                      },    
                    },  
                  }
end

-- ### Message table for Hybrid AI ###
function this.MessagesForHybridAI()
    return
      StrCode32Table {
        Trap=this.sahelanTraps,
        GameObject={    
                      { 
                        msg = "ChangePhase",
                        func = function( cpId, phase )
                          if phase == TppGameObject.PHASE_ALERT or phase == TppGameObject.PHASE_CAUTION then
                            CPPhaseSwitchCount = CPPhaseSwitchCount + 1
                            if PlayerIsDetected == false then
                              this.SetSahelanTypeHellboundAI()
                              TppMission.StartBossBattle()
                              PlayerIsDetected = true
                            end
                          elseif CPPhaseSwitchCount >= 5 and DidSahelanAISwitch == false then
                            this.SetDominionModeStageTypes()
                            DidSahelanAISwitch = true
                          end         
                        end
                      },
                      {
                        -- ### Checks if sahelan is dead###
                        msg = "Dead",
                        func = function(id)
                          if id == GameObject.GetGameObjectId("Sahelanthropus") then
                            InfCore.Log("SahelanBossEvents: sahelan dead")
                            this.StopRedStorm()
                            -- debug
                            InfCore.Log("SahelanBossEvents: Weak Hit Count totall: "..WeakpointHitCounts)
                          end
                        end,
                      },
                      -- ### Sent after mantis is hit by the player ###
                      {
                        msg = "Damage",
                        func = function (id)
                          if id == GameObject.GetGameObjectId("Mantis") then
                            InfCore.Log("SahelanBossEvents: Mantis hit by player")
                          end
                        end,
                      },
                      -- ### Sahelan head was broken by the player ###
                      {
                        msg = "SahelanHeadBroken",
                        func = function()
                          InfCore.Log("SahelanBossEvents: sahelan head broken")
                        end,
                      },
                      -- ### unknown when called exactly, calls a airtrike in sahelan
                      { 
                        msg = "SahelanEnableSuportAttack",
                        func = function()
                            this.CallSupportAttack()
                        end,
                      },
                      -- ### Makes the support heli attack sahelen, its essencial for battle sequence, not optional
                      { 
                        msg = "SahelanEnableHeliAttack",
                        func = function()
                          this.StopRedStorm()         
                          GameObject.SendCommand( { type="TppHeli2", index=0, }, { id="SetAntiSahelanEventEnabled", enabled=true } )   
                        end,
                      },
                      -- ### Triggers after sahelan uses the red mist grenades ###
                      { 
                        msg = "SahelanGrenadeExplosion",
                        func = function()
                            -- number set here defines the duration in seconds, can be canceled by fight sequence changing
                            this.StartRedStrom(100)
                        end,
                      },
                      -- ### Triggers after sahelan starts using the railgun for the first time ###
                      { 
                        msg = "Sahelan1stRailGun",
                        func = function()
                          DidSahelanUseRailgun = true
                          -- disables the heli attack against sahelan and requests a pull out
                          GameObject.SendCommand( { type="TppHeli2", index=0, }, { id="SetAntiSahelanEventEnabled", enabled=false } )
                          GameObject.SendCommand( { type="TppHeli2", index=0, }, { id="PullOut" } ) 
                        end,
                      },
                      -- ### Triggers after sahelan leaves rex mode for the 1st time and starts the last phase of the batlle ###
                      { 
                        msg = "SahelanReturned1stRailGun",
                        func = function()
                          InfCore.Log("SahelanBossEvents: SahelanReturned1stRailGun")
                        end,
                      },
                      -- ### Triggers at every fight phase change ###
                      { 
                        msg = "SahelanChangePhase",
                        func = function(id,phaseName)
                          if phaseName == TppSahelan2.SAHELAN2_PHASE_1ST  then 
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_1ST")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_2ND then 
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_2ND")
                            this.StartHeliAntiSahelan()
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_3RD then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_3RD")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_4TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_4TH")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_5TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_5TH")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_6TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_6TH")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_7TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_7TH")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_8TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_8TH") 
                          end
                        end,
                      },
                      -- ### Triggers every time a part is broken ? ###
                      { 
                        msg = "SahelanPartsBroken",
                        func = function()
                          InfCore.Log("SahelanBossEvents: SahelanPartsBroken")
                        end,
                      },
                      -- ### Triggers when the player hits the weak point (glowing chest when it does sword attacks ?) ###
                      { 
                        msg = "SahelanBlastDamageToWeakPoint",
                        func = function()
                          WeakpointHitCounts = WeakpointHitCounts + 1
                        end,
                      },
                      -- ### Triggers when sahelan attacks the heli before 1st rex mode ###
                      { 
                        msg = "SahelanSearchMissileToHeli",
                        func = function()
                        InfCore.Log("SahelanBossEvents: SahelanSearchMissileToHeli")         
                          this.StopRedStorm()
                        end,
                      },
        },
        Timer = {
                  {
                    msg = "Finish",
                    sender = "RedStromTimer",
                    func = function()
                      this.StopRedStorm()
                    end
                  },
				  --{	
					-- Starts the fight when the timer's value is reached
                    --msg = "Finish",
                    --sender = "SpawnTimer",
                    --func = function()
						--if Ivars.IsSahelanTimer:Get() == 1 then	
							-- No clue what this does
							--TppMission.StartBossBattle()
							--Activates sahelan
							--this.SetDominionModeStageTypes()
							-- Sets all CPs on aler and keeps them that way
							--if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
								--this.ChangeCommandPostPhase( TppGameObject.PHASE_ALERT )
								--this.KeepCommandPostAlert()
							--end
							-- sets the heli to Anti Sahelan mode, very important
							--this.SetUpSupportHeli()
							--TotalBrokenParts = 0
							-- debug log
							--InfCore.Log("SahelanBossEvents: ChangePhase = start fight")
						--end
					--end
                  --},					  
        }, 
      }
end


-- ### Message table for Dominion AI ###
function this.MessagesForDominionAI()
    return
      StrCode32Table {
        GameObject={    
                      { 
                        msg = "ChangePhase",
                        func = function( cpId, phase )
							if Ivars.IsSahelanTimer:Get() == 0 then	
								if phase == TppGameObject.PHASE_ALERT then								
									if CPPhaseSwitchCount <= 0 then
										CPPhaseSwitchCount = CPPhaseSwitchCount + 1
										-- No clue what this does
										TppMission.StartBossBattle()
										--Activates sahelan
										this.SetDominionModeStageTypes()
										-- Sets all CPs on aler and keeps them that way
										if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
											this.ChangeCommandPostPhase( TppGameObject.PHASE_ALERT )
											this.KeepCommandPostAlert()
										end
										-- sets the heli to Anti Sahelan mode, very important
										this.SetUpSupportHeli()
										TotalBrokenParts = 0
										-- debug log
										InfCore.Log("SahelanBossEvents: ChangePhase = start fight")
									end
								end
							end         
						end
                      },
                      {
                        -- ### Checks if sahelan is dead###
                        msg = "Dead",
                        func = function(id)
                          if id == GameObject.GetGameObjectId("Sahelanthropus") then
                            InfCore.Log("SahelanBossEvents: sahelan dead")
                            --disable red fog 
                            this.StopRedStorm()
                            if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
                                this.DisableKeepCommandPostAlert()
                                this.ResetDisableDDSupport()
                            end
                            --end boss fight
                            TppMission.FinishBossBattle()
                            -- sets support heli to default behaviour
                            this.DisableSetUpSupportHeli()
                            -- rewards for player
                            this.RewardPlayerAfterDefeatSally()
                            -- debug total weak hit count
                            --InfCore.Log("SahelanBossEvents: Weak Hit Count total: "..WeakpointHitCounts)
                          end
                        end,
                      },
                      -- ### Sent after mantis is hit by the player ###
                      {
                        msg = "Damage",
                        func = function (id)
                          if id == GameObject.GetGameObjectId("Mantis") then
                            InfCore.Log("SahelanBossEvents: Mantis hit by player")
                          end
                        end,
                      },
                      -- ### Sahelan head was broken by the player ###
                      {
                        msg = "SahelanHeadBroken",
                        func = function()
                          InfCore.Log("SahelanBossEvents: sahelan head broken")
                          if Ivars.IsSahelanDominionDifficulty:Get() == 1 then
                            this.SetSahelanTypeDominionAINormal()
                          end
                        end,
                      },
                      -- ### unknown when called exactly, calls a airtrike in sahelan
                      { 
                        msg = "SahelanEnableSuportAttack",
                        func = function()
                            this.CallSupportAttack()
                        end,
                      },
                      -- ### Makes the support heli attack sahelen, its essencial for battle sequence, not optional
                      { 
                        msg = "SahelanEnableHeliAttack",
                        func = function()
                          this.StopRedStorm()         
                          GameObject.SendCommand( { type="TppHeli2", index=0, }, { id="SetAntiSahelanEventEnabled", enabled=true } )   
                        end,
                      },
                      -- ### Triggers after sahelan uses the red mist grenades ###
                      { 
                        msg = "SahelanGrenadeExplosion",
                        func = function()
                            -- number set here defines the duration in seconds, can be canceled by fight sequence changing
                            if Ivars.IsSahelanDominionDifficulty:Get() == 0 then
                              this.StartRedStrom(60)
                            elseif Ivars.IsSahelanDominionDifficulty:Get() == 1 then
                              this.StartRedStrom(90)
                            elseif Ivars.IsSahelanDominionDifficulty:Get() == 2 then
                              Player.UnsetEquip{ slotType = PlayerSlotType.PRIMARY_1, dropPrevEquip = false,}
                              Player.UnsetEquip{ slotType = PlayerSlotType.PRIMARY_2, dropPrevEquip = false,}
                              this.StartRedStrom(110)
                            elseif Ivars.IsSahelanDominionDifficulty:Get() == 3 then
                              this.StartRedStrom(160)
                              Player.UnsetEquip{ slotType = PlayerSlotType.PRIMARY_1, dropPrevEquip = false,}
                              Player.UnsetEquip{ slotType = PlayerSlotType.PRIMARY_2, dropPrevEquip = false,}
                            else
                              return
                            end
                        end,
                      },
                      -- ### Triggers after sahelan starts using the railgun for the first time ###
                      { 
                        msg = "Sahelan1stRailGun",
                        func = function()
                          DidSahelanUseRailgun = true
                          -- disables the heli attack against sahelan and requests a pull out
                          GameObject.SendCommand( { type="TppHeli2", index=0, }, { id="SetAntiSahelanEventEnabled", enabled=false } )
                          GameObject.SendCommand( { type="TppHeli2", index=0, }, { id="PullOut" } ) 
                        end,
                      },
                      -- ### Triggers after sahelan leaves rex mode for the 1st time and starts the last phase of the batlle ###
                      { 
                        msg = "SahelanReturned1stRailGun",
                        func = function()
                          InfCore.Log("SahelanBossEvents: SahelanReturned1stRailGun")
                        end,
                      },
                      -- ### Triggers at every fight phase change ###
                      { 
                        msg = "SahelanChangePhase",
                        func = function(id,phaseName)
                          if phaseName == TppSahelan2.SAHELAN2_PHASE_1ST  then 
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_1ST")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_2ND then 
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_2ND")
                            this.StartHeliAntiSahelan()
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_3RD then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_3RD")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_4TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_4TH")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_5TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_5TH")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_6TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_6TH")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_7TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_7TH")
                          elseif phaseName == TppSahelan2.SAHELAN2_PHASE_8TH then
                            InfCore.Log("SahelanBossEvents: SAHELAN2_PHASE_8TH") 
                          end
                        end,
                      },
                      -- ### Triggers every time a part is broken ? ###
                      { 
                        msg = "SahelanPartsBroken",
                        func = function()
                          InfCore.Log("SahelanBossEvents: SahelanPartsBroken")
                          TotalBrokenParts = TotalBrokenParts + 1
                        end,
                      },
                      -- ### Triggers when the player hits the weak point (glowing chest when it does sword attacks ?) ###
                      { 
                        msg = "SahelanBlastDamageToWeakPoint",
                        func = function()
                          WeakpointHitCounts = WeakpointHitCounts + 1
                        end,
                      },
                      -- ### Triggers when sahelan attacks the heli before 1st rex mode ###
                      { 
                        msg = "SahelanSearchMissileToHeli",
                        func = function()
                        InfCore.Log("SahelanBossEvents: SahelanSearchMissileToHeli")         
                          this.StopRedStorm()
                        end,
                      },
        },
        Timer = {
                  {
                    msg = "Finish",
                    sender = "RedStromTimer",
                    func = function()
                      this.StopRedStorm()
                    end
                  },
                  {
					-- Starts the fight when the timer's value is reached
                    msg = "Finish",
                    sender = "SpawnTimer",
                    func = function()
						if Ivars.IsSahelanTimer:Get() == 1 then	
							-- No clue what this does
							TppMission.StartBossBattle()
							--Activates sahelan
							this.SetDominionModeStageTypes()
							-- Sets all CPs on aler and keeps them that way
							if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
								this.ChangeCommandPostPhase( TppGameObject.PHASE_ALERT )
								this.KeepCommandPostAlert()
							end
							-- sets the heli to Anti Sahelan mode, very important
							this.SetUpSupportHeli()
							TotalBrokenParts = 0
							-- debug log
							InfCore.Log("SahelanBossEvents: ChangePhase = start fight")
						end
					end
                  },				  
        }, 
      }
end





--  ### IMPORTANT: The "sahelanTraps" needs to be set up here 1st, otherwise a empty table will be submited ### 
--  ### Seems to work After Checkpoint and game reboot done this way                                        ###


function this.Init(missionTable)
  if Ivars.IsSahelanActiveIvar:Is(1) then
    if vars.missionCode==30010 then    
      this.sahelanTraps = {} 
      for trapName,sahelanRoutes in pairs ( this.SahelanRouteListForAfgh[Ivars.IsSahelanActiveArea:Get()] ) do
        local trapTable = {
          msg = "Enter",  sender = trapName,
          func = function ()  this.UpdateSahelanRoute( trapName ) end
        }
        table.insert( this.sahelanTraps, trapTable )
		-- Sets the random timer for starting fight
		this.SetTimer("SpawnTimer", math.random(Ivars.IsSahelanTimerLow:Get()*60,Ivars.IsSahelanTimerHigh:Get()*60))
      end
      this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForDominionAI())
    end 
  end
 end



this.SetUpEnemy = function ()
  if Ivars.IsSahelanActiveIvar:Is(1) then
    if vars.missionCode==30010 then
      this.SetUpSahelanAfghDominionAI()
    end
    CPPhaseSwitchCount = 0
    PlayerIsDetected = false
    DidSahelanAISwitch = false
    if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
      this.DisableDDSupport()
    end
  end
end 



function this.OnReload(missionTable)
  if Ivars.IsSahelanActiveIvar:Is(1) then
    if vars.missionCode==30010 then
      this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForDominionAI())
    end
    CPPhaseSwitchCount = 0
    PlayerIsDetected = false
    DidSahelanAISwitch = false
    if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
      this.DisableDDSupport()
    end
  end   
end


function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
  if Ivars.IsSahelanActiveIvar:Is(1) then
    if vars.missionCode==30010 then
      Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
    end
  end   
end
 
this.SetTimer = function( timeString, seconds )
	if GkEventTimerManager.IsTimerActive( timeString ) then		
		GkEventTimerManager.Stop( timeString )
		GkEventTimerManager.Start( timeString, seconds )
	else
		
		GkEventTimerManager.Start( timeString, seconds )
	end

end
 
return this 