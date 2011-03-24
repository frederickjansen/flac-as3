package be.alfredo.flac
{
	import be.alfredo.flac.frame.Channel;
	import be.alfredo.flac.frame.Frame;
	import be.alfredo.flac.metadata.Application;
	import be.alfredo.flac.metadata.Cuesheet;
	import be.alfredo.flac.metadata.Metadata;
	import be.alfredo.flac.metadata.Padding;
	import be.alfredo.flac.metadata.Picture;
	import be.alfredo.flac.metadata.SeekTable;
	import be.alfredo.flac.metadata.StreamInfo;
	import be.alfredo.flac.metadata.VorbisComment;
	import be.alfredo.io.BitArray;
	
	import flash.errors.EOFError;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	
	/**
	 * Decoder for the FLAC audio format
	 * 
	 * @author Frederick
	 */
	
	public class FLACDecoder
	{
		// Incoming FLAC file
		private var data:BitArray;
		
		// Samples remaining
		private var _remainingSamples:Number;
		
		private var soundBytes:BitArray;
		private var sound:Sound;
		private var soundChannel:SoundChannel;
		private var soundData:Vector.<Number> = new Vector.<Number>;
		
		// Metadata blocks
		private var _streaminfo:StreamInfo;
		private var padding:Padding;
		private var application:Application;
		private var seektable:SeekTable;
		private var vorbisComment:VorbisComment;
		private var cueSheet:Cuesheet;
		private var picture:Picture;
		
		public function FLACDecoder( data:ByteArray )
		{
			this.data = new BitArray(data);
			soundBytes = new BitArray();
			
			if( this.data.readUTFBytes(4) == "fLaC" )
			{
				parseMetadata();
			}
		}
		
		public function get streaminfo():StreamInfo
		{
			return _streaminfo;
		}

		public function get remainingSamples():Number
		{
			return _remainingSamples;
		}

		private function parseMetadata():void
		{
			var lastBlock:Boolean = data.readBit();
			var metadataBlockType:uint = data.readUnsignedBits(7);
			var metadataBlockLength:uint = data.readUnsignedBits(24);
			var metadataBlock:BitArray = new BitArray();
			
			data.readBytes( metadataBlock, 0, metadataBlockLength );
			
			switch( metadataBlockType )
			{
				case Metadata.STREAM_INFO:
					// Streaminfo
					_streaminfo = new StreamInfo( metadataBlock );
					break;
				case Metadata.PADDING:
					// Padding
					break;
				case Metadata.APPLICATION:
					// Application
					break;
				case Metadata.SEEK_TABLE:
					// Seektable
					break;
				case Metadata.VORBIS_COMMENT:
					// VorbisComment
					break;
				case Metadata.CUESHEET:
					// Cuesheet
					break;
				case Metadata.PICTURE:
					// Picture
					// TODO: There may be more than 1 picture block
					break;
				default:
					break;
			}
			
			// Final block?
			if( !lastBlock )
			{
				parseMetadata();
			}
			else
			{
				_remainingSamples = streaminfo.totalSamples;
				decodeFrames();
			}
		}
		
		private function decodeFrames():void
		{
			try
			{
				while( remainingSamples > 0 )
				{
					findFrameSync();
					readFrame();
				}
				playSound();
			}
			catch( e:EOFError )
			{
				trace( e );
			}
			
		}
		
		private function readFrame():void
		{
			var frame:Frame = new Frame( data, streaminfo );
			var pcmLength:uint = Channel( frame.channelData[0] ).pcm.length;
			for( var i:uint = 0; i < pcmLength ; i++ )
			{
				soundBytes.writeFloat( Number(Channel( frame.channelData[0] ).pcm[i] / 32768) );
				soundBytes.writeFloat( Number(Channel( frame.channelData[1] ).pcm[i] / 32768) );
				//soundData.push( Channel( frame.channelData[0] ).pcm[i] );
				//soundData.push( Channel( frame.channelData[1] ).pcm[i] );
			}
			_remainingSamples -= frame.blockSize;
		}
		
		private function playSound():void
		{
			sound = new Sound();
			soundChannel = new SoundChannel();
			soundBytes.position = 0;
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleDataHandler);
			soundChannel = sound.play();
		}
		
		private function sampleDataHandler(event:SampleDataEvent):void
		{
			for (var i:int = 0; i < 4096; i++) 
			{
				event.data.writeFloat(soundBytes.readFloat());
				event.data.writeFloat(soundBytes.readFloat());
			}
			
			/*var ba:ByteArray = new ByteArray();
			soundBytes.readBytes( ba, 0, Math.min(soundBytes.bytesAvailable, 4 * 4608) );
			event.data.writeBytes(ba, 0, ba.length);
			event.data.writeBytes(ba, 0, ba.length);*/
		}
		
		private function findFrameSync():void
		{
			var sync:uint;
			var syncNotFound:Boolean = true;
			
			try
			{
				while(syncNotFound)
				{
					sync = data.readUnsignedBits(14);
					
					if( sync == 0x3FFE )
					{
						syncNotFound = false;
						// Move back to the beginning of the sync code
						data.position -= 1;
					}
				}
			}
			catch( eof:EOFError )
			{
				throw new EOFError("Sync code not found");
			}
			
		}
	}
}