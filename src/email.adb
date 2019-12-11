with Ada.Containers.Formal_Vectors;

package body Email with SPARK_Mode is

   type Length_Type is range 0 .. 256;

   type Email_Address_Buffer_Type is array (Length_Type range <>) of Character;

   type Email_Address_Var_Type (Len : Length_Type := 20) is record
      Ct : Email_Address_Buffer_Type (1 .. Len);
   end record;

   package Int_To_String is new
     Ada.Containers.Formal_Vectors
       (Index_Type => Valid_Email_Address_Type,
        Element_Type => Email_Address_Var_Type);

   Data : Int_To_String.Vector (1024);

   --------------
   -- Is_Valid --
   --------------

   function Is_Valid (X : Valid_Email_Address_Type) return Boolean is
      (X <= Int_To_String.Last_Index (Data));

   ----------------------
   -- To_Email_Address --
   ----------------------

   procedure To_Email_Address (S : String;
                               Email : out Email_Address_Type) is
      use Ada.Containers;
      Copy : constant String (1 .. S'Length) := S;
   begin
      -- ??? would like to guarantee unicity
      if Int_To_String.Length (Data) < Max_Num_Emails then
         Int_To_String.Append (Data, (Len => S'Length,
                                      Ct => Email_Address_Buffer_Type (Copy)));
         Email := Int_To_String.Last_Index (Data);
      else
         Email := No_Email;
      end if;
   end To_Email_Address;

   ---------------
   -- To_String --
   ---------------

   function To_String (E : Valid_Email_Address_Type) return String is
      use Ada.Containers;
   begin
      pragma Assume (E <= Int_To_String.Last_Index (Data));
      return String (Int_To_String.Element (Data, E).Ct);
   end To_String;

end Email;
