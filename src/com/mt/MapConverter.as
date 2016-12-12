package com.mt
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.controls.Alert;
	
	public class MapConverter
	{
		private var dir:File;
		
		private var loader:URLLoader;
		/**
		 * 路点位图
		 */ 
		private var _roadMap:BitmapData;
		/**
		 * 路点位图与地图总尺寸的比例
		 */  
		private var _roadK:Number;
		/**
		 * 地图格子宽
		 */  
		private var TILE_WIDTH:int = 20;
		/**
		 * 地图格子高
		 */  
		private var TILE_HEIGHT:int = 20;
		/**
		 * 地图宽
		 */  
		private var MAP_WIDTH:int;
		/**
		 * 地图高
		 */  
		private var MAP_HEIGHT:int;
		/**
		 * 地图id
		 */
		private var MAP_ID:int;
		/**
		 * 地图格子数据
		 */
		private var _mapData:ByteArray;
		
		private var _header:MapHeader;
		
		public function MapConverter()
		{
			dir = File.documentsDirectory; //默认为文档文件夹
			var fileFilter:FileFilter = new FileFilter("JPG", "*.jpg");
			dir.browseForDirectory("请选择需要转换的目录");
			dir.addEventListener(Event.SELECT, DirectorySelectHandler);
		}
		
		private function DirectorySelectHandler(event:Event):void
		{
			trace(dir.nativePath);
			if (dir.nativePath.length > 0) loadConfig();
		}
		
		private function loadConfig():void
		{
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest(dir.nativePath + "\\mapconf.d5"));
			loader.addEventListener(IOErrorEvent.IO_ERROR,onConfigIO);
			loader.addEventListener(Event.COMPLETE,parseData);
			
		}
		
		private function parseData(e:Event):void
		{
			loader.removeEventListener(Event.COMPLETE,parseData);
			var by:ByteArray = loader.data as ByteArray;
			by.uncompress();
			var configXML:String = by.readUTFBytes(by.bytesAvailable);
			var _data:XML = new XML(configXML);
			MAP_WIDTH = _data.mapW;
			MAP_HEIGHT = _data.mapH;
			MAP_ID= _data.id;
			_header = new MapHeader(MAP_WIDTH, MAP_HEIGHT);
			loadRoadMap(dir.nativePath + "\\roadmap.png")
		}
		
		private function onConfigIO(e:IOErrorEvent):void
		{
			Alert.show("[MapConverter]Can not found map config file.");
		}
		
		private function loadRoadMap(url:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,configRoadMap);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,RoadLoadError);
			loader.load(new URLRequest(url));
		}
		
		private function configRoadMap(e:Event):void
		{ 
			var loadinfo:LoaderInfo = e.target as LoaderInfo;
			
			loadinfo.removeEventListener(Event.COMPLETE,configRoadMap);
			loadinfo.removeEventListener(IOErrorEvent.IO_ERROR,RoadLoadError);
			
			_roadMap = (loadinfo.content as Bitmap).bitmapData;
			_roadK =  _roadMap.width/MAP_WIDTH;
			
			loadinfo.loader.unload();
			
			updateTileData();
		}
		
		private function RoadLoadError(e:ErrorEvent):void
		{
			Alert.show("[MapConverter]Can not found road map file.");
		}
		
		private function updateTileData():void
		{
			var h:int = (MAP_HEIGHT + TILE_HEIGHT - 1)/TILE_HEIGHT + 2;
			var w:int = (MAP_WIDTH + TILE_WIDTH - 1)/TILE_WIDTH + 2;
			
			var _arry:ByteArray = new ByteArray();
			
			for(var y:uint = 0;y<h;y++)
			{
				for(var x:uint = 0;x<w;x++)
				{	
					_arry[x + y * w] = _roadMap.getPixel(int(TILE_WIDTH*x*_roadK),int(TILE_HEIGHT*y*_roadK))==0 ? 1 : 0;
				}
			}
			
			_arry.compress();
			
			var mapTag:MapTag = new MapTag(4000, _arry);
			_header.AddTag(mapTag);
			
			SaveToClient();
		}
		
		private function SaveToClient():void
		{
			var file:File = File.userDirectory.resolvePath(dir.nativePath + "\\Convert");
			file.createDirectory();
			var path:String = dir.nativePath + "\\Convert\\" + MAP_ID + ".map1";
			var mapCfgFile:File = new File(path);
			var stream:FileStream = new FileStream();
			stream.open(mapCfgFile, FileMode.WRITE);
			if (_mapData == null)
			{
				_mapData = new ByteArray();
				_mapData.endian = Endian.LITTLE_ENDIAN;
			}
			
			_header.WriteToClient(_mapData);
			stream.writeBytes(_mapData);
			stream.close();
			Alert.show("转换地图配置文件: " + mapCfgFile.url);
			Clear();
		}
		
		private function Clear():void
		{
			loader = null;
			_roadMap.dispose();
			_roadMap = null;
			_header.clear();
			_header = null;
		}
		
	}
}