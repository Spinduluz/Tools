SuperStrict

Private

Global _callbacks:Int()[20] '=[Null,Null,Null,Null,Null]
For Local i:Int=0 Until _callbacks.Length
	_callbacks[i]=Null
Next

Public

Function AddEventCallback( callback() )

	For Local i:Int=0 Until _callbacks.Length
		If Not _callbacks[i] Then 
			_callbacks[i]=callback
			Return
		EndIf
	Next

End Function

Function RemoveEventCallback( callback() )

	For Local i:Int=0 Until _callbacks.Length
		If _callbacks[i]=callback Then
			_callbacks[i]=Null
			Return
		End If
	Next
	
End Function

Function RunEventCallback()

	For Local callback()=EachIn _callbacks
		If callback Then callback()
	Next

End Function
