package be.alfredo.flac.frame
{
	import be.alfredo.io.BitArray;
	import be.alfredo.flac.metadata.StreamInfo;
	import be.alfredo.util.CRC;
	
	/**
	 * Decode an audio frame
	 */ 
	public class Frame
	{
		// Constants
		private static const CHANNEL_LEFT_SIDE_STEREO:String = "channel_left_side_stereo";
		private static const CHANNEL_RIGHT_SIDE_STEREO:String = "channel_right_side_stereo";
		private static const CHANNEL_MID_SIDE_STEREO:String = "channel_mid_side_stereo";
		private static const CHANNEL_INDEPENDENT:String = "channel_independent";
		
		/**
		 * Incoming audio data
		 */ 
		private var data:BitArray;
		
		/**
		 * StreamInfo metadata
		 */
		private var streamInfo:StreamInfo;
		
		/**
		 * @private
		 */
		private var _channelData:Array;

		/**
		 * Audio channels
		 */
		public function get channelData():Array
		{
			return _channelData;
		}
		
		/**
		 * Sync code
		 */ 
		private var syncCode:uint;
		
		/**
		 * Blocking strategy, either fixed or variable
		 */ 
		private var fixedBlockSize:Boolean;
		
		/**
		 * @private
		 */ 
		private var _blockSize:uint;

		/**
		 * Block size in inter-channel samples
		 */
		public function get blockSize():uint
		{
			return _blockSize;
		}
		
		/**
		 * Sample rate
		 */
		private var sampleRate:uint;
		
		/**
		 * Channel assignment
		 */ 
		private var channelAssignment:String;
		
		/**
		 * Amount of channels
		 */
		private var channels:uint;
		
		/**
		 * @private
		 */
		private var _bitsPerSample:uint;

		/**
		 * Sample size in bits
		 */
		public function get bitsPerSample():uint
		{
			return _bitsPerSample;
		}
		
		/**
		 * The sample number for the first sample in the frame.
		 */ 
		private var sampleNumber:Number;
		
		/**
		 * 8 or 16-bit (blocksize - 1)
		 */
		private var bsBits:uint = 0;
		
		/**
		 * 8 or 16-bit sample rate
		 */
		private var srBits:uint = 0;
		
		/**
		 * Start position of the frame to calculate the CRC from
		 */
		private var startPosition:uint;
		
		public var pcm:Vector.<int>;
		
		
		public function Frame(data:BitArray, streamInfo:StreamInfo)
		{
			this.data = data;
			this.streamInfo = streamInfo;
			_channelData = new Array();
			
			parseFrameHeader();
		}
		
		private function parseFrameHeader():void
		{
			startPosition = data.position;
			
			// Skip Sync code and match bit position
			data.position += 1;
			data.bitPosition = 7;
			
			// Mandatory value
			if( !data.readBit() )
			{
				fixedBlockSize = !data.readBit();
				getBlockSize();	
			}
			else
			{
				throw new Error("Mandatory value should be 0");
			}
		}
		
		private function getBlockSize():void
		{
			var bsType:uint = data.readUnsignedBits(4);
			switch( bsType )
			{
				case 0:
					break;
				case 1:
					_blockSize = 192;
					break;
				case 2:
				case 3:
				case 4:
				case 5:
					_blockSize = 576 << ( bsType - 2 );
					break;
				case 6: bsBits = 8;
					break;
				case 7: bsBits = 16;
					break;
				case 8:
				case 9:
				case 10:
				case 11:
				case 12:
				case 13:
				case 14:
				case 15:
					_blockSize = 256 << ( bsType - 8 );
					break;
				default:
					break;
			}
			getSampleRate();
		}
		
		private function getSampleRate():void
		{
			//var srType:uint = data.readUnsignedBits( 4, 4 );
			var srType:uint = data.readUnsignedBits( 4 );
			switch( srType )
			{
				case 0:
					sampleRate = streamInfo.sampleRate;
					break;
				case 1:
					sampleRate = 88200;
					break;
				case 2:
					sampleRate = 176400;
					break;
				case 3:
					sampleRate = 192000;
					break;
				case 4:
					sampleRate = 8000;
					break;
				case 5:
					sampleRate = 16000;
					break;
				case 6:
					sampleRate = 22050;
					break;
				case 7:
					sampleRate = 24000;
					break;
				case 8:
					sampleRate = 32000;
					break;
				case 9:
					sampleRate = 44100;
					break;
				case 10:
					sampleRate = 48000;
					break;
				case 11:
					sampleRate = 96000;
					break;
				case 12:
					// In KHz
					srBits = 8;
					break;
				case 13:
					// In Hz
					srBits = 16;
					break;
				case 14:
					// Same as 13, but in tens of Hz
					srBits = 160;
					break;
				case 15:
					throw new Error("Bad Sample Rate");
					break;
				default:
					break;
			}
			getChannelAssignment();
		}
		
		private function getChannelAssignment():void
		{
			var ChAss:uint = data.readUnsignedBits(4);
			channels = 2;
			
			switch( ChAss )
			{
				case 8:
					channelAssignment = CHANNEL_LEFT_SIDE_STEREO;
					break;
				case 9:
					channelAssignment = CHANNEL_RIGHT_SIDE_STEREO;
					break;
				case 10:
					channelAssignment = CHANNEL_MID_SIDE_STEREO;
					break;
				default:
					channels = ChAss + 1;
					channelAssignment = CHANNEL_INDEPENDENT;
					break;
			}
			getSampleSize();
		}
		
		private function getSampleSize():void
		{
			var sSize:uint = data.readUnsignedBits( 3 );
			
			switch( sSize )
			{
				case 0:
					_bitsPerSample = streamInfo.bitsPerSample;
					break;
				case 1:
					_bitsPerSample = 8;
					break;
				case 2:
					_bitsPerSample = 12;
					break;
				case 3:
					throw new Error("Bad Bits Per Sample");
					break;
				case 4:
					_bitsPerSample = 16;
					break;
				case 5:
					_bitsPerSample = 20;
					break;
				case 6:
					_bitsPerSample = 24;
					break;
				case 7:
					throw new Error("Bad Bits Per Sample");
					break;
				default:
					break;
			}
			
			// Mandatory value should be 0
			if( data.readBit() )
			{
				throw new Error("Mandatory value after sample size should be 0");
			}
			
			getleftoverValues();
		}
		
		private function getleftoverValues():void
		{
			// Coded sample/frame number
			if( !fixedBlockSize )
			{
				sampleNumber = data.readUnsignedUTF8();
			}
			else
			{
				var frameNumber:Number = data.readUnsignedUTF8();
				sampleNumber = frameNumber * streamInfo.minBlockSize;
			}
			
			if( bsBits )
			{
				_blockSize = data.readUnsignedBits( bsBits ) + 1;
			}
			
			if( srBits )
			{
				if( srBits == 8 )
					sampleRate = data.readUnsignedByte() * 1000;
				else if( srBits == 16 )
					sampleRate = data.readUnsignedShort();
				else
					sampleRate = data.readUnsignedShort() * 10;
			}
			
			var endPosition:uint = data.position;
			
			var crc8:uint = data.readUnsignedByte();
			data.position = startPosition;
			var crcData:BitArray = new BitArray();
			data.readBytes( crcData, 0, endPosition - startPosition );
			
			if( CRC.crc8Calc( crcData, crcData.length ) != crc8 )
			{
				throw new Error( "CRC-8 of header doesn't match" );
			}
			
			data.position = endPosition + 1;
			
			setChannels();
		}
		
		private function setChannels():void
		{
			for( var i:uint = 0; i < channels; i++ )
			{
				var bps:uint = _bitsPerSample;
				
				// Difference channel is one bit larger to hold all possible values
				if( channelAssignment == CHANNEL_LEFT_SIDE_STEREO	&& i == 1 ||
					channelAssignment == CHANNEL_RIGHT_SIDE_STEREO	&& i == 0 ||
					channelAssignment == CHANNEL_MID_SIDE_STEREO	&& i == 1 )
				{
					bps++;
				}
				channelData[i] = Channel.parseChannelAudio( data, this, streamInfo, bps );
			}
			
			data.byteAlignRight();
			
			// Check the CRC
			var endPosition:uint = data.position;
			var crc16:uint = data.readUnsignedShort();
			var crcData:BitArray = new BitArray();
			
			data.position = startPosition;
			data.readBytes( crcData, 0, endPosition - startPosition );
			
			if( CRC.crc16Calc( crcData, crcData.length ) != crc16 )
			{
				throw new Error( "CRC-16 of frame doesn't match" );
			}
			
			data.position = endPosition + 2;
			
			// Handle interchannel decorrelation
			switch( channelAssignment )
			{
				case CHANNEL_INDEPENDENT:
					break;
				case CHANNEL_LEFT_SIDE_STEREO:
					for( i = 0; i < Channel( channelData[0] ).pcm.length; i++ )
					{
						Channel( channelData[1] ).pcm[i] = Channel( channelData[0] ).pcm[i] - Channel( channelData[1] ).pcm[i];
					}
					break;
				case CHANNEL_RIGHT_SIDE_STEREO:
					for( i = 0; i < Channel( channelData[0] ).pcm.length; i++ )
					{
						Channel( channelData[0] ).pcm[i] += Channel( channelData[1] ).pcm[i];
					}
					break;
				case CHANNEL_MID_SIDE_STEREO:
					for( i = 0; i < Channel( channelData[0] ).pcm.length; i++ )
					{
						var mid:int = Channel( channelData[0] ).pcm[i];
						var side:int = Channel( channelData[1] ).pcm[i];
						var temp:int = (mid << 1) | (side & 1);
						// (((mid << 1)|(side&1)) + side) >> 1
						Channel( channelData[0] ).pcm[i] = (temp + side) >> 1;
						// (((mid << 1)|(side&1)) - side) >> 1
						Channel( channelData[1] ).pcm[i] = (temp - side) >> 1;
					}
					break;
			}
		}
	}
}