#include-once

Func Config_Save($sConfig = "", $sPath = "")
    Local $iIndex = -1
    If $sConfig = "" Then _GUICtrlComboBox_GetLBText($g_hCmb_Scripts, _GUICtrlComboBox_GetCurSel($g_hCmb_Scripts), $sConfig)
    $sConfig = StringReplace($sConfig, " ", "_")
    If $sPath = "" Then $sPath = $g_sProfileFolder & "\" & $Config_Profile_Name & "\" & StringReplace($sConfig, " ", "_")

    $iIndex = Script_IndexByName($sConfig)
    If $iIndex = -1 Then Return False

    Local $sData = ""

    Local $aConfig = $g_aScripts[$iIndex]
    Local $aSettingList = $aConfig[$CONFIG_SETTINGLIST] ;Array of settings

    For $i = 0 To UBound($aSettingList)-1
        Local $aSetting = $aSettingList[$i]
        $aSetting[$SETTING_VALUE] = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $i, 1)
        $aSettingList[$i] = $aSetting

        $sData &= @CRLF & $aSetting[0] & ':"' & $aSetting[1] & '"'
    Next

    $aConfig[$CONFIG_SETTINGLIST] = $aSettingList
    $g_aScripts[$iIndex] = $aConfig

    $sData = StringMid($sData, 2)
    If ($sPath <> "") Then
        FileOpen($sPath, $FO_OVERWRITE+$FO_CREATEPATH)
        FileWrite($sPath, $sData)
        FileClose($sPath)
    EndIf

    Config_Update()
EndFunc

Func Config_Update()
    Local $aConfigSettings = formatArgs(Script_DataByName("_Config")[2])
    Local $aDelaySettings = formatArgs(Script_DataByName("_Delays")[2])
    Local $aGeneralSettings = formatArgs(Script_DataByName("_General")[2])
    Local $aHourlySettings = formatArgs(Script_DataByName("_Hourly")[2])
    Local $aGuardianSettings = formatArgs(Script_DataByName("_Guardian")[2])
    Local $aExpeditionSettings = formatArgs(Script_DataByName("_Expedition")[2])
    Local $aFilterSettings = formatArgs(Script_DataByName("_Filter")[2])
    Local $aDragonFilterSettings = formatArgs(Script_DataByName("_DragonFilter")[2])
    Local $aAstroleagueSettings = formatArgs(Script_DataByName("_Astroleague")[2])
    Local $aChampionSettings = formatArgs(Script_DataByName("_Champion")[2])

    Config_CreateGlobals($aConfigSettings, "Config")
    Config_CreateGlobals($aDelaySettings, "Delay")
    Config_CreateGlobals($aGeneralSettings, "General")
    Config_CreateGlobals($aHourlySettings, "Hourly")
    Config_CreateGlobals($aGuardianSettings, "Guardian")
    Config_CreateGlobals($aExpeditionSettings, "Expedition")
    Config_CreateGlobals($aFilterSettings, "Filter")
    Config_CreateGlobals($aDragonFilterSettings, "DragonFilter")
    Config_CreateGlobals($aAstroleagueSettings, "Astroleague")

    ;parsing settings
    Switch $Config_Location_Stuck_Timeout
        Case "Never"
            $Config_Location_Stuck_Timeout = -1
        Case Else
            $Config_Location_Stuck_Timeout = Int(StringMid($Config_Location_Stuck_Timeout, 1, StringLen($Config_Location_Stuck_Timeout) - StringLen(" Minutes")))
    EndSwitch

    Switch $Config_Another_Device_Timeout
        Case "Never"
            $Config_Another_Device_Timeout = -1
        Case "Immediately"
            $Config_Another_Device_Timeout = 0
        Case Else
            $Config_Another_Device_Timeout = Int(StringMid($Config_Another_Device_Timeout, 1, StringLen($Config_Another_Device_Timeout) - StringLen(" Minutes")))
    EndSwitch

    $Config_Maintenance_Timeout = Int(StringMid($Config_Maintenance_Timeout, 1, StringLen($Config_Maintenance_Timeout) - StringLen(" Minutes")))

    $Config_Capture_Mode = Eval("BKGD_" & $Config_Capture_Mode)
    $Config_Mouse_Mode = Eval("MOUSE_" & $Config_Mouse_Mode)
    $Config_Swipe_Mode = Eval("SWIPE_" & $Config_Swipe_Mode)
    $Config_Back_Mode = Eval("BACK_" & $Config_Back_Mode)

    $Guardian_Check_Intervals = Int(StringMid($Guardian_Check_Intervals, 1, StringLen($Guardian_Check_Intervals) - StringLen(" Minutes")))

    $Expedition_Check_Intervals = Int(StringMid($Expedition_Check_Intervals, 1, StringLen($Expedition_Check_Intervals) - StringLen(" Hours")))
    Switch $Expedition_Use_Luck_Item
        Case "None"
            $Expedition_Use_Luck_Item = -1
        Case Else
            $Expedition_Use_Luck_Item = Eval("EXPEDITION_LUCK_" & $Expedition_Use_Luck_Item)
    EndSwitch
    Switch $Expedition_Explore_Time
        Case "2 Hours"
            $Expedition_Explore_Time = $EXPEDITION_HOUR_2
        Case "4 Hours"
            $Expedition_Explore_Time = $EXPEDITION_HOUR_4
        Case "8 Hours"
            $Expedition_Explore_Time = $EXPEDITION_HOUR_8
    EndSwitch

    $Astroleague_Check_Intervals = Int(StringMid($Astroleague_Check_Intervals, 1, StringLen($Astroleague_Check_Intervals) - StringLen(" Minutes")))
    $Astroleague_Draw_Match = Int(StringMid($Astroleague_Draw_Match, 1, StringLen($Astroleague_Draw_Match) - StringLen(" Minutes")))

    $Champion_Check_Intervals = Int(StringMid($Champion_Check_Intervals, 1, StringLen($Champion_Check_Intervals) - StringLen(" Minutes")))

    ;Cumulative
    If FileExists($g_sProfileFolder & "\" & $Config_Profile_Name & "\Cumulative") = True And $g_hLV_OverallStats <> Null Then
        Cumulative_Load()
    EndIf

    ResetHandles()
EndFunc

Func Config_Display(ByRef $hListView, $aScript) ;displayScriptData
    ;Must be in format: [[script, description, [[config, value, description], [..., ..., ...]]], ...]
    If isArray($aScript) = False Or UBound($aScript, $UBOUND_ROWS) <> 3 Then Return -1

    Local $aConfigList = $aScript[2] ;[[config, value, description], [..., ..., ...]]
    Local $iSize = UBound($aConfigList, $UBOUND_ROWS)

    _GUICtrlListView_DeleteAllItems($hListView)
    For $i = 0 To $iSize-1
        Local $aSetting = $aConfigList[$i] ;[config, value, description]
        _GUICtrlListView_AddItem($hListView, StringReplace($aSetting[0], "_", " "))
        _GUICtrlListView_AddSubItem($hListView, $i, $aSetting[1], 1)

        ;hidden values
        _GUICtrlListView_AddSubItem($hListView, $i, $aSetting[2], 2) ;description
        _GUICtrlListView_AddSubItem($hListView, $i, $aSetting[3], 3) ;type
        _GUICtrlListView_AddSubItem($hListView, $i, $aSetting[4], 4) ;type values
    Next
EndFunc

;Helper Functions----------------------------------------------------------------------

Func Config_Parse($sValue)
    Switch $sValue
        Case "Enabled", "Disabled"
            Return $sValue = "Enabled"
        Case Else
            Return $sValue
    EndSwitch
EndFunc

Func Config_CreateGlobals($aSetting, $sName)
    For $i = 0 To UBound($aSetting)-1
        If $aSetting[$i][1] = "~" Then ContinueLoop

        ;If isDeclared($sName & "_" & $aSetting[$i][0]) = False Then Log_Add($sName & "_" & $aSetting[$i][0] & " was not declared.", $LOG_ERROR)
        ;Log_Add($sName & "_" & $aSetting[$i][0] & " = " & Config_Parse($aSetting[$i][1]), $LOG_DEBUG)

        Assign($sName & "_" & $aSetting[$i][0], Config_Parse($aSetting[$i][1]), $ASSIGN_FORCEGLOBAL)
    Next
EndFunc