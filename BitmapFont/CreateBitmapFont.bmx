SuperStrict

Import MaxGUI.Drivers
Import MaxGUI.XPmanifest
Import MaxGui.ProxyGadgets

Import BRL.FreetypeFont
Import BRL.EventQueue

Import "../Window.bmx"

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
	
	Method Free()
		
		Super.Free
		
		If _panel Then FreeGadget _panel
		_panel=Null
	
	End Method

	Function Create:TFontTab( tabber:TTabber,Text:String )
	
		Local tab:TFontTab=New TFontTab
		tab._panel=CreateScrollPanel( 0,0,tabber.GetClientWidth(),tabber.GetClientHeight(),tabber._object )
		tab._object=ScrollPanelClient( TScrollPanel(tab._panel) )
		SetGadgetLayout tab._panel,1,1,1,1
		
		tabber.AddTab tab,Text
		
		Return tab
	
	End Function

End Type

Type TFontWindow Extends TWindow

	Field _tabber:TTabber
	Field _panel:TPanel
	Field _buttonExit:TButton
	
	Field _fileMenu:TMenu
	Field _editMenu:TMenu
	
	Method OnClose:Int()
	
		_running=False
		Return Super.OnClose()
	
	End Method

	Method OnGadgetAction:Int( obj:TGadgetObject )
	
		Select obj
		
		Case _buttonExit
			_running=False
			Return False
		
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
	
		_tabber=CreateTabber( 0,0,GetClientWidth()-200,GetClientHeight(),Self )
		_tabber.SetLayout 1,1,1,1
		
		TFontTab.Create( _tabber,"Font 0" )
		TFontTab.Create( _tabber,"Font 1" )
		TFontTab.Create( _tabber,"Font 2" )
		
		Local x:Int=GetClientWidth()-200
		_panel=CreatePanel( x,0,GetClientWidth()-x,GetClientHeight(),Self )
		_panel.SetLayout 0,1,1,1
		
		_buttonExit=CreateButton( "&Exit",(_panel.GetClientWidth()-80)/2,GetClientHeight()-34,80,24,_panel )
		_buttonExit.SetLayout 0,1,0,0
		
		_fileMenu=CreateMenu( "&File",0,Self,0,0 )
		_editMenu=CreateMenu( "&Edit",0,Self,0,0 )
		
		RestoreData FileMenuData
		CreateMenuItems _fileMenu
		
		RestoreData EditMenuData
		CreateMenuItems _editMenu
		
		UpdateMenu()
	
	End Method

	Function Create:TFontWindow( width:Int,height:Int )
		
		Local window:TFontWindow=New TFontWindow
		
		If Not window.Init( "Bitmap Font Creator",0,0,800,600,Null,_style ) Return Null
		window.InitControls()
		
		Return window
	
	End Function
	
End Type

Const _style:Int=WINDOW_CENTER|WINDOW_TITLEBAR|WINDOW_STATUS|WINDOW_MENU|WINDOW_CLIENTCOORDS|WINDOW_RESIZABLE

Global _window:TFontWindow

Public

Function CreateBitmapFont()

	_window=TFontWindow.Create( 800,600 )

End Function


CreateBitmapFont

While _running

	HandleWindowEvents()
	
Wend
