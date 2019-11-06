with Ada.Containers.Formal_Doubly_Linked_Lists;
with Ada.Containers.Formal_Hashed_Maps;

package body Database is

   type DB_Entry_Type is record
      Key : Key_Type;
      Email : Email_Address_Type;
   end record;

   package DB_Pack is new Ada.Containers.Formal_Doubly_Linked_Lists
     (Element_Type => DB_Entry_Type,
      "="          => "=");

   Database : DB_Pack.List (1000);

   ---------------------
   -- Add_To_Database --
   ---------------------

   procedure Add_To_Database
     (Email : Email_Address_Type;
      Key   : Key_Type)
   is
   begin
      DB_Pack.Append (Database, (Key, Email));
   end Add_To_Database;

   --------------
   -- Contains --
   --------------

   function Contains
     (Email : Email_Address_Type;
      Key   : Key_Type) return Boolean
   is (DB_Pack.Contains (Database, (Key, Email)));

   -----------------
   -- Query_Email --
   -----------------

   function Query_Email (Email : Email_Address_Type) return Key_Type
   is
   begin
      for Ent of Database loop
         if Ent.Email = Email then
            return Ent.Key;
         end if;
      end loop;
      return No_Key;
   end Query_Email;

   --------------------------
   -- Remove_From_Database --
   --------------------------

   procedure Remove_From_Database
     (Email : Email_Address_Type;
      Key   : Key_Type)
   is
      Pos : DB_Pack.Cursor := DB_Pack.Find (Database, (Key, Email));
   begin
      DB_Pack.Delete (Database, Pos);
   end Remove_From_Database;

end Database;
