package be.alfredo.flac.frame
{
	import be.alfredo.io.BitArray;
	import be.alfredo.flac.metadata.StreamInfo;
	
	/**
	 * A channel using LPC prediction.
	 */ 
	public class ChannelLPC extends Channel
	{
		public function ChannelLPC( data:BitArray, frame:Frame, streamInfo:StreamInfo, wastedBits:uint, bps:uint, order:uint )
		{
			var qlpPrecision:uint;
			var qlpShift:uint;
			var qlpCoeffs:Vector.<int> = new Vector.<int>( order, true );
			_pcm = new Vector.<int>;
			
			for( var i:uint = 0; i < order; i++ )
			{
				_pcm[i] = data.readSignedBits( bps );
			}
			
			qlpPrecision = data.readUnsignedBits( 4 ) + 1;
			qlpShift = data.readUnsignedBits( 5 );
			
			for( var j:uint = 0; j < order; j++ )
			{
				qlpCoeffs[j] = data.readSignedBits( qlpPrecision );
			}
			
			residuals = new Vector.<int>;
			readEncodedResidual( data, order, frame.blockSize, residuals );
			
			var residualLength:uint = residuals.length;
			for( i = 0; i < residualLength; i++ )
			{
				var sum:int = 0;
				
				for( j = 0; j < order; j++ )
				{
					sum += qlpCoeffs[j] * _pcm[order + i - j - 1];
				}
				_pcm.push( (sum >> qlpShift) + residuals[i] );
			}
			
			var pcmLength:uint = _pcm.length;
			if( wastedBits > 0 )
			{
				for( i = 0; i < pcmLength; i++ )
				{
					_pcm[i] <<= wastedBits;
				}
			}
		}
	}
}