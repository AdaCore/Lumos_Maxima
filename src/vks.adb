with AWS.MIME;
with AWS.Parameters;
with AWS.Status;

with Email;
with Keys;
with Server;
with Tokens;

use type AWS.Status.Request_Method;

package body VKS is

   function By_Fingerprint (Request : Status.Data) return Response.Data is
   begin
      if Status.Method (Request) /= Status.GET then
         raise Constraint_Error;
      end if;

      return Response.Build
        (MIME.Text_HTML, "<p>WIP on GET by-fingerprint</p>");
   end By_Fingerprint;

   function By_Keyid (Request : Status.Data) return Response.Data is
   begin
      if Status.Method (Request) /= Status.GET then
         raise Constraint_Error;
      end if;

      return Response.Build
        (MIME.Text_HTML, "<p>WIP on GET by-keyid</p>");
   end By_Keyid;

   function By_Email (Request : Status.Data) return Response.Data is
      use Email;
      use Keys;

      P : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
      E : Email_Address_Type;
      K : Key_Type;
   begin
      To_Email_Address (AWS.Parameters.Get (P, "email"), E);
      if E /= No_Email then
         K := Server.Query_Email (E);
         if K /= No_Key then
            return Response.Build
              (MIME.Text_HTML, "<p> The key is " & To_String (K) & "</p>");
         end if;
      end if;
      return Response.Build
        (MIME.Text_HTML, "<p> Key not found</p>");
   end By_Email;

   function Upload (Request : Status.Data) return Response.Data is
      P : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
      E : Email.Email_Address_Type;
      Key : constant Keys.Key_Type :=
        Keys.From_String (AWS.Parameters.Get (P, "key"));
      Token : Tokens.Token_Type;
   begin
      Email.To_Email_Address (AWS.Parameters.Get (P, "email"), E);
      --  check for valid email
      pragma Assert (E in Email.Valid_Email_Address_Type);
      Server.Request_Add (E, Key, Token);
      declare
         L : constant String :=
           "<a href=""/vks/v1/request-verify?token=" & Tokens.To_String (Token)
           &"""> Link to validate the token</a>";
         S : constant String :=
           "This is the confirmation link to verify the add." &
           " Normally we would send it by email, but this is just a demo.";
      begin
         return Response.Build
           (MIME.Text_HTML, "<p>" & S & "</p>" & "<p>" & L & "</p>");
      end;
   end Upload;

   function Request_Verify (Request : Status.Data) return Response.Data is
      P : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
      Token : constant Tokens.Token_Type :=
        Tokens.From_String (AWS.Parameters.Get (P, "token"));
      Status : Boolean;
   begin
      Server.Verify_Add (Token, Status);
      if Status then
         return Response.Build
           (MIME.Text_HTML, "<p>Successfully added key</p>");
      else
         return Response.Build
           (MIME.Text_HTML, "<p>Error when adding the key</p>");
      end if;
   end Request_Verify;

end VKS;
