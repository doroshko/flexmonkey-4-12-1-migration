package
{
	[Bindable]public class Item
	{
		private var _name:String;
		private var _photo:String;
		private var _price:String;
		
		public function Item()
		{
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(name:String):void
		{
			_name = name;
		}
		
		public function get photo():String
		{
			return _photo;
		}
		
		public function set photo(photo:String):void
		{
			_photo = photo;
		}
		
		public function get price():String
		{
			return _price;
		}
		public function set price(price:String):void
		{
			_price = price;
		}
		
	}
}