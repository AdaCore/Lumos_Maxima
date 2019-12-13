with Ada.Containers.Functional_Sets;

package Email with SPARK_Mode is

   --  emails are at most 256 characters long, see
   --  https://stackoverflow.com/questions/386294/what-is-the-maximum-length-of-a-valid-email-address

   Max_Email_Length : constant := 256;
   Max_Num_Emails : constant := 1024;

   type Email_Address_Type is new Integer range 0 .. Max_Num_Emails;

   subtype Valid_Email_Address_Type is Email_Address_Type
   range 1 .. Email_Address_Type'Last;

   No_Email : constant Email_Address_Type := 0;

   type Number_Set is private with Ghost;

   function Seen_Numbers return Number_Set with
     Ghost;

   function "<=" (Left, Right : Number_Set) return Boolean with Ghost;

   function Contains (Set : Number_Set; Email : Valid_Email_Address_Type)
                      return Boolean with Ghost;

   function Invariant return Boolean with Ghost;

   procedure To_Email_Address (S : String;
                               Email : out Email_Address_Type)
     with Pre => S'Length <= 256 and then Invariant,
     Post =>
       (Invariant and
          (if Email /= No_Email then Contains (Seen_Numbers, Email)) and
            Seen_Numbers'Old <= Seen_Numbers);
      --  returns No_Email if email address integer could not be created

   function To_String (E : Valid_Email_Address_Type) return String
     with Pre => Contains (Seen_Numbers, E) and then Invariant,
          Post => To_String'Result'Length <= 256;

private

   package Number_Sets is new Ada.Containers.Functional_Sets
     (Valid_Email_Address_Type);

   use Number_Sets;

   type Number_Set is record
      Numbers : Number_Sets.Set;
   end record;

   function "<=" (Left, Right : Number_Set) return Boolean is
     (Left.Numbers <= Right.Numbers);

   function Contains (Set : Number_Set; Email : Valid_Email_Address_Type)
     return Boolean is (Contains (Set.Numbers, Email));

end Email;
