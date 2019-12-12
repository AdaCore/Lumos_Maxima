with AWS.Status;
with AWS.Response;

use AWS;

package VKS is

   function By_Fingerprint (Request : Status.Data) return Response.Data;

   function By_Keyid (Request : Status.Data) return Response.Data;

   function By_Email (Request : Status.Data) return Response.Data;

   function Upload (Request : Status.Data) return Response.Data;

   function Request_Verify (Request : Status.Data) return Response.Data;

end VKS;
