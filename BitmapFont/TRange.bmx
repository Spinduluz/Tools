
Type TCharRange

	Field _start:Int
	Field _stop:Int
	
	Function Create:TRange( start:Int,stop:Int )
	
		Local range:TRange=New TRange
		range._start=start
		range._stop=stop
	
	End Function

End Type
