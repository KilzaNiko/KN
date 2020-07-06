#include-once

;Exclusive to the donator version
Func doBingo()
    Log_Level_Add("doBingo")
    Local $bOutput = False
    Local $hTimer = TimerInit()

    Log_Add("Collecting bingo.")
    While TimerDiff($hTimer) < 20000
        If _Sleep(300) Then ExitLoop
        Switch getLocation()
            Case "bingo"
                clickWhile(getPointArg("bingo-accept-all"), "isPixel", CreateArr(getPixelArg("bingo-accept-all")), 5, 200, "CaptureRegion()")
            Case "bingo-complete-popup"
                clickPoint(getPointArg("bingo-accept"))
            Case "bingo-get-rewards"
                closeWindow()
            Case "bingo-complete"
                Log_Add("Completed Bingo.", $LOG_INFORMATION)
                closeWindow()
                $bOutput = True
                ExitLoop
            Case "bingo-event"
                Log_Add("Completed Bingo.", $LOG_INFORMATION)
                For $i = 0 To 6
                    clickPoint(270+($i*75) & ",407", 3, 100)
                Next
                $bOutput = True
                ExitLoop
            Case "unknown"
            Case Else
                If HandleCommonLocations(getLocation()) = False And navigate("bingo", False, 3) = False Then ExitLoop
        EndSwitch
    WEnd
    navigate("village")

    Log_Add("Bingo result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc