package com.mt
{
	import flash.utils.ByteArray;

	public class BlockData implements IMapData
	{
		private var _compressLen:int;
		
		private var _compressData:ByteArray;
		
		public function BlockData(data:ByteArray)
		{
			this._compressLen = data.length;
			this._compressData = data;
		}
		
		public function get length():int
		{
			return _compressLen + 4;
		}
		
		public function WriteToClient(bytes:ByteArray):void
		{
			if (_compressLen > 0)
			{
				bytes.writeInt(_compressLen);
				bytes.writeBytes(_compressData);	
			}
			else
			{
				trace("[MapConverter]no block data");
			}
		}
		
		public function WriteToServer(bytes:ByteArray):void
		{
			if (_compressLen > 0)
			{
				_compressData.uncompress();
				bytes.writeBytes(_compressData);
			}
			else
			{
				trace("[MapConverter]no block data");
			}
		}
		
		public function clear():void
		{
			_compressData.clear();
			_compressData = null;
		}
	}
}