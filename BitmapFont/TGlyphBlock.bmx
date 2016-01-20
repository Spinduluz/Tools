
Type TGlyphBlock

	Field _index:Int
	Field _width:Int
	Field _height:Int
	Field _alloced:Int[,]
	Field _texels:Byte[]
	Field _image:TImage
	
	Method BlockAlloc:Int( width:Int,height:Int,x:Int Var,y:Int Var )
	
		Local best:Int,best2:Int,i:Int,j:Int
		
		For Local n:Int=0 Until 1
			best=_height
		
			For i:Int=0 Until _width-width
				best2=0
				
				For j=0 Until width
					If _alloced[n,i+j]>=best Exit
					If _alloced[n,i+j]>best2 best2=_alloced[n,i+j]
				Next
				If j=width
					x=i;
					y=best2
					best=best2
				End If
			Next
			
			If best+height>_height Continue
			
			For i:Int=0 Until width
				_alloced[n,x+i]=best+height
			Next
			
			Return n		
		Next
		Return -1	
		
	End Method
	
	Method Free()
	
		_image.Lock(0,True,True).ClearPixels 0
		_alloced=Null
		_texels=Null
		_image=Null
	
	End Method
	
	Function Create:TGlyphBlock( width:Int,height:Int )
	
		Local block:TGlyphBlock=New TGlyphBlock
		block._width=width
		block._height=height
		block._alloced=New Int[1,block._width]
		block._texels=New Byte[block._width*block._height]
		block._image=CreateImage( block._width,block._height,1,0 )
		Return Block
		
	End Function

End Type

