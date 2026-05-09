local this={}
local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId
local GetGameObjectIdByIndex = GameObject.GetGameObjectIdByIndex
local SendCommand = GameObject.SendCommand

local PlayerIsDetected = false
local SAHELAN_WEAKENING_COUNT = 2 

local SahelanAreasAfghPacks = {
  [0]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_0.fpk",
  },
  [1]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_1.fpk",
  },
  [2]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_2.fpk",
  },
  [3]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_3.fpk",
  },
  [4]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_4.fpk",
  },
  [5]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_5.fpk",
  },
  [6]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_6.fpk",
  },
  [7]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_7.fpk",
  },
  [8]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_8.fpk",
  },
  [9]={
    "/Assets/tpp/pack/mission2/shln/freeroam/skins/shln_skin_0.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/modes/shln_hellbound_cmn.fpk",
    "/Assets/tpp/pack/mission2/shln/freeroam/areas_afgh/afgh_area_9.fpk",
  },
}



local SahelanAreasAfghBaseRoutes = {
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

this.SahelanCounter = 0


this.registerMenus={
  "SahelanFreeRoamMenu",
}

this.registerIvars={
  "IsSahelanActiveIvar",
  "IsSahelanActiveArea",
}

this.SahelanFreeRoamMenu={
  parentRefs={"InfMenuDefs.safeSpaceMenu"},
  options={
    "Ivars.IsSahelanActiveIvar",
    "Ivars.IsSahelanActiveArea",
   -- "Ivars.IsRandomArea",
   -- "Ivars.CurrentModel",
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
  --range={max=9,min=0,increment=1},
  default=0,
  settings={0,1,2,3,4,5,6,7,8,9},
  settingNames="SahelanActiveAreaOptions",
  OnChange=function(self,settings)
    InfCore.DebugPrint(settings)
  end,
}

this.langStrings={
  eng={
      SahelanFreeRoamMenu="Free Roam Sahelanthropus Menu",
      IsSahelanActiveIvar="Sahelanthropus In Free Roam: ",
      IsSahelanActiveArea="Current Active Area: ",
      SahelanActiveAreaOptions = {"Northern Area","Outpost 04","Yakho Oboo","Lamar Khaate","Shago Kallai","Wakh Barracks","Da wiallo Kallai","Da Ghwandai Khar","Qaria Sakhra Ee","Mountain Relay Base"},
    },
  help={
    eng={
      SahelanFreeRoamMenu="Controls if Sahelanthropus will roam a area during free roam, what area and what model is used",
      IsSahelanActiveIvar="Controls if Sahelanthropus is either active or not during free roam play",
      IsSahelanActiveArea="Choose what area Sahelanthropus will roam during free roam if random area is set to false",
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

this.SetCautionRouteAlert = {
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
    "",
  },
  [2]={
    "",
  },
  [3]={
    "",
  },
  [4]={
    "",
  },
  [5]={
    "",
  },
  [6]={
    "",
  },
  [7]={
    "",
  },
  [8]={
    "",
  },
  [9]={
    "",
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
    "rt_shln_Null",
  },
}


this.SahelanLifeTable = {
  Body  = 10000,  
  Bp    = 10000,  
  Head  = 10000,  
  ArmR  = 10000,  
  ArmL  = 10000,  
  ThighR  = 10000,  
  ThighL  = 10000,  
  LegR  = 10000,  
  LegL  = 10000,  
  Tnk   = 10000,
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

this.SetSahelanType = function()
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local command = {id="SetStageType", index = 0, }  
  GameObject.SendCommand(gameObjectId, command)
end


this.UpdateSahelanBaseRoute = function( baseRouteName )
  --InfCore.DebugPrint("Sally: Base Route Updated to: "..baseRouteName)
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

  GameObject.SendCommand(gameObjectId, command1)
end

--no idea what this does 
this.ResetSahelanCounter = function()
  this.SahelanCounter = 0
end
this.CountSahelanCounter = function()
  this.SahelanCounter = this.SahelanCounter + 1
end


this.SetSahelanMissileRouteList = function(CurrentSearchMissilerouteList)

  local routeList = this.MissileRouteListForAfgh[Ivars.IsSahelanActiveArea:Get()]
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local indexNum = 0

  for k, routeName in pairs(routeList) do
    local command = {id="SetSearchMissileRouteAll", route= routeName, index=indexNum }
    GameObject.SendCommand(gameObjectId, command)
    indexNum = indexNum + 1
  end
end

this.SetSahelanSearchRouteList = function()

  local sahelanRouteTableAlert = this.SetCautionRouteAlert[Ivars.IsSahelanActiveArea:Get()]
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
    elseif v[1] == "rt_shln_Null0001" and v[2] ~= "rt_shln_Null0001" then 
      if k == trapName then 
          this.UpdateSahelanBaseRoute(v[2])
          InfCore.DebugPrint("UpdateSahelanRoute: "..trapName.." Base route assigned. base route updated to: "..v[2]) 
          return  
      end
    elseif v[1] ~= "rt_shln_Null0001" and v[2] == "rt_shln_Null0001" then 
      if k == trapName then 
          this.UpdateSahelanBaseRoute(v[1])
          InfCore.DebugPrint("UpdateSahelanRoute: "..trapName.." Base route assigned. base route updated to: "..v[1]) 
          return  
      end
    else
      InfCore.DebugPrint("this should not happen")  
    end 
  end 
end


this.SetUpSahelanAfgh = function()
  local gameObjectId = {type="TppSahelan2", group=0, index=0}
  local CombatGradecommand = { id = "SetCombatGrade", defenseValue=60000, defenseValueForWeakPoint=20000, offenseGrade=15, defenseGrade=15 }
  local CurrentBaseRoute = SahelanAreasAfghBaseRoutes[Ivars.IsSahelanActiveArea:Get()]

  --this.SetSahelanRoute( "rt_shlnArea9_OnTheHillTest", "rt_shlnArea9_OnTheHillTest" )
  
  GameObject.SendCommand(gameObjectId, CombatGradecommand)
  this.UpdateSahelanBaseRoute( CurrentBaseRoute )
  -- Sally wont move on alert without routes here
  this.SetSahelanSearchRouteList()
  --this.SetSahelanRouteLink()
  --this.SetSahelanMissileRouteList()
  this.SetSahelanLife(600000)
  this.SetSahelanPartsLife(this.SahelanLifeTable)
end


function this.AddMissionPacks(missionCode,packPaths)
  if Ivars.IsSahelanActiveIvar:Is(1) then
    if vars.missionCode==30010 then
      for i,packagePath in ipairs(SahelanAreasAfghPacks[Ivars.IsSahelanActiveArea:Get()])do
        packPaths[#packPaths+1]=packagePath
      end
    elseif vars.missionCode==30020 then
      --for i,packagePath in ipairs(this.packages.sally_stuffMafr)do
      --  packPaths[#packPaths+1]=packagePath
      --end
      return
    end
  end
end
   
function this.Messages()
    return
      StrCode32Table {
        Trap=this.sahelanTraps,
        GameObject={    
                      { 
                        msg = "ChangePhase",
                        func = function( cpId, phase )
                          if phase == TppGameObject.PHASE_ALERT or phase == TppGameObject.PHASE_CAUTION then
                            if PlayerIsDetected == false then
                              this.SetSahelanType()
                              TppMission.StartBossBattle()
                              PlayerIsDetected = true
                            end 
                          end         
                        end
                      },    
                    },  
                  }
end


--[[
  ### IMPORTANT: The "sahelanTraps" needs to be set up here 1st, otherwise a empty table will be submited ### 
  ### Seems to work After Checkpoint and game reboot done this way                                        ###
]]

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
      end
      this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
    end 
  end
 end



this.SetUpEnemy = function ()
  if Ivars.IsSahelanActiveIvar:Is(1) then
    if vars.missionCode==30010 then
      this.SetUpSahelanAfgh()
    end
  end
end 



function this.OnReload(missionTable)
  if Ivars.IsSahelanActiveIvar:Is(1) then
      if vars.missionCode==30010 then
        this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
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
 
 
return this 