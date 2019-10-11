package Keys is

   type Key_Type is private;

   No_Key : constant Key_Type;
private

   type Key_Type is new Integer; -- ???

   No_Key : constant Key_Type := 0;
   
end Keys;
