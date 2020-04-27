with Ada.Containers.Functional_Maps;
package Keys with SPARK_Mode,
  Initial_Condition => Invariant,
  Abstract_State    => Keys_State
is

   Max_Num_Keys : constant := 1024;
   
   type Key_Id is new Integer range 0 .. Max_Num_Keys;
   subtype Valid_Key_Id is Key_Id range 1 .. Key_Id'Last;

   No_Key : constant Key_Id := 0;

   package Key_Maps is new Ada.Containers.Functional_Maps (Key_Id, String);
   subtype Key_Map is Key_Maps.Map with Ghost;
   use Key_Maps;

   function Seen_Keys return Key_Map with
     Ghost,
     Global => Keys_State;

   function Invariant return Boolean with
     Ghost,
     Global => Keys_State;
   
   procedure To_Key_Id (S : String;
                        Id : out Key_Id)
   with
     Global => (In_Out => Keys_State),
     Pre    => Invariant,
     Post   => 
       (Id = No_Key 
        or else (Has_Key (Seen_Keys, Id) and then Get (Seen_Keys, Id) = S))
       and Seen_Keys'Old <= Seen_Keys
       and Invariant;
   
   function To_Key_String (Id : Key_Id) return String
   with
     Global => Keys_State,
     Pre    => Invariant and then Id = No_Key and then Has_Key (Seen_Keys, Id),
     Post   => To_Key_String'Result = Get (Seen_Keys, Id);

end Keys;
