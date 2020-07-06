#include-once

;Exclusive to the donator version

Func doDailies($bParam = True)

    Log_Level_Add("doDailies")
    Log_Add("Completing daily quests.")
    Local $bOutput = False

    While True
        If navigate("quests", True, 3) = True Then
            If isPixel(getPixelArg("daily-quests-inprogress"), 10, CaptureRegion()) = True Or isPixel(getPixelArg("daily-quests-completed")) = True Then
                collectQuest()
                $bOutput = True
                ExitLoop
            EndIf
            collectQuest()
        EndIf

        ;Map section (PVP, Stastone dungeon, Elemental dungeon, Catch 3 astromons)
        Local $aStats = $g_aStats
        Local $aValues = Stats_GetValues($g_aStats)

				_RunScript("Attack_PVP", CreateArr(1, 0, False, False, False, False, 0))
						If _Sleep(0) Then ExitLoop
				_RunScript("Farm_Starstone", CreateArr(1, "Normal", 1, False, "Any", 0, 0, 0, 0, True))
						If _Sleep(0) Then ExitLoop
				_RunScript("Farm_Starstone", CreateArr(1, "Elemental", 1, False, "Any", 0, 0, 0, 0, True))
						If _Sleep(0) Then ExitLoop
				_RunScript("Farm_Astromon", CreateArr(3, "slime", True, False, "Phantom Forest", "Normal", 1, "", 0))
						If _Sleep(0) Then ExitLoop

        Stats_Clear()

        $g_aStats = $aStats
        Stats_Values_Set($aValues)

        ;Village section (Send gold, Feed astromon, Upgrade gem)
        navigate("village", True)
        If doDailies_Send_Energy() = False Then ExitLoop
				If doDailies_Feed_Astromon() = False Then ExitLoop
        If doDailies_Gem_Upgrade() = False Then ExitLoop

				If $General_Dailies_Hero_Dungeons = True Then
					Log_Add("Farming Hero Dungeons.")
					_RunScript("Farm_Hero_Dungeons")
					If _Sleep(0) Then ExitLoop
				EndIf
				If $General_Dailies_Super_Festival = True Then
					doDailies_Super_Festival_Chest()
				EndIf

				Log_Add("Collecting quests.")
        collectQuest()

        $bOutput = True
        ExitLoop
    WEnd
    navigate("village")

    Log_Add("Daily Quest result: " & $bOutput & ".", $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func doDailies_Feed_Astromon()
    Log_Add("Feeding astromon.")
    If navigate("monsters", True, 3) = True Then
		clickPoint(getPointArg("monsters-recent"), 3)
		Sleep(20)
		clickPoint(getPointArg("monsters-grid-first"), 3)
		Sleep(20)
		If (clickUntil(getPointArg("monsters-level-up"), "isLocation", "monsters-level-up,monsters-level-up-max", 50, 100)) Then
			If getLocation() = "monsters-level-up-max" Then clickUntil("100,150","isLocation","monsters-level-up")
			If getLocation() = "monsters-level-up-max" Then clickUntil("187,150","isLocation","monsters-level-up")
				clickPoint(getPointArg("monsters-food-first"), 3)
				clickUntil(getPixelArg("monsters-feed-10"), "isPixel", getPixelArg("monsters-feed-10"), 10, 300, "CaptureRegion()")
				clickPoint(getPointArg("monsters-food-feed"), 3)
		EndIf
    EndIf
	Sleep(1000)
	Local $fPixel = isPixel(getPixelArg("confirm-feed"), 10, CaptureRegion())
	If $fPixel = True Then
		clickPoint("411,310")
		Return True
	Else
		Return True
	EndIf
    Return False
EndFunc

Func doDailies_Gem_Upgrade()
	Log_Add("Upgrading gems.")
	If navigate("manage", True, 3) = True Then
        CaptureRegion()
        Local $hTimer = TimerInit()
        While isArray(findImage("misc-recent")) = False
            If _Sleep(200) Or TimerDiff($hTimer) > 5000 Then ExitLoop
				clickPoint(getPointArg("manage-sort"))
				clickPoint(getPointArg("manage-sort-recent"))
        WEnd

        clickUntil(getPointArg("manage-sort-order"), "isPixel", getPixelArg("manage-oldest"), 5, 500, "CaptureRegion()")

        clickPoint(getPointArg("manage-grid-first"), 2, 200)
        If clickUntil(getPointArg("manage-upgrade"), "isLocation", "gem-upgrade-not-upgrading", 5, 300) Then
            If getLocation() = "dialogue-skip" Then skipDialogue()
				clickPoint(getPointArg("upgrade-confirm"), 4, 4500)
				clickWhile(getPointArg("manage-x"), "isLocation", "manage", 50, 200)

            Return True
        EndIf
    EndIf

    Return False
EndFunc

Func doDailies_Send_Energy()
    Log_Add("Sending energy to friends and searching astrogems available.")

    If navigate("friends", True, 3) Then
        clickWhile(getPointArg("friends-astrogems"), "isPixel", getPixelArg("top-friend-gem-redeem"), 200, 200, "CaptureRegion()")
        Return clickUntil(getPointArg("send-to-all"), "isPixel", getPixelArg("friends-send-to-all"), 10, 500, "CaptureRegion()")
		Sleep(1500)
		;Search astrogems available
		Local $avGem = findImage("friends-gem")
		While isArray($avGem) = True Then
			clickPoint($avGem)
		WEnd
    Else
        Log_Add("Could not navigate to friends.", $LOG_ERROR)
    EndIf

    Return False
EndFunc

Func doDailies_Close_Village_Interface()
    If getLocation() <> "village" Then Return False
    If clickWhile(getPointArg("village-missions-popup-close"), "isPixel", CreateArr(getPixelArg("village-missions-popup")), 5, 200, "CaptureRegion()") = False Then Return False
    If clickWhile(getPointArg("village-events-close"), "isPixel", CreateArr(getPixelArg("village-events")), 5, 200, "CaptureRegion()") = False Then Return False
    If clickWhile(getPointArg("village-pack-close"), "isPixel", CreateArr(getPixelArg("village-pack")), 5, 200, "CaptureRegion()") = False Then Return False
    Return True
EndFunc

Func doDailies_Super_Festival_Chest()
    Log_Add("Looking Super Festival.")
	navigate("map")
	If navigate("village", True, 3) = True Then
		Sleep(3000)
		doDailies_Close_Village_Interface()

		Local $sSuperFestival = findSuperFestival()

		If isArray($sSuperFestival) = False Then
			Log_Add("Super Festival not activated")
			Return False
		EndIf

		While isArray($sSuperFestival)
			clickPoint($sSuperFestival)
			waitLocation("super-fest-popup", 2)
			If isLocation("super-fest-popup") = True Then
				Log_Add("Looking Chest...")
				Sleep(2000)
				Local $sSuperFestival_Chest = findSuperFestival_Chest()
				If IsArray($sSuperFestival_Chest) Then
					Sleep(2000)
					clickPoint($sSuperFestival_Chest)
					Sleep(2000)
					clickPoint($sSuperFestival_Chest)
					Log_Add("Chest collected.")
					navigate("village")
					Return False
				Else
					Log_Add("Chest it was already collected.")
					Return False
				EndIf
			Else
				navigate("village")
			EndIf
		WEnd

	Else
		Log_Add("Could not navigate to village.", $LOG_ERROR)
	EndIf
EndFunc