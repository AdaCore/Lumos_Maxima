package Keys is

   Max_Num_Keys : constant := 1024;
   
   type Key_Id is new Integer range 0 .. Max_Num_Keys;
   subtype Valid_Key_Id is Key_Id range 1 .. Key_Id'Last;

   No_Key : constant Key_Id := 0;
   
   procedure To_Key_Id (S : String;
                        Id : out Key_Id);
   
   function To_Key_String (Id : Key_Id) return String;

end Keys;
