package Keys is

   type Key_Type is private;

   No_Key : constant Key_Type;
   
   function From_String (S : String) return Key_Type;
   function To_String (S : Key_Type) return String;
private

   type Key_Type is new Integer; -- ???

   No_Key : constant Key_Type := 0;
   
   function From_String (S : String) return Key_Type is
      (Key_Type'Value (S));
   
   function To_String (S : Key_Type) return String is
      (Key_Type'Image (S));

end Keys;
