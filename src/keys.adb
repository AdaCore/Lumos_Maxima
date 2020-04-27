with Ada.Containers.Formal_Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
use Ada.Containers;

package body Keys with SPARK_Mode,
  Refined_State => (Keys_State => (Model, Data))
is

   --  Renamings of utilities from Ada.Strings.Unbounded to add postconditions.
   --  The postconditions are expected to be unprovable.

   function "=" (X, Y : Unbounded_String) return Boolean with
     Post => "="'Result = (To_String (X) = To_String (Y));
   function "=" (X, Y : Unbounded_String) return Boolean renames
     Ada.Strings.Unbounded."=";
   function To_Unbounded_String (X : String) return Unbounded_String with
     Post => To_String (To_Unbounded_String'Result) = X;
   function To_Unbounded_String (X : String) return Unbounded_String renames
     Ada.Strings.Unbounded.To_Unbounded_String;

   package Int_To_String is new
     Ada.Containers.Formal_Vectors
       (Index_Type   => Valid_Key_Id,
        Element_Type => Unbounded_String);

   Data  : Int_To_String.Vector (Max_Num_Keys);
   Model : Key_Map with Ghost;

   ---------------
   -- Invariant --
   ---------------

   function Invariant return Boolean is
     ((for all Index of Model =>
            Index in 1 .. Int_To_String.Last_Index (Data)
       and then Get (Model, Index) = To_String (Int_To_String.Element (Data, Index)))
      and then (for all Index in 1 .. Int_To_String.Last_Index (Data) =>
                   Has_Key (Model, Index))
      and then Length (Model) = Int_To_String.Length (Data));

   ---------------
   -- Seen_Keys --
   ---------------

   function Seen_Keys return Key_Map is (Model);

   ---------------
   -- To_Key_Id --
   ---------------

   procedure To_Key_Id (S : String;
                        Id : out Key_Id)
   is
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
         Model := Add (Model, Id, S);
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
