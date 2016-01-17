
Function ConvertGlyph:TImage( Glyph:TImageGlyph )

	Local pixmap:TPixmap=Glyph.Pixels().Lock( 0,True,True )
	Local convert:TPixmap=CreatePixmap( pixmap.Width,pixmap.Height,PF_RGBA8888 ) 'Glyph.Pixels().Lock( 0,True,True ).Convert( PF_RGBA8888 )
	
	For Local y:Int=0 Until pixmap.Height
		For Local x:Int=0 Until pixmap.Width
			Local src:Byte Ptr=pixmap.PixelPtr( x,y )
			Local dst:Byte Ptr=convert.PixelPtr( x,y )
			
			If src[0]>0
				dst[0]=src[0]
				dst[1]=src[0]
				dst[2]=src[0]
				dst[3]=src[0]
			Else
				dst[0]=0
				dst[1]=0
				dst[2]=0
				dst[3]=0
			EndIf
		Next
	Next
	
	Local ret:TImage=CreateImage( convert.Width,convert.Height,1,0 )
	ret.SetPixmap( 0,convert )
	Return ret
		
End Function

Function CopyImage( dst:TImage,src:TImage,x:Int,y:Int )

	Local srcpixmap:TPixmap=src.Lock( 0,True,True )
	Local dstpixmap:TPixmap=dst.Lock( 0,True,True )
	
	For Local r:Int=0 Until src.height
		Local s:Byte Ptr=srcpixmap.PixelPtr( 0,r )
		Local d:Byte Ptr=dstpixmap.PixelPtr( x,y+r )
		MemCopy d,s,srcpixmap.pitch
	Next
	
End Function 

'----------------------------------------------------------------------------------------------------------------

Type TBitmapFont

	Field _blocks:TList
	Field _glyphs:TList
	
	Method GetGlyphBlock:TGlyphBlock( index:Int )
	
		Return TGlyphBlock( _blocks.ValueAtIndex(index) )
		
	End Method
	
	Method GetBlockImage:TImage( index:Int )

		Local block:TGlyphBlock=GetGlyphBlock( index )
		Return block._image
	
	End Method
	
	Method GetBlockCount:Int()
	
		Return _blocks.Count()
	
	End Method
	
	Method Remove()
	
		For Local block:TGlyphBlock=EachIn _blocks
			block.Remove
			block=Null
		Next
		_blocks.Clear
		_glyphs.Clear
		_blocks=Null
		_glyphs=Null
	
	End Method
	
	Function Create:TBitmapFont( font:TImageFont,start:Int,stop:Int,texw:Int,texh:Int )
	
		Local bitmapfont:TBitmapFont=New TBitmapFont
		Local glyph:TImageGlyph
		Local image:TImage
		Local block:TGlyphBlock=TGlyphBlock.Create( texw,texh )
		
		bitmapfont._glyphs=New TList
		bitmapfont._blocks=New TList
		
		block._index=bitmapfont._blocks.Count()
		bitmapfont._blocks.AddLast block
								
		For Local c:Int=start Until stop
		
			If c<=32 Continue 'Skip whitespaces
	
			Local x:Int,y:Int,r:Int,char:Int
			
			char=font.CharToGlyph( c )
			If char=-1 Continue

			glyph=font.LoadGlyph( char )
			image=ConvertGlyph( glyph )
			
			If Not image Continue
	
			For Local b:TGlyphBlock=EachIn bitmapfont._blocks
			
				r=b.BlockAlloc( image.width,image.height,x,y )
				If r<>-1
				
					bitmapfont._glyphs.AddLast( TGlyphMetrics.Create(b._index,x,y,image.width,image.height,glyph.Advance()) )
					CopyImage b._image,image,x,y
					Exit
					
				EndIf
						
			Next
			
			If r=-1
			
				block=TGlyphBlock.Create( texw,texh )
				block.BlockAlloc( image.width,image.height,x,y )
				CopyImage block._image,image,x,y
				
				block._index=bitmapfont._blocks.Count()
				bitmapfont._blocks.AddLast block
				bitmapfont._glyphs.AddLast( TGlyphMetrics.Create(block._index,x,y,image.width,image.height,glyph.Advance()) )
									
			EndIf
	
		Next
		
		Return bitmapfont		
	
	End Function 
End Type
