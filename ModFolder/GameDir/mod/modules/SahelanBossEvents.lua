local this={}
local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId
local GetGameObjectIdByIndex = GameObject.GetGameObjectIdByIndex
local SendCommand = GameObject.SendCommand

local PlayerIsDetected = false
local SAHELAN_WEAKENING_COUNT = 2 
local CPPhaseSwitchCount = 0
local DidSahelanUseRailgun = false
local WeakpointHitCounts = 0
local ActiveAreaRandomID = 0
local TotalBrokenParts = 0
local HasSahelanBeenBeaten = false



this.SahelanCounter = 0


this.registerMenus={
  "SahelanFreeRoamMenu",
  "SahelanFreeRoamMenuGNTN",
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
  "IsSahelanActiveInGntn",
  "IsSahelanAIModeGntn",
  "IsSahelanHellboundActiveAtStartGntn",
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
    "SahelanBossEvents.GOTODevArea", 	
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
  settings={0,1,2,3,4,5,6},
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
  save=IvarProc.CATEGORY_EXTERNAL,
  default=10,
  range={max=10000,min=1,increment=1},
}  

this.IsSahelanTimerHigh={
  save=IvarProc.CATEGORY_EXTERNAL,
  default=15,
  range={max=10000,min=1,increment=1},
}  

this.SahelanFreeRoamMenuGNTN={
  parentRefs={"SahelanBossEvents.SahelanFreeRoamMenu"},
  options={
    "Ivars.IsSahelanActiveInGntn",
    "Ivars.IsSahelanAIModeGntn",
  }
}

this.IsSahelanActiveInGntn={
    save=IvarProc.CATEGORY_EXTERNAL,
    range=Ivars.switchRange,
    settingNames="set_switch",
    default=1,
}

this.IsSahelanAIModeGntn={
  save=IvarProc.CATEGORY_EXTERNAL,
  default=0,
  settings={0,1},
  settingNames="SahelanGntnAIModeOptions",
}

this.langStrings={
  eng={
      SahelanFreeRoamMenu="Sahelanthropus Boss Events",
      IsSahelanActiveIvar="Sahelanthropus In Free Roam:",
      IsSahelanActiveArea="Current Active Area:",
      IsSahelanPatrolRandomArea="Randomize Active Area:",
      SahelanActiveAreaOptions={"Northern Area","Outpost 04","Yakho Oboo","Lamar Khaate","Shago Kallai","Wakh Barracks","Da wiallo Kallai","Da Ghwandai Khar","Qaria Sakhra Ee","Mountain Relay Base"},
      SahelanSkinOptions={"Default","Black","Red","GZ","Black Sky","Shagohod","Briges"},
      IsSahelanCurrentModel="Sahelanthropus Model: ",
      isLoadSahelanHealthBar="Health bar:",
      SahelanHealthBarOptions = {"Hide health bar","Show health bar"},
      IsSahelanDominionDifficulty = "Boss Fight Difficulty:",
      SahelanDifficultyOptions= {"Easy","Normal","Hard","Extreme"},
      IsSahelanTimer = "Start Condition:",
      SahelanTimerOptions= {"Alert","Random"},
      IsSahelanTimerLow = "Random Range Low:",
      IsSahelanTimerHigh = "Random Range High:",	  
      SahelanFreeRoamMenuGNTN="Guantanamo options",
      IsSahelanActiveInGntn="Active in Guantanamo",
      IsSahelanAIModeGntn="AI Mode",
      SahelanGntnAIModeOptions = {"Hellbound AI","Dominion AI"},
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
      SahelanFreeRoamMenuGNTN="Options menu for Sahelanthropus on Guantanamo",
      IsSahelanActiveInGntn="Controls if Sahelanthropus is either active or not during free roam play in Guantanamo",
      IsSahelanAIModeGntn="Select what AI mode to use",
    },
  },
}

this.SahelanRouteListForAfgh = {
  [0]={
    trapexample = { "rt_shln_Null", "rt_shln_Null" },
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
  [0]="rt_shln_Null",
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
  [0]="rt_shln_Null",
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
  [0]= "rt_shln_Null",
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
    "rt_shln_Null",
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


this.sahelanLinkRouteTableAfgh = {
  [0]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [1]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [2]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [3]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [4]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [5]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [6]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [7]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [8]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
  [9]={
    { { "rt_shln_Null", 0, }, { "rt_shln_Null", 0 }, },
  },
}

this.ignoreTrapListAfgh = {}

this.MissileRouteListForAfgh = {
  [0]={
    "rt_shln_Null",
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

this.SahelanRouteListForGntn = {
  [0]={
    Shln_GntnArea0_Trap0000 = { "rt_gntn_shlnArea0_s_0003", "rt_shln_Null", },
    Shln_GntnArea0_Trap0001 = { "rt_gntn_shlnArea0_s_0003", "rt_shln_Null", },
    Shln_GntnArea0_Trap0002 = { "rt_gntn_shlnArea0_s_0003", "rt_shln_Null", },
    Shln_GntnArea0_Trap0003 = { "rt_gntn_shlnArea0_s_0001", "rt_shln_Null", },
    Shln_GntnArea0_Trap0004 = { "rt_gntn_shlnArea0_s_0002", "rt_shln_Null", },
    Shln_GntnArea0_Trap0005 = { "rt_gntn_shlnArea0_s_0004", "rt_shln_Null", },
    Shln_GntnArea0_Trap0006 = { "rt_gntn_shlnArea0_s_0005", "rt_shln_Null", },
    Shln_GntnArea0_Trap0007 = { "rt_gntn_shlnArea0_s_0006", "rt_shln_Null", },
    Shln_GntnArea0_Trap0008 = { "rt_gntn_shlnArea0_s_0007", "rt_shln_Null", },
    Shln_GntnArea0_Trap0009 = { "rt_gntn_shlnArea0_s_0008", "rt_shln_Null", },
  },
}

this.setOnBootSneakRoutesGntn = {
  [0]="rt_gntn_shlnArea0_s_0000",
}

this.setOnBootCautionRoutesGntn = {
  [0]="rt_gntn_shlnArea0_n_0000",
}

this.SahelanAreasGntnBaseRoutes = {
  [0]= "rt_gntn_shlnArea0_b_0000",
}

this.MissileRouteListForGntn = {
  [0]={
    "rt_SearchMissile_GntnArea0_0000",
    "rt_SearchMissile_GntnArea0_0001",
    "rt_SearchMissile_GntnArea0_0002",
    "rt_SearchMissile_GntnArea0_0003",
    "rt_SearchMissile_GntnArea0_0004",
    "rt_SearchMissile_GntnArea0_0005",
    "rt_SearchMissile_GntnArea0_0006",
    "rt_SearchMissile_GntnArea0_0007",
    "rt_SearchMissile_GntnArea0_0008",
    "rt_SearchMissile_GntnArea0_0009",
    "rt_SearchMissile_GntnArea0_0010",
    "rt_SearchMissile_GntnArea0_0011",
    "rt_SearchMissile_GntnArea0_0012",
    "rt_SearchMissile_GntnArea0_0013",
    "rt_SearchMissile_GntnArea0_0014",
    "rt_SearchMissile_GntnArea0_0015",
    "rt_SearchMissile_GntnArea0_0016",
    "rt_SearchMissile_GntnArea0_0017",
    "rt_SearchMissile_GntnArea0_0018",
    "rt_SearchMissile_GntnArea0_0019",
    "rt_SearchMissile_GntnArea0_0020",
    "rt_SearchMissile_GntnArea0_0021",
    "rt_SearchMissile_GntnArea0_0022",
    "rt_SearchMissile_GntnArea0_0023",
    "rt_SearchMissile_GntnArea0_0024",
    "rt_SearchMissile_GntnArea0_0025",
  },
}

this.ignoreTrapListGntn = {}

this.sahelanLinkRouteTableGntn = {

  { { "rt_gntn_shlnArea0_n_0000", 0, }, { "rt_gntn_shlnArea0_n_0001", 0 }, },
  { { "rt_gntn_shlnArea0_n_0001", 0, }, { "rt_gntn_shlnArea0_n_0002", 0 }, },
  { { "rt_gntn_shlnArea0_n_0002", 0, }, { "rt_gntn_shlnArea0_n_0003", 0 }, },
  { { "rt_gntn_shlnArea0_n_0003", 0, }, { "rt_gntn_shlnArea0_n_0004", 0 }, },
  { { "rt_gntn_shlnArea0_n_0004", 0, }, { "rt_gntn_shlnArea0_n_0005", 0 }, },
  { { "rt_gntn_shlnArea0_n_0004", 0, }, { "rt_gntn_shlnArea0_n_0013", 0 }, },
  { { "rt_gntn_shlnArea0_n_0005", 0, }, { "rt_gntn_shlnArea0_n_0006", 0 }, },
  { { "rt_gntn_shlnArea0_n_0006", 0, }, { "rt_gntn_shlnArea0_n_0007", 0 }, },
  { { "rt_gntn_shlnArea0_n_0007", 0, }, { "rt_gntn_shlnArea0_n_0008", 0 }, },
  { { "rt_gntn_shlnArea0_n_0008", 0, }, { "rt_gntn_shlnArea0_n_0009", 0 }, },
  { { "rt_gntn_shlnArea0_n_0009", 0, }, { "rt_gntn_shlnArea0_n_0010", 0 }, },
  { { "rt_gntn_shlnArea0_n_0010", 0, }, { "rt_gntn_shlnArea0_n_0011", 0 }, },
  { { "rt_gntn_shlnArea0_n_0011", 0, }, { "rt_gntn_shlnArea0_n_0012", 0 }, },
  { { "rt_gntn_shlnArea0_n_0013", 0, }, { "rt_gntn_shlnArea0_n_0014", 0 }, },
  { { "rt_gntn_shlnArea0_n_0014", 0, }, { "rt_gntn_shlnArea0_n_0015", 0 }, },
  { { "rt_gntn_shlnArea0_n_0015", 0, }, { "rt_gntn_shlnArea0_n_0016", 0 }, },
  { { "rt_gntn_shlnArea0_n_0016", 0, }, { "rt_gntn_shlnArea0_n_0017", 0 }, },
  { { "rt_gntn_shlnArea0_n_0017", 0, }, { "rt_gntn_shlnArea0_n_0018", 0 }, },
  { { "rt_gntn_shlnArea0_n_0018", 0, }, { "rt_gntn_shlnArea0_n_0019", 0 }, },
  { { "rt_gntn_shlnArea0_n_0015", 0, }, { "rt_gntn_shlnArea0_n_0020", 0 }, },
  { { "rt_gntn_shlnArea0_n_0020", 0, }, { "rt_gntn_shlnArea0_n_0021", 0 }, },
  { { "rt_gntn_shlnArea0_n_0021", 0, }, { "rt_gntn_shlnArea0_n_0022", 0 }, },
  { { "rt_gntn_shlnArea0_n_0022", 0, }, { "rt_gntn_shlnArea0_n_0023", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 14, }, { "rt_gntn_shlnArea0_n_0000", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 15, }, { "rt_gntn_shlnArea0_n_0001", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 16, }, { "rt_gntn_shlnArea0_n_0002", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 17, }, { "rt_gntn_shlnArea0_n_0003", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 18, }, { "rt_gntn_shlnArea0_n_0004", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 18, }, { "rt_gntn_shlnArea0_n_0013", 0 }, },
  { { "rt_gntn_shlnArea0_n_0018", 0, }, { "rt_gntn_shlnArea0_n_0024", 0 }, },
  { { "rt_gntn_shlnArea0_n_0024", 0, }, { "rt_gntn_shlnArea0_n_0025", 0 }, },
  { { "rt_gntn_shlnArea0_n_0025", 0, }, { "rt_gntn_shlnArea0_n_0026", 0 }, },
  { { "rt_gntn_shlnArea0_n_0026", 0, }, { "rt_gntn_shlnArea0_n_0027", 0 }, },
  { { "rt_gntn_shlnArea0_n_0027", 0, }, { "rt_gntn_shlnArea0_n_0023", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 21, }, { "rt_gntn_shlnArea0_n_0028", 0 }, },
  { { "rt_gntn_shlnArea0_n_0028", 0, }, { "rt_gntn_shlnArea0_n_0029", 0 }, },
  { { "rt_gntn_shlnArea0_n_0029", 0, }, { "rt_gntn_shlnArea0_n_0030", 0 }, },
  { { "rt_gntn_shlnArea0_n_0030", 0, }, { "rt_gntn_shlnArea0_n_0031", 0 }, },
  { { "rt_gntn_shlnArea0_n_0006", 0, }, { "rt_gntn_shlnArea0_n_0033", 0 }, },
  { { "rt_gntn_shlnArea0_n_0033", 0, }, { "rt_gntn_shlnArea0_n_0034", 0 }, },
  { { "rt_gntn_shlnArea0_n_0034", 0, }, { "rt_gntn_shlnArea0_n_0035", 0 }, },
  { { "rt_gntn_shlnArea0_n_0035", 0, }, { "rt_gntn_shlnArea0_n_0031", 0 }, },
  { { "rt_gntn_shlnArea0_n_0035", 0, }, { "rt_gntn_shlnArea0_n_0036", 0 }, },
  { { "rt_gntn_shlnArea0_n_0036", 0, }, { "rt_gntn_shlnArea0_n_0037", 0 }, },
  { { "rt_gntn_shlnArea0_n_0034", 0, }, { "rt_gntn_shlnArea0_n_0037", 0 }, },
  { { "rt_gntn_shlnArea0_n_0037", 0, }, { "rt_gntn_shlnArea0_n_0038", 0 }, },
  { { "rt_gntn_shlnArea0_n_0033", 0, }, { "rt_gntn_shlnArea0_n_0038", 0 }, },
  { { "rt_gntn_shlnArea0_n_0038", 0, }, { "rt_gntn_shlnArea0_n_0039", 0 }, },
  { { "rt_gntn_shlnArea0_n_0039", 0, }, { "rt_gntn_shlnArea0_n_0040", 0 }, },
  { { "rt_gntn_shlnArea0_n_0019", 0, }, { "rt_gntn_shlnArea0_n_0041", 0 }, },
  { { "rt_gntn_shlnArea0_n_0041", 0, }, { "rt_gntn_shlnArea0_n_0042", 0 }, },
  { { "rt_gntn_shlnArea0_n_0042", 0, }, { "rt_gntn_shlnArea0_n_0043", 0 }, },
  { { "rt_gntn_shlnArea0_n_0043", 0, }, { "rt_gntn_shlnArea0_n_0044", 0 }, },
  { { "rt_gntn_shlnArea0_n_0044", 0, }, { "rt_gntn_shlnArea0_n_0045", 0 }, },
  { { "rt_gntn_shlnArea0_n_0045", 0, }, { "rt_gntn_shlnArea0_n_0046", 0 }, },
  { { "rt_gntn_shlnArea0_n_0046", 0, }, { "rt_gntn_shlnArea0_n_0047", 0 }, },
  { { "rt_gntn_shlnArea0_n_0047", 0, }, { "rt_gntn_shlnArea0_n_0048", 0 }, },
  { { "rt_gntn_shlnArea0_n_0048", 0, }, { "rt_gntn_shlnArea0_n_0013", 0 }, },
  { { "rt_gntn_shlnArea0_n_0048", 0, }, { "rt_gntn_shlnArea0_n_0049", 0 }, },
  { { "rt_gntn_shlnArea0_n_0049", 0, }, { "rt_gntn_shlnArea0_n_0050", 0 }, },
  { { "rt_gntn_shlnArea0_n_0050", 0, }, { "rt_gntn_shlnArea0_n_0028", 0 }, },
  { { "rt_gntn_shlnArea0_n_0050", 0, }, { "rt_gntn_shlnArea0_n_0033", 0 }, },
  { { "rt_gntn_shlnArea0_n_0050", 0, }, { "rt_gntn_shlnArea0_n_0005", 0 }, },
  { { "rt_gntn_shlnArea0_n_0044", 0, }, { "rt_gntn_shlnArea0_n_0051", 0 }, },
  { { "rt_gntn_shlnArea0_n_0051", 0, }, { "rt_gntn_shlnArea0_n_0052", 0 }, },
  { { "rt_gntn_shlnArea0_n_0052", 0, }, { "rt_gntn_shlnArea0_n_0053", 0 }, },
  { { "rt_gntn_shlnArea0_n_0053", 0, }, { "rt_gntn_shlnArea0_n_0054", 0 }, },
  { { "rt_gntn_shlnArea0_n_0054", 0, }, { "rt_gntn_shlnArea0_n_0055", 0 }, },
  { { "rt_gntn_shlnArea0_n_0055", 0, }, { "rt_gntn_shlnArea0_n_0056", 0 }, },
  { { "rt_gntn_shlnArea0_n_0056", 0, }, { "rt_gntn_shlnArea0_n_0057", 0 }, },
  { { "rt_gntn_shlnArea0_n_0057", 0, }, { "rt_gntn_shlnArea0_n_0058", 0 }, },
  { { "rt_gntn_shlnArea0_n_0058", 0, }, { "rt_gntn_shlnArea0_n_0059", 0 }, },
  { { "rt_gntn_shlnArea0_n_0059", 0, }, { "rt_gntn_shlnArea0_n_0060", 0 }, },
  { { "rt_gntn_shlnArea0_n_0060", 0, }, { "rt_gntn_shlnArea0_n_0061", 0 }, },
  { { "rt_gntn_shlnArea0_n_0060", 0, }, { "rt_gntn_shlnArea0_n_0062", 0 }, },
  { { "rt_gntn_shlnArea0_n_0061", 0, }, { "rt_gntn_shlnArea0_n_0062", 0 }, },
  { { "rt_gntn_shlnArea0_n_0062", 0, }, { "rt_gntn_shlnArea0_n_0063", 0 }, },
  { { "rt_gntn_shlnArea0_n_0023", 0, }, { "rt_gntn_shlnArea0_n_0027", 0 }, },
  { { "rt_gntn_shlnArea0_n_0054", 0, }, { "rt_gntn_shlnArea0_n_0064", 0 }, },
  { { "rt_gntn_shlnArea0_n_0064", 0, }, { "rt_gntn_shlnArea0_n_0065", 0 }, },
  { { "rt_gntn_shlnArea0_n_0065", 0, }, { "rt_gntn_shlnArea0_n_0066", 0 }, },
  { { "rt_gntn_shlnArea0_n_0065", 0, }, { "rt_gntn_shlnArea0_n_0067", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 24, }, { "rt_gntn_shlnArea0_n_0067", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 19, }, { "rt_gntn_shlnArea0_s_0000", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 20, }, { "rt_gntn_shlnArea0_s_0000", 1 }, },
  { { "rt_gntn_shlnArea0_b_0000", 21, }, { "rt_gntn_shlnArea0_s_0000", 2 }, },
  { { "rt_gntn_shlnArea0_b_0000", 21, }, { "rt_gntn_shlnArea0_s_0001", 0 }, },
  { { "rt_gntn_shlnArea0_b_0000", 20, }, { "rt_gntn_shlnArea0_s_0001", 18 }, },
  { { "rt_gntn_shlnArea0_b_0000", 19, }, { "rt_gntn_shlnArea0_s_0001", 19 }, },
  { { "rt_gntn_shlnArea0_s_0001", 0, }, { "rt_gntn_shlnArea0_s_0000", 2 }, },
  { { "rt_gntn_shlnArea0_s_0000", 1, }, { "rt_gntn_shlnArea0_s_0001", 19 }, },
  { { "rt_gntn_shlnArea0_s_0002", 18, }, { "rt_gntn_shlnArea0_s_0000", 6 }, },
  { { "rt_gntn_shlnArea0_s_0002", 19, }, { "rt_gntn_shlnArea0_s_0000", 7 }, },
  { { "rt_gntn_shlnArea0_s_0002", 20, }, { "rt_gntn_shlnArea0_s_0000", 8 }, },
  { { "rt_gntn_shlnArea0_s_0002", 22, }, { "rt_gntn_shlnArea0_s_0000", 10 }, },
  { { "rt_gntn_shlnArea0_s_0002", 23, }, { "rt_gntn_shlnArea0_s_0000", 11 }, },
  { { "rt_gntn_shlnArea0_s_0002", 24, }, { "rt_gntn_shlnArea0_b_0000", 20 }, },
  { { "rt_gntn_shlnArea0_s_0001", 0, }, { "rt_gntn_shlnArea0_s_0002", 0 }, },
  { { "rt_gntn_shlnArea0_s_0001", 1, }, { "rt_gntn_shlnArea0_s_0002", 21 }, },
  { { "rt_gntn_shlnArea0_s_0001", 2, }, { "rt_gntn_shlnArea0_s_0002", 20 }, },
  { { "rt_gntn_shlnArea0_s_0001", 1, }, { "rt_gntn_shlnArea0_s_0002", 20 }, },
  { { "rt_gntn_shlnArea0_s_0003", 0, }, { "rt_gntn_shlnArea0_b_0000", 21 }, },
  { { "rt_gntn_shlnArea0_s_0003", 0, }, { "rt_gntn_shlnArea0_b_0000", 33 }, },
  { { "rt_gntn_shlnArea0_s_0003", 0, }, { "rt_gntn_shlnArea0_b_0000", 34 }, },
  { { "rt_gntn_shlnArea0_s_0003", 0, }, { "rt_gntn_shlnArea0_s_0000", 2 }, },
  { { "rt_gntn_shlnArea0_s_0003", 1, }, { "rt_gntn_shlnArea0_s_0000", 3 }, },
  { { "rt_gntn_shlnArea0_s_0003", 14, }, { "rt_gntn_shlnArea0_s_0000", 7 }, },
  { { "rt_gntn_shlnArea0_s_0003", 15, }, { "rt_gntn_shlnArea0_s_0000", 8 }, },
  { { "rt_gntn_shlnArea0_s_0003", 32, }, { "rt_gntn_shlnArea0_s_0000", 13 }, },
  { { "rt_gntn_shlnArea0_s_0003", 33, }, { "rt_gntn_shlnArea0_s_0000", 0 }, },
  { { "rt_gntn_shlnArea0_s_0003", 34, }, { "rt_gntn_shlnArea0_s_0000", 1 }, },
  { { "rt_gntn_shlnArea0_s_0003", 33, }, { "rt_gntn_shlnArea0_s_0001", 18 }, },
  { { "rt_gntn_shlnArea0_s_0003", 34, }, { "rt_gntn_shlnArea0_s_0001", 19 }, },
  { { "rt_gntn_shlnArea0_s_0003", 17, }, { "rt_gntn_shlnArea0_s_0001", 2 }, },
  { { "rt_gntn_shlnArea0_s_0003", 21, }, { "rt_gntn_shlnArea0_s_0001", 7 }, },
  { { "rt_gntn_shlnArea0_s_0003", 22, }, { "rt_gntn_shlnArea0_s_0001", 8 }, },
  { { "rt_gntn_shlnArea0_s_0003", 23, }, { "rt_gntn_shlnArea0_s_0001", 9 }, },
  { { "rt_gntn_shlnArea0_s_0003", 24, }, { "rt_gntn_shlnArea0_s_0001", 10 }, },
  { { "rt_gntn_shlnArea0_s_0003", 0, }, { "rt_gntn_shlnArea0_s_0002", 0 }, },
  { { "rt_gntn_shlnArea0_s_0003", 34, }, { "rt_gntn_shlnArea0_s_0002", 24 }, },
  { { "rt_gntn_shlnArea0_s_0003", 1, }, { "rt_gntn_shlnArea0_s_0002", 1 }, },
  { { "rt_gntn_shlnArea0_s_0003", 2, }, { "rt_gntn_shlnArea0_s_0002", 2 }, },
  { { "rt_gntn_shlnArea0_s_0003", 3, }, { "rt_gntn_shlnArea0_s_0002", 3 }, },
  { { "rt_gntn_shlnArea0_s_0003", 4, }, { "rt_gntn_shlnArea0_s_0002", 5 }, },
  { { "rt_gntn_shlnArea0_s_0003", 5, }, { "rt_gntn_shlnArea0_s_0002", 7 }, },
  { { "rt_gntn_shlnArea0_s_0003", 6, }, { "rt_gntn_shlnArea0_s_0002", 6 }, },
  { { "rt_gntn_shlnArea0_s_0003", 7, }, { "rt_gntn_shlnArea0_s_0002", 9 }, },
  { { "rt_gntn_shlnArea0_s_0003", 8, }, { "rt_gntn_shlnArea0_s_0002", 10 }, },
  { { "rt_gntn_shlnArea0_s_0003", 9, }, { "rt_gntn_shlnArea0_s_0002", 11 }, },
  { { "rt_gntn_shlnArea0_s_0003", 11, }, { "rt_gntn_shlnArea0_s_0002", 10 }, },
  { { "rt_gntn_shlnArea0_s_0003", 12, }, { "rt_gntn_shlnArea0_s_0002", 13 }, },
  { { "rt_gntn_shlnArea0_s_0003", 13, }, { "rt_gntn_shlnArea0_s_0002", 15 }, },
  { { "rt_gntn_shlnArea0_s_0003", 14, }, { "rt_gntn_shlnArea0_s_0002", 19 }, },
  { { "rt_gntn_shlnArea0_s_0003", 15, }, { "rt_gntn_shlnArea0_s_0002", 20 }, },
  { { "rt_gntn_shlnArea0_s_0004", 0, }, { "rt_gntn_shlnArea0_b_0000", 22 }, },
  { { "rt_gntn_shlnArea0_s_0004", 18, }, { "rt_gntn_shlnArea0_b_0000", 24 }, },
  { { "rt_gntn_shlnArea0_s_0004", 19, }, { "rt_gntn_shlnArea0_b_0000", 18 }, },
  { { "rt_gntn_shlnArea0_s_0005", 0, }, { "rt_gntn_shlnArea0_s_0004", 17 }, },
  { { "rt_gntn_shlnArea0_s_0005", 22, }, { "rt_gntn_shlnArea0_s_0004", 20 }, },
  { { "rt_gntn_shlnArea0_s_0005", 21, }, { "rt_gntn_shlnArea0_s_0004", 21 }, },
  { { "rt_gntn_shlnArea0_s_0005", 19, }, { "rt_gntn_shlnArea0_s_0004", 2 }, },
  { { "rt_gntn_shlnArea0_s_0005", 18, }, { "rt_gntn_shlnArea0_s_0004", 3 }, },
  { { "rt_gntn_shlnArea0_s_0005", 15, }, { "rt_gntn_shlnArea0_s_0004", 10 }, },
  { { "rt_gntn_shlnArea0_s_0005", 13, }, { "rt_gntn_shlnArea0_s_0004", 11 }, },
  { { "rt_gntn_shlnArea0_s_0005", 11, }, { "rt_gntn_shlnArea0_s_0004", 14 }, },
  { { "rt_gntn_shlnArea0_s_0005", 0, }, { "rt_gntn_shlnArea0_s_0004", 0 }, },
  { { "rt_gntn_shlnArea0_s_0005", 0, }, { "rt_gntn_shlnArea0_s_0004", 0 }, },
  { { "rt_gntn_shlnArea0_s_0005", 5, }, { "rt_gntn_shlnArea0_s_0006", 0 }, },
  { { "rt_gntn_shlnArea0_s_0006", 16, }, { "rt_gntn_shlnArea0_s_0004", 15 }, },
  { { "rt_gntn_shlnArea0_s_0006", 18, }, { "rt_gntn_shlnArea0_s_0005", 10 }, },
  { { "rt_gntn_shlnArea0_s_0006", 16, }, { "rt_gntn_shlnArea0_s_0005", 10 }, },
  { { "rt_gntn_shlnArea0_s_0006", 19, }, { "rt_gntn_shlnArea0_s_0005", 9 }, },
  { { "rt_gntn_shlnArea0_s_0006", 15, }, { "rt_gntn_shlnArea0_s_0005", 9 }, },
  { { "rt_gntn_shlnArea0_s_0006", 20, }, { "rt_gntn_shlnArea0_s_0005", 8 }, },
  { { "rt_gntn_shlnArea0_s_0006", 21, }, { "rt_gntn_shlnArea0_s_0005", 7 }, },
  { { "rt_gntn_shlnArea0_s_0006", 23, }, { "rt_gntn_shlnArea0_s_0005", 4 }, },
  { { "rt_gntn_shlnArea0_s_0006", 31, }, { "rt_gntn_shlnArea0_s_0005", 22 }, },
  { { "rt_gntn_shlnArea0_s_0006", 32, }, { "rt_gntn_shlnArea0_s_0005", 19 }, },
  { { "rt_gntn_shlnArea0_s_0006", 32, }, { "rt_gntn_shlnArea0_s_0004", 2 }, },
  { { "rt_gntn_shlnArea0_s_0007", 0, }, { "rt_gntn_shlnArea0_s_0004", 18 }, },
  { { "rt_gntn_shlnArea0_s_0007", 2, }, { "rt_gntn_shlnArea0_s_0005", 2 }, },
  { { "rt_gntn_shlnArea0_s_0007", 1, }, { "rt_gntn_shlnArea0_s_0005", 1 }, },
  { { "rt_gntn_shlnArea0_s_0008", 23, }, { "rt_gntn_shlnArea0_s_0007", 6 }, },
  { { "rt_gntn_shlnArea0_s_0008", 22, }, { "rt_gntn_shlnArea0_s_0007", 7 }, },
  { { "rt_gntn_shlnArea0_s_0008", 21, }, { "rt_gntn_shlnArea0_s_0007", 8 }, },
  { { "rt_gntn_shlnArea0_s_0008", 20, }, { "rt_gntn_shlnArea0_s_0007", 9 }, },
  { { "rt_gntn_shlnArea0_s_0008", 19, }, { "rt_gntn_shlnArea0_s_0007", 10 }, },
  { { "rt_gntn_shlnArea0_s_0008", 18, }, { "rt_gntn_shlnArea0_s_0007", 11 }, },
  { { "rt_gntn_shlnArea0_s_0008", 18, }, { "rt_gntn_shlnArea0_s_0007", 15 }, },
}

this.SetCautionRouteAlertGntn = {
  [0]={
    "rt_gntn_shlnArea0_n_0000",
    "rt_gntn_shlnArea0_n_0001",
    "rt_gntn_shlnArea0_n_0002",
    "rt_gntn_shlnArea0_n_0003",
    "rt_gntn_shlnArea0_n_0004",
    "rt_gntn_shlnArea0_n_0005",
    "rt_gntn_shlnArea0_n_0006",
    "rt_gntn_shlnArea0_n_0007",
    "rt_gntn_shlnArea0_n_0008",
    "rt_gntn_shlnArea0_n_0009",
    "rt_gntn_shlnArea0_n_0010",
    "rt_gntn_shlnArea0_n_0011",
    "rt_gntn_shlnArea0_n_0012",
    "rt_gntn_shlnArea0_n_0013",
    "rt_gntn_shlnArea0_n_0014",
    "rt_gntn_shlnArea0_n_0015",
    "rt_gntn_shlnArea0_n_0016",
    "rt_gntn_shlnArea0_n_0017",
    "rt_gntn_shlnArea0_n_0018",
    "rt_gntn_shlnArea0_n_0019",
    "rt_gntn_shlnArea0_n_0020",
    "rt_gntn_shlnArea0_n_0021",
    "rt_gntn_shlnArea0_n_0022",
    "rt_gntn_shlnArea0_n_0023",
    "rt_gntn_shlnArea0_n_0024",
    "rt_gntn_shlnArea0_n_0025",
    "rt_gntn_shlnArea0_n_0026",
    "rt_gntn_shlnArea0_n_0027",
    "rt_gntn_shlnArea0_n_0028",
    "rt_gntn_shlnArea0_n_0029",
    "rt_gntn_shlnArea0_n_0030",
    "rt_gntn_shlnArea0_n_0031",
    "rt_gntn_shlnArea0_n_0032",
    "rt_gntn_shlnArea0_n_0033",
    "rt_gntn_shlnArea0_n_0034",
    "rt_gntn_shlnArea0_n_0035",
    "rt_gntn_shlnArea0_n_0036",
    "rt_gntn_shlnArea0_n_0037",
    "rt_gntn_shlnArea0_n_0038",
    "rt_gntn_shlnArea0_n_0039",
    "rt_gntn_shlnArea0_n_0040",
    "rt_gntn_shlnArea0_n_0041",
    "rt_gntn_shlnArea0_n_0042",
    "rt_gntn_shlnArea0_n_0043",
    "rt_gntn_shlnArea0_n_0044",
    "rt_gntn_shlnArea0_n_0045",
    "rt_gntn_shlnArea0_n_0046",
    "rt_gntn_shlnArea0_n_0047",
    "rt_gntn_shlnArea0_n_0048",
    "rt_gntn_shlnArea0_n_0049",
    "rt_gntn_shlnArea0_n_0050",
    "rt_gntn_shlnArea0_n_0051",
    "rt_gntn_shlnArea0_n_0052",
    "rt_gntn_shlnArea0_n_0053",
    "rt_gntn_shlnArea0_n_0054",
    "rt_gntn_shlnArea0_n_0055",
    "rt_gntn_shlnArea0_n_0056",
    "rt_gntn_shlnArea0_n_0057",
    "rt_gntn_shlnArea0_n_0058",
    "rt_gntn_shlnArea0_n_0059",
    "rt_gntn_shlnArea0_n_0060",
    "rt_gntn_shlnArea0_n_0061",
    "rt_gntn_shlnArea0_n_0062",
    "rt_gntn_shlnArea0_n_0063",
    "rt_gntn_shlnArea0_n_0064",
    "rt_gntn_shlnArea0_n_0065",
    "rt_gntn_shlnArea0_n_0066",
    "rt_gntn_shlnArea0_n_0067",
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

this.SetSahelanSearchRouteListForAfgh = function()

  local sahelanRouteTableAlert = this.SetCautionRouteAlertAfgh[Ivars.IsSahelanActiveArea:Get()]
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local indexNum = 0

  
  for k, routeName in pairs(sahelanRouteTableAlert) do
    local command = {id="SetCautionRouteAll", route= routeName, index=indexNum }
    GameObject.SendCommand(gameObjectId, command)
    indexNum = indexNum + 1
  end
end

this.SetSahelanSearchRouteListForGntn = function()

  local sahelanRouteTableAlert = this.SetCautionRouteAlertGntn[0]
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local indexNum = 0

  
  for k, routeName in pairs(sahelanRouteTableAlert) do
    local command = {id="SetCautionRouteAll", route= routeName, index=indexNum }
    GameObject.SendCommand(gameObjectId, command)
    indexNum = indexNum + 1
  end
end

this.SetSahelanRouteLink = function()

  local routeLinkTable = this.sahelanLinkRouteTableGntn
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
  local sahelanRouteTable = this.SahelanRouteListForGntn[0]
  local ignoreTrapList = this.ignoreTrapListAfgh

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
          InfCore.DebugPrint("UpdateSahelanRoute: "..trapName.." Activated Routes updated to: Sneak Route: "..v[1].." Caution Route: "..v[2]) 
          return  
        end
    elseif v[1] == "rt_shln_Null" and v[2] == "rt_shln_Null" then 
        if k == trapName then 
          InfCore.DebugPrint("UpdateSahelanRoute: No Routes assigned to: "..trapName.." No updates done !")
          return  
        end
    elseif v[1] ~= "rt_shln_Null" and v[2] == "rt_shln_Null" then 
      if k == trapName then 
          this.SetSahelanSneakRoute(v[1])
          InfCore.DebugPrint("UpdateSahelanRoute: "..trapName.." Only Sneak route assigned. Sneak route updated to: "..v[1])  
          return  
      end
    elseif v[1] == "rt_shln_Null" and v[2] ~= "rt_shln_Null" then 
      if k == trapName then 
          this.SetSahelanCautionRoute(v[2])
          InfCore.DebugPrint("UpdateSahelanRoute: "..trapName.." Only Caution route assigned. Caution route updated to: "..v[2])  
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
    --WeatherManager.RequestTag("Sahelan_fog", 3 ) 
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
  -- Calls in the support heli with a special command, sets a point to spawn and a point to despawn instead of a route
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


-- ### Setup func for hellbound AI
this.SetUpSahelanAfghHellboundAI = function()

  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local CombatGradecommand = { id = "SetCombatGrade", defenseValue=60000, defenseValueForWeakPoint=20000, offenseGrade=15, defenseGrade=15 }

  local CurrentBaseRoute = this.SahelanAreasAfghBaseRoutes[Ivars.IsSahelanActiveArea:Get()]

  this.SetSahelanSneakRoute(this.setOnBootSneakRoutesAfgh[Ivars.IsSahelanActiveArea:Get()])
  this.SetSahelanCautionRoute(this.setOnBootCautionRoutesAfgh[Ivars.IsSahelanActiveArea:Get()])
  
  GameObject.SendCommand(gameObjectId, CombatGradecommand)
  this.UpdateSahelanBaseRoute( CurrentBaseRoute )
  -- Sally wont move on alert without routes here
  this.SetSahelanSearchRouteListForAfgh()
  this.SetSahelanRouteLink()
  this.SetSahelanMissileRouteList(this.MissileRouteListForAfgh[Ivars.IsSahelanActiveArea:Get()])
  this.SetSahelanLife(this.SahelanMainLifeTable[4])
  this.SetSahelanPartsLife(this.SahelanLifePartsTable[4])

end


this.SetUpSahelanHellboundAIForGntn = function()

  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local CombatGradecommand = { id = "SetCombatGrade", defenseValue=60000, defenseValueForWeakPoint=20000, offenseGrade=15, defenseGrade=15 }

  local CurrentBaseRoute = this.SahelanAreasGntnBaseRoutes[0]

  this.SetSahelanSneakRoute(this.setOnBootSneakRoutesGntn[0])
  this.SetSahelanCautionRoute(this.setOnBootCautionRoutesGntn[0])
  
  GameObject.SendCommand(gameObjectId, CombatGradecommand)
  this.UpdateSahelanBaseRoute( CurrentBaseRoute )
  this.SetSahelanSearchRouteListForGntn()
  this.SetSahelanRouteLink()
  this.SetSahelanMissileRouteList(this.MissileRouteListForGntn[0])
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

this.SetTimer = function( timeString, seconds )
  if GkEventTimerManager.IsTimerActive( timeString ) then   
    GkEventTimerManager.Stop( timeString )
    GkEventTimerManager.Start( timeString, seconds )
  else
    
    GkEventTimerManager.Start( timeString, seconds )
  end

end

this.GOTODevArea = function ()
  TppMission.ReserveMissionClear{ nextMissionId = 13050}
end


function this.AddMissionPacks(missionCode,packPaths)

  local SahelanAreasAfghPacks = {
  [0]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_0.fpk",
  },
  [1]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_1.fpk",
  },
  [2]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_2.fpk",
  },
  [3]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_3.fpk",
  },
  [4]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_4.fpk",
  },
  [5]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_5.fpk",
  },
  [6]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_6.fpk",
  },
  [7]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_7.fpk",
  },
  [8]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_8.fpk",
  },
  [9]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_9.fpk",
  },
}

local SahelanAreasGntnPacks = {
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_"..Ivars.IsSahelanAIModeGntn:Get().."_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_gntn/gntn_area_0.fpk",
}

local SahelanAreasDEVPacks = {
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_"..Ivars.IsSahelanCurrentModel:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_1_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/ui/shln_healthbar_"..Ivars.isLoadSahelanHealthBar:Get()..".fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_DEV/DEV_area_0.fpk",
}

  if vars.missionCode==30010 then
    if Ivars.IsSahelanActiveIvar:Is(1) then
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
    end
  elseif vars.missionCode==30040 then
    if Ivars.IsSahelanActiveInGntn:Get() == 1 then
      for i,packagePath in ipairs(SahelanAreasGntnPacks)do
        packPaths[#packPaths+1]=packagePath
      end
    end
  elseif vars.missionCode==13050 then 
    if Ivars.IsSahelanActiveIvar:Get() == 1 then
      for i,packagePath in ipairs(SahelanAreasDEVPacks)do
        packPaths[#packPaths+1]=packagePath
      end
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
                        if Ivars.IsSahelanTimer:Get() == 0 then
                          if phase == TppGameObject.PHASE_ALERT or phase == TppGameObject.PHASE_CAUTION then
                            if PlayerIsDetected == false then
                              this.SetSahelanTypeHellboundAI()
                              TppMission.StartBossBattle()
                              PlayerIsDetected = true
                            end 
                          end 
                        end
                      end
                    },    
                  },   
        Timer = {
                  {
                    -- Starts the fight when the timer's value is reached
                    msg = "Finish",
                    sender = "SpawnTimer",
                    func = function()
                      if Ivars.IsSahelanTimer:Get() == 1 then 
                        InfCore.DebugPrint("SpawnTimer Finish")  
                        -- No clue what this does
                        TppMission.StartBossBattle()
                        --Activates sahelan
                        this.SetSahelanTypeHellboundAI()
                        TppMission.StartBossBattle()
                        -- debug log
                        InfCore.Log("SahelanBossEvents: SpawnTimer = Finish, start fight")
                      end
                    end
                  },          
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
this.sahelanTraps = {} 

function this.Init(missionTable)

  TppStory.SetMissionOpenFlag(13050,false)
  TppStory.DisableMissionNewOpenFlag(13050)

  if vars.missionCode==30010 then
    if Ivars.IsSahelanActiveIvar:Is(1) then    
      for trapName,sahelanRoutes in pairs ( this.SahelanRouteListForAfgh[Ivars.IsSahelanActiveArea:Get()] ) do
        local trapTable = {
          msg = "Enter",  sender = trapName,
          func = function ()  this.UpdateSahelanRoute( trapName ) end
        }
        table.insert( this.sahelanTraps, trapTable )
      end
      if Ivars.IsSahelanTimer:Get() == 1 then 
        -- Sets the random timer for starting fight
        this.SetTimer("SpawnTimer", math.random(Ivars.IsSahelanTimerLow:Get()*60,Ivars.IsSahelanTimerHigh:Get()*60))
      end
      this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForDominionAI())
    end 
  elseif vars.missionCode==30040 then
    if Ivars.IsSahelanActiveInGntn:Get() == 1 then
      if Ivars.IsSahelanAIModeGntn:Get() == 0 then 
        for trapName,sahelanRoutes in pairs ( this.SahelanRouteListForGntn[0] ) do
          local trapTable = {
            msg = "Enter",  sender = trapName,
            func = function ()  this.UpdateSahelanRoute( trapName ) end
          }
          table.insert( this.sahelanTraps, trapTable )
        end
        if Ivars.IsSahelanTimer:Get() == 1 then 
          if Ivars.IsSahelanTimerLow:Get() > Ivars.IsSahelanTimerHigh:Get() then
            InfCore.DebugPrint("Hey dummy! the TimerHigh is lower than the TimerLow! that aint how it works init :| ")  
          else 
             -- Sets the random timer for starting fight
            this.SetTimer("SpawnTimer", math.random(Ivars.IsSahelanTimerLow:Get()*60,Ivars.IsSahelanTimerHigh:Get()*60))
          end
        end
        this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForHellboundAI())
      elseif Ivars.IsSahelanAIModeGntn:Get() == 1 then
        if Ivars.IsSahelanTimer:Get() == 1 then 
          if Ivars.IsSahelanTimerLow:Get() > Ivars.IsSahelanTimerHigh:Get() then
            InfCore.DebugPrint("Hey dummy! the TimerHigh is lower than the TimerLow! that aint how it works init :| ")  
          else 
             -- Sets the random timer for starting fight
            this.SetTimer("SpawnTimer", math.random(Ivars.IsSahelanTimerLow:Get()*60,Ivars.IsSahelanTimerHigh:Get()*60))
          end
        end
        this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForDominionAI())
      end
    end
    --DEV only, for now i will reuse afgh Stuff
  elseif vars.missionCode==13050 then 
    if Ivars.IsSahelanActiveIvar:Is(1) then    
      this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForDominionAI())
    end
  end
 end



this.SetUpEnemy = function ()

  if vars.missionCode==30010 then
    if Ivars.IsSahelanActiveIvar:Is(1) then
      this.SetUpSahelanAfghDominionAI()
      CPPhaseSwitchCount = 0
      PlayerIsDetected = false
      if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
        this.DisableDDSupport()
      end
    end
  elseif vars.missionCode==30040 then
    if Ivars.IsSahelanActiveInGntn:Get() == 1 then
      if Ivars.IsSahelanAIModeGntn:Get() == 0 then 
        this.SetUpSahelanHellboundAIForGntn()
      elseif Ivars.IsSahelanAIModeGntn:Get() == 1 then
        this.SetUpSahelanAfghDominionAI()
      end
      CPPhaseSwitchCount = 0
      PlayerIsDetected = false
      if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
        this.DisableDDSupport()
      end
    end
  elseif vars.missionCode==13050 then
    if Ivars.IsSahelanActiveIvar:Is(1) then
      this.SetUpSahelanAfghDominionAI()
    end
  end
end 



function this.OnReload(missionTable)
  if vars.missionCode==30010 then
    if Ivars.IsSahelanActiveIvar:Is(1) then
      if Ivars.IsSahelanTimer:Get() == 1 then 
          if Ivars.IsSahelanTimerLow:Get() > Ivars.IsSahelanTimerHigh:Get() then
            InfCore.DebugPrint("Hey dummy! the TimerHigh is lower than the TimerLow! that aint how it works init :| ")  
          else 
             -- Sets the random timer for starting fight
            this.SetTimer("SpawnTimer", math.random(Ivars.IsSahelanTimerLow:Get()*60,Ivars.IsSahelanTimerHigh:Get()*60))
          end
        end
      this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForDominionAI())
    end
    CPPhaseSwitchCount = 0
    PlayerIsDetected = false
    if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
      this.DisableDDSupport()
    end
  elseif vars.missionCode==30040 then
    if Ivars.IsSahelanActiveInGntn:Get() == 1 then
      if Ivars.IsSahelanAIModeGntn:Get() == 0 then 
        if Ivars.IsSahelanTimer:Get() == 1 then 
          if Ivars.IsSahelanTimerLow:Get() > Ivars.IsSahelanTimerHigh:Get() then
            InfCore.DebugPrint("Hey dummy! the TimerHigh is lower than the TimerLow! that aint how it works init :| ")  
          else 
             -- Sets the random timer for starting fight
            this.SetTimer("SpawnTimer", math.random(Ivars.IsSahelanTimerLow:Get()*60,Ivars.IsSahelanTimerHigh:Get()*60))
          end
        end
        this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForHellboundAI())
      elseif Ivars.IsSahelanAIModeGntn:Get() == 1 then
        if Ivars.IsSahelanTimer:Get() == 1 then 
          if Ivars.IsSahelanTimerLow:Get() > Ivars.IsSahelanTimerHigh:Get() then
            InfCore.DebugPrint("Hey dummy! the TimerHigh is lower than the TimerLow! that aint how it works init :| ")  
          else 
             -- Sets the random timer for starting fight
            this.SetTimer("SpawnTimer", math.random(Ivars.IsSahelanTimerLow:Get()*60,Ivars.IsSahelanTimerHigh:Get()*60))
          end
        end
        this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForDominionAI())
      end
    end
    CPPhaseSwitchCount = 0
    PlayerIsDetected = false
    if Ivars.IsSahelanDominionDifficulty:Get() == 3 then
      this.DisableDDSupport()
    end
  elseif vars.missionCode==13050 then
    if Ivars.IsSahelanActiveIvar:Is(1) then
      this.messageExecTable=Tpp.MakeMessageExecTable(this.MessagesForDominionAI())
    end
  end   
end


function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
  if vars.missionCode==30010 then
    if Ivars.IsSahelanActiveIvar:Get() == 1 then
      Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
    end
  elseif vars.missionCode==30040 then
    if Ivars.IsSahelanActiveInGntn:Get() == 1 then
      Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
    end
  elseif vars.missionCode==13050 then 
    if Ivars.IsSahelanActiveIvar:Get() == 1 then
      Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
    end
  end   
end
 
return this 