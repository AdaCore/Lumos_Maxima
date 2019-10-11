with Email; use Email;
with Keys; use Keys;
package Server with SPARK_Mode is

   type Token_Type is private;

   No_Token : constant Token_Type;
   
   procedure Request_Add
      (Email : Email_Address_Type;
       Key   : Key_Type;
       Token : out Token_Type);

   procedure Verify_Add
     (Token : Token_Type;
      Status : out Boolean);

   function Query_Email
      (Email : Email_Address_Type)
      return Key_Type;

   procedure Request_Remove
      (Email : Email_Address_Type;
       Key   : Key_Type;
       Token : out Token_Type);

   procedure Verify_Remove
     (Token : Token_Type;
      Status : out Boolean);

private
   
   type Token_Type is mod 2 ** 64;

   No_Token : constant Token_Type := 0;
end Server;
