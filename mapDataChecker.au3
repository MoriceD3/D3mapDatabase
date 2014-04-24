#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#Region ### START Koda GUI section ### Form=C:\_Bot\D3mapDatabase\mapDataChecker.kxf
$Form1 = GUICreate("mapData checker", 325, 368, 192, 124)
$Button1 = GUICtrlCreateButton("Ouvrir fichier mapData", 8, 16, 307, 25)
$Button2 = GUICtrlCreateButton("Sélectionner répertoire de comparaison", 8, 56, 307, 25)
$Button3 = GUICtrlCreateButton("Comparer", 80, 104, 155, 25)
GUICtrlSetState($Button3, $GUI_DISABLE)
$Label1 = GUICtrlCreateLabel("", 8, 168, 308, 188)
$Label2 = GUICtrlCreateLabel("Résultat : ", 8, 144, 52, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $mapDataFile = False
Global $mapDataDirectory = False

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			Local $sFileOpenDialog = FileOpenDialog("Sélectionner le fichier mapData", @scriptdir & "\upload", "mapData (*.ini)", $FD_FILEMUSTEXIST)
		    If @error Then
		        MsgBox($MB_SYSTEMMODAL, "", "Pas de fichier sélectionné.")
		        FileChangeDir(@ScriptDir)
		    Else
		        FileChangeDir(@ScriptDir)
		        $mapDataFile = $sFileOpenDialog
				ConsoleWrite("mapData file : " & $mapDataFile & @CRLF)
				If $mapDataDirectory <> False Then
					GUICtrlSetState($Button3, $GUI_ENABLE)
				EndIf
		    EndIf
		Case $Button2
			Local $sFileOpenDialog = FileSelectFolder ("Sélectionner le fichier mapData", "" , 0 ,@scriptdir & "\mapData")
		    If @error Then
		        MsgBox($MB_SYSTEMMODAL, "", "Pas de répertoire sélectionné.")
		    Else
		        $mapDataDirectory = $sFileOpenDialog
				ConsoleWrite("Folder : " & $mapDataDirectory & @CRLF)
				If $mapDataFile <> False Then
					GUICtrlSetState($Button3, $GUI_ENABLE)
				EndIf
		    EndIf
		Case $Button3
			compareFiles()
	EndSwitch
WEnd

Func compareFiles()
	$area = IniRead($mapDataFile,"SceneInfo","areaid",-1)

	If $area = -1 Then
		displayResult("Fichier ne contenant d'areaID !")
		Return
	EndIf

	$meshSize = IniRead($mapDataFile, "SceneInfo", "SceneSize", -1)
	$count_scene = 0
	Dim $Scene_table_totale[$meshSize + 1][8]

	For $i = 0 To $meshSize
		$temp = IniRead($mapDataFile, "MeshData", "Mesh" & $i, -1)
		If $temp <> -1 Then
			$temp = StringSplit($temp, ",", 2)
			If $temp[2] <> 0x00013CB6 And $temp[2] <> 0x00013C2E And $temp[2] <> 0x0000D50F Then
				$count_scene += 1
				$Scene_table_totale[$count_scene - 1][0] = $temp[0]
				$Scene_table_totale[$count_scene - 1][1] = $temp[1]
				$Scene_table_totale[$count_scene - 1][2] = $temp[2]
				$Scene_table_totale[$count_scene - 1][3] = $temp[3]
				$Scene_table_totale[$count_scene - 1][4] = $temp[4]
				$Scene_table_totale[$count_scene - 1][5] = $temp[5]
				$Scene_table_totale[$count_scene - 1][6] = $temp[6]
				$Scene_table_totale[$count_scene - 1][7] = $temp[7]
			EndIf
		EndIf
	Next

	$directory = _FileListToArray ( $mapDataDirectory , "*.ini", 1 , True)
	If @Error Then
		displayResult("Problème d'énumération des mapData déjà présents !")
		Return
	EndIf
	$text = ""
	$duplicate = False
	Local $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($mapDataFile, $sDrive, $sDir, $sFilename, $sExtension)

	For $z = 1 To $directory[0]
		$temp_area = IniRead($directory[$z] ,"SceneInfo","areaid",-1)
		If $area = $temp_area Then
			$temp_meshSize = IniRead($directory[$z], "SceneInfo", "SceneSize", -1)
			$temp_count_scene = 0
			Dim $temp_Scene_table_totale[$meshSize + 1][8]
			$currentFile = $directory[$z]
			For $i = 0 To $temp_meshSize
				$temp = IniRead($currentFile, "MeshData", "Mesh" & $i, -1)
				If $temp <> -1 Then
					$temp = StringSplit($temp, ",", 2)
					If $temp[2] <> 0x00013CB6 And $temp[2] <> 0x00013C2E And $temp[2] <> 0x0000D50F Then
						$temp_count_scene += 1
						$temp_Scene_table_totale[$temp_count_scene - 1][0] = $temp[0]
						$temp_Scene_table_totale[$temp_count_scene - 1][1] = $temp[1]
						$temp_Scene_table_totale[$temp_count_scene - 1][2] = $temp[2]
						$temp_Scene_table_totale[$temp_count_scene - 1][3] = $temp[3]
						$temp_Scene_table_totale[$temp_count_scene - 1][4] = $temp[4]
						$temp_Scene_table_totale[$temp_count_scene - 1][5] = $temp[5]
						$temp_Scene_table_totale[$temp_count_scene - 1][6] = $temp[6]
						$temp_Scene_table_totale[$temp_count_scene - 1][7] = $temp[7]
					EndIf
				EndIf
			Next

			$findCount = 0
			For $i = 0 To UBound($Scene_table_totale) - 1
				$meshfound = False
				For $j = 0 To UBound($temp_Scene_table_totale) - 1
					If $Scene_table_totale[$i][2] = $temp_Scene_table_totale[$j][2] And $Scene_table_totale[$i][3] = $temp_Scene_table_totale[$j][3] And $Scene_table_totale[$i][4] = $temp_Scene_table_totale[$j][4] And $Scene_table_totale[$i][5] = $temp_Scene_table_totale[$j][5] And $Scene_table_totale[$i][6] = $temp_Scene_table_totale[$j][6] Then
						$meshfound = True
						ExitLoop
					EndIf
				Next
				If $meshfound = False Then
					ExitLoop
				Else
					$findCount += 1
				EndIf
			Next
			ConsoleWrite(StringReplace($currentFile,$mapDataDirectory & "\" ,"") & " : " & $findCount & " / " & UBound($Scene_table_totale) & @CRLF)
			If $findCount = UBound($Scene_table_totale) Then
				$duplicate = True

				$text = $sFilename & "." & $sExtension & " : " & @CRLF & " - Doublon avec : " & StringReplace($currentFile,$mapDataDirectory & "\" ,"")
				$text = $text & @CRLF & @CRLF & "Penser à vérifier les positions !!"
				ExitLoop
			EndIf
		EndIf
	Next
	If $duplicate = False Then
		$text = $sFilename & "." & $sExtension & " : " & @CRLF & " - Ce fichier mapData semble nouveau"
	EndIf
	displayResult($text)

EndFunc

Func displayResult($string)
	GUICtrlSetData($Label1, $string)
EndFunc