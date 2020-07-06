#include-once

;Exclusive to the donator version
Func Farm_Wings($bParam = True, $aStats = Null)
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Wings")[2]), "Farm_Wings")
    ;Hourly Script

	;Starting script
    Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Golem")[2]), "Farm_Golem")
    Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Rare")[2]), "Farm_Rare")
	Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Starstone")[2]), "Farm_Starstone")

    Status("Farm Forever has started.")
    Local $aGolem_Param = [$Farm_Wings_Runs, $Farm_Golem_Dungeon_Level, $Farm_Golem_Guided_Auto, $Farm_Wings_Refill, $Farm_Forever_Golem_Gold_Goal, $Farm_Golem_Target_Boss]
	Local $aRare_Param = [$Farm_Wings_Runs, $Farm_Rare_Map, $Farm_Rare_Difficulty, $Farm_Rare_Stage_Level, $Farm_Rare_Capture, $Farm_Wings_Refill, $Farm_Golem_Target_Boss]
	Local $aStarstone_Param = [$Farm_Wings_Runs, $Farm_Starstone_Dungeon_Type, $Farm_Starstone_Dungeon_Level, $Farm_Starstone_Guided_Auto, $Farm_Starstone_Stone_Element, $Farm_Starstone_High_Stones, $Farm_Starstone_Mid_Stones, $Farm_Starstone_Low_Stones, $Farm_Wings_Refill, $Farm_Starstone_Target_Boss]
	
	Global $Status
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf
	
    Log_Level_Add("Farm_Wings")

    Status("Farm wings has started.", $LOG_INFORMATION)

	Local $bIdle = True
    Local $hIdle = Null
	
    While $g_bRunning = True
        If _Sleep(200) Then ExitLoop
		
		Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        If $bIdle = True Then 
            If getLocation() <> "village" Then navigate("village")

            If $hIdle = Null Then $hIdle = TimerInit()

            Local $iSeconds = $Farm_Wings_Idle_Time*60 - Int((TimerDiff($hIdle)/1000))
            Status("Currently idling for " & Int($iSeconds/60) & " minutes.")
            If $iSeconds <= 0 Then
                $bIdle = False
                $hIdle = Null
            Else
				; Switch location just to detect real freezes of the game
				If (Mod(Int((TimerDiff($hIdle)/1000)),($Config_Location_Stuck_Timeout*60-5)) == 0  And (TimerDiff($hIdle) > 2000)) Then
					navigate("quests")
				EndIf
			EndIf

            ContinueLoop
        EndIf
        
		Stats_Clear()
		Switch $Farm_Wings_Script
            Case "Farm_Golem"
				_RunScript("Farm_Golem", $aGolem_Param)
				$bIdle = True
			Case "Farm_Rare"
				_RunScript("Farm_Rare", $aRare_Param)
				$bIdle = True
			Case "Farm_Starstone"
				_RunScript("Farm_Starstone", $aStarstone_Param)
				$bIdle = True
		EndSwitch
    WEnd
    
    Log_Add("Farm_Wings has ended.")
    Log_Level_Remove()
EndFunc