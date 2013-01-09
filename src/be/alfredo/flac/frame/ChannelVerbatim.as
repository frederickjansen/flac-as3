package be.alfredo.flac.frame
{
	import be.alfredo.io.BitArray;
	import be.alfredo.flac.metadata.StreamInfo;

	public class ChannelVerbatim extends Channel
	{
		/**
		 * Zero order predictor channel, where the residual is the signal itself
		 */ 
		public function ChannelVerbatim( data:BitArray, frame:Frame, streamInfo:StreamInfo )
		{
			var bs:uint = frame.blockSize;
			var bps:uint = frame.bitsPerSample;
			_pcm = new Vector.<int>( bs, true );
			
			for( var i:uint = 0; i < bs; i++ )
			{
				_pcm[i] = data.readSignedBits( bps );
			}
		}
	}
}