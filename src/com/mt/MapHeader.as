package com.mt
{
	import flash.utils.ByteArray;
	
	import mx.formatters.DateFormatter;

	public class MapHeader
	{
		// 文件标记
		private var _flag:int;
		// 版本号
		private var _version:int;
		// 时间
		private var _date:String;
		// utc时间
		private var _utc:int;
		// 地图宽
		private var _width:int;
		// 地图高
		private var _height:int;
		// 数据块
		private var _tagArray:Array;
		
		public function MapHeader(width:int, height:int)
		{
			this._flag = 0x50414d;
			this._version = 1;
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYY/MM/DD JJ:NN:SS";
			var date:Date = new Date();
			this._date = dateFormatter.format(date);
			this._utc = date.getTime();
			this._width = width;
			this._height = height;
			_tagArray = new Array();
		}
		
		public function AddTag(tag:MapTag)
		{
			_tagArray.push(tag);
		}
		
		public function WriteToClient(bytes:ByteArray)
		{
			bytes.writeInt(_flag);
			bytes.writeInt(_version);
			bytes.writeUTF(_date);
			bytes.writeInt(_width);
			bytes.writeInt(_height);
			for (var i:int = 0; i < _tagArray.length; ++i)
			{
				var tag:MapTag = _tagArray[i];
				tag.WriteToClient(bytes);	
			}
		}
		
		public function WriteToServer(bytes:ByteArray)
		{
			bytes.writeInt(_flag);
			bytes.writeInt(_version);
			bytes.writeInt(_utc);
			bytes.writeInt(_width);
			bytes.writeInt(_height);
			for (var i:int = 0; i < _tagArray.length; ++i)
			{
				var tag:MapTag = _tagArray[i];
				if (tag.tagType == 4000)
				{
					tag.WriteToServer(bytes);	
					break;
				}
			}
		}
		
		public function clear():void
		{
			for (var i:int = 0; i < _tagArray.length; ++i)
			{
				_tagArray[i].clear();	
			}
			_tagArray = null;
		}
	}
}