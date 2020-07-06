#include-once

Func Farm_Starstone($bParam = True, $aStats = Null)
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Starstone")[2]), "Farm_Starstone")
    ;Runs, Dungeon Type, Dungeon Level, Guided Auto, Stone Element, High Stones, Mid Stones, Low Stones, Refill, Target Boss

    Log_Level_Add("Farm_Starstone")

    Global $Status, $Runs, $Win_Rate, $Average_Time, $Astrogems_Used, $High_Stones, $Mid_Stones, $Low_Stones, $Eggs_Found
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Ratio",      "Runs",             "Farm_Starstone_Runs"), _
                    CreateArr("Percent",    "Win_Rate",         "Runs"), _
                    CreateArr("Time",       "Average_Time",     "Runs"), _
                    CreateArr("Ratio",      "Astrogems_Used",   "Farm_Starstone_Refill"), _
                    CreateArr("Ratio",      "High_Stones",      "Farm_Starstone_High_Stones"), _
                    CreateArr("Ratio",      "Mid_Stones",       "Farm_Starstone_Mid_Stones"), _
                    CreateArr("Ratio",      "Low_Stones",       "Farm_Starstone_Low_Stones"), _
                    CreateArr("Number",     "Eggs_Found") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

    Status("Farm Starstone has started.", $LOG_INFORMATION)

    Local $hAverage = Null
    navigate("map", True)
    While $g_bRunning = True
        If _Sleep(200) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        Switch $sLocation
            Case "map"
                If $Farm_Starstone_Runs <> 0 And $Runs >= $Farm_Starstone_Runs Then ExitLoop
                If (($Farm_Starstone_High_Stones = 0 And $Farm_Starstone_Mid_Stones = 0) And $Farm_Starstone_Low_Stones = 0) = False Then
                    If $Farm_Starstone_High_Stones = 0 Or $High_Stones >= $Farm_Starstone_High_Stones Then
                        If $Farm_Starstone_Mid_Stones = 0 Or $Mid_Stones >= $Farm_Starstone_Mid_Stones Then
                            If $Farm_Starstone_Low_Stones = 0 Or $Low_Stones >= $Farm_Starstone_Low_Stones Then
                                ExitLoop
                            EndIf
                        EndIf
                    EndIf
                EndIf

                Local $sType = $Farm_Starstone_Dungeon_Type="Normal"?"starstone":"elemental"
                Status(StringFormat("Looking for %s dungeons.", $sType))
                navigate($sType & "-dungeons")
            Case "starstone-dungeons", "elemental-dungeons"
                Status("Searching for dungeon level.")
                Local $aLevel = findBLevel($Farm_Starstone_Dungeon_Level)
                If isArray($aLevel) = True Then
                    clickPoint($aLevel)
                    waitLocation("map-battle", 10)
                Else
                    clickDrag($g_aSwipeDown)
                EndIf
            Case "map-battle", "battle-end"
                If $Farm_Starstone_Runs <> 0 And $Runs >= $Farm_Starstone_Runs Then ExitLoop
                If (($Farm_Starstone_High_Stones = 0 And $Farm_Starstone_Mid_Stones = 0) And $Farm_Starstone_Low_Stones = 0) = False Then
                    If $Farm_Starstone_High_Stones = 0 Or $High_Stones >= $Farm_Starstone_High_Stones Then
                        If $Farm_Starstone_Mid_Stones = 0 Or $Mid_Stones >= $Farm_Starstone_Mid_Stones Then
                            If $Farm_Starstone_Low_Stones = 0 Or $Low_Stones >= $Farm_Starstone_Low_Stones Then
                                ExitLoop
                            EndIf
                        EndIf
                    EndIf
                EndIf

                Status("Entering battle x" & $Runs+1, $LOG_PROCESS)
                If enterBattle() = True Then
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Runs += 1
                    Cumulative_AddNum("Runs (Farm Starstone)", 1)
                EndIf
            Case "defeat"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null

                $Win_Rate -= 1
                Status("You have been defeated.", $LOG_INFORMATION)
                navigate("battle-end", True)
            Case "refill"
                If $Farm_Starstone_Refill <> 0 And $Astrogems_Used+30 > $Farm_Starstone_Refill Then ExitLoop
                Status("Refilling energy.")

                Local $iRefill = doRefill()
                If $iRefill = -1 Then ExitLoop
                If $iRefill = 1 Then $Astrogems_Used += 30
            Case "battle", "battle-auto"
                Status("Currently in battle.")

                Switch $Farm_Starstone_Guided_Auto
                    Case "Full"
                        If $sLocation = "battle-auto" Then clickPoint(getPointArg("battle-auto"))
                        Local $aRound = getRound()

                        If $General_Guided_Auto_Active = False Then
                            Local $bEnemy = (isArray($aRound) = True And $aRound[0] = $aRound[1])
                            attackGuided($Farm_Starstone_Guided_Auto & ($bEnemy?"-Attack":""))
                            ContinueLoop
                        Else
                            If Not(isArray($aRound) = True And $aRound[0] = $aRound[1]) Then
                                attackGuided($Farm_Starstone_Guided_Auto)
                                ContinueLoop
                            EndIf
                        EndIf
                    Case "Semi"
                        attackGuided($Farm_Starstone_Guided_Auto)
                EndSwitch

                If $sLocation = "battle" Then clickBattle()
            Case "pause"
                Status("In pause screen, unpausing.")
                clickPoint(getPointArg("battle-continue"))
            Case "battle-end-exp"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null

                Status("Going to check stone.")
                clickUntil(getPointArg("battle-sell-item-second"), "isLocation", "battle-sell-item,battle-end", 300, 100)
            Case "battle-sell"
                Status("Clicking third item.")
                clickPoint(getPointArg("battle-sell-item-third"))
            Case "battle-sell-item"
                Status("Capturing stone data.")
                Local $aStone = getStone()
                If $aStone <> -1 Then
                    Switch $aStone[0]
                        Case "gold"
                            clickPoint(getPointArg("battle-sell-item-okay"))
                            ContinueLoop
                        Case "egg"
                            $Eggs_Found += 1
                            Status("Found egg x" & $Eggs_Found)
                            Cumulative_AddNum("Resource Collected (Egg)", 1)
                        Case Else
                            Local $sElement = StringLower($Farm_Starstone_Stone_Element)
                            If $sElement = "any" Or $sElement = $aStone[0] Then
                                Assign($aStone[1] & "_Stones", Eval($aStone[1] & "_Stones")+$aStone[2])
                            EndIf
                            Log_Add(StringFormat("Found %s %s x%s.", $aStone[1], $aStone[0], $aStone[2]), $LOG_INFORMATION)
                            Cumulative_AddNum("Resource Collected (" & _StringProper($aStone[1]) & " " & _StringProper($aStone[0]) & ")", $aStone[2])
                    EndSwitch
                Else
                    Status("Error: could not detect stone.", $LOG_ERROR)
                EndIf

                navigate("battle-end", True)
            Case "battle-boss"
                If $Farm_Starstone_Target_Boss = True Then
                    Status("Targeting boss.")
                    waitLocation("battle,battle-auto", 2)
                    If _Sleep($Delay_Target_Boss_Delay) Then ExitLoop
                    clickPoint("395, 317")
                EndIf
            Case "battle-gem-full", "map-gem-full"
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
            Case Else
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then
                    If waitLocation("battle,battle-auto,battle-boss", 5) = False Then
                        Status("Proceeding to Farm Starstone.")
                        navigate("map", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd

    Status("Farm Starstone has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc
