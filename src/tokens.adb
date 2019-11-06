with Ada.Containers.Formal_Hashed_Maps;
package body Tokens is

   type DB_Entry_Type is record
      Key : Key_Type;
      Email : Email_Address_Type;
   end record;

   function Token_Hash (H : Token_Type) return Ada.Containers.Hash_Type;

   function Token_Hash (H : Token_Type) return Ada.Containers.Hash_Type is
      (Ada.Containers.Hash_Type (H));

   package Request_Maps is new Ada.Containers.Formal_Hashed_Maps
     (Key_Type => Token_Type,
      Element_Type => DB_Entry_Type,
      Hash => Token_Hash,
      Equivalent_Keys => "=",
      "=" => "=");

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

   -------------------
   -- Get_Add_Email --
   -------------------

   function Get_Add_Email (Token : Token_Type) return Email_Address_Type is
     (Request_Maps.Element (Pending_Add_Map, Token).Email);

   -----------------
   -- Get_Add_Key --
   -----------------

   function Get_Add_Key (Token : Token_Type) return Key_Type is
     (Request_Maps.Element (Pending_Add_Map, Token).Key);

   ----------------------
   -- Get_Remove_Email --
   ----------------------

   function Get_Remove_Email (Token : Token_Type) return Email_Address_Type is
     (Request_Maps.Element (Pending_Remove_Map, Token).Email);

   --------------------
   -- Get_Remove_Key --
   --------------------

   function Get_Remove_Key (Token : Token_Type) return Key_Type is
     (Request_Maps.Element (Pending_Remove_Map, Token).Key);

   -------------------------
   -- Include_Add_Request --
   -------------------------

   procedure Include_Add_Request
     (Email : Email_Address_Type;
      Key   : Key_Type;
      Token : out Token_Type)
   is
      T : Token_Type;
   begin
      Create_Token (T);
      Request_Maps.Include (Pending_Add_Map, T, (Key, Email));
      Token := T;
   end Include_Add_Request;

   ----------------------------
   -- Include_Remove_Request --
   ----------------------------

   procedure Include_Remove_Request
     (Email : Email_Address_Type;
      Key   : Key_Type;
      Token : out Token_Type)
   is
      T : Token_Type;
   begin
      Create_Token (T);
      Request_Maps.Include (Pending_Remove_Map, T, (Key, Email));
      Token := T;
   end Include_Remove_Request;

   ---------------
   -- Valid_Add --
   ---------------

   function Valid_Add (Token : Token_Type) return Boolean is
     (Request_Maps.Contains (Pending_Add_Map, Token));

   ------------------
   -- Valid_Remove --
   ------------------

   function Valid_Remove (Token : Token_Type) return Boolean is
     (Request_Maps.Contains (Pending_Remove_Map, Token));


end Tokens;
