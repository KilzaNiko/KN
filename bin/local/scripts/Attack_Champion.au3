#include-once

;Exclusive to the donator version
Func Attack_Champion($bParam = True, $aStats = Null)
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Attack_Champion")[2]), "Attack_Champion")
    ;Runs, Idle Time, Attack Strongest, Focus Enemy

    $Attack_Champion_Idle_Time = ($Attack_Champion_Idle_Time="Never")?0:Int(StringMid($Attack_Champion_Idle_Time, 1, StringLen($Attack_Champion_Idle_Time) - StringLen(" Minutes")))

    Log_Level_Add("Attack_Champion")

    Global $Status, $Champion_Runs, $Champion_Wins
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Ratio",      "Champion_Runs",         "Attack_Champion_Runs"), _
                    CreateArr("Ratio",      "Champion_Wins",         "Champion_Runs") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

    Status("Attack Champion has started.", $LOG_INFORMATION)

    Local $bIdle = False
    Local $hIdle = Null
    Local $hStuckTimer = TimerInit()

    navigate("map", True)
    While $g_bRunning = True
        If _Sleep(200) Then ExitLoop

        If $bIdle = True Then 
            $g_hTimerLocation = Null
            If getLocation() <> "village" Then navigate("village")

            If $Attack_Champion_Idle_Time = 0 Then ExitLoop
            If $hIdle = Null Then $hIdle = TimerInit()

            Local $iSeconds = $Attack_Champion_Idle_Time*60 - Int((TimerDiff($hIdle)/1000))
            Status("Currently idling for " & Int($iSeconds/60) & " minutes.")
            If $iSeconds <= 0 Then
                $bIdle = False
                $hIdle = Null
            EndIf

            ContinueLoop
        EndIf

        Local $sLocation = getLocation()
        Common_Stuck($sLocation)
        
        Switch $sLocation
            Case "map"
                Status("Looking for champion league.")
                If navigate("championleague", True, 2) = False Then
                    Status("Cannot navigate to champion league.", $LOG_ERROR)
                    $bIdle = True
                EndIf
            Case "astroleague"
                Status("Status", "Looking for a match.")
                $hStuckTimer = Null

                If Attack_PVP_Refresh() Then
                    If _Sleep(3000) Then ExitLoop
                EndIf

                clickDrag($g_aSwipeDown)
                If _Sleep(1000) Then ExitLoop

                CaptureRegion()

                If $Attack_Champion_Attack_Strongest = True Then 
                    clickDrag($g_aSwipeUpFast)
                    If _Sleep(2000) Then ExitLoop
                EndIf

                Local $aPoint = Attack_Champion_Find()
                Local $hTimer = TimerInit()
                While TimerDiff($hTimer) < 20000
                    If _Sleep(200) Then ExitLoop
                    
                    $aPoint = Attack_Champion_Find()
                    If isArray($aPoint) Then ExitLoop
                    clickDrag(Eval("g_aSwipe" & ($Attack_Champion_Attack_Strongest?"Down":"Up")))
                WEnd

                If isArray($aPoint) = True Then
                    clickPoint($aPoint)
                    waitLocation("map-battle", 5)
                Else
                    Status("Could not find a match.", $LOG_ERROR)
                    $bIdle = True
                    navigate("map")
                EndIf
            Case "map-battle"
                If $Attack_Champion_Runs <> 0 And $Champion_Runs >= $Attack_Champion_Runs Then ExitLoop
                
                Status("Entering match x" & $Champion_Runs+1, $LOG_PROCESS)
                If enterBattle() = True Then 
                    $Champion_Runs += 1
                    $Champion_Wins += 1
                    Cumulative_AddRatio("PVP Win Ratio (Champion)")
                EndIf
            Case "battle", "battle-auto"
                $g_hTimerLocation = Null ;Prevent anti-stuck timer
                ;Separate stuck timer
                    If $hStuckTimer = Null Then $hStuckTimer = TimerInit()
                    If TimerDiff($hStuckTimer) > 120000 And Mod(Int(TimerDiff($hStuckTimer)/1000)+1, 5) = 0 Then
                        If FileExists(@ScriptDir & "\bin\images\misc\misc-pvp-stuck.bmp") = False Then
                            CaptureRegion("\bin\images\misc\misc-pvp-stuck.bmp", 80, 80, 650, 450)
                        Else
                            CaptureRegion()
                            If isArray(findImage("misc-pvp-stuck", 99, 0)) = True Then
                                Log_Add("Game has froze in PVP, exiting pvp script.", $LOG_ERROR)

                                FileDelete(@ScriptDir & "\bin\images\misc\misc-pvp-stuck.bmp")
                                ExitLoop
                            EndIf

                            FileDelete(@ScriptDir & "\bin\images\misc\misc-pvp-stuck.bmp")
                        EndIf
                    EndIf
                ;-----

                If $sLocation = "battle" Then
                    Local $hTimer = TimerInit()
                    Local $bInBattle = True
                    While TimerDiff($hTimer) < 500
                        If getLocation() <> "battle" Then 
                            $bInBattle = False
                        EndIf
                        If _Sleep(50) Then ExitLoop
                    WEnd
                    
                    If $bInBattle = True Then 
                        If $Attack_Champion_Focus_Enemy = True Then clickPoint(getPointArg("guided-4-mon-first"))
                        clickBattle()
                    EndIf
                EndIf
                
            Case "championleague-victory"
                If clickUntil(getPointArg("tap"), "isLocation", "pvp-battle-end,battle-end", 20, 500) = True Then 
                    Status("You have won a match x" & $Champion_Wins & ".", $LOG_INFORMATION)
                EndIf
            Case "championleague-defeat"
                If clickUntil(getPointArg("tap"), "isLocation", "pvp-battle-end,battle-end", 20, 500) = True Then
                    Status("You have lost a match.")
                    $Champion_Wins -= 1
                    Cumulative_SubRatio_Num("PVP Win Ratio (Champion)")
                EndIf
            Case "astroleague-refill", "buy-gem", "buy-gold"
                Status("Out of tickets, " & (($Attack_Champion_Idle_Time=0)?"stopping script.":"going into idle."))
                $bIdle = True
            Case "pvp-battle-end", "battle-end"
                Status("Match has ended.")
                clickPoint(getPointArg("astroleague-exit"))
            Case "pause"
                Status("Unpausing the match.")
                clickPoint(getPointArg("battle-continue"))
            Case Else
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then
                    If waitLocation("battle,battle-auto,battle-boss", 5) = False Then
                        Status("Proceeding to Attack Champion.")
                        navigate("map", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd
    
    Log_Add("Attack Champion has ended.")
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc

;Helper functions

Func Attack_Champion_Find($aStarting = "705,470")
    Local $aFound = -1
    CaptureRegion()
    $aFound = findColor($aStarting, "1,-270", 0xD59825, 10, 1, -1)
    If isArray($aFound) = True Then
        If isArray(findColor($aFound, "1,-40", 0xD9071D, 10, 1, -1)) = True Then
            Return Attack_Champion_Find("705," & ($aFound[1]-80)) ;ignore defeated
        Else
            Return $aFound
        EndIf
    EndIf
    Return -1
EndFunc