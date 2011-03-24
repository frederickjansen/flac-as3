package be.alfredo.flac.metadata
{
	import be.alfredo.io.BitArray;
	
	import flash.utils.ByteArray;

	/**
	 * StreamInfo metadata block
	 */ 
	public class StreamInfo
	{
		private var data:BitArray;
		
		public var minBlockSize:uint;
		public var maxBlockSize:uint;
		public var minFrameSize:uint;
		public var maxFrameSize:uint;
		public var sampleRate:uint;
		public var channels:uint;
		public var bitsPerSample:uint;
		public var totalSamples:Number;
		public var md5Signature:uint;
		public var fixedBlockSize:Boolean;
		
		public function StreamInfo( data:BitArray )
		{
			this.data = data;
			
			parseStreamInfo();
		}
		
		private function parseStreamInfo():void
		{
			minBlockSize = data.readUnsignedShort();
			maxBlockSize = data.readUnsignedShort();
			minFrameSize = data.readUnsignedBits(24);
			maxFrameSize = data.readUnsignedBits(24);
			
			sampleRate = data.readUnsignedBits(20);
			channels = data.readUnsignedBits(3) + 1;
			bitsPerSample = data.readUnsignedBits(5) + 1;
			totalSamples = data.readUnsignedBits(4) << 32 | data.readUnsignedInt();
			// skip md5
			data.position += 16;
			
			fixedBlockSize	= minBlockSize == maxBlockSize ? true : false;
		}
	}
}