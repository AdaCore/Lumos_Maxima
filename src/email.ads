with Ada.Containers.Functional_Sets;

package Email with SPARK_Mode is

   --  emails are at most 256 characters long, see
   --  https://stackoverflow.com/questions/386294/what-is-the-maximum-length-of-a-valid-email-address

   Max_Email_Length : constant := 256;
   Max_Num_Emails : constant := 1024;

   type Email_Id is new Integer range 0 .. Max_Num_Emails;

   subtype Valid_Email_Id is Email_Id
   range 1 .. Email_Id'Last;

   No_Email_Id : constant Email_Id := 0;

   type Number_Set is private with Ghost;

   function Seen_Numbers return Number_Set with Ghost;

   function "<=" (Left, Right : Number_Set) return Boolean with Ghost;

   function Contains
      (Set   : Number_Set;
       Email : Valid_Email_Id)
       return Boolean with Ghost;

   function Invariant return Boolean with Ghost;

   procedure To_Email_Id
      (S     : String;
       Email : out Email_Id)
   with Pre  => S'Length <= 256 and then Invariant,
        Post => Invariant
          and (if Email /= No_Email_Id then Contains (Seen_Numbers, Email))
          and Seen_Numbers'Old <= Seen_Numbers;
      --  returns No_Email if email address integer could not be created

private

   package Number_Sets is
     new Ada.Containers.Functional_Sets (Valid_Email_Id);

   use Number_Sets;

   type Number_Set is record
      Numbers : Number_Sets.Set;
   end record;

   function "<=" (Left, Right : Number_Set) return Boolean is
     (Left.Numbers <= Right.Numbers);

   function Contains
     (Set   : Number_Set;
      Email : Valid_Email_Id)
      return Boolean
   is (Contains (Set.Numbers, Email));

end Email;
