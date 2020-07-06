#include-once

Func Farm_Forever($bParam = True, $aStats = Null)
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Forever")[2]), "Farm_Forever")
    ;First Script, Golem Refill, Golem Gold Goal, Astrogems, Golem Settings, Gem Settings
    Log_Level_Add("Farm_Forever")
    
    ;Starting script
    Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Golem")[2]), "Farm_Golem")
    Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Gem")[2]), "Farm_Gem")

    Status("Farm Forever has started.")
    Local $aGolem_Param = [0, $Farm_Golem_Dungeon_Level, $Farm_Golem_Guided_Auto, $Farm_Forever_Golem_Refill, $Farm_Forever_Golem_Gold_Goal, $Farm_Golem_Target_Boss]
    Local $aGem_Param = [$Farm_Forever_Astrogems, $Farm_Gem_Astromon, $Farm_Gem_Release_Evo3, $Farm_Gem_Max_Catch, $Farm_Gem_Finish_Round, $Farm_Gem_Final_Round, $Farm_Gem_Map, $Farm_Gem_Difficulty, $Farm_Gem_Stage_Level, $Farm_Gem_Capture, 0]

    While $g_bRunning
        If _Sleep(1000) Then ExitLoop

        Stats_Clear()
        If $Farm_Forever_First_Script = "Farm_Golem" Then
            _RunScript("Farm_Golem", $aGolem_Param)
            Stats_Clear()
            _RunScript("Farm_Gem", $aGem_Param)
        Else
            _RunScript("Farm_Gem", $aGem_Param)
            Stats_Clear()
            _RunScript("Farm_Golem", $aGolem_Param)
        EndIf
    WEnd

    ;End script
    Log_Add("Farm Forever has ended.")
    Log_Level_Remove()
EndFunc