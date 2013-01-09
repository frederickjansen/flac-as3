package be.alfredo.flac.frame
{
	import be.alfredo.io.BitArray;
	import be.alfredo.flac.metadata.StreamInfo;

	public class ChannelConstant extends Channel
	{
		/**
		 * Constant audio channel, mostly used for digital silence
		 */ 
		public function ChannelConstant( source:BitArray, frame:Frame, streamInfo:StreamInfo )
		{
			var bps:uint = source.readSignedBits( frame.bitsPerSample );
			var length:uint = frame.blockSize;
			_pcm = new Vector.<int>(frame.blockSize, true);
			
			for( var i:uint = 0; i < length; i++ )
			{
				_pcm[i] = bps;
			}
		}
	}
}