// 地图阻挡数据
package com.mt
{
	import flash.utils.ByteArray;

	public class MapTag
	{
		// tagtype
		private var _tagType:int;
		// tag长度 (data的长度)
		private var _dataLength:int;
		// 地图数据
		private var _data:IMapData;
		
		public function get tagType():int
		{
			return this._tagType;
		}
		
		public function MapTag(type:int, data:ByteArray)
		{
			this._tagType = type;
			// 阻挡数据
			if (type == 4000)
			{
				var block:BlockData = new BlockData(data);
				this._data = block;				
			}
			else if (type == 5000)
			{
				
			}
			this._dataLength = this._data.length;
		}
		
		public function WriteToClient(bytes:ByteArray):void
		{
			bytes.writeInt(_tagType);
			bytes.writeInt(_dataLength);
			_data.WriteToClient(bytes);
		}
		
		public function WriteToServer(bytes:ByteArray):void
		{
			_data.WriteToServer(bytes);
		}
		
		public function clear():void
		{
			_data.clear();
			_data = null;
		}
	}
}