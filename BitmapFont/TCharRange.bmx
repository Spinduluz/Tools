
Type TCharRange

	Field _start:Int
	Field _stop:Int
	
	Function Create:TCharRange( start:Int,stop:Int )
	
		Local range:TCharRange=New TCharRange
		range._start=start
		range._stop=stop
		Return range
	
	End Function

End Type
