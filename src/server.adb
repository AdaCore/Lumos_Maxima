package body Server with SPARK_Mode is

   -----------------
   -- Request_Add --
   -----------------

   procedure Request_Add
      (Email : Email_Address_Type;
       Key   : Key_Type;
       Token : out Token_Type)
   is
   begin
      Include_Add_Request (Email, Key, Token);
   end Request_Add;

   ----------------
   -- Verify_Add --
   ----------------

   procedure Verify_Add
     (Token  : Token_Type;
      Status : out Boolean)
   is
      Email : Email_Address_Type;
      Key   : Key_Type;
   begin
      Get_Add_Info (Token, Status, Email, Key);
      if Status and then not Contains (Email, Key) then
         Add_To_Database (Email, Key);
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
      return Database.Query_Email (Email);
   end Query_Email;

   --------------------
   -- Request_Remove --
   --------------------

   procedure Request_Remove
      (Email : Email_Address_Type;
       Key   : Key_Type;
       Token : out Token_Type)
   is
   begin
      if Contains (Email, Key) then
         Include_Remove_Request (Email, Key, Token);
      else
         Token := No_Token;
      end if;
   end Request_Remove;

   -------------------
   -- Verify_Remove --
   -------------------

   procedure Verify_Remove
     (Token  : Token_Type;
      Status : out Boolean)
   is
      Email : Email_Address_Type;
      Key   : Key_Type;
   begin
      Get_Remove_Info (Token, Status, Email, Key);
      if Status and then Contains (Email, Key) then
         Remove_From_Database (Email, Key);
      end if;
   end Verify_Remove;

end Server;
