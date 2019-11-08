with Ada.Containers.Formal_Doubly_Linked_Lists;
with Ada.Containers.Formal_Hashed_Maps;
use Ada.Containers;

package body Database with SPARK_Mode,
  Refined_State => (Database_State => (Database, DB_Model))
is

   package DB_Pack is new Ada.Containers.Formal_Doubly_Linked_Lists
     (Element_Type => DB_Entry_Type,
      "="          => "=");
   use DB_Pack;

   Database : DB_Pack.List (1000);
   DB_Model : Model_Type with Ghost;

   ---------------------
   -- Add_To_Database --
   ---------------------

   procedure Add_To_Database
     (Email : Email_Address_Type;
      Key   : Key_Type)
   is
   begin
      pragma Assume
        (Length (Database) < Database.Capacity,
         "We have enough room for a new entry in the database");

      Append (Database, (Key, Email));
      DB_Model := Add (DB_Model, (Key, Email));
   end Add_To_Database;

   --------------
   -- Contains --
   --------------

   function Contains
     (Email : Email_Address_Type;
      Key   : Key_Type) return Boolean
   is (Contains (Database, (Key, Email)));

   ---------------
   -- Invariant --
   ---------------

   function Invariant return Boolean is

      --  Database does not contain duplicates

     ((for all I in Formal_Model.Model (Database) =>
         (for all J in Formal_Model.Model (Database) =>
              (if Formal_Model.Element (Formal_Model.Model (Database), I) =
                   Formal_Model.Element (Formal_Model.Model (Database), J)
               then I = J)))

      --  Database and DB_Model contain the same pairs

      and (for all Pair of Database => Contains (DB_Model, Pair))
      and (for all Pair of DB_Model => Contains (Database, Pair))
      and Length (DB_Model) = Length (Database));

   -----------------
   -- Query_Email --
   -----------------

   function Query_Email (Email : Email_Address_Type) return Key_Type
   is
      use Formal_Model;
   begin
      for C in Database loop
         pragma Loop_Invariant
           (for all I in 1 .. P.Get (Positions (Database), C) - 1 =>
                Element (Model (Database), I).Email /= Email);
         declare
            Ent : DB_Entry_Type renames Element (Database, C);
         begin
            if Ent.Email = Email then
               return Ent.Key;
            end if;
         end;
      end loop;
      return No_Key;
   end Query_Email;

   -----------
   -- Model --
   -----------

   function Model return Model_Type is (DB_Model);

   --------------------------
   -- Remove_From_Database --
   --------------------------

   procedure Remove_From_Database
     (Email : Email_Address_Type;
      Key   : Key_Type)
   is
      Pos : Cursor := Find (Database, (Key, Email));
   begin
      Delete (Database, Pos);
      DB_Model := Remove (DB_Model, (Key, Email));
   end Remove_From_Database;

end Database;
