#include-once

;v1.5.5 Compatible
Global $Config_Profile_Name = "Default"
Global $Config_Scheduled_Restart = -1
Global $Config_Location_Stuck_Timeout = 10
Global $Config_Another_Device_Timeout = 0
Global $Config_Maintenance_Timeout = 5
Global $Config_Save_Logs = True
Global $Config_Log_Debug = True
Global $Config_Log_Clicks = True
Global $Config_ADB_Path = "C:\Program Files (x86)\Nox\bin\nox_adb.exe"
Global $Config_ADB_Device = "127.0.0.1:62001"
Global $Config_ADB_Shared_Folder1 = "/mnt/shared/App/"
Global $Config_ADB_Shared_Folder2 = "C:\Users\" & @ComputerName & "\Nox_share\App\"
Global $Config_ADB_Method = "input event"
Global $Config_ADB_Input_Event_Version = 0
Global $Config_Emulator_Title = "NoxPlayer"
Global $Config_Emulator_Property = "[CLASS:Qt5QWindowIcon; TEXT:ScreenBoardClassWindow]"
Global $Config_Display_Scaling = 100
Global $Config_Capture_Mode = $BKGD_WINAPI
Global $Config_Mouse_Mode = $MOUSE_CONTROL
Global $Config_Swipe_Mode = $SWIPE_ADB
Global $Config_Back_Mode = $BACK_ADB

Global $Delay_Swipe_Delay = 300
Global $Delay_Navigation_Timeout = 30
Global $Delay_Target_Boss_Delay = 10
Global $Delay_ADB_Timeout = 5000
Global $Delay_Restart_Timeout = 300
Global $Delay_Guided_Auto_Delay = 100
Global $Delay_Confirm_Button_Friend_Gifts_Delay = 700
Global $Delay_Clicks_Collect_Hiddens_Delay = 0

Global $General_Collect_Quests = True
Global $General_Sell_Gems = "1,2,3"
Global $General_Guided_Auto_Type = "Default"
Global $General_Guided_Auto_Active = True
Global $General_Max_Exotic_Chips = 20
Global $General_Dailies_Hero_Dungeons = False
Global $General_Super_Festival = False

Global $Hourly_Hourly_Script = True
Global $Hourly_Collect_Hiddens = True
Global $Hourly_Click_Nezz = False
Global $Hourly_Complete_Bingo = True
Global $Hourly_Daily_Quests = True
Global $Hourly_Gold_Dungeon = True
Global $Hourly_Special_Guardian_Dungeon = True
Global $Hourly_Buy_First_Item = True
Global $Hourly_Buy_Secret_Egg = False
Global $Hourly_Check_Exotic_Festival = True
Global $Hourly_Collect_Inbox = True
Global $Hourly_Get_Daily_Eggs_Trinkets = True

Global $Guardian_Guardian_Script = True
Global $Guardian_Guardian_Mode = "Both"
Global $Guardian_Guided_Auto = False
Global $Guardian_Target_Boss = True
Global $Guardian_Check_Intervals = 30

Global $Expedition_Expedition_Script = True
Global $Expedition_Check_Intervals = 1
Global $Expedition_Use_Luck_Item = -1
Global $Expedition_Explore_Time = 2

Global $Astroleague_Astroleague_Script = True
Global $Astroleague_Check_Intervals = 60
Global $Astroleague_Attack_Strongest = True
Global $Astroleague_Attack_Random = True
Global $Astroleague_Random_Only = False
Global $Astroleague_Focus_Enemy = False
Global $Astroleague_Draw_Match = 5

Global $Champion_Champion_League_Script = False
Global $Champion_Check_Intervals = 180
Global $Champion_Attack_Strongest = True
Global $Champion_Focus_Enemy = True

Global $Filter_4_Star_Filter = False
Global $Filter_4_Star_Types = ""
Global $Filter_4_Star_Stats = ""
Global $Filter_4_Star_Substats = ""
Global $Filter_5_Star_Filter = True
Global $Filter_5_Star_Types = "Valor,Vitality,Life,Protection,Ruin,Conviction,Intuition"
Global $Filter_5_Star_Stats = "P.HP,P.ATK,P.DEF,CRIT RATE"
Global $Filter_5_Star_Substats = "3,4"
Global $Filter_6_Star_Filter = True
Global $Filter_6_Star_Types = "Valor,Vitality,Life,Protection,Ruin,Conviction,Intuition"
Global $Filter_6_Star_Stats = "P.HP,P.ATK,P.DEF,CRIT RATE"
Global $Filter_6_Star_Substats = "2,3,4"

Global $DragonFilter_4_Star_Filter = False
Global $DragonFilter_4_Star_Types = ""
Global $DragonFilter_4_Star_Stats = ""
Global $DragonFilter_4_Star_Substats = ""
Global $DragonFilter_5_Star_Filter = True
Global $DragonFilter_5_Star_Types = "Leech,Pugilist,Siphon"
Global $DragonFilter_5_Star_Stats = "P.HP,P.ATK,P.DEF,CRIT RATE"
Global $DragonFilter_5_Star_Substats = "3,4"
Global $DragonFilter_6_Star_Filter = True
Global $DragonFilter_6_Star_Types = "Leech,Pugilist,Siphon"
Global $DragonFilter_6_Star_Stats = "P.HP,P.ATK,P.DEF,CRIT RATE"
Global $DragonFilter_6_Star_Substats = "1,2,3,4"

Global $Attack_PVP_Runs = 0
Global $Attack_PVP_Idle_Time = 30
Global $Attack_PVP_Attack_Strongest = True
Global $Attack_PVP_Attack_Random = True
Global $Attack_PVP_Random_Only = False
Global $Attack_PVP_Focus_Enemy = False
Global $Attack_PVP_Draw_Match = 5

Global $Attack_Champion_Runs = 0
Global $Attack_Champion_Idle_Time = 60
Global $Attack_Champion_Attack_Strongest = True
Global $Attack_Champion_Focus_Enemy

Global $Farm_Wings_Script = "Farm_Golem"
Global $Farm_Wings_Runs = 5
Global $Farm_Wings_Refill = 1
Global $Farm_Wings_Idle_Time = 60

Global $Farm_Forever_First_Script = "Farm_Golem"
Global $Farm_Forever_Golem_Refill = 0
Global $Farm_Forever_Golem_Gold_Goal = 1320000
Global $Farm_Forever_Astrogems = 400
Global $Farm_Forever_Golem_Settings = "Farm Golem"
Global $Farm_Forever_Gem_Settings = "Farm Gem"

Global $Farm_Rare_Runs = 0
Global $Farm_Rare_Map = "Phantom Forest"
Global $Farm_Rare_Difficulty = "Normal"
Global $Farm_Rare_Stage_Level = 1
Global $Farm_Rare_Capture = "Legendary,Exotic,Super Rare,Rare,Variant"
Global $Farm_Rare_Refill = 300
Global $Farm_Rare_Target_Boss = True

Global $Farm_Golem_Runs = 0
Global $Farm_Golem_Dungeon_Level = 8
Global $Farm_Golem_Guided_Auto = False
Global $Farm_Golem_Refill = 300
Global $Farm_Golem_Gold_Goal = 0
Global $Farm_Golem_Target_Boss = True

Global $Farm_Gem_Astrogems = 300
Global $Farm_Gem_Astromon = "Slime"
Global $Farm_Gem_Release_Evo3 = True
Global $Farm_Gem_Max_Catch = 16
Global $Farm_Gem_Finish_Round = False
Global $Farm_Gem_Final_Round = False
Global $Farm_Gem_Map = "Phantom Forest"
Global $Farm_Gem_Difficulty = "Normal"
Global $Farm_Gem_Stage_Level = 1
Global $Farm_Gem_Capture = "Legendary,Exotic,Super Rare,Rare,Variant"
Global $Farm_Gem_Refill = 300

Global $Farm_Astromon_Amount = 16
Global $Farm_Astromon_Astromon = "one-star"
Global $Farm_Astromon_Finish_Round = False
Global $Farm_Astromon_Final_Round = False
Global $Farm_Astromon_Map = "Phantom Forest"
Global $Farm_Astromon_Difficulty = "Normal"
Global $Farm_Astromon_Stage_Level = 1
Global $Farm_Astromon_Capture = "Legendary,Exotic,Super Rare,Rare,Variant"
Global $Farm_Astromon_Refill = 300

Global $Farm_Guardian_Mode = "Both"
Global $Farm_Guardian_Refill = 300
Global $Farm_Guardian_Idle_Time = 30
Global $Farm_Guardian_Guided_Auto = False
Global $Farm_Guardian_Target_Boss = True

Global $Farm_Starstone_Runs = 0
Global $Farm_Starstone_Dungeon_Type = "Normal"
Global $Farm_Starstone_Dungeon_Level = 10
Global $Farm_Starstone_Guided_Auto = False
Global $Farm_Starstone_Stone_Element = "Any"
Global $Farm_Starstone_High_Stones = 50
Global $Farm_Starstone_Mid_Stones = 0
Global $Farm_Starstone_Low_Stones = 0
Global $Farm_Starstone_Refill = 300
Global $Farm_Starstone_Target_Boss = True

Global $Farm_Dragon_Runs = 0
Global $Farm_Dragon_Dungeon_Level = 8
Global $Farm_Dragon_Refill = 300
Global $Farm_Dragon_Gem_Filter = "_Filter"
Global $Farm_Dragon_Dragon_Gem_Filter = "_DragonFilter"
Global $Farm_Dragon_Continue_On_Defeat = True
Global $Farm_Dragon_Target_Middle = True
Global $Farm_Dragon_Target_Boss = True