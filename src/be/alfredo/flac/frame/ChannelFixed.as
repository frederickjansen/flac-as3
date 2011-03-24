package be.alfredo.flac.frame
{
	import be.alfredo.io.BitArray;
	import be.alfredo.flac.metadata.StreamInfo;

	/**
	 * A channel using fixed linear prediction.
	 */ 
	public class ChannelFixed extends Channel
	{
		public function ChannelFixed( data:BitArray, frame:Frame, streamInfo:StreamInfo, wastedBits:uint, bps:uint, order:uint )
		{
			_pcm = new Vector.<int>;
			// read warmup samples
			//var warmup:Vector.<uint> = new Vector.<uint>( order, true );
			for( var i:uint = 0; i < order; i++ )
			{
				//warmup[i] = data.readUnsignedBits( bps );
				_pcm[i] = data.readSignedBits( bps );
			}
			
			residuals = new Vector.<int>;
			readEncodedResidual( data, order, frame.blockSize, residuals );
			
			var resLength:uint = residuals.length;
			
			switch( order )
			{
				case 0:
					for( var j:uint = 0; j < resLength; j++ )
					{
						// _pcm[i] = residual[i]
						_pcm[j] = residuals[j];
					}
					break;
				case 1:
					for( var k:uint = 0; k < resLength; k++ )
					{
						// _pcm[i+1] = _pcm[i] + residual[i] (
						_pcm[k+1] = _pcm[k] + residuals[k];
					}
					break;
				case 2:
					for( var l:uint = 0; l < resLength; l++ )
					{
						// _pcm[i+2] = 2*_pcm[i+1] - _pcm[i] + residual[i]
						_pcm[l+2] = (_pcm[k+1] << 1) - _pcm[k] + residuals[l];
					}
					break;
				case 3:
					for( var m:uint = 0; m < resLength; m++ )
					{
						// _pcm[i+3] = 3*_pcm[i+2] - 3*_pcm[i+1] + _pcm[i] + residual[i]
						_pcm[m+3] = (( (_pcm[m+2] - _pcm[m+1]) << 1 ) + (_pcm[m+2] - _pcm[m+1]) ) + _pcm[m] + residuals[m];
					}
					break;
				case 4:
					for( var n:uint = 0; n < resLength; n++ )
					{
						// _pcm[i+4] = 4*_pcm[i+3] - 6*_pcm[i+2] + 4*_pcm[i+1] + _pcm[i] + residual[i]
						_pcm[n+4] = ( (_pcm[n+3] + _pcm[n+1]) << 2 ) - ( (_pcm[n+2] << 2) + (_pcm[n+2] << 1) ) + _pcm[n] + residuals[n];
					}
					break;
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