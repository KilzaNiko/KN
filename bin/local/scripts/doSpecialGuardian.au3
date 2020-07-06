#include-once

Func doSpecialGuardian()
    Log_Level_Add("doSpecialGuardian")
    Log_Add("Checking for special guardian dungeon.")

    Local $bOutput = False 
    Local $hTimer = TimerInit()
    While TimerDiff($hTimer) < 600000
        If _Sleep(300) Then ExitLoop

        Local $sLocation = getLocation()
        Switch $sLocation
            Case "special-guardian-dungeons"
                CaptureRegion()
                Local $aFound = findColor("643,200", "1,270", 0xFEF8CA, 5)
                If isArray($aFound) = True Then
                    clickPoint($aFound)
                    waitLocation("map-battle", 10)
                Else
                    $bOutput = True
                    ExitLoop
                EndIf
            Case "map-battle"
                Log_Add("Attacking special guardian dungeon.", $LOG_INFORMATION)
                enterBattle()
            Case "refill"
                doRefill()
            Case "battle-auto"
            Case "battle"
                    clickBattle()
            Case "battle-end-exp", "battle-sell", "battle-sell-item", "battle-end"
                    navigate("special-guardian-dungeons")
            Case "pause"
                    clickPoint(getPointArg("battle-continue"))
            Case "battle-gem-full", "map-gem-full"
                If $General_Sell_Gems = "" Then
                    Status("Gem inventory is full, stopping script.", $LOG_INFORMATION)
                    ExitLoop
                Else
                    Status("Gem inventory is full, selling gems: " & $General_Sell_Gems, $LOG_INFORMATION)
                    sellGems($General_Sell_Gems)
                EndIf
            Case Else
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then 
                    If waitLocation("battle,battle-auto,battle-boss", 5) = False Then
                        If navigate("special-guardian-dungeons", True) = False Then ExitLoop
                    EndIf
                EndIf
        EndSwitch
    WEnd
    navigate("map")
    
    Log_Add("Special guardian result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()

    Return $bOutput
EndFunc