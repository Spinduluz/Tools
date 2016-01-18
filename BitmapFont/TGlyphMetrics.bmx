
Type TGlyphMetrics

	Field _index:Int
	Field _char:Int
	Field _x:Int
	Field _y:Int
	Field _width:Int
	Field _height:Int
	Field _advance:Float
	
	Field _glyph_x:Int
	Field _glyph_y:Int
	Field _glyph_w:Int
	Field _glyph_h:Int
	
	Function Create:TGlyphMetrics( index:Int,char:Int,x:Int,y:Int,width:Int,height:Int,glyph:TImageGlyph )
	
		Local metrics:TGlyphMetrics=New TGlyphMetrics
		metrics._index=index
		metrics._char=char
		metrics._y=y
		metrics._x=x
		metrics._width=width
		metrics._height=height
		metrics._advance=glyph.Advance()
		
		glyph.GetRect( metrics._glyph_x,metrics._glyph_y,metrics._glyph_w,metrics._glyph_h )
		DebugLog metrics._glyph_x+" "+metrics._glyph_y+" "+metrics._glyph_w+" "+metrics._glyph_h+" ["+Chr(char)+"]"
		
		Return metrics
	
	End Function
	
End Type
