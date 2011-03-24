package be.alfredo.flac.metadata
{
	import be.alfredo.io.BitArray;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * This block is for storing pictures associated with the file, most 
	 * commonly cover art from CDs. There may be more than one PICTURE 
	 * block in a file.
	 * 
	 * @see http://flac.sourceforge.net/format.html#metadata_block_picture
	 */
	public class Picture
	{
		/**
		 * @private
		 */
		private var _pictureType:uint;
		
		/**
		 * The picture type according to the ID3v2 APIC frame
		 */
		public function get pictureType():uint
		{
			return _pictureType;
		}
		
		/**
		 * @private
		 */
		private var _mimeTypeLength:uint;
		
		/**
		 * The length of the MIME type string in bytes.
		 */ 
		public function get mimeTypeLength():uint
		{
			return _mimeTypeLength;
		}
		
		/**
		 * @private
		 */
		private var _mimeTypeString:String;
		
		/**
		 * The MIME type string, in printable ASCII characters 0x20-0x7e. 
		 * The MIME type may also be --> to signify that the data part is 
		 * a URL of the picture instead of the picture data itself.
		 */ 
		public function get mimeTypeString():String
		{
			return _mimeTypeString;
		}
		
		/**
		 * @private
		 */
		private var _pictureDescriptionLength:uint;
		
		/**
		 * The length of the description string in bytes.
		 */
		public function get pictureDescriptionLength():uint
		{
			return _pictureDescriptionLength;
		}
		
		/**
		 * @private
		 */
		private var _pictureDescription:String;
		
		/**
		 * The description of the picture, in UTF-8.
		 */
		public function get pictureDescription():String
		{
			return _pictureDescription;
		}
		
		/**
		 * @private
		 */
		private var _pictureWidth:uint;
		
		/**
		 * The width of the picture in pixels.
		 */
		public function get pictureWidth():uint
		{
			return _pictureWidth;
		}
		
		/**
		 * @private
		 */
		private var _pictureHeight:uint;
		
		/**
		 * The height of the picture in pixels.
		 */
		public function get pictureHeight():uint
		{
			return _pictureHeight;
		}
		
		/**
		 * @private
		 */
		private var _pictureColorDepth:uint;
		
		/**
		 * The color depth of the picture in bits-per-pixel.
		 */ 
		public function get pictureColorDepth():uint
		{
			return _pictureColorDepth;
		}
		
		/**
		 * @private
		 */
		private var _pictureColorsUsed:uint;
		
		/**
		 * For indexed-color pictures (e.g. GIF), the number of 
		 * colors used, or 0  for non-indexed pictures.
		 */
		public function get pictureColorsUsed():uint
		{
			return _pictureColorsUsed;
		}
		
		/**
		 * @private
		 */
		private var _pictureBytes:uint;
		
		/**
		 * The length of the picture data in bytes.
		 */ 
		public function get pictureBytes():uint
		{
			return _pictureBytes;
		}
		
		/**
		 * @private
		 */		
		private var _picture:*;
		
		/**
		 * The binary picture data.
		 * The type is unknown because it can either be the actual image data
		 * or simply a URL to the image.
		 */
		public function get picture():*
		{
			return _picture;
		}
		
		/**
		 * @private
		 * Holds the incoming ByteArray.
		 */
		private var data:ByteArray;
		
		/**
		 * @private
		 * Determins whether picture data is URL or not.
		 * If true, the picture data contains the URL to the image.
		 * If false, it's the actual image data.
		 */
		private var pictureUrl:Boolean;
		
		
		/**
		 * Constructor
		 */
		public function Picture( data:BitArray )
		{
			this.data = data;
			
			parsePicture();
		}
		
		/**
		 * @private
		 */ 
		private function parsePicture():void
		{
			_pictureType				= data.readUnsignedInt();
			_mimeTypeLength				= data.readUnsignedInt();
			_mimeTypeString 			= data.readUTFBytes( mimeTypeLength << 3 );
			_pictureDescriptionLength	= data.readUnsignedInt();
			_pictureDescription			= data.readUTFBytes( pictureDescriptionLength << 3 );
			_pictureWidth				= data.readUnsignedInt();
			_pictureHeight				= data.readUnsignedInt();
			_pictureColorDepth			= data.readUnsignedInt();
			_pictureColorsUsed			= data.readUnsignedInt();
			_pictureBytes				= data.readUnsignedInt();
			pictureUrl					= mimeTypeString == "-->" ? true : false;
			
			if( pictureUrl )
			{
				_picture = data.readUTFBytes( pictureBytes << 3 );
			}
			else
			{
				// TODO: Find an actual file which has a Picture metadata block to see which
				// images are supported.
			}
		}
	}
}