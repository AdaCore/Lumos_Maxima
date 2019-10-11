with Ada.Containers.Formal_Doubly_Linked_Lists;
with Ada.Containers.Formal_Hashed_Maps;

package body Server with SPARK_Mode is

   type DB_Entry_Type is record
      Key : Key_Type;
      Email : Email_Address_Type;
   end record;

   package DB_Pack is new Ada.Containers.Formal_Doubly_Linked_Lists
     (Element_Type => DB_Entry_Type,
      "="          => "=");

   function Token_Hash (H : Token_Type) return Ada.Containers.Hash_Type;

   function Token_Hash (H : Token_Type) return Ada.Containers.Hash_Type is
      (Ada.Containers.Hash_Type (H));

   package Request_Maps is new Ada.Containers.Formal_Hashed_Maps
     (Key_Type => Token_Type,
      Element_Type => DB_Entry_Type,
      Hash => Token_Hash,
      Equivalent_Keys => "=",
      "=" => "=");

   Database : DB_Pack.List (1000);
   Pending_Add_Map : Request_Maps.Map (100, 100);
   Pending_Remove_Map : Request_Maps.Map (100, 100);

   Counter : Token_Type := 0;

   procedure Create_Token (T : out Token_Type);


   ------------------
   -- Create_Token --
   ------------------

   procedure Create_Token (T : out Token_Type) is
   begin
      -- ??? Much too easy to guess
      Counter := Counter + 1;
      T := Counter;
   end Create_Token;

   -----------------
   -- Request_Add --
   -----------------

   procedure Request_Add
      (Email : Email_Address_Type;
       Key   : Key_Type;
       Token : out Token_Type)
   is
      T : Token_Type;
   begin
      Create_Token (T);
      Request_Maps.Include (Pending_Add_Map, T, (Key, Email));
      Token := T;
   end Request_Add;

   ----------------
   -- Verify_Add --
   ----------------


   procedure Verify_Add
     (Token : Token_Type;
      Status : out Boolean)
   is
      use Request_Maps;
      C : Cursor := Find (Pending_Add_Map, Token);
   begin
      if C /= No_Element then
         declare
            Ent : constant DB_Entry_Type :=
              Element (Pending_Add_Map, C);
         begin
            DB_Pack.Append (Database, Ent);
            Status := True;
         end;
      else
         Status := False;
      end if;
   end Verify_Add;

   -----------------
   -- Query_Email --
   -----------------

   function Query_Email
      (Email : Email_Address_Type)
      return Key_Type
   is
   begin
      for Ent of Database loop
         if Ent.Email = Email then
            return Ent.Key;
         end if;
      end loop;
      return No_Key;
   end Query_Email;

   --------------------
   -- Request_Remove --
   --------------------

   procedure Request_Remove
      (Email : Email_Address_Type;
       Key   : Key_Type;
       Token : out Token_Type)
   is
      Ent : DB_Entry_Type := (Key, Email);
   begin
      if DB_Pack.Contains (Database, Ent) then
         Create_Token (Token);
         Request_Maps.Include (Pending_Remove_Map, Token, (Key, Email));
      else
         Token := No_Token;
      end if;
   end Request_Remove;

   -------------------
   -- Verify_Remove --
   -------------------

   procedure Verify_Remove
     (Token : Token_Type;
      Status : out Boolean)
   is
      use Request_Maps;
      C : Cursor := Find (Pending_Remove_Map, Token);
   begin
      if C /= No_Element then
         declare
            Ent : constant DB_Entry_Type :=
              Element (Pending_Add_Map, C);
            C_DB : DB_Pack.Cursor := DB_Pack.Find (Database, Ent);
         begin
            DB_Pack.Delete (Database, C_DB);
            Status := True;
         end;
      else
         Status := False;
      end if;
   end Verify_Remove;

end Server;
