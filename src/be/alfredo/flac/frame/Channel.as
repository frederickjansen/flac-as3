package be.alfredo.flac.frame
{
	import be.alfredo.io.BitArray;
	import be.alfredo.flac.metadata.StreamInfo;

	/**
	 * Base class for all channels
	 */ 
	public class Channel
	{
		protected var _pcm:Vector.<int>;
		
		/**
		 * Vector of raw samples
		 */ 
		public function get pcm():Vector.<int>
		{
			return _pcm;
		}

		protected var residuals:Vector.<int>;
		
		/**
		 * Create and return a new audio channel
		 * 
 		 * @param	data		BitArray containing the data
		 * @param	frame		Frame containing the encoded audio samples
		 * @param	streamInfo	StreamInfo containing audio information
		 * @param	bps			Adjusted bps value
		 * @return	Channel		The decoded audio channel
		 */ 
		public static function parseChannelAudio( data:BitArray, frame:Frame, streamInfo:StreamInfo, bps:uint ):*
		{
			if( data.readBit() )
			{
				throw new Error("Zero bit padding expected");
			}
			
			var type:uint = data.readUnsignedBits( 6 );
			var wastedBits:uint = 0;
			
			if( data.readBit() )
			{
				// Strictly positive unary
				wastedBits = data.readUnary( 1 ) + 1;
			}
			
			bps -= wastedBits;
			
			var order:uint;
			if( type == 0 )
			{
				// Subframe Constant
				return new ChannelConstant( data, frame, streamInfo );
			}
			else if( type == 1 )
			{
				// Subframe Verbatim
				return new ChannelVerbatim( data, frame, streamInfo );
			}
			else if( (type & 0x38) == 0x08 && (type & 0x07) <= 4 )
			{
				// Subframe Fixed
				order = type & 0x07;
				return new ChannelFixed( data, frame, streamInfo, wastedBits, bps, order );
			}
			else if( (type & 0x20) == 0x20 )
			{
				// Subframe LPC
				order = (type & 0x1F) + 1;
				return new ChannelLPC( data, frame, streamInfo, wastedBits, bps, order );
			}
			else
			{
				throw new Error( "Invalid subframe type" );
			}
		}
		
		/**
		 * Decode a frame's residual using Rice entropy coding.
		 * 
		 * @param	data		BitArray containing the data
		 * @param	order		Order to deduct from the first partition
		 * @param	blockSize	Samples in one block
		 * @param	residuals	Vector containing all values used in entropy coding (rice)
		 */ 
		protected function readEncodedResidual( data:BitArray, order:uint, blockSize:uint, residuals:Vector.<int> ):void
		{
			var samplesPerPartition:uint;
			var riceParameter:uint;
			var escapeCode:uint;
			var bps:uint = 0;
			
			var codingMethod:uint = data.readUnsignedBits( 2 );
			var partitionOrder:uint = data.readUnsignedBits( 4 );
			/*switch( codingMethod )
			{
				case ENTROPY_CODING_METHOD_PARTITIONED_RICE:
				case ENTROPY_CODING_METHOD_PARTITIONED_RICE2:
					partitionOrder = data.readUnsignedBits( 4 );
					break;
				default:
					throw new Error( "Entropy coding method not supported" );
			}*/
			
			var partitions:uint = 1 << partitionOrder;
			for( var currentPartition:uint = 0; currentPartition < partitions; currentPartition++ )
			{
				if( currentPartition == 0 )
				{
					//samplesPerPartition = (blockSize >> partitionOrder) - order;
					samplesPerPartition = (blockSize >> partitionOrder) - order;
				}
				else
				{
					//samplesPerPartition = blockSize >> partitionOrder;
					samplesPerPartition = blockSize >> partitionOrder;
				}
				
				switch( codingMethod )
				{
					case 0:
						riceParameter = data.readUnsignedBits( 4 );
						if( riceParameter == 0x0F ) // escape code
						{
							bps = data.readUnsignedBits( 5 );
						}
						break;
					case 1:
						riceParameter = data.readUnsignedBits( 5 );
						if( riceParameter == 0x1F ) // escape code
						{
							bps = data.readUnsignedBits( 5 );
						}
						break;
					default:
						throw new Error( "Entropy coding method not supported" );
						break;
				}
				
				if( bps == 0 )
				{
					for( var i:uint = 0; i < samplesPerPartition; i++ )
					{
						residuals.push( data.readSignedRice( riceParameter ) );
					}
				}
				else
				{
					for( var j:uint = 0; j < samplesPerPartition; j++ )
					{
						residuals.push( data.readSignedBits( bps ) );
					}
				}
			}
		}
	}
}