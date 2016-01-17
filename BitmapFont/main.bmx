SuperStrict

Framework Openb3d.b3dglgraphics

Rem
?Win32
Import MaxGui.FLTKMaxGui
?Not Win32
Import MaxGui.Drivers
?
End Rem
Import MaxGUI.Drivers
Import MaxGUI.XPmanifest

Import MaxGUI.Localization
Import MaxGui.ProxyGadgets
Import BRL.FreetypeFont
Import BRL.EventQueue
Import BRL.PngLoader

Import "../Window.bmx"

Private

Include "TGlyphMetrics.bmx"
Include "TGlyphBlock.bmx"
Include "TBitmapFont.bmx"
Include "TFontTab.bmx"

Const _fltkmaxgui:Int=False

Const MENU_FILE_NEW:Int=1000
Const MENU_FILE_LOAD:Int=1001
Const MENU_FILE_SAVE:Int=1002
Const MENU_FILE_SAVEAS:Int=1003
Const MENU_FILE_CLOSETAB:Int=1004
Const MENU_FILE_EXIT:Int=1005

Global _fontsizes:String[]=["8","9","10","11","12","14","16","18","20","22","24","28","36","72","100"]
Global _texsizes:String[]=["64","128","256","512","1024"]

Const  _style:Int=WINDOW_CENTER|WINDOW_TITLEBAR|WINDOW_STATUS|WINDOW_MENU|WINDOW_CLIENTCOORDS|WINDOW_RESIZABLE
Global _window:TGadget
Global _tabber:TGadget
Global _filemenu:TGadget
Global _current:TFontTab
Global _textureslider:TGadget
Global _gadgets:TList=New TList

Function IsFontBuilderItem:Int( source:Object )

	For Local item:Object=EachIn _gadgets
		If item=source Return True
	Next
	Return False

End Function

Public

_window=CreateWindow( "Generation",0,0,800,600,Null,_style )
_gadgets.AddLast _window

' Create file menu
_filemenu=CreateMenu( "&File",0,WindowMenu(_window) )
_gadgets.AddLast _filemenu

_gadgets.AddLast CreateMenu( "&New",MENU_FILE_NEW,_filemenu,KEY_N,MODIFIER_COMMAND )
CreateMenu "",0,_filemenu
_gadgets.AddLast CreateMenu( "&Load",MENU_FILE_LOAD,_filemenu,KEY_L,MODIFIER_COMMAND )
_gadgets.AddLast CreateMenu( "&Save",MENU_FILE_SAVE,_filemenu,KEY_S,MODIFIER_COMMAND )
_gadgets.AddLast CreateMenu( "Save &As",MENU_FILE_SAVEAS,_filemenu,KEY_A,MODIFIER_COMMAND )
CreateMenu "",0,_filemenu
_gadgets.AddLast CreateMenu( "&Close Tab",MENU_FILE_CLOSETAB,_filemenu,KEY_W,MODIFIER_COMMAND )
CreateMenu "",0,_filemenu
_gadgets.AddLast CreateMenu( "E&xit",MENU_FILE_EXIT,_filemenu,KEY_F4,MODIFIER_ALT )
' Create edit menu

_tabber=CreateTabber( 0,0,ClientWidth(_window),ClientHeight(_window)-30,_window )
_gadgets.AddLast _tabber
SetGadgetLayout _tabber,1,1,1,1
ClearGadgetItems _tabber

_textureslider=CreateSlider( 10,ClientHeight(_window)-30,80,24,_window,SLIDER_HORIZONTAL|SLIDER_TRACKBAR )
_gadgets.AddLast _textureslider
SetSliderRange _textureslider,0,0

UpdateWindowMenu _window 

_current=Null
If TFontTab.GetTabCount()
	_current=TFontTab.GetTab( 0 )
	_current.Show()
End If

Local running:Int=True

While running

	If PollEvent()
		If IsFontBuilderItem( EventSource() )
			Select EventID()
			
				Case EVENT_WINDOWCLOSE
					FreeGadget _window
					running=False
					
				Case EVENT_GADGETACTION
					If EventSource()=_tabber
						_current.Hide()
						_current=TFontTab.GetTab( EventData() )
						_current.Show()
						
						SetSliderRange _textureslider,0,_current.GetBlockCount()-1
					End If
					
					If EventSource()=_textureslider
						If _current
							_current.SetBlockImage( SliderValue(_textureslider) )						
						End If
					End If
					
				Case EVENT_MENUACTION
					Select EventData()
						Case MENU_FILE_NEW
							If TFontTab.Create()
								If _current _current.Hide()
								_current=TFontTab.GetTab( TFontTab.GetTabCount()-1 )
								_current.Show()
								SetSliderRange _textureslider,0,_current.GetBlockCount()-1
								SelectGadgetItem _tabber,TFontTab.GetTabCount()-1
							End If
							ActivateGadget _window
							
						Case MENU_FILE_CLOSETAB
							TFontTab.RemoveTab SelectedGadgetItem(_tabber)
					
						Case MENU_FILE_EXIT
							FreeGadget _window
							running=False
							
					End Select
					
			End Select
		End If
	End If

	RunEventCallback()

Wend