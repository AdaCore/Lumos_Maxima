with Ada.Containers.Formal_Hashed_Maps;
with Ada.Containers; use Ada.Containers;

package body Tokens with SPARK_Mode,
  Refined_State =>
    (Token_State => (Pending_Add_Map, Pending_Remove_Map, Token_Model),
     Clock_State => Counter)
is

   --  Containers used for our real datastructure

   type DB_Entry_Type is record
      Key   : Key_Type;
      Email : Email_Address_Type;
   end record;

   package Request_Maps is new Ada.Containers.Formal_Hashed_Maps
     (Key_Type => Token_Type,
      Element_Type => DB_Entry_Type,
      Hash => Token_Hash,
      Equivalent_Keys => "=",
      "=" => "=");

   Pending_Add_Map    : Request_Maps.Map (100, 100);
   Pending_Remove_Map : Request_Maps.Map (100, 100);

   Token_Model        : Token_Set with Ghost;

   --  The creation of token is simplistic, it uses a counter which is
   --  incremented for each new token.

   Counter            : Token_Type := 0;

   procedure Create_Token
     (T  : out Token_Type) with
     Pre  => Invariant,
     Post => Invariant and not Has_Key (Token_Model.Tokens, T);

   ------------------
   -- Create_Token --
   ------------------

   procedure Create_Token (T : out Token_Type) is
   begin
      -- ??? Much too easy to guess
      Counter := Counter + 1;
      T := Counter;

      pragma Assume
        (not Has_Key (Token_Model.Tokens, T), "All created tokens are new");
      --  The fact that T is a new token is not provable currently. It would
      --  require linking existing token to the current value of Counter in the
      --  invariant, which would make Invariant a volatile function as
      --  Clock_State is volatile.
      --  In a more complex implementation where information is stored inside
      --  the token, we may not need the fact that T is new, as long as it
      --  maps to the same information in the token model.
   end Create_Token;

   ------------------
   -- Get_Add_Info --
   ------------------

   procedure Get_Add_Info
     (Token : Token_Type;
      Valid : out Boolean;
      Email : out Email_Address_Type;
      Key   : out Key_Type)
   is
      use Request_Maps;
      C : constant Cursor := Find (Pending_Add_Map, Token);
   begin
      if C /= No_Element then
         declare
            Info : DB_Entry_Type renames Element (Pending_Add_Map, C);
         begin
            Email := Info.Email;
            Key := Info.Key;
            Valid := True;
         end;
      else
         Email := No_Email;
         Key := No_Key;
         Valid := False;
      end if;
   end Get_Add_Info;

   ---------------------
   -- Get_Remove_Info --
   ---------------------

   procedure Get_Remove_Info
     (Token : Token_Type;
      Valid : out Boolean;
      Email : out Email_Address_Type;
      Key   : out Key_Type)
   is
      use Request_Maps;
      C : constant Cursor := Find (Pending_Remove_Map, Token);
   begin
      if C /= No_Element then
         declare
            Info : DB_Entry_Type renames Element (Pending_Remove_Map, C);
         begin
            Email := Info.Email;
            Key := Info.Key;
            Valid := True;
         end;
      else
         Email := No_Email;
         Key := No_Key;
         Valid := False;
      end if;
   end Get_Remove_Info;

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
      pragma Assume
        (Request_Maps.Length (Pending_Add_Map) <
             Request_Maps.Capacity (Pending_Add_Map),
         "We have enough room for a new Add request");
      pragma Assume
        (Length (Token_Model.Tokens) < Count_Type'Last,
         "We have enough room for a new seen token");

      Create_Token (T);
      Request_Maps.Include (Pending_Add_Map, T, (Key, Email));
      Token_Model.Tokens := Add (Token_Model.Tokens, T, (Key, Email, True));
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
      pragma Assume
        (Request_Maps.Length (Pending_Remove_Map) <
             Request_Maps.Capacity (Pending_Remove_Map),
         "We have enough room for a new Remove request");
      pragma Assume
        (Length (Token_Model.Tokens) < Count_Type'Last,
         "We have enough room for a new seen token");

      Create_Token (T);
      Request_Maps.Include (Pending_Remove_Map, T, (Key, Email));
      Token_Model.Tokens := Add (Token_Model.Tokens, T, (Key, Email, False));
      Token := T;
   end Include_Remove_Request;

   ---------------
   -- Invariant --
   ---------------

   function Invariant return Boolean is

      --  All tokens for pending requests have been seen

     ((for all T of Pending_Add_Map =>
                Has_Key (Token_Model.Tokens, T)
           and then Request_Maps.Element (Pending_Add_Map, T).Key =
             Get (Token_Model.Tokens, T).Key
           and then Request_Maps.Element (Pending_Add_Map, T).Email =
             Get (Token_Model.Tokens, T).Email
           and then Get (Token_Model.Tokens, T).Is_Add)
      and (for all T of Pending_Remove_Map =>
                Has_Key (Token_Model.Tokens, T)
           and then Request_Maps.Element (Pending_Remove_Map, T).Key =
             Get (Token_Model.Tokens, T).Key
           and then Request_Maps.Element (Pending_Remove_Map, T).Email =
             Get (Token_Model.Tokens, T).Email
           and then not Get (Token_Model.Tokens, T).Is_Add));

   -----------------
   -- Seen_Tokens --
   -----------------

   function Seen_Tokens return Token_Set is (Token_Model);

end Tokens;
