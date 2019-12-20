with Email; use Email;
with Keys;  use Keys;
with Ada.Containers.Functional_Sets;

--  Interface to the database. It can be implemented using local datastructures
--  (like here) or a persistent mechanism (file system, sql database...).

package Database with SPARK_Mode,
  Initial_Condition => Invariant,
  Abstract_State    => Database_State
is

   --  The model of a database is a set of pairs of a key and an email

   type DB_Entry_Type is record
      Key   : Key_Type;
      Email : Email_Address_Type;
   end record;

   package DB_Entry_Sets is new Ada.Containers.Functional_Sets
     (Element_Type => DB_Entry_Type);
   use DB_Entry_Sets;
   subtype Model_Type is DB_Entry_Sets.Set with Ghost;

   function Model return Model_Type with
     Ghost,
     Global => Database_State;

   --  Invariant linking the model of our database to its content

   function Invariant return Boolean with
     Ghost,
     Global => Database_State;

   --  Queries on the content of the database

   function Contains
     (Email : Email_Address_Type;
      Key   : Key_Type) return Boolean
   with
     Global => Database_State,
     Pre    => Invariant,
     Post   => Contains'Result = Contains (Model, (Key, Email));

   function Query_Email (Email : Email_Address_Type) return Key_Type with
     Global         => Database_State,
     Pre            => Invariant,
     Contract_Cases =>
       ((for some Pair of Model => Pair.Email = Email) =>
          Contains (Model, (Query_Email'Result, Email)),
        others                                         =>
          Query_Email'Result = No_Key);

   --  Queries to update the database

   procedure Add_To_Database
     (Email : Email_Address_Type;
      Key   : Key_Type)
   with
     Global => (In_Out => Database_State),
     Pre    => Invariant and then not Contains (Email, Key),
     Post   => Invariant
       and Model'Old <= Model
       and Included_Except (Model, Model'Old, (Key, Email))
       and Contains (Model, (Key, Email));

   procedure Remove_From_Database
     (Email : Email_Address_Type;
      Key   : Key_Type)
   with
     Global => (In_Out => Database_State),
     Pre    => Invariant and then Contains (Email, Key),
     Post   => Invariant
       and Model <= Model'Old
       and Included_Except (Model'Old, Model, (Key, Email))
       and not Contains (Model, (Key, Email));

end Database;
