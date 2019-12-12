with AWS.MIME;
with AWS.Status;

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
   begin
      if Status.Method (Request) /= Status.GET then
         raise Constraint_Error;
      end if;

      return Response.Build
        (MIME.Text_HTML, "<p>WIP on GET by-email</p>");
   end By_Email;

   function Upload (Request : Status.Data) return Response.Data is
   begin
      if Status.Method (Request) /= Status.POST then
         raise Constraint_Error;
      end if;

      return Response.Build
        (MIME.Text_HTML, "<p>WIP on POST upload</p>");
   end Upload;

   function Request_Verify (Request : Status.Data) return Response.Data is
   begin
      if Status.Method (Request) /= Status.POST then
         raise Constraint_Error;
      end if;

      return Response.Build
        (MIME.Text_HTML, "<p>WIP on POST request-verify</p>");
   end Request_Verify;

end VKS;
