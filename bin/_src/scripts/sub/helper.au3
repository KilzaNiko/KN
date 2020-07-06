#include-once

#cs
	Function: Retrieves data of current gem on screen. Works during battle-sell-item location
	Parameters:
		$bCapture: Save unknown gems
	Returns: [grade, shape, type, stat, sub, price]
		- If one of the items are missing then return -1
#ce
Func getGemData($bCapture = True)
	Local $aGemData[6] = ["-", "-", "-", "-", "-", "-"] ;Stores current gem data
	If (isLocation("battle-sell-item")) Then
		Select ;grade
			Case isPixel("399,175,0xF39C72|399,164,0xF769BA|406,144,0x261612")
				$aGemData[0] = "EGG"
				Return $aGemData
			Case isPixel("399,175,0x9A450C|399,164,0xF5D444|406,144,0xFDF953", 20)
				$aGemData[0] = "GOLD"
				Return $aGemData
			Case isPixel("406,144,0x261612")
				$aGemData[0] = 1
			Case isPixel("413,144,0x261612")
				$aGemData[0] = 2
			Case isPixel("418,144,0x261612")
				$aGemData[0] = 3
			Case isPixel("423,144,0x261612")
				$aGemData[0] = 4
			Case isPixel("428,144,0x261714")
				$aGemData[0] = 5
			Case Else
				$aGemData[0] = 6
		EndSelect

		Select ;shape
			Case Not(isPixel("413,159,0x261612"))
				$aGemData[1] = "S"
			Case Not(isPixel("414,168,0x261612"))
				$aGemData[1] = "D"
			Case Else
				$aGemData[1] = "T"
		EndSelect

		For $strType In $g_aGem_pixelTypes ;types
			Local $sType = StringSplit($strType, ":", 2)
			If (isPixel($sType[1], 20)) Then
				$aGemData[2] = $sType[0]
				ExitLoop
			EndIf
		Next

		For $strStat In $g_aGem_pixelStats ;main stats
			Local $aStat = StringSplit($strStat, ":", 2)
			If (isPixel($aStat[1], 20)) Then
				$aGemData[3] = $aStat[0]
				ExitLoop
			EndIf
		Next

		If (isArray(findColor("350,329", "50,1", "0xE9E3DE", 20))) Then ;number of substats
			$aGemData[4] = "4"
		ElseIf (isArray(findColor("350,311", "50,1", "0xE9E3DE", 20))) Then
			$aGemData[4] = "3"
		ElseIf (isArray(findColor("350,296", "50,1", "0xE9E3DE", 20))) Then
			$aGemData[4] = "2"
		ElseIf (isArray(findColor("350,329", "50,1", "0xE9E3DE", 20))) Then
			$aGemData[4] = "1"
		EndIf

		;Handles if gem is unknown
		If (($aGemData[0] = "-") Or ($aGemData[1] = "-") Or ($aGemData[2] = "-") Or ($aGemData[3] = "-") Or ($aGemData[4] = "-")) Then
			$g_sErrorMessage = "getGemData() => Something is missing: " & _ArrayToString($aGemData)
			Return -1
		EndIf

		$aGemData[5] = getGemPrice($aGemData)
	EndIf
	Return $aGemData
EndFunc

#cs
	Function: Returns gem price using the data passed in
	Parameters:
		gemData: [Array] [grade, shape, type, stat, sub]
	Returns: (Int) Gem price
#ce
Func getGemPrice($aGemData)
	Local $iRank = 0

	;Looking if rank exists in g_aGemRanks
	For $i = 0 To UBound($g_aGemRanks)-1
		If (StringInStr($g_aGemRanks[$i], $aGemData[2])) Then
			$iRank = $i
			ExitLoop
		EndIf
	Next

	Local $iSub = 0 ;Formatting sub for index
	Switch $aGemData[4]
		Case 4
			$iSub = 0
		Case 3
			$iSub = 1
		Case 2
			$iSub = 2
	EndSwitch

    Local $iGemPrice = $g_aGemGrade[$aGemData[0]-1][$iSub][$iRank]
    Log_Add("Gem Price: " & $iGemPrice, $LOG_DEBUG)
    Return $iGemPrice
	;Gem prices are location in 3 different arrays organized in ranks. Refer to Global variables.
	;Return Int(Execute("$g_aGemGrade" & $aGemData[0] & "Price[" & $iSub & "][" & $iRank & "]"))
EndFunc

#cs
	Function: Filters gems that do not meet the criteria
	Parameters:
		$aGemData: Gem data. Refer to getGemData() function.
		$aFilter: format=[[4*-Filter, ""], [4*-Types, ""], [4*-Stats, ""], [4*-Substats, ""], ...]
	Returns:
		If the gem meets the criteria returns true; otherwise, returns false.
#ce
Func filterGem($aGemData, $bCheckDragonGems = False)
	If ($bCheckDragonGems And StringInStr("leech,pugilist,siphon", $aGemData[2])) Then
		Local $iGrade = $aGemData[0]
		Local $t_bFilter = Eval("DragonFilter_" & $iGrade & "_Star_Filter")
		Local $t_bFilterTypes = StringInStr(Eval("DragonFilter_" & $iGrade & "_Star_Types"), $aGemData[2])
		Local $t_bFilterStats = StringInStr(Eval("DragonFilter_" & $iGrade & "_Star_Stats"), $aGemData[3])
		Local $t_bFilterSubStats = StringInStr(Eval("DragonFilter_" & $iGrade & "_Star_Substats"), $aGemData[4])
	Else
		Local $iGrade = $aGemData[0]
		Local $t_bFilter = Eval("Filter_" & $iGrade & "_Star_Filter")
		Local $t_bFilterTypes = StringInStr(Eval("Filter_" & $iGrade & "_Star_Types"), $aGemData[2])
		Local $t_bFilterStats = StringInStr(Eval("Filter_" & $iGrade & "_Star_Stats"), $aGemData[3])
		Local $t_bFilterSubStats = StringInStr(Eval("Filter_" & $iGrade & "_Star_Substats"), $aGemData[4])
	EndIf

	If (Not($t_bFilter) Or Not($t_bFilterTypes) Or Not($t_bFilterStats) Or Not($t_bFilterSubStats)) Then Return False

	Return True
EndFunc

#cs
	Function: Puts gem data into readable string.
	Parameters:
		$aGemData: Gem data. Refer to function: getGemData()
	Returns: Ex. 4*	Triangle Intuition %Atk
#ce
Func stringGem($aGemData)
	Local $sShape = "[Shape]"
	Switch $aGemData[1]
	Case "S"
		$sShape = "Square"
	Case "T"
		$sShape = "Triangle"
	Case "D"
		$sShape = "Diamond"
	EndSwitch

	Local $sType = "[Type]"
	$sType = _StringProper($aGemData[2])

	Local $sStat = "[Stat]"
	If (StringInStr($aGemData[3], ".")) Then
		Local $t_aSplit = StringSplit($aGemData[3], ".", $STR_NOCOUNT)

		$sStat = "+"
		If ($t_aSplit[0] = "P") Then $sStat = "%"

		$sStat &= _StringProper($t_aSplit[1])
	Else
		$sStat = _StringProper($aGemData[3])
	EndIf

	Local $sSub = "[Substat]"
	$sSub = $aGemData[4] & " Substat"
	If ($aGemData[4] > 1) Then $sSub &= "s"

	Return $aGemData[0] & "*; " & $sShape & "; " & $sType & "; " & $sStat & "; " & $sSub
EndFunc

#cs
	Function: Looks for level in map stage selection location.
	Parameters:
		$iLevel: Integer from 1-17.
	Return:
		Array point of where the energy is. -1 on not found.
#ce
Func findLevel($iLevel)
	Local $aPoint[2]
	Local $sLevel = StringLower($iLevel)
	If $sLevel = "boss" Then $sLevel = "any"

	If getLocation() = "map-stage" Then
		If StringIsDigit($sLevel) = True Then
			If ($sLevel < 10) Then $sLevel = "0" & $sLevel ;Must be in format ##
			$sLevel = "n" & $sLevel
		EndIf

		Local $t_sImageName = "level-" & $sLevel
		Local $t_aPoint = findImage($t_sImageName, 90, 0, 400, 220, 380, 260, True, True)

		If $t_aPoint = -1 Then Return -1
		;Found point

		$aPoint[0] = 725
		$aPoint[1] = $t_aPoint[1]
		Return $aPoint
	EndIf

	Return -2
EndFunc

Func findBLevel($iLevel)
	Local $aPoint[2]
	Local $aPoint = findImage("level-b" & ($iLevel<10?"0":"") & $iLevel , 93, 0, 310, 160, 50, 330, True, True) ;tolerance 100, rectangle at (402,229) dim. 50x250
	If isArray($aPoint) = False Then Return -1

	$aPoint[0] = 626 ;x coordinate for left side of button
	Return $aPoint
EndFunc

#cs
	Function: Finds an available guardian dungeon based on the current guardian dungeons.
	Parameters:
		$sMode: "left", "right", "both" - Handles the left/right side on the two visible guardian dungeon.
	Return: Points of the energy of the guardian dungeon.
#ce
Func findGuardian($sMode)
	$sMode = StringLower(StringStripWS($sMode, $STR_STRIPALL))

	CaptureRegion("\bin\images\misc\misc-guardian-left", 335, 191, 15, 15)
	CaptureRegion("\bin\images\misc\misc-guardian-right", 398, 191, 15, 15)
	Local $sImagePath, $aResult = False
	Local Const $iX = 650
	Switch $sMode
		Case "left", "right"
			$sImagePath = "misc-guardian-" & $sMode
			$aResult = findImage($sImagePath, 70, 0, 550, 250, 60, 250, True, True)
			If (Not(isArray($aResult))) Then Return -1
		Case Else
			$sImagePath = "misc-guardian-left"
			$aResult = findImage($sImagePath, 70, 0, 550, 250, 60, 250, True, True)
			If (Not(isArray($aResult))) Then
				$sImagePath = "misc-guardian-right"
				$aResult = findImage($sImagePath, 70, 0, 550, 250, 60, 250, True, True)
				If (Not(isArray($aResult))) Then Return -1
			EndIf
	EndSwitch
	$aResult[0] = $iX

	Return $aResult
EndFunc

#cs
	Function: Retrieves village position and angle.
	Return: Village position from 0-5. 0-2 for first ship, 3-4 for second, and 5-6 for third.
#ce
Func getVillagePos()
	CaptureRegion()

	;Traverse through idShip checking the pixel sets.
	For $i = 0 To UBound($g_aVillagePos)-1
		If (isPixel($g_aVillagePos[$i], 10)) Then Return $i
	Next

	;Return -1 if ship not found.
	Return -1
EndFunc

#cs
	Function: Checks if there are still astrochips left, only works if in 'battle' location.
	Returns Codes:
	   -2: Unknown
	   -1: Not in battle
		0: No astrocips
		1: Has astrochips
#ce
Func hasAstrochips()
	If Not(isLocation("battle")) Then Return -1
	If (isPixel("162,509,0x612C22/340,507,0x612C22/513,520,0x612C22/683,520,0x612C22")) = True Then
		If (isPixel("743,279,0x53100C|746,266,0xBD3229")) Then Return 0

		Return 1
	EndIf

	Return -2
EndFunc

#cs
	Function: Gets stone data.
	Returns: Array => [ELEMENT, GRADE, QUANTITY] ex. ["fire", "high", 3]
#ce
Func getStone()
	;Defining variables
	Local $sElement = "", $sGrade = "", $iQuantity = -1

	;Check if egg or gold
	If isPixel(getPixelArg("battle-item-egg"), 10, CaptureRegion()) Then
		Local $t_aData = ["egg", "n/a", "1"]
		Return $t_aData
	ElseIf isPixel(getPixelArg("battle-item-gold"), 10, CaptureRegion()) Then
		Local $t_aData = ["gold", "n/a", "n/a"]
		Return $t_aData
	EndIf

	;Getting element and grade
	Local $aElements = ["normal", "water", "wood", "fire", "dark", "light"]
	Local $aGrades = ["low", "mid", "high"]
	For $sCurElement In $aElements
		For $sCurGrade In $aGrades
			If isPixel(getPixelArg("stone-" & $sCurElement & "-" & $sCurGrade), 50, CaptureRegion()) = True Or findImage("stone-" & $sCurElement & "-" & $sCurGrade, 90, 0, 359, 131, 80, 80) <> -1 Then
				If FileExists(@ScriptDir & "\bin\images\stone\stone-" & $sCurElement & "-" & $sCurGrade) = False Then
					CaptureRegion("\bin\images\stone\stone-" & $sCurElement & "-" & $sCurGrade, 382, 145, 35, 45)
				EndIf
				$sElement = $sCurElement
				$sGrade = $sCurGrade

				ExitLoop(2)
			EndIf
		Next
	Next

	If ($sElement = "" Or $sGrade = "") Then
		Local $iCounter = 0
		While FileExists(@ScriptDir & "\bin\images\stone\stone-unknown" & $iCounter & ".bmp")
			$iCounter += 1
		WEnd
		CaptureRegion("\bin\images\stone\stone-unknown" & $iCounter, 382, 145, 35, 45)
		Log_Add("Could not get Element or Grade", $LOG_ERROR)
		Return -1
	EndIf

	;Getting quantity
	CaptureRegion("", 440, 214, 50, 20)
	For $i = 1 To 5
		If (isArray(findImage("misc-stone-x" & $i, 90, 0, 440, 214, 50, 20, False))) Then
			$iQuantity = $i
			ExitLoop
		EndIf
	Next

	If ($iQuantity = -1) Then
		Log_Add("Could not get quantity", $LOG_ERROR)
		Return -1
	EndIf

	Local $t_aData = [$sElement, $sGrade, $iQuantity]
	Return $t_aData
EndFunc

#cs
	Function: Retrieves which round the battle is currently.
	Parameters:
		$aPixels: List where the pixel rounds are.
	Return: Current round and the number of total rounds: Array format=[current, max, isLastRound, isBoss, MonsPerRound]
#ce
Func getRound($bUpdate = True)
	If ($bUpdate) Then CaptureRegion()
	Local $iMax = 0 ;Max number of rounds
	Local $iCurr = 0 ;Current round
	$g_sErrorMessage = ""
	;Getting round info
	For $i = 1 To 4
		If ($i > 1 And $iMax = 0 And checkRoundPixels("max-round-" & $i)) Then $iMax = $i
		If ($iCurr = 0 And checkRoundPixels("curr-round-" & $i)) Then $iCurr = $i
	Next

	If ($iMax = 0) Then  $g_sErrorMessage &= "getRound() => Could not find max."
	If ($iCurr = 0) Then $g_sErrorMessage &= "getRound() => Could not find current."

	If ($g_sErrorMessage <> "") Then Return -1

	Local $t_aResult = [$iCurr, $iMax]
	Return $t_aResult
EndFunc

Func checkRoundPixels($sPixelArg)
	Local $t_sArgument = getPixelArg($sPixelArg)
	If ($t_sArgument = "" Or $t_sArgument = -1) Then Return False

	Return isPixel($t_sArgument)
EndFunc

#cs
	Function: Tries to close a in game window interface.
	Parameters:
	Return: If window was closed successfully then return true. Else return false.
#ce
Func closeWindow()
	Local $sCurrLocation = getLocation()
	;Switch $sCurrLocation
		;Case "autobattle-prompt"
		;	Return clickWhile(getPointArg("autobattle-prompt-close"), "isLocation", "autobattle-prompt", 5, 1000)
		;Case "monsters-previous-awaken"
		;	Return clickWhile(getPointArg("already-awakened-close"), "isLocation", "monsters-previous-awaken", 5, 1000)
		;Case "refill"
		;	Return clickWhile(getPointArg("refill-close"), "isLocation", "refill", 5, 1000)
		;Case "boutique"
		;	Return clickWhile(getPointArg("boutique-close"), "isLocation", "boutique", 5, 1000)
		;Case Else
			Local $aPoints = findImageMultiple("location-dialogue-close", 90, 5, 5, 0, 0, 0, 800, 552, True, True)
			If IsArray($aPoints) Then
				For $i = 0 to UBound($aPoints)-1
					Local $sLoc = getLocation()

					clickPoint(CreateArr($aPoints[$i][0], $aPoints[$i][1]))
					If _Sleep(300) Then ExitLoop

					If $sLoc <> getLocation() Then ExitLoop
				Next

				Return True
			Else
				$g_sErrorMessage = "closeWindow() => No close found."
				Return False
			EndIf
	;EndSwitch
EndFunc

#cs
	Function: Tries to close dialogue between players in game
	Return: If dialogue has been closed successfully then return true. Else return false.
#ce
Func skipDialogue()
	Local $t_iTimerInit = TimerInit()
	While isLocation("dialogue-skip")
		If (TimerDiff($t_iTimerInit) >= 5000) Then Return False

		clickWhile(getPointArg("dialogue-skip"), "isLocation", "dialogue-skip", 5, 1000)
		If (_Sleep(200)) Then Return False
	WEnd
EndFunc

Func testEachPixel($sPixelString)
	CaptureRegion()
	Local $aFailedPixelResults[0]
	If (StringInStr($sPixelString,'/',$STR_NOCASESENSE)) Then
		Local $a_sPixels = StringSplit($sPixelString, '/', $STR_NOCOUNT)
		For $i = 0 To UBound($a_sPixels)
			Local $sPixels = $a_sPixels[$i]
			If (isPixel($sPixels)) Then ExitLoop
			Local $aPixels = StringSplit($sPixels,'|', $STR_NOCOUNT)
			checkEachPixel($aFailedPixelResults,$aPixels)
		Next
	Else
		Local $aPixels = StringSplit($sPixels,'|', $STR_NOCOUNT)
		checkEachPixel($aFailedPixelResults,$aPixels)
	EndIf
	Return $aFailedPixelResults
EndFunc

Func checkEachPixel(ByRef $aFailedArray, $aPixels)
	If (Not(IsArray($aFailedArray))) Then Return False

	For $p = 0 To UBound($aPixels)
		If (Not(isPixel($aPixels[$p]))) Then _ArrayAdd($aFailedArray, $aPixels[$p])
	Next

	Return True
EndFunc

;Only deals with 1D array
Func __ArrayToString($aArray, $iLayer = 1)
    Local $sArray = ""
    For $i = 0 To UBound($aArray)-1
        Local $temp = $aArray[$i]
        If isArray($temp) = True Then
            $sArray &= "\" & $iLayer & __ArrayToString($temp, $iLayer+1)
        Else
            $sArray &= "\" & $iLayer & $temp
        EndIf
    Next
    Return $sArray
EndFunc

;Deals with string that come from __ArrayToString 310 338
Func __ArrayFromString($sString, $iLayer = 1)
    Local $aArray = StringSplit($sString, "\" & $iLayer, $STR_ENTIRESPLIT+$STR_NOCOUNT)
	For $i = UBound($aArray)-1 To 0 Step -1
		If $aArray[$i] = "" Then _ArrayDelete($aArray, $i)
	Next

    For $i = 0 To UBound($aArray)-1
        If StringInStr($aArray[$i], "\" & $iLayer+1) Then
            $aArray[$i] = __ArrayFromString($aArray[$i], $iLayer+1)
        EndIf
    Next
    Return $aArray
EndFunc

Func CreateArr($o1 = Null, $o2 = Null, $o3 = Null, $o4 = Null, $o5 = Null, $o6 = Null, $o7 = Null, $o8 = Null, $o9 = Null, $o10 = Null, _
			   $o11 = Null, $o12 = Null, $o13 = Null, $o14 = Null, $o15 = Null, $o16 = Null, $o17 = Null, $o18 = Null, $o19 = Null, $o20 = Null)
	;count defined
	For $i = 20 To 1 Step -1
		If Eval("o" & $i) <> Null Then
			ExitLoop
		EndIf
	Next

	;assign
	Local $arr[$i]
	For $x = 0 To $i-1
		$arr[$x] = Eval("o" & $x+1)
	Next

	Return $arr
EndFunc

Func clickBattle()
	Local $sLocation = getLocation()
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < 200
		If _Sleep(50) Then ExitLoop
		If getLocation() <> $sLocation Then Return False
	WEnd

	Do
		clickPoint(getPointArg("battle-auto"))
		If _Sleep(500) Then ExitLoop
	Until(getLocation() <> $sLocation)

	Return True
EndFunc

Func findMap($sMap)
	If getLocation() <> "map" Then Return -1
	$sMap = StringReplace(StringLower($sMap)," ","-")

	Local $aPoint = findImage("map-" & $sMap, 90, 100, 0, 0, 800, 552, True, True)

	If isArray($aPoint) = False Then clickDrag($g_aSwipeRightFast)
	While isArray($aPoint) = False
		If _Sleep(200) Or getLocation() <> "map" Then ExitLoop
		If $sMap = "astromon-league" Then
			If findImage("map-astromon-league-disabled", 90, 100, 0, 0, 800, 552, True, True) Then
				$aPoint = -1
				ExitLoop
			EndIf
		EndIf

		$aPoint = findImage("map-" & $sMap, 90, 100, 0, 0, 800, 552, True, True)
		If isArray(findImage("map-terrestrial-rift", 90, 500, 0, 0, 800, 552, True, True)) = True Then ExitLoop

		If isArray($aPoint) = False Then
			clickDrag($g_aSwipeLeft)
		EndIf
	WEnd

	If $sMap = "ancient-dungeon" And isArray($aPoint) = True Then $aPoint[1] -= 100
	Return $aPoint
EndFunc

Func goBack()
	Log_Add("Sending back command", $LOG_DEBUG)
	If isPixel(getPixelArg("back"), 20, CaptureRegion()) = True Then
		clickPoint(getPointArg("back"))
	Else
		If closeWindow() = False Then clickPoint(getPointArg("tap"))
	EndIf
EndFunc

;-----Functions added-----¬
#cs
	DV: ._KN
	Function: Find Hero selected
	Return: Coordinates of the Hero"
#ce
Func findHDungeons($sHero)
	Local $aPoint[2]
	$aPoint = findImage("hero-" & $sHero, 90, 100, 75, 130, 200, 350, True, True)

	$aPoint[0] = 110 ;x coordinate for select hero
	Return $aPoint
EndFunc

#cs
	DV: ._KN
	Function: Find level in Hero Dungeons
	Return: Coordinates of the level
#ce
Func findHLevel($iLevel)
	Local $aPoint[2]
	Local $aPoint = findImage("level-h" & $iLevel, 90, 100, 300, 290, 50, 200, True, True)
	While isArray($aPoint) = False
		$aPoint = findImage("level-h" & $iLevel, 90, 100, 300, 290, 50, 200, True, True)
		If isArray($aPoint) = False Then
			clickDrag($g_aSwipeUp)
		EndIf
	WEnd

	$aPoint[0] = 660 ;x coordinate for left side of button
	Return $aPoint
EndFunc

#cs
	DV: ._KN
	Function: Find item in Shop
	Return: Coordinates of the item
#ce
Func findShop($aItem)
	Local $i_Drag = 0
	Local $aPoint = findImage("shop-" & $aItem, 90, 100, 180, 150, 230, 320, True, True)
	While isArray($aPoint) = False
		$aPoint = findImage("shop-" & $aItem, 90, 100, 180, 150, 230, 320, True, True)
		If isArray($aPoint) = False Then
			clickDrag($g_aSwipeUp)
			$i_Drag = $i_Drag + 1
			If $i_Drag >= 7 Then
				ExitLoop
			EndIf
		EndIf
	WEnd

	Return $aPoint
EndFunc

#cs
	DV: ._KN
	Function: Find aviable gems in Friend List
	Return: Coordinates of the button "Get Astrogem"
#ce
Func findGem_FriendList($aGems)
	Local $aPoint[2]
	Local $aPoint = findImage($aGems, 90, 100, 500, 217, 170, 40, True, True)
	While isArray($aPoint) = False
		$aPoint = findImage($aGems, 90, 100, 500, 217, 170, 40, True, True)
	WEnd
	$aPoint[0] = 725 ;x coordinate for "Get Astrogem" button
	Return $aPoint
EndFunc

Func Dailies_Hero_Dungeons()
	If $Dailies_Hero_Dungeons = True Then
		Return True
	Else
		Return False
	EndIf
EndFunc

#cs
	DV: ._KN
	Function: Find Super Festival in village
	Return: Coordinates of the Super Festival Box
#ce
Func findSuperFestival()
	Local $aPoint[2]
	$aPoint = findImage("misc-super-festival", 75, 100, 0, 0, 800, 552, True, True)
	If isArray($aPoint) = False Then
		$aPoint = findImage("misc-super-festival-1", 75, 100, 0, 0, 800, 552, True, True)
		Return $aPoint
	EndIf
	$aPoint[1] = $aPoint[1] + 20
	Return $aPoint
EndFunc

#cs
	DV: ._KN
	Function: Search chest of the Super Festival
	Return: Coordinates of the chest
#ce
Func findSuperFestival_Chest()
	Local $aPoint = findImage("misc-super-festival-chest", 70, 500, 0, 80, 800, 350, True, True)
	If isArray($aPoint) = False Then
		$aPoint = findImage("misc-super-festival-chest-1", 70, 500, 0, 80, 800, 350, True, True)
		If isArray($aPoint) = False Then
			$aPoint = findImage("misc-super-festival-chest-2", 70, 500, 0, 80, 800, 350, True, True)
		EndIf
	EndIf
	Return $aPoint
EndFunc

#cs
	DV: ._KN
	Function: Find text "Rare Detected" on location "battle", is help for auto_guided
	Return: Array or -1 (False), but the answer is only used if it is array or not (isArray() = True or False)
#ce
Func findRareText()
	Local $aPoint = findImage("catch-rare-detected", 70, 500, 0, 66, 800, 22, True, True)
	Local $aPoint_1 = findImage("catch-rare-detected", 70, 500, 0, 465, 800, 22, True, True)
	If IsArray($aPoint) Then
		Return $aPoint
	ElseIf IsArray($aPoint_1) Then
		Return $aPoint_1
	Else
		Return $aPoint
	EndIf
EndFunc

#cs ----Farm-Golem-------¬
	DV: ._KN
	Function: Find attacks of the golem
	Return: Array or -1 (False), but the answer is only used if it is array or not (isArray() = True or False)
#ce
Func findAttack_Golem()
	Local $aPoint_beam = findImage("golem-attack-beam", 70, 100, 607, 387, 190, 65, True, True)
	Local $aPoint_slam = findImage("golem-attack-slam", 70, 100, 607, 387, 190, 65, True, True)
	If IsArray($aPoint_beam) Then
		Return $aPoint_beam
	ElseIf IsArray($aPoint_slam) Then
		Return $aPoint_slam
	Else
		Return $aPoint_beam
	EndIf
EndFunc

Func findChest_Golem()
	Local $aPoint = findImage("golem-chest", 70, 100, 368, 389, 62, 53, True, True)
	Return $aPoint
EndFunc

Func findDefeat_Golem()
	Local $aPoint = findImage("golem-defeat", 70, 100, 303, 200, 200, 33, True, True)
	Return $aPoint
EndFunc
;------------------------^