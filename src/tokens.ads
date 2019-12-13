with Email; use Email;
with Keys;  use Keys;
with Ada.Containers.Functional_Maps;

--  Interface to the token handling mechanism. It can be implemented using
--  internal databases (like here) or by haching all the required information
--  in the token, assuming they are hard enough to forge.

package Tokens with SPARK_Mode,
  Initial_Condition => Invariant,
  Abstract_State    => (Token_State, (Clock_State with External))
is

   type Token_Type is private;

   No_Token : constant Token_Type;

   --  The model of our system is a set of seen token. All seen tokens can be
   --  mapped to an email and a key, and we can determine whether they encode
   --  an add or remove request.
   --  We have used a private type for this datastructure as we cannot
   --  instanciate a container containing tokens before the full view of token
   --  is availlable.

   type Token_Set is private with Ghost;

   function Seen_Tokens return Token_Set with
     Ghost,
     Global => Token_State;

   function "<=" (Left, Right : Token_Set) return Boolean with Ghost;

   function Contains (Set : Token_Set; Token : Token_Type) return Boolean with
     Ghost;

   function Get_Email
     (Set   : Token_Set;
      Token : Token_Type) return Email_Address_Type
   with
     Ghost,
     Pre  => Contains (Set, Token);

   function Get_Key (Set : Token_Set; Token : Token_Type) return Key_Type with
     Ghost,
     Pre => Contains (Set, Token);

   function Is_Add (Set : Token_Set; Token : Token_Type) return Boolean with
     Ghost,
     Pre => Contains (Set, Token);

   function Is_Remove (Set : Token_Set; Token : Token_Type) return Boolean is
     (not Is_Add (Set, Token))
   with Ghost,
     Pre => Contains (Set, Token);

   --  Invariant linking the model to the internal state of our system

   function Invariant return Boolean with
     Ghost,
     Global => Token_State;

   --  We use procedures to query the validity and associations of a token all
   --  at once, as the validity of the token may be influenced by the time and
   --  we don't want to query the associations of an invalid token.
   --  If a token is valid, then it must have been seen. On the other hand, we
   --  do not specify when a token can become invalid. We have safety
   --  properties, but not liveness properties.

   procedure Get_Add_Info
     (Token : Token_Type;
      Valid : out Boolean;
      Email : out Email_Address_Type;
      Key   : out Key_Type)
   with
   --  Global => (In_Out => (Clock_State, Token_State)),
     Pre    => Invariant,
     Post   => Invariant
     and (if Valid
          then Contains (Seen_Tokens, Token)
            and Is_Add (Seen_Tokens, Token)
            and Email = Get_Email (Seen_Tokens, Token)
            and Key = Get_Key (Seen_Tokens, Token)
          else Email = No_Email and Key = No_Key)
     and Seen_Tokens'Old = Seen_Tokens;

   procedure Get_Remove_Info
     (Token : Token_Type;
      Valid : out Boolean;
      Email : out Email_Address_Type;
      Key   : out Key_Type)
   with
  --   Global => (In_Out => (Clock_State, Token_State)),
     Pre    => Invariant,
     Post   => Invariant
     and (if Valid
          then Contains (Seen_Tokens, Token)
            and Is_Remove (Seen_Tokens, Token)
            and Email = Get_Email (Seen_Tokens, Token)
            and Key = Get_Key (Seen_Tokens, Token)
          else Email = No_Email and Key = No_Key)
     and Seen_Tokens'Old = Seen_Tokens;

   --  The two procedures below are used to create a token. They may or may not
   --  read/update the clock state and the token state. We don't specify here
   --  that Token should not be already in the set of seen tokens. We could
   --  in particular consider that all tokens are in this set from the
   --  beginning if all the information is already contained in the token
   --  (modulo the cardinality of the set of seen tokens).

   procedure Include_Add_Request
     (Email : Email_Address_Type;
      Key   : Key_Type;
      Token : out Token_Type)
   with
     Global => (In_Out => (Clock_State, Token_State)),
     Pre    => Invariant,
     Post   => Invariant
     and Contains (Seen_Tokens, Token)
     and Is_Add (Seen_Tokens, Token)
     and Email = Get_Email (Seen_Tokens, Token)
     and Key = Get_Key (Seen_Tokens, Token)
     and Seen_Tokens'Old <= Seen_Tokens;

   procedure Include_Remove_Request
     (Email : Email_Address_Type;
      Key   : Key_Type;
      Token : out Token_Type)
   with
     Global => (In_Out => (Clock_State, Token_State)),
     Pre    => Invariant,
     Post   => Invariant
     and Contains (Seen_Tokens, Token)
     and Is_Remove (Seen_Tokens, Token)
     and Email = Get_Email (Seen_Tokens, Token)
     and Key = Get_Key (Seen_Tokens, Token)
     and Seen_Tokens'Old <= Seen_Tokens;

   function To_String (T : Token_Type) return String;
   function From_String (T : String) return Token_Type;

private

   type Token_Type is mod 2 ** 32;

   No_Token : constant Token_Type := 0;

   function Token_Hash (H : Token_Type) return Ada.Containers.Hash_Type;

   function Token_Hash (H : Token_Type) return Ada.Containers.Hash_Type is
      (Ada.Containers.Hash_Type (H));

   --  Full definition of the model of our system. We use a functional map
   --  to link seen tokens to a record holding all the necessary information.

   type Token_Info is record
      Key    : Key_Type;
      Email  : Email_Address_Type;
      Is_Add : Boolean;
   end record;

   package Token_Sets is new Ada.Containers.Functional_Maps
     (Token_Type, Token_Info);
   use Token_Sets;

   type Token_Set is record
      Tokens : Token_Sets.Map;
   end record;

   function "<=" (Left, Right : Token_Set) return Boolean is
     (Left.Tokens <= Right.Tokens);

   function Contains (Set : Token_Set; Token : Token_Type) return Boolean is
     (Has_Key (Set.Tokens, Token));

   function Get_Email
     (Set   : Token_Set;
      Token : Token_Type) return Email_Address_Type
   is (Get (Set.Tokens, Token).Email);

   function Get_Key (Set : Token_Set; Token : Token_Type) return Key_Type is
     (Get (Set.Tokens, Token).Key);

   function Is_Add (Set : Token_Set; Token : Token_Type) return Boolean is
     (Get (Set.Tokens, Token).Is_Add);

   function To_String (T : Token_Type) return String is
     (Token_Type'Image (T));

   function From_String (T : String) return Token_Type is
      (Token_Type'Value (T));

end Tokens;
