#include-once

Func Farm_Dragon($bParam = True, $aStats = Null) 
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Dragon")[2]), "Farm_Dragon")
    ;Runs, Dungeon Level, Refill, Gem Filter, Dragon Gem Filter, Continue On Defeat, Target Middle, Target Boss

    Log_Level_Add("Farm_Dragon")

    Global $Status, $Runs, $Win_Rate, $Average_Time, $Astrogems_Used, $Gold_Earned, $Gems_Kept, $Eggs_Found
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Ratio",      "Runs",             "Farm_Dragon_Runs"), _
                    CreateArr("Percent",    "Win_Rate",         "Runs"), _
                    CreateArr("Time",       "Average_Time",     "Runs"), _
                    CreateArr("Ratio",      "Astrogems_Used",   "Farm_Dragon_Refill"), _
                    CreateArr("Number",     "Gold_Earned"), _
                    CreateArr("Number",     "Gems_Kept"), _
                    CreateArr("Number",     "Eggs_Found") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

    Status("Farm Dragon has started.", $LOG_INFORMATION)

    Local $hAverage = Null
    Local $bMiddle = False
    navigate("map", True)
    While $g_bRunning = True
        If _Sleep(200) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        Switch $sLocation
            Case "map"
                If $Farm_Dragon_Runs <> 0 And $Runs >= $Farm_Dragon_Runs Then ExitLoop

                Status("Looking for dragon dungeons.")
                navigate("dragon-dungeons")
            Case "dragon-dungeons"
                Status("Searching for dragon level.")
                Local $aLevel = findBLevel($Farm_Dragon_Dungeon_Level)
                If isArray($aLevel) = True Then 
                    clickPoint($aLevel)
                    waitLocation("map-battle", 10)
                Else
                    clickDrag($g_aSwipeDown)
                EndIf
            Case "map-battle", "battle-end"
                If $Farm_Dragon_Runs <> 0 And $Runs >= $Farm_Dragon_Runs Then ExitLoop

                Status("Entering battle x" & $Runs+1, $LOG_PROCESS)
                If enterBattle() = True Then
                    $bMiddle = False
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Runs += 1
                    Cumulative_AddNum("Runs (Farm Dragon)", 1)
                EndIf
            Case "defeat"
                Status("You have been defeated.", $LOG_INFORMATION)
                If $Farm_Dragon_Continue_On_Defeat = True Then
                    Status("Continuing battle.", $LOG_INFORMATION)
                    
                    clickWhile(getPointArg("battle-defeat-continue"), "isLocation", "defeat", 10, 500)
                    If _Sleep(1000) Then ExitLoop
                    clickPoint(getPointArg("boss"))
                Else
                    $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                    $hAverage = Null

                    $Win_Rate -= 1
                    navigate("battle-end", True)
                EndIf
            Case "refill"
                If $Farm_Dragon_Refill <> 0 And $Astrogems_Used+30 > $Farm_Dragon_Refill Then ExitLoop
                Status("Refilling energy.")

                Local $iRefill = doRefill()
                If $iRefill = -1 Then ExitLoop
                If $iRefill = 1 Then $Astrogems_Used += 30
            Case "battle"
                Status("Currently in battle.")
                If getLocation() = "battle" Then clickBattle()
            Case "battle-auto"
                Status("Currently in battle.")

                If $Farm_Dragon_Target_Middle = True Then
                    Local $aRound = getRound()
                    If (isArray($aRound) = True And $aRound[0] = 1) And $bMiddle = False Then
                        clickPoint(getPointArg("guided-3-mon-second"))
                        $bMiddle = True
                    EndIf
                EndIf
            Case "pause"
                Status("In pause screen, unpausing.")
                clickPoint(getPointArg("battle-continue"))
            Case "battle-end-exp"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null

                Status("Going to check gem.")
                clickUntil(getPointArg("battle-sell-item-second"), "isLocation", "battle-sell-item,battle-end", 300, 100)
            Case "battle-sell"
                Status("Clicking third item.")
                clickPoint(getPointArg("battle-sell-item-third"))
            Case "battle-sell-item"
                Status("Capturing gem data.")
                Local $aGem = getGemData()
                If $aGem <> -1 Then
                    Local $bSold = False
                    Switch $aGem[0]
                        Case "GOLD"
                            clickPoint(getPointArg("battle-sell-item-okay"))
                            ContinueLoop
                        Case "EGG"
                            $Eggs_Found += 1
                            Status("Found egg x" & $Eggs_Found)
                            Cumulative_AddNum("Resource Collected (Egg)", 1)
                        Case Else
                            If filterGem($aGem, True) = False Then
                                $bSold = True
                                clickPoint(getPointArg("battle-sell-item-sell"))
                            EndIf

                            If $bSold = False Then 
                                $Gems_Kept += 1
                                Cumulative_AddNum("Resource Collected (Dragon Gem)", 1)
                            Else
                                $Gold_Earned += getGemPrice($aGem)
                                Cumulative_AddNum("Resource Earned (Gold)", getGemPrice($aGem))
                            EndIf
                            Log_Add(($bSold?"Sold":"Kept") & ": " & stringGem($aGem), $LOG_INFORMATION)
                    EndSwitch
                Else
                    Status("Error: could not detect gem.", $LOG_ERROR)
                EndIf
                
                navigate("battle-end", True)
            Case "battle-boss"
                If $Farm_Dragon_Target_Boss = True Then
                    Status("Targeting boss.")
                    waitLocation("battle,battle-auto", 2)
                    If _Sleep($Delay_Target_Boss_Delay) Then ExitLoop
                    clickPoint("395, 317")
                EndIf
            Case "map-gem-full", "battle-gem-full"
                If $General_Sell_Gems = "" Then
                    Status("Gem inventory is full, stopping script.", $LOG_INFORMATION)
                    ExitLoop
                Else
                    Status("Gem inventory is full, selling gems: " & $General_Sell_Gems, $LOG_INFORMATION)
                    sellGems($General_Sell_Gems)
                EndIf
            Case "buy-gem", "buy-gold"
                Status("Not enough astrogems, stopping script.", $LOG_ERROR)
                ExitLoop
            Case "dragon-sigils-empty"
                Status("No more dragon sigils left. Ending script.", $LOG_INFORMATION)
                clickWhile(getPointArg("dragon-sigils-empty-confirm"), "isLocation", "dragon-sigils-empty", 10, 750)
                ExitLoop
            Case Else
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then 
                    If waitLocation("battle,battle-auto,battle-boss", 5) = False Then
                        Status("Proceeding to Farm Dragon.")
                        navigate("map", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd

    Status("Farm Dragon has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc