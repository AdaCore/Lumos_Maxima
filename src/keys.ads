package Keys is

   type Key_Type is private;

   No_Key : constant Key_Type;
   
   function From_String (S : String) return Key_Type;
private

   type Key_Type is new Integer; -- ???

   No_Key : constant Key_Type := 0;
   
   function From_String (S : String) return Key_Type is
      (Key_Type'Value (S));
   
end Keys;
