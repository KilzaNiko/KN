#include-once

Func Farm_Hero_Dungeons($bParam = True, $aStats = Null)
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Hero_Dungeons")[2]), "Farm_Hero_Dungeons")
    ;Runs, Dungeon Level, Guided Auto, Refill, Target Boss

    Log_Level_Add("Farm_Hero_Dungeons")

    Global $Status, $Attacks, $Astrogems_Used, $Astrogems_Used, $Win_Rate, $Hero, $Level_Dungeon
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
					CreateArr("Text",      	"Hero"), _
					CreateArr("Text",      	"Level_Dungeon"), _
					CreateArr("Ratio",      "Attacks",              "Farm_Hero_Dungeons_Attacks"), _
                    CreateArr("Ratio",      "Astrogems_Used",       "Farm_Hero_Dungeons_Refill") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

	Hero(StringFormat("%s", $Farm_Hero_Dungeons_Hero))
	Level_Dungeon(StringFormat("%s", $Farm_Hero_Dungeons_Dungeon_Level))
    Status("Farm Hero Dungeons has started.", $LOG_INFORMATION)

    Local $hAverage = Null
    ;navigate("map", True)

    While $g_bRunning = True
		getLocation()
        If _Sleep(200) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        Switch $sLocation
			Case "first-hero-dungeons", "second-hero-dungeons", "third-hero-dungeons", "fourth-hero-dungeons"
				Local $pAvailableAttacks = isPixel(getPixelArg("attacks-available-hero-dungeons"), 10, CaptureRegion())
				If $pAvailableAttacks = True Then
					Status("Selecting hero to farm.")

					Status(StringFormat("Looking for %s hero dungeons.", $Farm_Hero_Dungeons_Hero))
					Local $aHero = findHDungeons($Farm_Hero_Dungeons_Hero)
					If isArray($aHero) Then
						clickPoint($aHero)
						waitLocation($Farm_Hero_Dungeons_Hero & "-hero-dungeons", 3)
					EndIf

					Status(StringFormat("Looking for level %s dungeon.", $Farm_Hero_Dungeons_Dungeon_Level))
					Local $aLevel = findHLevel($Farm_Hero_Dungeons_Dungeon_Level)
					If isArray($aLevel) Then
						clickPoint($aLevel)
						waitLocation("map-battle", 2)
					EndIf
				Else
					Log_Add("No daily attacks available.")
					navigate("map")
					ExitLoop
				EndIf
			Case "map"
				If $Farm_Hero_Dungeons_Attacks <> 0 And $Attacks >= $Farm_Hero_Dungeons_Attacks Then ExitLoop
                navigate("hero-dungeons")
			Case "map-battle"
                Status("Entering battle x" & $Attacks+1, $LOG_PROCESS)
                If enterBattle() = True Then
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Attacks += 1
                    Cumulative_AddNum("Attacks (Farm Hero Dungeons)", 1)
                EndIf
            Case "battle-end"
                Status("Exiting to dungeon.")
                clickPoint(getPointArg("battle-end-exit-hero-dungeons"))
                waitLocation("first-hero-dungeons", 3)
            Case "defeat"
                Status("You have been defeated.", $LOG_INFORMATION)
                navigate("battle-end", True)
            Case "refill"
                If $Farm_Hero_Dungeons_Refill <> 0 And $Astrogems_Used+30 > $Farm_Hero_Dungeons_Refill Then ExitLoop
                Status("Refilling energy.")

                Local $iRefill = doRefill()
                If $iRefill = -1 Then
                    $bIdle = True
                    ContinueLoop
                EndIf
                If $iRefill = 1 Then $Astrogems_Used += 30
            Case "battle", "battle-auto"
                Status("Currently in battle.")

                Switch $Farm_Hero_Dungeons_Guided_Auto
                    Case "Full"
                        If $sLocation = "battle-auto" Then clickPoint(getPointArg("battle-auto"))
                        Local $aRound = getRound()

                        If $General_Guided_Auto_Active = False Then
                            Local $bEnemy = (isArray($aRound) = True And $aRound[0] = $aRound[1])
                            attackGuided($Farm_Hero_Dungeons_Guided_Auto & ($bEnemy?"-Attack":""))
                            ContinueLoop
                        Else
                            If Not(isArray($aRound) = True And $aRound[0] = $aRound[1]) Then
                                attackGuided($Farm_Hero_Dungeons_Guided_Auto)
                                ContinueLoop
                            EndIf
                        EndIf
                    Case "Semi"
                        attackGuided($Farm_Hero_Dungeons_Guided_Auto)
                EndSwitch

                If $sLocation = "battle" Then clickBattle()
            Case "pause"
                Status("In pause screen, unpausing.")
                clickPoint(getPointArg("battle-continue"))
            Case "battle-end-exp", "battle-sell", "battle-sell-item"
                navigate("battle-end")
            Case "battle-boss"
                If $Farm_Hero_Dungeons_Target_Boss = True Then
                    Status("Targeting boss.")
                    waitLocation("battle,battle-auto", 2)
                    If _Sleep($Delay_Target_Boss_Delay) Then ExitLoop
                    clickPoint("403, 175")
                EndIf
            Case "map-gem-full", "battle-gem-full"
                If $General_Sell_Gems = "" Then
                    Status("Gem inventory is full, stopping script.", $LOG_INFORMATION)
                    ExitLoop
                Else
                    Status("Gem inventory is full, selling gems: " & $General_Sell_Gems, $LOG_INFORMATION)
                    sellGems($General_Sell_Gems)
                EndIf
            Case "buy-gem", "buy-gold"
                Status("Not enough astrogems, stopping script.", $LOG_ERROR)
                ExitLoop
			Case "attacks-not-available"
				Sleep(2000)
				clickPoint(getPointArg("attacks-not-available-exit"))
				Status("No more attacks available")
				navigate("hero-dungeons")
				ExitLoop
            Case Else
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then
                    If waitLocation("battle,battle-auto,battle-boss", 5) = False Then
                        Status("Proceeding to Farm Hero Dungeons.")
                        navigate("map", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd

    Status("Farm Hero Dungeon has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc