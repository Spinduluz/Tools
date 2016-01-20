SuperStrict

Import MaxGUI.Drivers
Import MaxGUI.ProxyGadgets

Private

Global _windows:TList=New TList
Global _currentGadgetList:TList=Null

Function _GetGadget:TGadget( obj:TGadgetObject )

	If obj Then Return obj._object
	Return Null
	
End Function

Function _isEventSource:Int( obj:TGadgetObject )

	If EventSource()=obj._object Then Return True
	For Local gadget:TGadgetObject=EachIn obj._childs
		If EventSource()=gadget._object Then Return True
		If _FindEventSource( gadget ) Then Return True
	Next
	Return False

End Function

Function _findEventSource:TGadgetObject( obj:TGadgetObject )

	If EventSource()=obj._object Then Return obj
	For Local gadget:TGadgetObject=EachIn obj._childs
		If EventSource()=gadget._object Then Return gadget
		Local g:TGadgetObject=_findEventSource( gadget )
		If g Then Return g
	Next

End Function

Public

Function HandleWindowEvents()

	If Not PollEvent() Then Return

	For Local window:TWindow=EachIn _windows
	
		Local obj:TGadgetObject=_findEventSource( window )
	
		If obj Then

			Local dontfree:Int=True
		
			Select EventID()
			Case EVENT_WINDOWCLOSE
				dontfree=window.OnClose()
				
			Case EVENT_WINDOWSIZE
				dontfree=window.OnSize( EventX(),EventY() )
				
			Case EVENT_WINDOWMOVE
				dontfree=window.OnMove( EventX(),EventY() )
				
			Case EVENT_WINDOWACTIVATE
		
			Case EVENT_WINDOWACCEPT
			
			Case EVENT_GADGETACTION
				If obj.GetClass()=GADGET_TABBER Then
					TTabber( obj ).ShowTab( EventData() )
					dontfree=window.OnGadgetAction( obj )
				Else
					dontfree=window.OnGadgetAction( obj )
				End If
			
			Case EVENT_MENUACTION
				If obj.GetClass()=GADGET_MENUITEM Then
					dontfree=window.OnMenuAction( obj,TMenu(obj)._tag )
				Else
				
				End If
				
			End Select
		
			If Not dontfree Then
				
				_windows.Remove window
				window.Free
				
			End If
			
		End If
	
	Next

End Function

'
' TGadgetObject
'
Type TGadgetObject

	Field _object:TGadget
	Field _childs:TList=New TList
	
	Method Show()
	
		If Not _object Then Return
		ShowGadget _object
	
	End Method
	
	Method Hide()
	
		If Not _object Then Return
		HideGadget _object
	
	End Method
	
	Method SetLayout( Left:Int,Right:Int,top:Int,bottom:Int )
	
		If Not _object Then Return
		SetGadgetLayout _object,Left,Right,top,bottom
	
	End Method
	
	Method SetColor( red:Int,green:Int,blue:Int,bg:Int=True )
	
		If Not _object Then Return
		SetGadgetColor _object,red,green,blue,bg
	
	End Method
	
	Method AddItem( Text:String,flags:Int=0,icon:Int=-1,tip:String="",extra:Object=Null )
	
		If Not _object Then Return
		AddGadgetItem _object,Text,flags,icon,tip,extra
	
	End Method
	
	Method InsertItem( index:Int,Text:String,flags:Int=0,icon:Int=-1,tip:String="",extra:Object )
	
		If Not _object Then Return
		InsertGadgetItem _object,index,Text,flags,icon,tip,extra
	
	End Method
	
	Method SelectItem( index:Int )
	
		If Not _object Then Return
		SelectGadgetItem _object,index
	
	End Method
	
	Method GetItemCount:Int()
	
		If Not _object Then Return -1
		Return CountGadgetItems( _object )
	
	End Method
	
	Method ClearItems()
	
		If Not _object Then Return
		ClearGadgetItems _object
	
	End Method
	
	Method GetClientWidth:Int()
	
		Return ClientWidth( _object )
	
	End Method
	
	Method GetClientHeight:Int()
	
		Return ClientHeight( _object )
	
	End Method
	
	Method GetClass:Int()
	
		If Not _object Then Return -1
		Return GadgetClass( _object )
	
	End Method

	Method Free()
	
		For Local gadget:TGadgetObject=EachIn _childs
		
			gadget.Free
			gadget=Null
		
		Next
		
		_childs.Clear
		_childs=Null
	
		If _object Then FreeGadget( _object )
		_object=Null
	
	End Method

End Type

'
' TTab
'

Type TTab
End Type

'
' TTabber
'
Type TTabber Extends TGadgetObject

	Field _tabs:TList=New TList
	Field _currentTab:TGadgetObject
	
	Method AddTab( obj:TGadgetObject,Text:String )
	
		If Not _object Then Return
		AddItem Text
		
		_tabs.AddLast obj
		
		If Not _currentTab Then 
			_currentTab=TGadgetObject( _tabs.ValueAtIndex(0) )
			_currentTab.Show
		End If
	
	End Method
	
	Method GetTab:TGadgetObject( index:Int )
	
		If index<0 And index>=GetTabCount() Then Return Null
		Return TGadgetObject( _tabs.ValueAtIndex(index) )
	
	End Method
	
	Method GetTabCount:Int()
	
		Return _tabs.Count()
	
	End Method
	
	Method SelectTab( index:Int )
	
		Local count:Int=GetItemCount()
		If count<=0 Then Return
		If index<0 And index>=count Then Return
		SelectItem index
		ShowTab index
	
	End Method
	
	Method ShowTab( index:Int )
	
		Local count:Int=GetTabCount()
		If count<=0 Then Return
		If index<=0 And index>=count Then Return
		
		_currentTab.Hide
		_currentTab=GetTab( index )
		_currentTab.Show
	
	End Method

	Function Create:TTabber( x:Int,y:Int,width:Int,height:Int,group:TGadgetObject )
	
		Local tabber:TTabber=New TTabber
	
		tabber._object=CreateTabber( x,y,width,height,_GetGadget(group) )
		tabber.ClearItems
		
		If Not tabber._object Then Return Null
		If group Then group._childs.AddLast tabber
	
		Return tabber
	
	End Function
	
End Type

'
' TPanel
'
Type TPanel Extends TGadgetObject

	Function Create:TPanel( x:Int,y:Int,width:Int,height:Int,group:TGadgetObject,style:Int=0,title:String="" )
	
		Local panel:TPanel=New TPanel
		
		panel._object=CreatePanel( x,y,width,height,_GetGadget(group),style,title )
		If Not panel._object Then Return Null
		If group Then group._childs.AddLast panel
		
		Return panel
	
	End Function

End Type

'
' TMenu
'
Type TMenu Extends TGadgetObject

	Field _tag:Int

	Function Create:TMenu( label:String,tag:Int,parent:TGadgetObject,hotkey:Int,modifier:Int )
	
		Local menu:TMenu=New TMenu
		
		Local par:TGadget=Null
		If parent And parent.GetClass()=GADGET_WINDOW Then
			par=WindowMenu( _GetGadget(parent) ) 
		Else
			par=_GetGadget( parent )
		End If
		
		menu._object=CreateMenu( label,tag,par,hotkey,modifier )
		If Not menu._object Then Return Null
		
		menu._tag=tag
		If parent Then parent._childs.AddLast menu
		
		Return menu
	
	End Function

End Type

'
' TButton
'
Type TButton Extends TGadgetObject
		
	Function Create:TButton( label:String,x:Int,y:Int,width:Int,height:Int,group:TGadgetObject )
	
		Local button:TButton=New TButton
		
		button._object=CreateButton( label,x,y,width,height,_GetGadget(group) )
		If Not button._object Then Return Null

		If group Then group._childs.AddLast button
		
		Return button
	
	End Function

End Type

'
' TScrollablePanel
'
Type TScrollablePanel Extends TGadgetObject
	
	Function Create:TScrollablePanel( x:Int,y:Int,width:Int,height:Int,group:TGadgetObject,flags:Int=0 )
	
		Local panel:TScrollablePanel=New TScrollablePanel
		
		panel._object=CreateScrollPanel( x,y,width,height,_GetGadget(group),flags )
		If Not panel._object Then Return Null
		
		If group Then group._childs.AddLast panel
		
		Return panel
	
	End Function	

End Type


'
' TWindow
'
Type TWindow Extends TGadgetObject

	Field _active:Int
	
	Method CreateTabber:TTabber( x:Int,y:Int,width:Int,height:Int,group:TGadgetObject )
	
		Return TTabber.Create( x,y,width,height,group )
	
	End Method
	
	Method CreatePanel:TPanel( x:Int,y:Int,width:Int,height:Int,group:TGadgetObject,style:Int=0,title:String="" )
	
		Return TPanel.Create( x,y,width,height,group,style,title )
		
	End Method
	
	Method CreateMenu:TMenu( label:String,tag:Int,parent:TGadgetObject,hotkey:Int,modifier:Int )

		Return TMenu.Create( label,tag,parent,hotkey,modifier )
	
	End Method

	Method CreateButton:TButton( label:String,x:Int,y:Int,width:Int,height:Int,group:TGadgetObject )
	
		Return TButton.Create( label,x,y,width,height,group )
	
	End Method
	
	Method SetActive( active:Int )
	
		_active=active
	
	End Method
	
	Method UpdateMenu()
	
		UpdateWindowMenu( _object )
	
	End Method
	
	Method OnClose:Int()
	
		Return False
	
	End Method
	
	Method OnSize:Int( width:Int,height:Int )
	
		Return True
	
	End Method
	
	Method OnMove:Int( x:Int,y:Int )
	
		Return True
	
	End Method
	
	Method OnMenuAction:Int( obj:TGadgetObject,tag:Int )
	
		Return True
	
	End Method
	
	Method OnGadgetAction:Int( obj:TGadgetObject )
	
		Return True
	
	End Method

	Method Init:Int( title:String,x:Int,y:Int,width:Int,height:Int,group:TGadgetObject=Null,style:Int )
	
		Local parent:TGadget=Null
		If group Then parent=group._object
		
		_object=CreateWindow( title,x,y,width,height,parent,style )
		
		If Not _object Then Return False
		_active=True
		
		_windows.AddLast Self
	
		Return True
	
	End Method

End Type

