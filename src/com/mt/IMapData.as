package com.mt
{
	import flash.utils.ByteArray;

	public interface IMapData
	{
		function WriteToClient(bytes:ByteArray):void;
		function WriteToServer(bytes:ByteArray):void;
		function get length():int;
		function clear():void;
	}
}