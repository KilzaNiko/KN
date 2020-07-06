#include-once

Func doHourly()
    Log_Level_Add("doHourly")
    Log_Add("Performing hourly tasks")

    Local $hTimer = TimerInit()
    Local $aTurn = ["Collect_Hiddens", "Click_Nezz", "Complete_Bingo", "Collect_Inbox", "Buy_First_Item", "Check_Exotic_Festival", "Get_Daily_Eggs_Trinkets", "Gold_Dungeon", "Special_Guardian_Dungeon", "Daily_Quests"]
    For $i = 0 To UBound($aTurn)-1
        If _Sleep(100) Then ExitLoop
        If Eval("Hourly_" & $aTurn[$i]) = False Then ContinueLoop
        Local $bResult = Call("Hourly_" & $aTurn[$i])
        Log_Add($aTurn[$i] & " result: " & $bResult, $LOG_DEBUG)
    Next

    Cumulative_AddNum("Collected (Hourly)", 1)

    Log_Level_Remove()
    Return True
EndFunc

;----------------------------------------------
;Helper functions

Func Hourly_Close_Village_Interface()
    If getLocation() <> "village" Then Return False
    If clickWhile(getPointArg("village-missions-popup-close"), "isPixel", CreateArr(getPixelArg("village-missions-popup")), 5, 200, "CaptureRegion()") = False Then Return False
    If clickWhile(getPointArg("village-events-close"), "isPixel", CreateArr(getPixelArg("village-events")), 5, 200, "CaptureRegion()") = False Then Return False
    If clickWhile(getPointArg("village-pack-close"), "isPixel", CreateArr(getPixelArg("village-pack")), 5, 200, "CaptureRegion()") = False Then Return False
    Return True
EndFunc

Func Hourly_Get_Village_Pos()
    Local $iPos = -1
    Local $iTries = 0

    If getLocation() <> "village" Then navigate("village")
    While $iPos = -1 And $iTries < 5
        Hourly_Close_Village_Interface()

        $iPos = getVillagePos()
        If ($iPos = -1) Then

            Log_Add("Airship position not found. Reloading village.", $LOG_ERROR)

            navigate("map")
            navigate("village")

            If _Sleep(2000) Then ExitLoop
            Hourly_Close_Village_Interface()
        Else
            Log_Add("Airship position detected: " & $iPos & ".", $LOG_DEBUG)
        EndIf
        $iTries += 1
    WEnd
	Return $iPos
EndFunc

;----------------------------------------------

Func Hourly_Collect_Hiddens()
    If isLocation("village,quests,monsters,monsters-evolution") = True Then navigate("map")
    Local $iPos = Hourly_Get_Village_Pos()
    If $iPos = -1 Then Return False

    Log_Add("Collecting hidden rewards.")
    Local $aPoints = StringSplit($g_aVillageTrees[$iPos], "|", 2)
    For $i = 0 To UBound($aPoints)-2
        If _Sleep(100) Then Return False

        Log_Add("Collecting hidden #" & $i+1)

        Local $hTimer = TimerInit()

        Local $bLog = $g_bLogEnabled
        $g_bLogEnabled = False
        While TimerDiff($hTimer) < 5000
            If _Sleep(200) Then Return False
            Switch getLocation()
                Case "village"
                    Hourly_Close_Village_Interface()
                    clickPoint($aPoints[$i])
					Sleep($Delay_Clicks_Collect_Hiddens_Delay)
                Case "hourly-reward"
                    Cumulative_AddNum("Collected (Hidden Trees)", 1)
                    navigate("village")
                    ExitLoop
                Case Else
                    If navigate("village", False, 3) = False Then Return False
            EndSwitch
        WEnd
        $g_bLogEnabled = $bLog
    Next
    Return True
EndFunc

Func Hourly_Click_Nezz()
    Local $iPos = Hourly_Get_Village_Pos()
    If $iPos = -1 Then Return False

    Local $aNezzLoc = getArg($g_aNezzPos, "village-pos" & $iPos)
    If ($aNezzLoc <> -1) Then
        Log_Add("Attempting to click nezz.")
        For $aNezz In StringSplit($aNezzLoc, "|", $STR_NOCOUNT)
            clickPoint($aNezz, 1)

            If _Sleep(500) Then Return False

            Local $sLocation = getLocation()
            If $sLocation <> "village" Then

                If $sLocation = "dialogue-skip" Then
                    Log_Add("Found nezz", $LOG_INFORMATION)
                    Cumulative_AddNum("Collected (Nezz)", 1)
                    navigate("village")
                    Return True
                EndIf

                navigate("village")
            EndIf
        Next
    EndIf

    Return False
EndFunc

Func Hourly_Buy_First_Item()
    Log_Add("Buying first item in shop.")
    If navigate("shop", False, 3) = True Then
        clickWhile(getPointArg("shop-buy"), "isLocation", "shop", 5, 200)
        clickUntil(getPointArg("shop-buy-confirm"), "isLocation", "shop", 3, 200)

		If $Hourly_Buy_Secret_Egg = True Then
			Log_Add("Search egg in shop")
			Local $sEgg = "secret-egg"
			Local $aEgg = findShop($sEgg)
			If isArray($aEgg) = True Then
				Log_Add("Egg found!")
				clickPoint($aEgg)
				clickPoint(getPointArg("shop-buy"))

				Local $sLocation = getLocation()
				If $sLocation = "refill-confirm" Then
					Log_Add("You don't have enough money")
					navigate("village")
				Else
					clickPoint(getPointArg("shop-buy-confirm"))
				EndIf
				waitLocation("shop", 10)
			Else
				Log_Add("Egg not found!")
			EndIf
		EndIf
        Return True
    Else
        Log_Add("Could not navigate to shop.", $LOG_ERROR)
    EndIf
    Return False
EndFunc

Func Hourly_Collect_Inbox()
	Log_Add("Collecting inbox.")
	navigate("inbox")
	Status("Collecting inbox.")
	If isLocation("inbox") = True Then
		Sleep(700)
		clickPoint(getPointArg("inbox-accept-all"))
		Sleep($Delay_Confirm_Button_Friend_Gifts_Delay) ;Time of wait for click in the confirm button
		clickPoint(getPointArg("inbox-accept-all-confirm"))
	EndIf

	Sleep(1000)

	Log_Add("Collecting Friend Gifts.")
	navigate("friend-gifts")
	Status("Collecting Friend Gifts.")
	If isLocation("friend-gifts") = True Then
		Sleep(100)
		clickPoint(getPointArg("inbox-accept-all"))
	EndIf

	navigate("village")
	Return False
EndFunc

Func Hourly_Complete_Bingo()
    Return doBingo()
EndFunc

Func Hourly_Check_Exotic_Festival()
    Log_Add("Collecting Festival Ticket.")

    If isPixel(getPixelArg("exotic-fest-ticket-available"), 10, CaptureRegion()) or getLocation() = "exotic-festival" Then
        If clickUntil(getPointArg("exotic-festival-tickets"),"isLocation","exotic-festival,unknown") = True Then
            Do
                If _Sleep(200) Then Return False

                If getLocation() = "exotic-ticket-claim" Then clickUntil(getPointArg("exotic-ticket-claim-close"),"isLocation","exotic-festival")
                Local $aPoint = findImage("misc-exotic-ticket", 90, 2000)
                If isArray($aPoint) Then
                    $aPoint[1] += 55
                    If clickUntil($aPoint, "isLocation", "exotic-ticket-claim") Then
                        clickUntil(getPointArg("exotic-ticket-claim-close"),"isLocation","exotic-festival,unknown")
                    EndIf
                    Cumulative_AddNum("Collected (Exotic/Festival Ticket)", 1)
                EndIf
            Until(isArray($aPoint) = False)
        EndIf
    EndIf

    navigate("village")
    Return True
EndFunc

Func Hourly_Get_Daily_Eggs_Trinkets()
    Log_Add("Collecting daily eggs/trinkets.")

    If navigate("village-summon", False, 3) = True Then
        If isPixel(getPixelArg("village-summon-egg"), 10, CaptureRegion()) = True Then
            clickUntil(getPixelArg("village-summon-egg"), "isLocation", "summon-astromon-popup", 20, 1000)
        EndIf
		clickPoint(getPointArg("village-summon-trinket"))
        If isPixel(getPixelArg("village-summon-egg"), 10, CaptureRegion()) = True Then
            clickUntil(getPixelArg("village-summon-egg"), "isLocation", "village-summon", 20, 1000)
        EndIf
    Else
        Log_Add("Could not navigate to village summons.", $LOG_ERROR)
        Return False
    EndIf

    navigate("village")
    Return True
EndFunc

Func Hourly_Gold_Dungeon()
    Return doGoldDungeon()
EndFunc

Func Hourly_Special_Guardian_Dungeon()
    Return doSpecialGuardian()
EndFunc

Func Hourly_Daily_Quests()
    Return doDailies()
EndFunc