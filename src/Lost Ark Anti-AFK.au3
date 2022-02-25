#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=warrior.ico
#AutoIt3Wrapper_Outfile=Lost Ark Anti-AFK.exe
#AutoIt3Wrapper_Outfile_x64=Lost Ark Anti-AFK.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         Mark Westenberg

 Script Function:
	Keep Lost Ark Alive

#ce ----------------------------------------------------------------------------

#include <TrayConstants.au3> ; Required for the $TRAY_ICONSTATE_SHOW constant.
#Include <WinAPIEx.au3>
#include <AutoItConstants.au3>
#Include <WinAPIEx.au3>
#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <ColorConstants.au3>


Local $hDLL = DllOpen("user32.dll")
Local $ScreenCtrX = (@DeskTopWidth / 2) ; X coordinate of mouse movement
Local $ScreenCtrY = @DeskTopHeight/ 2 ; Y coordinate of mouse movement
Local $ActionST = 2000 ; in miliseconds
Local $GlobalST = 30000 ; in miliseconds
Local $CapsLockIsOn = False, $onOff, $state = False
Local $MouseButton = $MOUSE_CLICK_RIGHT

Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.

Func CheckState() ; program should only be active when capslock is on.
   If _IsPressed("A2", $hDLL) Then ; can be disabled by pressing LCTRL for a period of time.
	  Exit ; quits the program when left control is pressed
   EndIf
   Return BitAND(_WinAPI_GetKeyState(0x14), 1) = 1 ;==>_GetCapsLockState
EndFunc

Func MoveMouseTo($x, $y)
   If CheckState() Then
	  MouseMove($x, $y) ;
	  MouseClick($MouseButton)
	  Sleep($ActionST)
   EndIf
EndFunc

Func KeepAlive($x1, $x2, $y)
   If CheckState() Then
	  MoveMouseTo($x1, $y)
	  MoveMouseTo($x2, $y)
   EndIf
EndFunc

Func UpdateDot()
	Local $color = ($state = True) ? $COLOR_GREEN : $COLOR_RED
	GUICtrlSetGraphic($onOff, $GUI_GR_COLOR, $color, $color)
	GUICtrlSetGraphic($onOff, $GUI_GR_PIE, 2.5, 2.5, 5, 0,360)
	GUICtrlSetGraphic($onOff, $Gui_gr_refresh)
EndFunc

Func Main()
	Local $idRestore = TrayCreateItem("Restore Window")
	Local $idExit = TrayCreateItem("Exit")

    TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.
	TraySetToolTip("Keeping Lost Ark Alive") ; Set the tray menu tooltip with information about the icon index.

	Local $hGUI = GUICreate("Lost Ark Anti-AFK", 400,470)
    GUICtrlCreatePic(@ScriptDir & "\AntiAFK-Banner.jpg", 0, 0, 400, 225) ; banner

	$font="Arial" ; default font
	GUISetFont (14, 700, 0, $font) ; Large font for title
	GUICtrlCreateLabel ("Stay logged into Lost Ark",10,250) ; Title
	GUISetFont (10, 400, 0, $font); ; reset font to normal

	; timer for movement repeat
	GUICtrlCreateLabel("Repeat mouse movement every:", 10, 280)
	Local $globalTime = GUICtrlCreateInput("30", 200, 278, 50,20)
	GUICtrlCreateUpdown($globalTime)
	GUICtrlCreateLabel("second(s)", 252, 280)

	GUIStartGroup()
	$mouse_btn_Left = GUICtrlCreateRadio("Left Mouse Button", 10, 300, 150, 20)
	$mouse_btn_Right = GUICtrlCreateRadio("Right Mouse Button", 10, 320, 150, 20)
	GUICtrlSetState($mouse_btn_Right, $GUI_CHECKED)

	; controls
	GUISetFont (11, 700, 0, $font) ; Large font for title
	GUICtrlCreateLabel ("Shortcuts/Keys",10,360) ; Title
	GUISetFont (10, 400, 0, $font); ; reset font to normal
	GUICtrlCreateLabel ("CAPSLOCK: Activate/Deactivate",10,380)
	GUICtrlCreateLabel ("LEFT CTRL: Hold to close",10,400)

	; show status dot
	$onOff = GUICtrlCreateGraphic(15, 449, 5,5)
	GUICtrlSetGraphic($onOff, $GUI_GR_MOVE, 5, 5)
	GUICtrlSetGraphic($onOff, $GUI_GR_COLOR, $COLOR_RED, $COLOR_RED)
    GUICtrlSetGraphic($onOff, $GUI_GR_PIE, 2.5, 2.5, 5, 0,360)

	Local $enabledText = ($state = True) ? "Anti-AFK is enabled" : "Anti-AFK is disabled"

	Local $enabledLabel = GUICtrlCreateLabel ("Anti-AFK is disabled" & $enabledText,33,443)
	;Local $btnAct = GUICtrlCreateButton("Enable/Disable", 35, 420, 125, 25) ; exit button
	Local $btnExit = GUICtrlCreateButton("Exit Program", 310, 440, 85, 25) ; exit button

	GUISetState(@SW_SHOW, $hGUI)

	$state = CheckState()

	$Timer = TimerInit()
	; Loop until the user exits.
    While 1

		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $btnExit
                Exit
			Case $GUI_EVENT_MINIMIZE
				GuiSetState(@SW_HIDE, $hGUI);hide GUI
			Case $mouse_btn_Left
				$MouseButton = $MOUSE_CLICK_LEFT
			Case $mouse_btn_Right
				$MouseButton = $MOUSE_CLICK_RIGHT
		EndSwitch
		Switch TrayGetMsg()
			Case $idExit ; Exit the loop.
				Exit
			Case $idRestore
				GuiSetState(@SW_SHOW, $hGUI);hide GUI
				GuiSetState(@SW_RESTORE, $hGUI);hide GUI
				TraySetToolTip("Click to restore window...")  ; The Tooltip text is only changed when the tray icon is visible.
		EndSwitch

		if $state <> CheckState() Then
			$state = CheckState()
			UpdateDot()
		EndIf

		$enabledText = ($state = True) ? "Anti-AFK is enabled" : "Anti-AFK is disabled"
		GUICtrlSetData($enabledLabel, $enabledText)
		$GlobalST = GUICtrlRead($globalTime)*1000

		if TimerDiff($Timer) >= $GlobalST Then
			KeepAlive($ScreenCtrX+100,$ScreenCtrX-100, $ScreenCtrY-15)
			$Timer = TimerInit()
		EndIf
    WEnd

EndFunc


Main()
