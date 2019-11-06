with Email; use Email;
with Keys;  use Keys;
package Tokens is

   type Token_Type is private;

   No_Token : constant Token_Type;

   function Valid_Add (Token : Token_Type) return Boolean;

   function Get_Add_Email (Token : Token_Type) return Email_Address_Type with
     Pre => Valid_Add (Token);

   function Get_Add_Key (Token : Token_Type) return Key_Type with
     Pre => Valid_Add (Token);

   function Valid_Remove (Token : Token_Type) return Boolean;

   function Get_Remove_Email (Token : Token_Type) return Email_Address_Type with
     Pre => Valid_Remove (Token);

   function Get_Remove_Key (Token : Token_Type) return Key_Type with
     Pre => Valid_Remove (Token);

   procedure Include_Add_Request
     (Email : Email_Address_Type;
      Key   : Key_Type;
      Token : out Token_Type)
     with Post => Valid_Add (Token)
     and then Get_Add_Email (Token) = Email
     and then Get_Add_Key (Token) = Key;

   procedure Include_Remove_Request
     (Email : Email_Address_Type;
      Key   : Key_Type;
      Token : out Token_Type)
   with Post => Valid_Remove (Token)
     and then Get_Remove_Email (Token) = Email
     and then Get_Remove_Key (Token) = Key;

private

   type Token_Type is mod 2 ** 64;

   No_Token : constant Token_Type := 0;
end Tokens;
