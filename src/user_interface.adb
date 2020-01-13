with Ada.Directories;
with AWS.Messages;
with AWS.MIME;
with AWS.Utils;
with VKS;

package body User_Interface with SPARK_Mode => Off is

   function Starts_With (S, Prefix : String) return Boolean;

   ---------
   -- Get --
   ---------

   function Get (Request : in AWS.Status.Data) return AWS.Response.Data is
      URI      : constant String := AWS.Status.URI (Request);
   begin
      if Starts_With (URI, "/vks") then
         if URI = "/vks/v1/by-fingerprint" then
            return VKS.By_Fingerprint (Request);
         elsif URI = "/vks/v1/by-keyid" then
            return VKS.By_Keyid (Request);
         elsif URI = "/vks/v1/by-email" then
            return VKS.By_Email (Request);
         elsif URI = "/vks/v1/upload" then
            return VKS.Upload (Request);
         elsif URI = "/vks/v1/request-verify" then
            return VKS.Request_Verify (Request);
         end if;
      else
         if URI = "/" then
            return AWS.Response.File
                 (Content_Type => AWS.MIME.Text_HTML,
                  Filename     =>
                    Ada.Directories.Compose ("resources", "index.html"));
         end if;

         declare
            Filename : constant String :=
              Ada.Directories.Compose ("resources", URI (2 .. URI'Last));
         begin
            if AWS.Utils.Is_Regular_File (Filename) then
               return AWS.Response.File
                 (Content_Type => AWS.MIME.Content_Type (Filename),
                  Filename     => Filename);
            end if;
         end;
      end if;
      return AWS.Response.Acknowledge
        (AWS.Messages.S404,
         "<p>Page '" & URI & "' Not found.");
   end Get;

   -----------------
   -- Starts_With --
   -----------------

   function Starts_With (S, Prefix : String) return Boolean is
   begin
      if Prefix'Length > S'Length then
         return False;
      else
         return Prefix = S (S'First .. S'First + Prefix'Length - 1);
      end if;
   end Starts_With;

end User_Interface;
