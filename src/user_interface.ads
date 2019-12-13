with AWS.Status;
with AWS.Response;

use AWS;

package User_Interface is

   function User_Add (Request : Status.Data) return Response.Data;

end User_Interface;
