#include-once

#cs 
    Function: Prevents getting stuck at an unknown/unspecified location for a script.
    Parameter: Reference to current location of the script.
#ce
Global $Common_Stuck_Timer = Null
Global $Common_Stuck_Unknown_Tap = Null
Global $Common_Stuck_Battle_Stuck = Null
Global $Common_Stuck_Unknown_Battle = Null
Func Common_Stuck(ByRef $sLocation)
    If ($sLocation = "battle-end" Or $sLocation = "map" Or $sLocation = "village") Then
        $Common_Stuck_Battle_Stuck = Null
        $Common_Stuck_Unknown_Battle = Null
    EndIf

    Switch $sLocation
        Case "unknown"
            CaptureRegion()
            If isArray(getRound()) = False Then

                If TimerDiff($Common_Stuck_Unknown_Tap) > 5000 Then
                    clickPoint(getPointArg("tap"))
                    $Common_Stuck_Unknown_Tap = TimerInit()
                EndIf

                $sLocation = getLocation()
                ContinueCase
            Else
                ;In battle, but location cannot be found because Auto button is stuck
                $Common_Stuck_Battle_Stuck = TimerInit()
                If TimerDiff($Common_Stuck_Unknown_Battle) > 6000 Then $Common_Stuck_Unknown_Battle = TimerInit()
                If TimerDiff($Common_Stuck_Unknown_Battle) > 5000 Then
                    Log_Add("Stuck in battle, trying to unstuck.", $LOG_DEBUG)
                    clickBattle()
                    If waitLocation("battle,battle-auto", 1) = False Then
                        ContinueCase ;In case frozen, proceed with normal stuck
                    EndIf
                    $Common_Stuck_Unknown_Battle = TimerInit()
                EndIf

                $Common_Stuck_Timer = Null
            EndIf
        Case "battle-auto", "battle"
                If $sLocation = "unknown" Then ContinueCase

                $Common_Stuck_Unknown_Battle = TimerInit()
                If TimerDiff($Common_Stuck_Battle_Stuck) > 6000 Then $Common_Stuck_Battle_Stuck = TimerInit()
                If TimerDiff($Common_Stuck_Battle_Stuck) > 5000 Then
                    $sLocation = getLocation()
                    If $sLocation = "battle" And TimerDiff($Common_Stuck_Battle_Stuck) > 60000 Then
                        ContinueCase
                    EndIf
                    
                    $Common_Stuck_Battle_Stuck = TimerInit()
                EndIf

        Case "lost-connection", "loading"
            If _Sleep(10) Then Return 0

            If $Common_Stuck_Timer = Null Then
                $Common_Stuck_Timer  = TimerInit()
            Else
                $sLocation = getLocation()
                Switch $sLocation
                    Case "lost-connection"
                        Log_Add("Lost connection detected, retrying.", $LOG_INFORMATION)
                        clickWhile(getPointArg("lost-connection-retry"), "isLocation", "lost-connection")
                        $sLocation = getLocation()
                    Case "another-device"
                        Log_Add("Another device detected!", $LOG_INFORMATION)

                        Switch $Config_Another_Device_Timeout
                            Case -1
                                Log_Add("Restart time set to Never, Stopping script.", $LOG_INFORMATION)
                                Stop()
                            Case 0
                                Log_Add("Restart time set to Immediately", $LOG_INFORMATION)
                            Case Else
                                Local $iMinutes = $Config_Another_Device_Timeout
                                Log_Add("Restart time set to " & $iMinutes & " minutes.", $LOG_INFORMATION)
                                
                                Local $hTimer = TimerInit()
                                $g_bAntiStuck = True
                                While TimerDiff($hTimer) < ($iMinutes*60000)
                                    Local $iSeconds = Int(($iMinutes*60) - (TimerDiff($hTimer)/1000))
                                    Status("Restarting in: " & getTimeString($iSeconds))
                                    If _Sleep(1000) Then ExitLoop
                                WEnd
                                $g_bAntiStuck = False
                        EndSwitch
                EndSwitch
            EndIf
        Case Else
            $Common_Stuck_Timer = Null
    EndSwitch
EndFunc