#include-once

#cs
    Function: Script to navigate locations in MSL game.
    Parameters:
        $sLocation: One of the locations.
        $bForceSurrender: If in battle will surrender the match
        $iAttempt: Number of attempts
    Returns:
        if success, true
        if fail, false
#ce
Func navigate($sFind, $bForceSurrender = False, $iAttempt = 1)
    Log_Level_Add("navigate")
    Log_Add("Navigating to " & $sFind & ".")

    $sFind = StringStripWS(StringLower($sFind), $STR_STRIPALL)

    While $iAttempt > 0
        $iAttempt -= 1

        If _Sleep(0) Then ExitLoop
        If $sFind = getLocation() Then ExitLoop

        Local $hTimer = TimerInit()
        While TimerDiff($hTimer) < $Delay_Navigation_Timeout*1000
            If _Sleep(300) Or $sFind = getLocation() Then ExitLoop
            If HandleCommonLocations(getLocation()) = True Then ContinueLoop

            Switch getLocation()
                Case "another-device"
                    Log_Add("Another device detected!", $LOG_INFORMATION)

                    Switch $Config_Another_Device_Timeout
                        Case -1
                            Log_Add("Restart time set to Never, Stopping script.", $LOG_INFORMATION)
                            Stop()
                        Case 0
                            Log_Add("Restart time set to Immediately", $LOG_INFORMATION)
                            RestartGame()
                        Case Else
                            Local $iMinutes = $Config_Another_Device_Timeout
                            Log_Add("Restart time set to " & $iMinutes & " minutes.", $LOG_INFORMATION)

                            Local $hTimer = TimerInit()
                            $g_bAntiStuck = False
                            While TimerDiff($hTimer) < ($iMinutes*60000)
                                Local $iSeconds = Int(($iMinutes*60) - (TimerDiff($hTimer)/1000))
                                Status("Restarting in: " & getTimeString($iSeconds))
                                If (_Sleep(1000)) Then ExitLoop
                            WEnd
                            $g_bAntiStuck = True
                            RestartGame()
                    EndSwitch
                Case "defeat"
                    clickPoint(getPointArg("battle-give-up"))
                    ContinueLoop
                Case "catch-success"
                    If $bForceSurrender = True Then
                        SendBack()
                        ContinueLoop
                    EndIf
                    If $sFind <> "catch-mode" Then ExitLoop(2)
                Case "battle", "battle-auto"
                    If $bForceSurrender = True Then
                        clickPoint(getPointArg("battle-pause"))
                        ContinueLoop
                    EndIf
                    If $sFind <> "catch-mode" Then ExitLoop(2)
                Case "pause"
                    If $bForceSurrender = True Then
                        clickWhile(getPointArg("battle-give-up"), "isLocation", "pause,unknown,popup-window", 60, 500)
                        ContinueLoop
                    EndIf
                    If $sFind <> "catch-mode" Then ExitLoop(2)
                Case "battle-end-exp", "battle-sell", "astroleague-defeat", "astroleague-victory", "champion-defeat", "champion-victory"
                    clickWhile(getPointArg("tap"), "isLocation", "battle-end-exp,battle-sell,astroleague-defeat,astroleague-victory,champion-defeat,champion-victory,unknown", 100, 100)
                    ContinueLoop
                Case "battle-sell-item"
                    clickPoint(getPointArg("battle-sell-item-cancel"))
                    clickPoint(getPointArg("battle-sell-item-okay"))
                    ContinueLoop
                Case "unknown"
                    If Mod(Int(TimerDiff($hTimer)/1000)+1, 8) = 0 Then SendBack()
                    If Mod(Int(TimerDiff($hTimer)/1000)+1, 5) = 0 Then clickPoint(getPointArg("tap"))
                    ContinueLoop
            EndSwitch

            Local $sLocation = getLocation()
            If $sFind = $sLocation Then ContinueLoop
            ;Handles normal locations
            Switch $sFind
                Case "village"
                    Switch $sLocation
                        Case "battle-end", "pvp-battle-end"
                            clickPoint(getPointArg("battle-end-airship"))
                            If waitLocation("loading,village", 5) Then clickPoint(getPointArg("astroleague-exit"))
                        Case "hourly-reward"
                            clickPoint(getPointArg("get-reward"))
                        Case Else
                            goBack()
                    EndSwitch
                Case "map"
                    Switch $sLocation
                        Case "map-stage"
                            clickPoint(getPointArg("map-stage-close"))
                        Case "battle-end", "pvp-battle-end"
                            clickPoint(getPointArg("battle-end-map"))
                            If waitLocation("loading,map", 5) Then clickPoint(getPointArg("astroleague-exit"))
                        Case "village"
                            clickPoint(getPointArg("village-play"))
                            waitLocation("loading,bingo,unknown,dialogue-skip", 5)
                        Case Else
                            goBack()
                    EndSwitch
                Case "battle-end"
                    Switch $sLocation
                        Case "popup-window", "battle-sell-item"
                            goBack()
                        Case "battle-end-exp", "unknown", "battle-sell"
                            clickPoint(getPointArg("tap"))
                            clickPoint("742,477")
                    EndSwitch
                Case "golem-dungeons"
                    Switch $sLocation
                        Case "map"
                            Local $aPoint = findMap("Ancient Dungeon")
                            If isArray($aPoint) = True Then
                                clickPoint($aPoint)
                                waitLocation("ancient-colossus-dungeon", 5)
                            EndIf
                        Case "ancient-colossus-dungeon"
                            clickPoint("200,250")
                            waitLocation("golem-dungeons", 5)
                        Case "map-battle", "autobattle-prompt", "dialogue", "monsters-astromon", "popup-window"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "dragon-dungeons"
                    Switch $sLocation
                        Case "map"
                            Local $aPoint = findMap("Dragon Dungeon")
                            If isArray($aPoint) = True Then clickPoint($aPoint)
                        Case "map-battle", "autobattle-prompt", "dialogue", "monsters-astromon", "popup-window"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "quests"
                    Switch $sLocation
                        Case "village"
                            clickPoint(getPointArg("village-quests"))
                            waitLocation("quests", 5)
                        Case "autobattle-prompt", "popup-window", "dialogue"
                            goBack()
                        Case Else
                            If navigate("village", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "catch-mode"
                    If isArray(findImage("misc-no-astrochips")) = True Then ExitLoop

                    Switch $sLocation
                        Case "battle-auto"
                            Local $aRound = getRound()
                            clickPoint(getPointArg("battle-auto"))
                            clickPoint(getPointArg("battle-catch"))

                            If waitLocation("unknown,catch-mode,battle", 5, False) = "unknown" Then
                                Local $aRound2 = getRound()
                                If isArray($aRound) = True And isArray($aRound2) = True Then
                                    If $aRound[0] <> $aRound2[0] Then
                                        waitLocation("battle-auto,battle", 5)
                                        clickPoint(getPointArg("battle-catch"))
                                        waitLocation("catch-mode", 5)
                                    EndIf
                                EndIf
                            EndIf
                        Case "battle", "catch-success"
                            clickPoint(getPointArg("battle-catch"))
                        Case "pause"
                            clickPoint(getPointArg("battle-continue"))
                        Case "battle-end-exp", "battle-sell", "battle-sell-item", "battle-end"
                            ExitLoop
                        Case Else
                            goBack()
                    EndSwitch
                Case "monsters"
                    Switch $sLocation
                        Case "village"
                            clickPoint(getPointArg("village-monsters"))
                        Case "battle-end", "pvp-battle-end"
                            clickPoint(getPointArg("battle-end-monsters"))
                        Case "monsters-level-up", "manage", "monsters-evolution", "awakened-success"
                            clickPoint(getPointArg("manage-x"))
                        Case "popup-window", "monsters-astromon", "monsters-awaken", "monsters-evolve", "gem-upgrade-not-upgrading", _
                                "gem-consecutive-upgrades", "release-confirm", "release-reward"
                            goBack()
                        Case Else
                            If navigate("village", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "manage"
                    Switch $sLocation
                        Case "monsters"
                            clickPoint(getPointArg("monsters-manage"))
                        Case "gem-upgrade-not-upgrading", "gem-consecutive-upgrades"
                            goBack()
                        Case "popup-window"
                            If isPixel("748,151,0xFFD428", 10, CaptureRegion()) = True Then
                                clickPoint(CreateArr(362, 117))
                            Else
                                ContinueCase
                            EndIf
                        Case Else
                            If navigate("monsters", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "dungeons"
                    Switch $sLocation
                        Case "guardian-dungeons", "starstone-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons", "extra-dungeons", "dungeon-info"
                            If $sLocation = "special-guardian-dungeons" Then clickDrag($g_aDungeonsSwipeDown)
                            $sFind = $sLocation
                        Case "map"
                            Local $aPoint = findMap("Dungeons")
                            If isArray($aPoint) Then
                                clickPoint($aPoint)
                                waitLocation("startstone-dungeons,extra-dungeons", 2)
                            EndIf
                        Case "map-battle", "popup-window", "autobattle-prompt"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "guardian-dungeons", "starstone-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons"
                    Switch $sLocation
                        Case "starstone-dungeons", "extra-dungeons"
                            Local $aPoint = StringSplit(getPointArg("dungeons-" & StringSplit($sFind, "-", 2)[0]), ",", 2)
                            If $sLocation = "extra-dungeons" Then $aPoint[1] += 64

                            Switch $sFind
                                Case "special-guardian-dungeons"
                                    clickDrag($g_aDungeonsSwipeUp)
                                    If _Sleep(1000) Then ExitLoop

                                    $aPoint = findImage("map-special-dungeon",95,0,70,335,215,150,True,True)

                                    If isArray($aPoint) = False Then ExitLoop
                                    clickPoint($aPoint)
                                Case Else
                                    clickPoint($aPoint)
                            EndSwitch
                        Case "guardian-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons", "dungeon-info"
                            clickPoint(getPointArg("dungeons-starstone"))
                        Case Else
                            If navigate("dungeons", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "astroleague"
                    Switch $sLocation
                        Case "map"
                            Local $aPoint = findMap("Astromon League")
                            If isArray($aPoint) Then
                                clickPoint($aPoint)
                                waitLocation("leagues", 2)
                            EndIf
                        Case "leagues"
                            clickPoint(getPointArg("leagues-astromon"))
                            waitLocation("astroleague", 2)
                        Case "map-battle", "popup-window"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "championleague"
                    Switch $sLocation
                        Case "map"
                            Local $aPoint = findMap("Astromon League")
                            If isArray($aPoint) Then
                                clickPoint($aPoint)
                                waitLocation("leagues", 2)
                            EndIf
                        Case "leagues"
                            clickPoint(getPointArg("leagues-champion"))
                            waitLocation("astroleague", 2)
                        Case "astroleague"
                            $sFind = "astroleague"
                            ExitLoop
                        Case "map-battle", "popup-window"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "bingo"
                    Switch $sLocation
                        Case "village"
                            clickPoint(getPointArg("bingo-icon"))
                            waitLocation("bingo,bingo-complete", 5)
                        Case "bingo-complete"
                            $sFind = $sLocation
                        Case "popup-window"
                            goBack()
                        Case Else
                            If navigate("village", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "friends"
					Switch $sLocation
                        Case "village"
                            clickUntil(getPointArg("tab-expand"), "isPixel", CreateArr("139,249,0xF9C749", 20), 5, 100, "CaptureRegion()")
                            clickPoint(getPointArg("tab-friends"))
						Case Else
							If isPixel(getPixelArg("friend-requests-active"), 10, CaptureRegion()) = True Then
								Sleep(400)
								clickPoint(getPointArg("friends-list"), 2, 150)
								ExitLoop
						    ElseIf isPixel(getPixelArg("shield-friend-list"), 10, CaptureRegion()) = True Then
								ExitLoop
						    Else
								If navigate("village", $bForceSurrender) = False Then ExitLoop
							EndIf
                    EndSwitch
                Case "toc"
                    Switch $sLocation
                        Case "map"
                            Local $aPoint = findMap("Tower of Chaos")
                            If isArray($aPoint) Then
                                clickPoint($aPoint)
                                waitLocation("toc", 2)
                            EndIf
                        Case "popup-window", "refill", "map-battle", "autobattle-prompt"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "shop"
                    Switch $sLocation
                        Case "village"
                            Local $iVillage = getVillagePos()
                            If $iVillage = -1 Then
                                navigate("map", $bForceSurrender)
                                ContinueLoop
                            Else
                                Local $aTrees = StringSplit($g_aVillageTrees[$iVillage], "|", $STR_NOCOUNT)
                                If isArray($aTrees) = True Then clickPoint($aTrees[UBound($aTrees)-1])
                            EndIf
                        Case "popup-window"
                            goBack()
                        Case Else
                            If navigate("village", $bForceSurrender) = False Then Exitloop
                    EndSwitch
                Case "association"
                    Switch $sLocation
                        Case "map"
                            Local $aPoint = findMap("Astromasters Association")
                            If isArray($aPoint) Then
                                clickPoint($aPoint)
                                waitLocation("association", 2)
                            EndIf
                        Case "association-expedition", "popup-window"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = False Then ExitLoop
                    EndSwitch
                Case "village-summon"
                    Switch $sLocation
                        Case "village"
                            clickPoint(getPointArg("village-summon"))
                            waitLocation("village-summon", 5)
                        Case Else
                            If navigate("village", $bForceSurrender) = False Then ExitLoop
					EndSwitch
				Case "hero-dungeons"
                    Switch $sLocation
                        Case "map"
                            Local $aPoint = findMap("hero-dungeons")
                            If isArray($aPoint) Then
                                clickPoint($aPoint)
								waitLocation("first-hero-dungeons,second-hero-dungeons,third-hero-dungeons,fourth-hero-dungeons", 3)
                            EndIf
						Case "first-hero-dungeons", "second-hero-dungeons", "third-hero-dungeons", "fourth-hero-dungeons"
							$sFind = $sLocation
                        Case "popup-window", "refill", "map-battle", "autobattle-prompt", "unknown"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = False Then ExitLoop
					EndSwitch
				Case "inbox"
                    Switch $sLocation
                        Case "village"
                            clickUntil(getPointArg("tab-expand"), "isPixel", CreateArr("139,249,0xF9C749", 20), 5, 100, "CaptureRegion()")
                            clickPoint(getPointArg("tab-inbox"))
                        Case Else
                            If clickUntil(getPointArg("inbox"), "isLocation", "inbox", 3, 200) = False Then
                                If navigate("village", $bForceSurrender) = False Then ExitLoop
                            EndIf
					EndSwitch
				Case "friend-gifts"
                    Switch $sLocation
                        Case "village"
                            clickUntil(getPointArg("tab-expand"), "isPixel", CreateArr("139,249,0xF9C749", 20), 5, 100, "CaptureRegion()")
                            clickPoint(getPointArg("tab-inbox"))
							Sleep(700)
						Case "inbox"
							clickPoint(getPointArg("friend-gifts"))
							waitLocation("friend-gifts", 20)
                        Case Else
                            If clickUntil(getPointArg("friend-gifts"), "isLocation", "inbox", 3, 200) = False Then
                                If navigate("village", $bForceSurrender) = False Then ExitLoop
                            EndIf
                    EndSwitch
                Case Else
                    Log_Add($sFind & " is not navigable.", $LOG_ERROR)
                    ExitLoop
            EndSwitch
        WEnd
    WEnd

	If $sFind = "friends" Then
		$sFind = "map-battle"
	EndIf

    Local $bOutput = (getLocation() = $sFind)
    Log_Add("Navigating result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc