#include-once

Global $Guided_Auto_Semi = True
Func attackGuided($sType, $iDelay = "")
    Local $bLog = $g_bLogEnabled
    $g_bLogEnabled = False
    If $iDelay = "" Then $iDelay = $Delay_Guided_Auto_Delay
    Switch $sType
        Case "Full"
            If getLocation() = "battle" Then
                Local $aPoints[0][4]
                Local $sPointArg = "guided-%d-mon-%%s%s"
                $sPointArg = StringFormat($sPointArg, 4, ($General_Guided_Auto_Type="Chibi"?"-chibi":""))
                _ArrayAdd($aPoints, getPointArg(StringFormat($sPointArg, "first")) &    ",1,0",     0, ",")
                _ArrayAdd($aPoints, getPointArg("battle-first-friendly-mon") &          ",2,10",    0, ",")
                _ArrayAdd($aPoints, getPointArg(StringFormat($sPointArg, "second")) &   ",1,0",     0, ",")
                _ArrayAdd($aPoints, getPointArg("battle-second-friendly-mon") &         ",2,10",    0, ",")
                _ArrayAdd($aPoints, getPointArg(StringFormat($sPointArg, "third")) &    ",1,0",     0, ",")
                _ArrayAdd($aPoints, getPointArg("battle-third-friendly-mon") &          ",2,10",    0, ",")
                _ArrayAdd($aPoints, getPointArg(StringFormat($sPointArg, "fourth")) &   ",1,0",     0, ",")
                _ArrayAdd($aPoints, getPointArg("battle-fourth-friendly-mon") &         ",2,10",    0, ",")
                clickMultiple($aPoints, $iDelay)
            EndIf
        Case "Full-Attack"
            If getLocation() = "battle" Then
                Local $aPoints[0][4]
                Local $sPointArg = "guided-%d-mon-%%s%s"
                $sPointArg = StringFormat($sPointArg, 4, ($General_Guided_Auto_Type="Chibi"?"-chibi":""))
                _ArrayAdd($aPoints, getPointArg("battle-first-friendly-mon") &          ",2,10",    0, ",")
                _ArrayAdd($aPoints, getPointArg("battle-second-friendly-mon") &         ",2,10",    0, ",")
                _ArrayAdd($aPoints, getPointArg("battle-third-friendly-mon") &          ",2,10",    0, ",")
                _ArrayAdd($aPoints, getPointArg("battle-fourth-friendly-mon") &         ",2,10",    0, ",")
                clickMultiple($aPoints, $iDelay)
            EndIf
        Case "Semi"
            Local $aRound = getRound()
            If isArray($aRound) = False Then Return False
            If $Guided_Auto_Semi = True And $aRound[0] = 1 Then
                $Guided_Auto_Semi = False
                clickPoint(getPointArg("guided-4-mon-first" & ($General_Guided_Auto_Type="Chibi"?"-chibi":"")))
                If getLocation() = "battle" Then clickBattle()
            Else
                If $aRound[0] <> 1 Then $Guided_Auto_Semi = True
            EndIf
    EndSwitch
    $g_bLogEnabled = $bLog
EndFunc

Func attackGuided_Rare($sType, $iDelay = "")
    Local $bLog = $g_bLogEnabled
    $g_bLogEnabled = False
    If $iDelay = "" Then $iDelay = $Delay_Guided_Auto_Delay
    Switch $sType
        Case "Full"
            If getLocation() = "battle" And Not(isArray(findRareText())) Then
				Local $aPoints[0][4]
				Local $sPointArg = "guided-rare-%d-mon-%%s%s"
				$sPointArg = StringFormat($sPointArg, 4, ($General_Guided_Auto_Type="Chibi"?"-chibi":""))
				_ArrayAdd($aPoints, getPointArg(StringFormat($sPointArg, "first")) &    ",1,0",     0, ",")
				_ArrayAdd($aPoints, getPointArg("battle-first-friendly-mon") &          ",2,10",    0, ",")
				_ArrayAdd($aPoints, getPointArg(StringFormat($sPointArg, "second")) &   ",1,0",     0, ",")
				_ArrayAdd($aPoints, getPointArg("battle-second-friendly-mon") &         ",2,10",    0, ",")
				_ArrayAdd($aPoints, getPointArg(StringFormat($sPointArg, "third")) &    ",1,0",     0, ",")
				_ArrayAdd($aPoints, getPointArg("battle-third-friendly-mon") &          ",2,10",    0, ",")
				_ArrayAdd($aPoints, getPointArg(StringFormat($sPointArg, "fourth")) &   ",1,0",     0, ",")
				_ArrayAdd($aPoints, getPointArg("battle-fourth-friendly-mon") &         ",2,10",    0, ",")
				clickMultiple($aPoints, $iDelay)
            EndIf
    EndSwitch
    $g_bLogEnabled = $bLog
EndFunc