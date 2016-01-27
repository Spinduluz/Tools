
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
	
	Method Free()
	
		For Local block:TGlyphBlock=EachIn _blocks
		
			block.Free
			block=Null
			
		Next
		
		_blocks.Clear
		_glyphs.Clear
		_blocks=Null
		_glyphs=Null
	
	End Method
	
	Method Save( name:String,path:String )
	
		Local fullpath:String=""
	
		If name="" Then Return
		
		For Local block:TGlyphBlock=EachIn _blocks	
		
			Local pixmap:TPixmap=block._image.Lock( 0,True,True )
			
			fullpath=""
			If path<>"" Then
				fullpath=path+"/"
			End If
			fullpath:+name+"_"+block._index+".png"
			
			SavePixmapPNG( pixmap,fullpath,9 )
			
		Next
		
		fullpath=""
		If path<>"" Then
			fullpath=path+"/"
		End If
		fullpath:+name+".dat"
		
		Local stream:TStream=WriteStream( fullpath )
		
		Local sid:String="FONT"
		Local id:Byte Ptr=sid.ToCString()
		stream.Write id,4
		MemFree id
		
		stream.WriteInt _glyphs.Count()
		
		For Local g:TGlyphMetrics=EachIn _glyphs
		
			g.Write stream
		
		Next
		
		CloseStream( stream )	
	
	End Method
	
	Function Create:TBitmapFont( font:TImageFont,range:TList,texw:Int,texh:Int )
	
		If Not font Then Return Null
	
		Local bitmapfont:TBitmapFont=New TBitmapFont
		Local glyph:TImageGlyph
		Local image:TImage
		Local block:TGlyphBlock=TGlyphBlock.Create( texw,texh )
		Local char:Int
		
		bitmapfont._glyphs=New TList
		bitmapfont._blocks=New TList
		
		block._index=bitmapfont._blocks.Count()
		bitmapfont._blocks.AddLast block
		
		'Always add space if only for metrics
		'		
		char=font.CharToGlyph( 32 )
		glyph=font.LoadGlyph( char )
		bitmapFont._glyphs.AddLast( TGlyphMetrics.Create(-1,32,0,0,-1,-1,glyph) )	
		
		For Local r:TCharRange=EachIn range	
						
			For Local c:Int=r._start Until r._stop
			
				If c<=32 Then Continue 'Skip whitespaces
		
				Local x:Int,y:Int,r:Int
				
				char=font.CharToGlyph( c )
				If char=-1 Then Continue
	
				glyph=font.LoadGlyph( char )
				If Not glyph.Pixels() Then Continue
				
				image=ConvertGlyph( glyph )
				If Not image Then Continue
		
				For Local b:TGlyphBlock=EachIn bitmapfont._blocks
				
					r=b.BlockAlloc( image.width,image.height,x,y )					
					If r<>-1
					
						bitmapfont._glyphs.AddLast( TGlyphMetrics.Create(b._index,c,x,y,image.width,image.height,glyph) )
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
					bitmapfont._glyphs.AddLast( TGlyphMetrics.Create(block._index,c,x,y,image.width,image.height,glyph) )
										
				EndIf
		
			Next
		
		Next
		
		Return bitmapfont		
	
	End Function 
End Type
