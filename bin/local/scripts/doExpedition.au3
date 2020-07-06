#include-once

Func doExpedition()
    Log_Level_Add("doExpedition")
    Local $bResult = False

    Local $iCounter = 1
    Local $hTimer = TimerInit()
    While TimerDiff($hTimer) < 120000
        If _Sleep(1000) Then ExitLoop
        Local $sLocation = getLocation()
        Switch $sLocation
            Case "association"
                Log_Add("Searching for an expedition.")
                Local $aPoint = Expedition_FindExplore()
                If isArray($aPoint) = True Then
                    clickPoint($aPoint)
                    waitLocation("association-expedition", 5)
                Else
                    Log_Add("Expedition Complete.")
                    $bResult = True
                    ExitLoop
                EndIf
            Case "association-expedition"
                Select
                    Case findImage("expedition-complete") <> -1
                        clickPoint("702,463")
                    Case findImage("expedition-unknown") <> -1
                        clickPoint("698,380")
                    Case findImage("expedition-explore") <> -1
                        Switch $Expedition_Use_Luck_Item
                            Case $EXPEDITION_LUCK_LOW
                                clickUntil("652,315", "isPixel", CreateArr("652,315,0x37F09D"), 10, 1000, "CaptureRegion()")
                            Case $EXPEDITION_LUCK_MEDIUM
                                clickUntil("702,315", "isPixel", CreateArr("702,315,0x37F09D"), 10, 1000, "CaptureRegion()")
                            Case $EXPEDITION_LUCK_HIGH
                                clickUntil("752,315", "isPixel", CreateArr("752,315,0x37F09D"), 10, 1000, "CaptureRegion()")
                        EndSwitch

                        Switch $Expedition_Explore_Time
                            Case $EXPEDITION_HOUR_2
                                clickUntil("364,155", "isPixel", CreateArr("344,155,0x34F09A"), 10, 1000, "CaptureRegion()")
                            Case $EXPEDITION_HOUR_4
                                clickUntil("452,155", "isPixel", CreateArr("432,155,0x34F09A"), 10, 1000, "CaptureRegion()")
                            Case $EXPEDITION_HOUR_8
                                clickUntil("540,155", "isPixel", CreateArr("520,155,0x34F09A"), 10, 1000, "CaptureRegion()")
                        EndSwitch

                        clickWhile(getPointArg("expedition-autoselect"), "isPixel", CreateArr("399,248,0x7D624D"), 5, 200, "CaptureRegion()")
                        clickPoint(getPointArg("expedition-explore"))
                    Case findImage("expedition-exploring") <> -1
                        Cumulative_AddNum("Collected (Expedition)", 1)
                        Log_Add("Explored expedition x" & $iCounter, $LOG_INFORMATION)
                        $iCounter += 1

                        navigate("association")
                    Case Else
                        clickPoint("702,463")
                EndSelect
            Case "refill"
                doRefill()
            Case "map"
                navigate("association", True)
            Case "unknown"
                If waitLocation("association,association-expedition", 2) = False And isPixel("399,109,0xBBB6E5", 10, CaptureRegion()) = True Then
                    clickPoint("698,380")
                Else
                    ContinueCase                
                EndIf
            Case Else
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then
                    If waitLocation("association-expedition,association", 5) = False Then
                        If navigate("association", True, 2) = False Then
                            ExitLoop
                        EndIf
                    EndIf
                EndIf
        EndSwitch
    WEnd
    navigate("map")

    Log_Level_Remove()
    Return $bResult
EndFunc

Func Expedition_FindExplore()
    Local $aOutput = -1 ;End with point for explore/complete button
    Local Const $SWIPE = [675,169,375,169] ;Swipe Left

    If getLocation() <> "association" Then 
        If navigate("association", True, 2) = False Then Return $aOutput
    EndIf

    Local $hTimer = TimerInit()
    Local $aPoint[2] = [Null, Null]
    While TimerDiff($hTimer) < 20000
        Local $aPoints = findImageMultiple("expedition-explored")
        If $aPoints <> -1 Then
            For $i = 0 To UBound($aPoints)-1
                If isPixel(CreateArr($aPoints[$i][0], 364, 0x203909), 5, CaptureRegion()) = False Then
                    $aPoint[0] = $aPoints[$i][0]
                    $aPoint[1] = $aPoints[$i][1]
                    ExitLoop(2)
                EndIf
            Next
        EndIf

        If findImage("expedition-end") <> -1 Then ExitLoop
        clickDrag($SWIPE)
        If _Sleep(1500) Then ExitLoop
    WEnd

    If $aPoint[0] <> Null Then $aOutput = $aPoint

    Return $aOutput
EndFunc