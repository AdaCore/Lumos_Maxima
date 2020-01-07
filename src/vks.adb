with Ada.Containers.Indefinite_Doubly_Linked_Lists;
with Ada.Strings.Unbounded;
use type Ada.Strings.Unbounded.Unbounded_String;
with Ada.Text_IO;
with AWS.MIME;
with AWS.Parameters;
with AWS.Status;
with AWS.Translator;
with GNAT.Regpat;

with Email;
with Keys;
with Server;
with Tokens;

use type AWS.Status.Request_Method;

package body VKS with SPARK_Mode => Off is

   package String_Lists is new
     Ada.Containers.Indefinite_Doubly_Linked_Lists (String);

   function Build_HTML_Answer (S : String) return Response.Data;

   function Extract_Email (Key : String) return String_Lists.List;

   Re : constant GNAT.Regpat.Pattern_Matcher :=
     GNAT.Regpat.Compile ("<[[:print:]]+?>");

   -----------------------
   -- Build_HTML_Answer --
   -----------------------

   function Build_HTML_Answer (S : String) return Response.Data is
   begin
      return Response.Build
        (MIME.Text_HTML,
         "<!DOCTYPE html>" &
           "<html>" &
           "<head>" &
           "<script src=""https://code.jquery.com/jquery-1.10.2.js""></script>" &
           "<link rel=""stylesheet"" href=""style.css"">" &
           "</head>" &
           "<body>" &
           "<div id=""nav-placeholder""> </div>" &
           "<script> $(function(){ $(""#nav-placeholder"").load(""/nav.html""); }); </script>" &
           S &
           "</body>" &
           "</html>");
   end Build_HTML_Answer;

   --------------------
   -- By_Fingerprint --
   --------------------

   function By_Fingerprint (Request : Status.Data) return Response.Data is
   begin
      if Status.Method (Request) /= Status.GET then
         raise Constraint_Error;
      end if;

      return Response.Build
        (MIME.Text_HTML, "<p>WIP on GET by-fingerprint</p>");
   end By_Fingerprint;

   --------------
   -- By_Keyid --
   --------------

   function By_Keyid (Request : Status.Data) return Response.Data is
   begin
      if Status.Method (Request) /= Status.GET then
         raise Constraint_Error;
      end if;

      return Response.Build
        (MIME.Text_HTML, "<p>WIP on GET by-keyid</p>");
   end By_Keyid;

   --------------
   -- By_Email --
   --------------

   function By_Email (Request : Status.Data) return Response.Data is
      use Email;
      use Keys;

      P : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
      E : Email_Id;
      K : Key_Type;
   begin
      To_Email_Address (AWS.Parameters.Get (P, "email"), E);
      if E /= No_Email_Id then
         K := Server.Query_Email (E);
         if K /= No_Key then
            return Build_HTML_Answer
              ("<p> The key is " & To_String (K) & "</p>");
         end if;
      end if;
      return Build_HTML_Answer
        ("<p> Key not found</p>");
   end By_Email;

      -------------------
   -- Extract_Email --
   -------------------

   function Extract_Email (Key : String) return String_Lists.List is
      use GNAT.Regpat;
      Dec : constant String := AWS.Translator.Base64_Decode (Key);
      Current : Natural := Dec'First;
      Matches : Match_Array (0 .. 0);
      Result : String_Lists.List := String_Lists.Empty_List;
   begin
      loop
         Match (Re, Dec, Matches, Current);
         exit when Matches (0) = No_Match;
         Result.Append (Dec (Matches (0).First .. Matches (0).Last));
         Current := Matches (0).Last + 1;
      end loop;
      return Result;
   end Extract_Email;

   ------------
   -- Upload --
   ------------

   function Upload (Request : Status.Data) return Response.Data is
      P : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
      E : Email.Email_Id;
      Key : constant Keys.Key_Type := Keys.From_String ("1");
      Token : Tokens.Token_Type;
      Keytext : constant String := AWS.Parameters.Get (P, "keytext");
      Addr : constant String_Lists.List := Extract_Email (Keytext);
   begin
      for S of Addr loop
         Ada.Text_IO.Put_Line (S);
      end loop;
      Email.To_Email_Address (Addr.First_Element, E);
      --  check for valid email
      pragma Assert (E in Email.Valid_Email_Id);
      Server.Request_Add (E, Key, Token);
      declare
         L : constant String :=
           "<a href=""/vks/v1/request-verify?token=" & Tokens.To_String (Token)
           &"""> Link to validate the token</a>";
         S : constant String :=
           "This is the confirmation link to verify the add." &
           " Normally we would send it by email, but this is just a demo.";
      begin
         return Build_HTML_Answer
           ("<p>" & S & "</p>" & "<p>" & L & "</p>");
      end;
   end Upload;

   --------------------
   -- Request_Verify --
   --------------------

   function Request_Verify (Request : Status.Data) return Response.Data is
      P : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
      Token : constant Tokens.Token_Type :=
        Tokens.From_String (AWS.Parameters.Get (P, "token"));
      Status : Boolean;
   begin
      Server.Verify_Add (Token, Status);
      if Status then
         return Build_HTML_Answer
           ("<p>Successfully added key</p>");
      else
         return Build_HTML_Answer
           ("<p>Error when adding the key</p>");
      end if;
   end Request_Verify;

end VKS;
