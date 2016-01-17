
Type TGlyphMetrics

	Field _index:Int
	Field _char:Int
	Field _x:Int
	Field _y:Int
	Field _width:Int
	Field _height:Int
	Field _advance:Float
	
	Function Create:TGlyphMetrics( index:Int,x:Int,y:Int,width:Int,height:Int,advance:Float )
	
		Local metrics:TGlyphMetrics=New TGlyphMetrics
		metrics._index=index
		metrics._y=y
		metrics._x=x
		metrics._width=width
		metrics._height=height
		metrics._advance=advance
		Return metrics
	
	End Function
	
End Type
