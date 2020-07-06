#include-once

;Exclusive to the donator version
Func Attack_PVP($bParam = True, $aStats = Null)
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Attack_PVP")[2]), "Attack_PVP")
    ;Runs, Idle Time, Attack Strongest, Attack Random, Random Only, Focus Enemy, Draw Match

    $Attack_PVP_Idle_Time = ($Attack_PVP_Idle_Time="Never")?0:Int(StringMid($Attack_PVP_Idle_Time, 1, StringLen($Attack_PVP_Idle_Time) - StringLen(" Minutes")))
    $Attack_PVP_Draw_Match = Int(StringMid($Attack_PVP_Draw_Match, 1, StringLen($Attack_PVP_Draw_Match) - StringLen(" Minutes")))

    Log_Level_Add("Attack_PVP")

    Global $Status, $PVP_Runs, $PVP_Wins
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Ratio",      "PVP_Runs",         "Attack_PVP_Runs"), _
                    CreateArr("Ratio",      "PVP_Wins",         "PVP_Runs") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

    Status("Attack PVP has started.", $LOG_INFORMATION)

    Local $hDraw = Null
    Local $bIdle = False
    Local $hIdle = Null
    Local $bRandom = False
    Local $bFocused = False
    Local $hStuckTimer = Null

    navigate("map", True)
    While $g_bRunning = True
        If _Sleep(200) Then ExitLoop

        If $bIdle = True Then 
            $g_hTimerLocation = Null
            If getLocation() <> "village" Then navigate("village")

            If $Attack_PVP_Idle_Time = 0 Then ExitLoop
            If $hIdle = Null Then $hIdle = TimerInit()

            Local $iSeconds = $Attack_PVP_Idle_Time*60 - Int((TimerDiff($hIdle)/1000))
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
                Status("Looking for astroleague.")
                If navigate("astroleague", True, 2) = False Then
                    Status("Cannot navigate to astroleague.", $LOG_ERROR)
                    $bIdle = True
                EndIf
            Case "astroleague"
                Status("Status", "Looking for a match.")
                $hStuckTimer = Null
                If Attack_PVP_Refresh() Then
                    If _Sleep(3000) Then ExitLoop
                    $bRandom = True
                EndIf
                clickDrag($g_aSwipeDown)
                If _Sleep(1000) Then ExitLoop

                CaptureRegion()
                If $Attack_PVP_Random_Only = True Then
                    If isPixel(getPixelArg("astroleague-random"), 20) = True Then
                        If $bRandom = True Then
                            clickPoint(getPointArg("astroleague-random"))
                            waitLocation("map-battle", 10)
                        Else
                            $bIdle = True
                        EndIf
                        ContinueLoop
                    Else
                        Status("PvP Matches not yet available, attacking normally.", $LOG_INFORMATION)
                    EndIf
                EndIf

                If ($Attack_PVP_Attack_Random = True And isPixel(getPixelArg("astroleague-random"), 20) = True) And $bRandom = True Then
                    clickPoint(getPointArg("astroleague-random"))
                    waitLocation("map-battle", 10)
                    ContinueLoop
                EndIf

                If $Attack_PVP_Attack_Strongest = True Then 
                    clickDrag($g_aSwipeUpFast)
                    If _Sleep(2000) Then ExitLoop
                EndIf

                Local $aPoint = Attack_PVP_Find()
                Local $hTimer = TimerInit()
                While TimerDiff($hTimer) < 20000
                    If _Sleep(200) Then ExitLoop
                    
                    $aPoint = Attack_PVP_Find()
                    If isArray($aPoint) Then ExitLoop
                    clickDrag(Eval("g_aSwipe" & ($Attack_PVP_Attack_Strongest?"Down":"Up")))
                WEnd

                If isArray($aPoint) = True Then
                    clickPoint($aPoint)
                    waitLocation("map-battle", 10)
                Else
                    Status("Could not find a match.", $LOG_ERROR)
                    $bIdle = True
                    navigate("map")
                EndIf
            Case "map-battle"
                If $Attack_PVP_Runs <> 0 And $PVP_Runs >= $Attack_PVP_Runs Then ExitLoop
                
                Status("Entering match x" & $PVP_Runs+1, $LOG_PROCESS)
                If enterBattle() = True Then 
                    $bRandom = False
                    $PVP_Runs += 1
                    $PVP_Wins += 1
                    Cumulative_AddRatio("PVP Win Ratio (Astroleague)")
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

                If $Attack_PVP_Focus_Enemy = True And $bFocused = False Then 
                    If _Sleep(3500) Then ExitLoop
                    clickPoint(getPointArg("guided-4-mon-first"))
                    $bFocused = True
                EndIf

                If getLocation() = "battle" Then 
                    Local $hTimer = TimerInit()
                    Local $bInBattle = True
                    While TimerDiff($hTimer) < 500
                        If getLocation() <> "battle" Then 
                            $bInBattle = False
                        EndIf
                        If _Sleep(50) Then ExitLoop
                    WEnd
                    If $bInBattle = True Then clickBattle()
                EndIf

                If $hDraw = Null Then Status("Currently in battle.")
                If $hDraw <> Null Or isPixel(getPixelArg("astroleague-draw"), 20) = True Then
                    If $hDraw = Null Then $hDraw = TimerInit()
                    Status("Drawing match in " & ($Attack_PVP_Draw_Match - Int((TimerDiff($hDraw)/1000/60))) & " minutes.", $LOG_PROCESS)
                    If TimerDiff($hDraw) > ($Attack_PVP_Draw_Match*60*1000) Then
                        Status("Battle took too long, drawing the match.", $LOG_INFORMATION)
                        $PVP_Wins -= 1

                        Local $hTimer = TimerInit()
                        While TimerDiff($hTimer) < 5000
                            If _Sleep(200) Or isLocation("pvp-battle-end,battle-end") = True Then ExitLoop
                            clickPoint(getPointArg("astroleague-draw"))
                            clickPoint(getPointArg("astroleague-draw-confirm"))
                        WEnd
                        If isLocation("pvp-battle-end,battle-end") = False Then navigate("map", True)
                        $bIdle = True
                    EndIf
                EndIf
            Case "astroleague-victory"
                If clickUntil(getPointArg("tap"), "isLocation", "pvp-battle-end,battle-end", 20, 500) = True Then 
                    Status("You have won a match x" & $PVP_Wins & ".", $LOG_INFORMATION)
                EndIf
            Case "astroleague-defeat"
                If clickUntil(getPointArg("tap"), "isLocation", "pvp-battle-end,battle-end", 20, 500) = True Then
                    Status("You have lost a match.")
                    Cumulative_SubRatio_Num("PVP Win Ratio (Astroleague)")
                    $PVP_Wins -= 1
                EndIf
            Case "astroleague-refill", "buy-gem", "buy-gold"
                Status("Out of tickets, " & (($Attack_PVP_Idle_Time=0)?"stopping script.":"going into idle."))
                $bIdle = True
            Case "pvp-battle-end", "battle-end"
                Status("Match has ended.")
                clickPoint(getPointArg("astroleague-exit"))
                $bFocused = False
                $hDraw = Null
            Case "pause"
                Status("Unpausing the match.")
                clickPoint(getPointArg("battle-continue"))
            Case Else
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then
                    If waitLocation("battle,battle-auto,battle-boss", 5) = False Then
                        Status("Proceeding to Attack PVP.")
                        navigate("map", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd
    
    Log_Add("Attack PVP has ended.")
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc

;Helper functions
Func Attack_PVP_Refresh()
    If isPixel(getPixelArg("astroleague-free"), 10, CaptureRegion()) = True Then
        If clickWhile(getPointArg("astroleague-refresh"), "isLocation", "astroleague", 5, 500) = True Then
            Return clickUntil(getPointArg("astroleague-confirm"), "isLocation", "astroleague", 5, 500)
        EndIf
    EndIf
EndFunc

Func Attack_PVP_Find($aStarting = "705,470")
    Local $aFound = -1
    CaptureRegion()
    $aFound = findColor($aStarting, "1,-270", 0x638342, 10, 1, -1)
    If isArray($aFound) = True Then
        If isArray(findColor($aFound, "1,-40", 0xD9071D, 10, 1, -1)) = True Then
            Return Attack_PVP_Find("705," & ($aFound[1]-80)) ;ignore defeated
        Else
            Return $aFound
        EndIf
    EndIf
    Return -1
EndFunc