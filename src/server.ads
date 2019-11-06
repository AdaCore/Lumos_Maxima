with Email;  use Email;
with Keys;   use Keys;
with Tokens; use Tokens;

package Server with SPARK_Mode is
   
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

end Server;
