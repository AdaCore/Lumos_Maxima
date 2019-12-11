package Email with SPARK_Mode is

   --  emails are at most 256 characters long, see
   --  https://stackoverflow.com/questions/386294/what-is-the-maximum-length-of-a-valid-email-address

   Max_Email_Length : constant := 256;
   Max_Num_Emails : constant := 1024;

   type Email_Address_Type is new Integer range 0 .. Max_Num_Emails;

   subtype Valid_Email_Address_Type is Email_Address_Type
   range 1 .. Email_Address_Type'Last;

   No_Email : constant Email_Address_Type := 0;

   procedure To_Email_Address (S : String;
                               Email : out Email_Address_Type)
     with Pre => S'Length <= 256;
      --  returns No_Email if email address integer could not be created

   function To_String (E : Valid_Email_Address_Type) return String
   with Post => To_String'Result'Length <= 256;

end Email;
