with Ada.Containers.Formal_Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body Keys is

   package Int_To_String is new
     Ada.Containers.Formal_Vectors
       (Index_Type => Valid_Key_Id,
        Element_Type => Unbounded_String);

   Data : Int_To_String.Vector (Max_Num_Keys);

   ---------------
   -- To_Key_Id --
   ---------------

   procedure To_Key_Id (S : String;
                        Id : out Key_Id)
   is
      use Ada.Containers;
      use Int_To_String;
      UB : constant Unbounded_String := To_Unbounded_String (S);
   begin
      for Index in 1 .. Last_Index (Data) loop
         if Element (Data, Index) = UB then
            Id := Index;
            return;
         end if;
      end loop;
      if Length (Data) < Max_Num_Keys then
         Append (Data, UB);
         Id := Last_Index (Data);
      else
         Id := No_Key;
      end if;
   end To_Key_Id;

   -------------------
   -- To_Key_String --
   -------------------

   function To_Key_String (Id : Key_Id) return String is
   begin
      return To_String (Int_To_String.Element (Data, Id));
   end To_Key_String;
end Keys;
