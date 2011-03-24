package
{
	import be.alfredo.flac.FLACDecoder;
	import be.alfredo.io.BitArray;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Main extends Sprite
	{
		private var fr:FileReference;
		private var flac:FLACDecoder;
		private var remainingSamplesText:TextField;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
//			urlLoader.load(new URLRequest("../libs/04 Misery Business.flac"));
			urlLoader.load(new URLRequest("../libs/DaFunk.flac"));
			
			/*fr = new FileReference();
			fr.addEventListener( Event.SELECT, selectHandler );
			fr.addEventListener( Event.COMPLETE, onComplete );
			
			stage.addEventListener( MouseEvent.CLICK, onClick );*/
		}
		
		private function onClick( event:MouseEvent ):void
		{
			var ff:FileFilter = new FileFilter("FLAC", "*.flac");
			fr.browse([ff]);
		}
		
		private function selectHandler( event:Event ):void
		{
			fr.load();
		}
		
		private function onComplete( event:Event ):void
		{
			//flac = new FLACDecoder( fr.data );
			//addEventListener(Event.ENTER_FRAME, onEnterFrame);
			flac = new FLACDecoder( event.target.data );
			/*remainingSamplesText = new TextField();
			remainingSamplesText.autoSize = TextFieldAutoSize.LEFT;
			addChild(remainingSamplesText);*/
		}
		
	}
}