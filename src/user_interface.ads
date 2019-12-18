with AWS.Status;
with AWS.Response;

use AWS;

package User_Interface is

   function Get (Request : in AWS.Status.Data) return AWS.Response.Data;

end User_Interface;
