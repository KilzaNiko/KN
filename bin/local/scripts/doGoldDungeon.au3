#include-once

;Exclusive to the donator version
Func doGoldDungeon()
    Log_Level_Add("doGoldDungeon")
    Log_Add("Checking for gold dungeon.")

    Local $bOutput = False 
    Local $hTimer = TimerInit()
    While TimerDiff($hTimer) < 45000
        If _Sleep(300) Then ExitLoop
        Local $sLocation = getLocation()
        Switch $sLocation
            Case "battle-auto", "unknown"
                $hTimer = TimerInit()
            Case "battle"
                clickBattle()
            Case "pause"
                clickPoint(getPointArg("battle-continue"))
            Case "battle-end-exp", "battle-sell", "battle-sell-item", "battle-end"
                $bOutput = True
                ExitLoop
            Case "map-battle"
                Log_Add("Attacking gold dungeon.")
                enterBattle()
            Case "refill"
                If doRefill() <= 0 Then ExitLoop
            Case "gold-dungeons"
                If isPixel(getPixelArg("gold-dungeons-attempt"), 30) = False Then 
                    $bOutput = True
                    ExitLoop
                EndIf
                clickPoint(getPointArg("gold-dungeons-energy"))
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
                        navigate("gold-dungeons", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd
    navigate("map")

    Log_Add("Gold Dungeon completed.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return $bOutput
EndFunc