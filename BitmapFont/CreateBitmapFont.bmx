SuperStrict

'?Win32
'Import MaxGUI.FLTKMaxGui
'?Not Win32
Import MaxGUI.Drivers
'?
Import MaxGUI.XPmanifest
Import MaxGui.ProxyGadgets

Import BRL.FreetypeFont
Import BRL.EventQueue

Import "../Window.bmx"

'-------------------------------------------------------------------------------

Global _shell32:Int=LoadLibraryA( "shell32.dll" )
Global _ole32:Int=LoadLibraryA( "ole32.dll" )

Global SHGetKnownFolderPath:Int( refid:Byte Ptr,flags:Int,token:Byte Ptr,path:Short Ptr Var ) "Win32"
Global CoTaskMemFree( mem:Byte Ptr ) "Win32"

SHGetKnownFolderPath=GetProcAddress( _shell32,"SHGetKnownFolderPath" )
CoTaskMemFree=GetProcAddress( _ole32,"CoTaskMemFree" )

Const SYSTEMFOLDER_DOCUMENTS:Int=1
Const SYSTEMFOLDER_GAMES:Int=2

Function GetDocumentsFolder:String()

	Const FOLDERID_Documents$="{FDD39AD0-238F-46AF-ADB4-6C85480369C7}"
	Global IID_FOLDERID_Documents:GUID=New GUID
	Global documentFolder:String=""
	
	If documentFolder<>"" Then Return documentFolder
	
	If Not SHGetKnownFolderPath Then 
		documentFolder=getenv_( "APPDATA" )
		Return documentFolder		
	End If
	
	Local res:Int=IIDFromString( FOLDERID_Documents,IID_FOLDERID_Documents )
	If res<>0 Then 
		documentFolder=getenv_( "APPDATA" )
		Return documentFolder
	End If
	
	If documentFolder="" Then
		Local wstring:Short Ptr
		SHGetKnownFolderPath( IID_FOLDERID_Documents,0,Null,wstring )
		
		documentFolder=String.FromWString( wstring )
		CoTaskMemFree( wstring )
	
	End If
	
	Return documentFolder

End Function

Function GetSaveGamesFolder:String()

	Const FOLDERID_Games$="{4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4}"
	Global IID_FOLDERID_Games:GUID=New GUID
	Global gamesFolder:String=""
	
	If gamesFolder<>"" Then Return gamesFolder
	
	If Not SHGetKnownFolderPath Then 
		gamesFolder=getenv_( "APPDATA" )
		Return gamesFolder		
	End If
	
	Local res:Int=IIDFromString( FOLDERID_Games,IID_FOLDERID_Games )
	If res<>0 Then 
		gamesFolder=getenv_( "APPDATA" )
		Return gamesFolder
	End If
	
	If gamesFolder="" Then
		Local wstring:Short Ptr
		SHGetKnownFolderPath( IID_FOLDERID_Games,0,Null,wstring )
		
		gamesFolder=String.FromWString( wstring )
		CoTaskMemFree( wstring )
	
	End If
	
	Return gamesFolder

End Function

DebugLog GetDocumentsFolder()
DebugLog GetSaveGamesFolder()

'--------------------------------------------------------------------------------

Local test:String="sdhfskjdh"
DebugLog test.ToInt()

Private

Include "TGlyphBlock.bmx"
Include "TGlyphMetrics.bmx"
Include "TBitmapFont.bmx"
Include "TCharRange.bmx"

Global _running:Int=True

#FileMenuData
DefData 7
DefData "&New",MENU_FILE_NEW,KEY_N,MODIFIER_COMMAND
DefData "",0,0,0
DefData "&Open",MENU_FILE_OPEN,KEY_O,MODIFIER_COMMAND
DefData "&Save",MENU_FILE_SAVE,KEY_S,MODIFIER_COMMAND
DefData "Save &As",MENU_FILE_SAVEAS,KEY_S,MODIFIER_COMMAND|MODIFIER_ALT
DefData "",0,0,0
DefData "E&xit",MENU_FILE_EXIT,KEY_F4,MODIFIER_ALT

#EditMenuData
DefData 3
DefData "Cu&t",MENU_EDIT_CUT,KEY_X,MODIFIER_COMMAND
DefData "&Copy",MENU_EDIT_COPY,KEY_C,MODIFIER_COMMAND
DefData "&Paste",MENU_EDIT_PASTE,KEY_P,MODIFIER_COMMAND

Global _fontSizeData:String[]=["8","9","10","11","12","14","16","18","20","22","24","26","28","36","72","144"]
Global _textureSizeData:String[]=["64","128","256","512","1024","2048","4096"]

Const _style:Int=WINDOW_CENTER|WINDOW_TITLEBAR|WINDOW_STATUS|WINDOW_MENU|WINDOW_CLIENTCOORDS|WINDOW_RESIZABLE


' Menu items
Const MENU_FILE_NEW%		=1000
Const MENU_FILE_OPEN%		=1001
Const MENU_FILE_SAVE%		=1002
Const MENU_FILE_SAVEAS%		=1003
Const MENU_FILE_CLOSETAB%	=1004
Const MENU_FILE_EXIT%		=1005

Const MENU_EDIT_CUT%		=1020
Const MENU_EDIT_COPY%		=1021
Const MENU_EDIT_PASTE%		=1022

Type TFontTab Extends TGadgetObject

	Field _panel:TGadget
	Field _bitmapFont:TBitmapFont
	
	Method SetSize( width:Int,height:Int )
	
		Local x:Int,y:Int
		x=GadgetX( _panel )
		y=GadgetY( _panel )
		SetGadgetShape _panel,x,y,width,height
	
	End Method

	Method Show()
	
		ShowGadget _panel
	
	End Method
	
	Method Hide()
	
		HideGadget _panel
	
	End Method

	Method Free()
		
		Super.Free
		
		If _panel Then FreeGadget _panel
		_panel=Null
	
	End Method

	Method SetBitmap( index:Int )
	
		Local pixmap:TPixmap=_bitmapFont.GetBlockImage(index).Lock( 0,True,True )
		SetColor 0,0,0
		SetPixmap pixmap,PANELPIXMAP_CENTER
	
	End Method
	
	Method GetBitmapCount:Int()
	
		Return _bitmapFont.GetBlockCount()
	
	End Method

	Function Create:TFontTab( tabber:TTabber,Text:String,font:TImageFont,texw:Int=256,texh:Int=256,range:TList=Null )
	
		If range=Null Then Return Null
	
		Local tab:TFontTab=New TFontTab
		tab._panel=CreateScrollPanel( 0,0,tabber.GetClientWidth(),tabber.GetClientHeight(),tabber._object,0 )
		SetGadgetLayout tab._panel,1,1,1,1
		
		tab._object=ScrollPanelClient( TScrollPanel(tab._panel) )
		tab.SetShape 0,0,texw,texh
	
		tab._bitmapFont=TBitmapFont.Create( font,range,texw,texh )
		If Not tab._bitmapFont Then Return Null
		
		Local pixmap:TPixmap=tab._bitmapFont.GetBlockImage(0).Lock( 0,True,True )
		tab.SetColor 0,0,0
		tab.SetPixmap pixmap,PANELPIXMAP_CENTER
		
		tabber.AddTab tab,Text
		tabber.SelectTab tabber.GetTabCount()-1
		
		Return tab
	
	End Function

End Type

Type TFontPanel Extends TPanel

	Function Create:TFontPanel( x:Int,y:Int,width:Int,height:Int,group:TGadgetObject,style:Int=0,title:String="" )
	
		Local panel:TFontPanel=New TFontPanel		
		If Not panel.InitControl( x,y,width,height,group,style,title ) Then Return Null
		
		Return panel
	
	End Function

End Type

Type TFontWindow Extends TWindow

	Field _tabber:TTabber
	Field _panel:TPanel
	
	Field _fontBox:TTextField
	Field _fontFile:String
	
	Field _sizeBox:TComboBox
	
	Field _buttonExit:TButton
	Field _buttonBrowse:TButton
	Field _buttonCreate:TButton
	
	Field _buttonBold:TButton
	Field _buttonItalic:TButton
	
	Field _fileMenu:TMenu
	Field _editMenu:TMenu
	
	Field _widthBox:TComboBox
	Field _heightBox:TComboBox
	
	Field _fromCharacter:TTextField
	Field _toCharacter:TTextField
	Field _rangeBox:TListBox
	Field _buttonAddRange:TButton
	Field _buttonRemoveRange:TButton
	
	Field _selectBitmap:TSlider
	Field _bitmapLabel:TLabel
	
	Method CreateBitmapFont()
		
		Local width:Int,height:Int,style:Int,size:Int
		
		If _fontFile="" Or FileType( _fontFile )<>1 Then Return
		
		width=_widthBox.GetText().ToInt()
		height=_heightBox.GetText().ToInt()
		size=_sizeBox.GetText().ToInt()
		
		If width<=0 Then width=256
		If height<=0 Then height=256
		If size<=0 Then size=12
		
		style=SMOOTHFONT
		If _buttonBold.GetState() Then style:|BOLDFONT
		If _buttonItalic.GetState() Then style:|ITALICFONT
		
		Local font:TImageFont
		font=LoadImageFont( _fontFile,size,style )
		If Not font Then Return
		
		Local range:TList=New TList
		
		For Local c:Int=0 Until _rangeBox.GetItemCount()
			range.AddLast _rangeBox.GetItemExtra(c)
		Next
		
		If range.Count()=0 Then range.AddLast TCharRange.Create( 32,128 )
		
		Local tab:TFontTab=TFontTab.Create( _tabber,StripExt(StripDir(_fontFile))+"_"+size,font,width,height,range )
		_selectBitmap.SetRange 0,tab.GetBitmapCount()-1
		_bitmapLabel.SetText "Current bitmap: 0"
		
		range.Clear
		range=Null
	
	End Method
	
	Method OnClose:Int()
	
		_running=False
		Return Super.OnClose()
	
	End Method

	Method OnGadgetAction:Int( obj:TGadgetObject )
	
		Select obj
		
		Case _buttonExit
			_running=False
			Return False
			
		Case _buttonBrowse
			_fontFile:String=RequestFile( "Open font file","Font files:ttf,fon;All Files:*" )
			If _fontFile<>"" Then _fontBox.SetText StripDir(_fontFile)
			
		Case _buttonCreate
			CreateBitmapFont
			
		Case _buttonAddRange 'FIXME
			If _fromCharacter.GetText()<>"" And _toCharacter.GetText()<>"" Then
				Local fromChar:Int=_fromCharacter.GetText().ToInt()
				Local toChar:Int=_toCharacter.GetText().ToInt()
				
				If fromChar<toChar Then
					Local rangeString:String=fromChar+":"+toChar+" ['"+Chr(fromChar)+"']-['"+Chr(toChar)+"']"
					_rangeBox.AddItem rangeString,0,-1,"",TCharRange.Create(fromChar,toChar)					
				End If
			End If
		
		Case _buttonRemoveRange
			If _rangeBox.SelectedItem()>-1 Then _rangeBox.RemoveItem _rangeBox.SelectedItem()
			
		Case _tabber
			_selectBitmap.SetRange( 0,TFontTab(_tabber.GetTab(EventData())).GetBitmapCount()-1 )
			_selectBitmap.SetValue( 0 )
			TFontTab( _tabber.GetTab(EventData()) ).SetBitmap 0
			
		Case _selectBitmap
			TFontTab( _tabber.GetTab(_tabber.SelectedItem()) ).SetBitmap EventData()
			_bitmapLabel.SetText "Current bitmap: "+EventData()

		End Select
		
		Return True
	
	End Method
	
	Method OnMenuAction:Int( obj:TGadgetObject,tag:Int )
	
		Select tag
		
		Case MENU_FILE_NEW
			Notify "New"
			
		Case MENU_FILE_EXIT
			_running=False
			Return False
		
		End Select
		
		Return True
	
	End Method
	
	Method CreateMenuItems( parent:TGadgetObject )
	
		Local num:Int
		Local label:String,tag:Int,hotkey:Int,modifier:Int
	
		ReadData num
		
		For Local i:Int=0 Until num
		
			ReadData label,tag,hotkey,modifier
			CreateMenu( label,tag,parent,hotkey,modifier )
			
		Next
	
	End Method

	Method InitControls()
	
		' FIXME:
		' Clean this up and make it easier to change layout
		' I tried to keep this somewhat clean but failed
		
		Local x:Int,y:Int,w:Int,h:Int
	
		' Create tabber
		'
		_tabber=CreateTabber( 0,0,GetClientWidth()-250,GetClientHeight(),Self )
		_tabber.SetLayout 1,1,1,1
		
		' Create menu
		'
		_fileMenu=CreateMenu( "&File",0,Self,0,0 )
		_editMenu=CreateMenu( "&Edit",0,Self,0,0 )
		
		RestoreData FileMenuData
		CreateMenuItems _fileMenu
		
		RestoreData EditMenuData
		CreateMenuItems _editMenu
		
		UpdateMenu()
		
		' Create tool panel
		'
		x=GetClientWidth()-250 ; y=0 ; w=GetClientWidth()-x ; h=GetClientHeight()	
		_panel=CreatePanel( x,y,w,h,Self )
		_panel.SetLayout 0,1,1,1
		
		' Exit button
		'
		_buttonExit=CreateButton( "&Exit",(_panel.GetClientWidth()-80)/2,GetClientHeight()-34,80,24,_panel )
		_buttonExit.SetLayout 0,1,0,1
		
		' Font file panel
		'
		Local tmpPanel:TPanel=CreatePanel( 5,5,_panel.GetClientWidth()-10,410,_panel,PANEL_GROUP,"Font file" )
		tmpPanel.SetLayout 0,0,1,0
		
		x=5 ; y=5 ; w=tmpPanel.GetClientWidth()-35 ; h=24		
		_fontBox=CreateTextField( x,y,w,h,tmpPanel )
		_buttonBrowse=CreateButton( "...",tmpPanel.GetClientWidth()-30,5,25,24,tmpPanel )
		
		x=tmpPanel.GetClientWidth()-75 ; y=35 ; w=50 ; h=24
		_buttonBold=CreateButton( "Bold",x,y,w,h,tmpPanel,BUTTON_CHECKBOX )
		_buttonItalic=CreateButton( "Italic",x,55,50,24,tmpPanel,BUTTON_CHECKBOX )

		_sizeBox=CreateComboBox( 5,35,tmpPanel.GetClientWidth()/4,24,tmpPanel,COMBOBOX_EDITABLE )
		For Local s:String=EachIn _fontSizeData
			_sizeBox.AddItem s
		Next
		_sizeBox.SelectItem 0
		
		_buttonCreate=CreateButton( "&Create",5,tmpPanel.GetClientHeight()-29,90,24,tmpPanel )
		
		Local sizePanel:TPanel=CreatePanel( 5,80,tmpPanel.GetClientWidth()-10,55,tmpPanel,PANEL_GROUP,"Texture size" )
		
		Local width:Int=(sizePanel.GetClientWidth()-50)/2
		_widthBox=CreateComboBox( 10,5,width,24,sizePanel )
		_heightBox=CreateComboBox( sizePanel.GetClientWidth()-10-width,5,width,24,sizePanel )
		CreateLabel "X",width+10,8,(sizePanel.GetClientWidth()-10-width)-(width+10),24,sizePanel,LABEL_CENTER
		
		For Local s:String=EachIn _textureSizeData
			_widthBox.AddItem s
			_heightBox.AddItem s
		Next
		_widthBox.SelectItem 2
		_heightBox.SelectItem 2
		
		tmpPanel=CreatePanel( 5,140,tmpPanel.GetClientWidth()-10,215,tmpPanel,PANEL_GROUP,"Character range(s)" )
		
		width=(tmpPanel.GetClientWidth()-60)/2
		_fromCharacter=CreateTextField( 10,5,width,24,tmpPanel )
		_toCharacter=CreateTextField( tmpPanel.GetClientWidth()-10-width,5,width,24,tmpPanel )
		
		CreateLabel "to",width+10,8,(tmpPanel.GetClientWidth()-10-width)-(width+10),24,tmpPanel,LABEL_CENTER
		_rangeBox=CreateListBox( 10,35,tmpPanel.GetClientWidth()-20,tmpPanel.GetClientHeight()-40-30,tmpPanel )
		
		width=(tmpPanel.GetClientWidth()-40)/2
		_buttonAddRange=CreateButton( "&Add",10,tmpPanel.GetClientHeight()-30,width,24,tmpPanel )
		_buttonRemoveRange=CreateButton( "&Remove",tmpPanel.GetClientWidth()-10-width,tmpPanel.GetClientHeight()-30,width,24,tmpPanel )
		
		_selectBitmap=CreateSlider( 5,435,_panel.GetClientWidth()-10,24,_panel,SLIDER_TRACKBAR|SLIDER_HORIZONTAL )
		_selectBitmap.SetRange 0,0
		
		_bitmapLabel=CreateLabel( "Current bitmap: -",5,420,_panel.GetClientWidth()-10,24,_panel )
	
	End Method

	Function Create:TFontWindow( width:Int,height:Int )
		
		Local window:TFontWindow=New TFontWindow
		
		If Not window.Init( "Bitmap Font Creator",0,0,800,600,Null,_style ) Return Null
		window.SetMinSize 640,480
		window.InitControls()
		
		Return window
	
	End Function
	
End Type

Global _window:TFontWindow

Public

Function CreateBitmapFont()

	_window=TFontWindow.Create( 800,600 )

End Function


CreateBitmapFont

While _running

	HandleWindowEvents()
	
Wend
