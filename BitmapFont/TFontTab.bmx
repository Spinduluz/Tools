
Global _fontSizes:String[]=["8","9","10","11","12","14","16","18","20","22","24","28","36","72","100"]
Global _texSizes:String[]=["64","128","256","512","1024","2048","4096","8192"]

Function NewFontDialog:Int( fontpath:String Var,fsize:Int Var,texwidth:Int Var,texheight:Int Var )

	Local dialog:TGadget=CreateWindow( "New font",0,0,320,304,_window,WINDOW_CENTER|WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS )
	Local pathBox:TGadget=CreateTextField( 10,10,230,24,dialog )
	Local buttonBrowse:TGadget=CreateButton( "...",240,10,20,24,dialog )
	Local sizeBox:TGadget=CreateComboBox( 260,10,50,24,dialog,COMBOBOX_EDITABLE )
	Local ranges:TGadget=CreateListBox( 190,130,120,164,dialog )
	Local buttonOk:TGadget=CreateButton( "&Ok",10,270,80,24,dialog )
	Local buttonCancel:TGadget=CreateButton( "&Cancel",100,270,80,24,dialog ) 
	Local running:Int=True
	Local widthBox:TGadget=CreateComboBox( 90,45,60,24,dialog )
	Local heightBox:TGadget=CreateComboBox( 90,70,60,24,dialog )
	
	Local rangeStart:TGadget=CreateTextField( 20,135,60,24,dialog )
	Local rangeStop:TGadget=CreateTextField( 105,135,60,24,dialog )
	
	Local rangeAdd:TGadget=CreateButton( "&Add",20,165,60,24,dialog )
	Local rangeRemove:TGadget=CreateButton( "&Remove",105,165,60,24,dialog )
	
	fontpath=""
	fsize=0
	texwidth=0
	texheight=0
	
	Local widthLabel:TGadget=CreateLabel( "Texture width:",10,50,90,24,dialog )
	Local heightLabel:TGadget=CreateLabel( "Texture height:",10,75,90,24,dialog )
	Local rangesLabel:TGadget=CreateLabel( "Character ranges",190,110,120,24,dialog,LABEL_CENTER )
	
	CreateLabel "",10,105,300,5,dialog,LABEL_SEPARATOR
	Local rangeTitle:TGadget=CreateLabel( "Add/Remove ranges",10,110,175,24,dialog,LABEL_CENTER )
	Local addRange:TGadget=CreateLabel( "to",70,140,45,24,dialog,LABEL_CENTER )
	
	For Local s:String=EachIn _fontSizes
	
		AddGadgetItem sizeBox,s
		
	Next
	SelectGadgetItem sizeBox,3
	
	For Local s:String=EachIn _texSizes
	
		AddGadgetItem widthBox,s
		AddGadgetItem heightBox,s
		
	Next
	SelectGadgetItem widthBox,2
	SelectGadgetItem heightBox,2
	
	'Adjust stuff
	If _fltkmaxgui
		SetGadgetShape widthBox,95,45,60,24
		SetGadgetShape heightBox,95,70,60,25
		SetGadgetShape widthLabel,10,45,90,24
		SetGadgetShape heightLabel,10,70,90,24
	End If
	
	While running
	
		If PollEvent()
			
			Select EventID()
			
			Case EVENT_WINDOWCLOSE
				running=False
				FreeGadget dialog
				
			Case EVENT_GADGETSELECT
				If EventSource()=ranges
					
					Local index:Int
					Local range:TCharRange
					
					index=EventData()
					If index=-1 Continue
					
					range=TCharRange( EventExtra() )
					
					SetGadgetText rangeStart,range._start
					SetGadgetText rangeStop,range._stop
					
				End If 'EventSource()=ranges
			
			Case EVENT_GADGETACTION
				If EventSource()=buttonBrowse
				
					fontpath=RequestFile( "Open font file","Font files:ttf,fon;All Files:*",False,"" )
					If fontpath<>""
					
						SetGadgetText pathBox,StripDir(fontpath)
						
					End If
					
				End If 'EventSource()=buttonBrowse
				
				If EventSource()=buttonCancel
				
					FreeGadget dialog
					Return False
					
				End If 'EventSource()=buttonCancel
				
				If EventSource()=rangeAdd
				
					If GadgetText( rangeStart )="" Or GadgetText( rangeStop )="" Continue
					
					Local start:Int=GadgetText(rangeStart).ToInt()
					Local stop:Int=GadgetText(rangeStop).ToInt()
					
					If start=0 Or stop=0 Continue
					
					AddGadgetItem ranges,start+"-"+stop,0,-1,"",TCharRange.Create(start,stop)
					
					SetGadgetText rangeStart,""
					SetGadgetText rangeStop,""
					
				End If 'EventSource()=rangeAdd
				
				If EventSource()=rangeRemove
				
					If SelectedGadgetItem( ranges )=-1 Continue
					RemoveGadgetItem ranges,SelectedGadgetItem(ranges)
					
				End If 'EventSource()=rangeRemove
				
				If EventSource()=buttonOk
				
					If fontpath<>"" And FileType(fontpath)=1
					
						fsize=GadgetText(sizeBox).ToInt()
						texwidth=GadgetText(widthBox).ToInt()
						texheight=GadgetText(heightBox).ToInt()
						
						If Not fsize fsize=11
						If Not texwidth texwidth=256
						If Not texheight texheight=256
						
						FreeGadget( dialog )
						Return True
						
					End If
					
				End If 'EventSource()=buttonOk
				
			End Select
						
		End If
	
	Wend
	
	Return False		

End Function

'----------------------------------------------------------------------------------------------------------------

Type TFontTab

	Field _scrollpanel:TScrollpanel
	Field _panel:TGadget
	Field _path:String
	Field _size:Int
	Field _bitmapfont:TBitmapFont
	Field _currentpixmap:TPixmap
	Field _texwidth:Int
	Field _texheight:Int
	
	Global _tabs:TList=New TList
	
	Method Hide()
	
		HideGadget _scrollpanel
		
	End Method
	
	Method Show()
	
		ShowGadget _scrollpanel
	
	End Method
	
	Method Remove()
	
		_panel=Null
		_scrollpanel=Null
		_currentpixmap=Null
		_bitmapfont.Remove
	
	End Method
	
	Method GetBitmapFont:TBitmapFont()
	
		Return _bitmapfont
	
	End Method
	
	Method GetBlockCount:Int()
	
		Return _bitmapfont.GetBlockCount()
	
	End Method
	
	Method SetBlockImage( index:Int )
	
		_currentpixmap=_bitmapfont.GetBlockImage(index).Lock(0,True,True)
		SetGadgetPixmap _panel,_currentpixmap,PANELPIXMAP_CENTER
	
	End Method
	
	Function GetTab:TFontTab( index:Int )
	
		Return TFontTab( _tabs.ValueAtIndex(index) )
	
	End Function
	
	Function GetLastTab:TFontTab()
	
		Return TFontTab( _tabs.Last() ) 
	
	End Function
	
	Function GetTabCount:Int()
	
		Return _tabs.Count()
	
	End Function
	
	Function RemoveTab( index:Int )
	
		If index<0 Return
		
		Local tab:TFontTab=TFontTab( _tabs.ValueAtIndex(index) )
		
		_tabs.Remove tab
		RemoveGadgetItem _tabber,index
		
		If _current=tab
			If CountGadgetItems( _tabber )=0
				_current.Hide()
				_current=Null
				SetGadgetPixmap tab._panel,Null
			Else
				_current=TFontTab( _tabs.Last() )
			End If		
		End If
		
		tab.Remove		
	
	End Function
	
	Function Create:TFontTab()
		
		Local tab:TFontTab=New TFontTab
		Local size:Int
		'
		If Not NewFontDialog( tab._path,tab._size,tab._texwidth,tab._texheight ) Return Null
	
		tab._scrollpanel=CreateScrollPanel( 0,0,ClientWidth(_tabber),ClientHeight(_tabber),_tabber,0 )
		SetGadgetLayout tab._scrollpanel,1,1,1,1
		HideGadget tab._scrollpanel

		AddGadgetItem _tabber,StripDir( StripExt(tab._path) )+"_"+tab._size
		_tabs.AddLast tab
		
		Local font:TImageFont=LoadImageFont( tab._path,tab._size,0 )
		tab._bitmapfont=TBitmapFont.Create( font,33,128,tab._texwidth,tab._texheight )
		
		tab._panel=ScrollPanelClient( tab._scrollpanel )
		SetGadgetColor tab._panel,0,0,0

		tab.SetBlockImage( 0 )
		SetGadgetShape tab._panel,0,0,tab._currentpixmap.width,tab._currentpixmap.height
			
		Return tab
	
	End Function

End Type

