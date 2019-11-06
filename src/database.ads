with Email; use Email;
with Keys; use Keys;

package Database is

   procedure Add_To_Database
     (Email : Email_Address_Type;
      Key   : Key_Type);

   procedure Remove_From_Database
     (Email : Email_Address_Type;
      Key   : Key_Type)
   with Pre => Contains (Email, Key);

   function Contains
     (Email : Email_Address_Type;
      Key   : Key_Type) return Boolean;

   function Query_Email (Email : Email_Address_Type) return Key_Type;

end Database;
