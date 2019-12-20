with Email;    use Email;
with Keys;     use Keys;
with Tokens;   use Tokens;
with Database; use Database;

package Server with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   use Database.DB_Entry_Sets;

   --  Invariant of the server

   function Invariant return Boolean is
     (Tokens.Invariant and then Database.Invariant)
   with Ghost;

   function Query_Email (Email : Email_Address_Type) return Key_Type with
     Pre            => Invariant,
     Contract_Cases =>

        --  If we have an entry for Email in the database, we return a key
        --  associated to Email in the database.

       ((for some Pair of Model => Pair.Email = Email) =>
           Contains (Model, (Query_Email'Result, Email)),

        --  Otherwise, we return No_Key.

        others                                         =>
          Query_Email'Result = No_Key);
   
   procedure Request_Add
     (Email :     Email_Address_Type;
      Key   :     Key_Type;
      Token : out Token_Type)
   with 
     Pre  => Invariant,
     Post => Invariant

     --  Token is associated to a seen request for the addition of a pair
     --  Email / Key in the database. We don't specify anything about the
     --  validity of this token as it may depend on external constraints
     --  (the time...).

       and Contains (Seen_Tokens, Token)
       and Email = Get_Email (Seen_Tokens, Token)
       and Key = Get_Key (Seen_Tokens, Token)
       and Is_Add (Seen_Tokens, Token)
       and Seen_Tokens'Old <= Seen_Tokens;

   procedure Verify_Add
     (Token  :     Token_Type;
      Status : out Boolean)
   with
     Pre  => Invariant,
     Post => Invariant

       --  If Status is set to True, Token was a seen request for the addition
       --  of a pair Email / Key in the database, and there is now an entry for
       --  this pair in the database after the call.

       and (if Status
            then Contains (Seen_Tokens, Token)
              and Is_Add (Seen_Tokens, Token)
              and Model'Old <= Model
              and Included_Except
                (Model, Model'Old, 
                  (Get_Key (Seen_Tokens, Token), Get_Email (Seen_Tokens, Token)))
              and Contains
                (Model, 
                  (Get_Key (Seen_Tokens, Token), Get_Email (Seen_Tokens, Token)))
  
       --  Otherwise, the database was not modified
  
            else Model = Model'Old)
       and Seen_Tokens'Old <= Seen_Tokens;

   procedure Request_Remove
     (Email :     Email_Address_Type;
      Key   :     Key_Type;
      Token : out Token_Type)
   with 
     Pre  => Invariant,
     Post => Invariant
       and Seen_Tokens'Old <= Seen_Tokens,
     Contract_Cases =>

       --  If an entry for the pair Email / Key is in the database, Token is
       --  associated to a seen request for the removal of the pair
       --  Email / Key from the database. We don't specify anything about the
       --  validity of this token as it may depend on external constraints
       --  (the time...).

       (Contains (Model, (Key, Email)) => Contains (Seen_Tokens, Token)
                                      and Is_Remove (Seen_Tokens, Token)
                                      and Email = Get_Email (Seen_Tokens, Token)
                                      and Key = Get_Key (Seen_Tokens, Token),

       --  Otherwise, we return No_Token.

        others                         => Token = No_Token);

   procedure Verify_Remove
     (Token  :     Token_Type;
      Status : out Boolean)
   with 
     Pre  => Invariant,
     Post => Invariant

       --  If Status is set to True, Token was a seen request for the removal
       --  of a pair Email / Key from the database, and there are no entries for
       --  this pair in the database after the call.
  
       and (if Status
            then Contains (Seen_Tokens, Token)
              and Is_Remove (Seen_Tokens, Token)
              and Model <= Model'Old
              and Included_Except
                (Model'Old, Model, 
                  (Get_Key (Seen_Tokens, Token), Get_Email (Seen_Tokens, Token)))
              and not Contains
                (Model, 
                  (Get_Key (Seen_Tokens, Token), Get_Email (Seen_Tokens, Token)))
  
       --  Otherwise, the database was not modified
  
            else Model = Model'Old)
       and Seen_Tokens'Old <= Seen_Tokens;

end Server;
