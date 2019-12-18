with AWS.Status;
with AWS.Response;

package User_Interface is

   function Get (Request : in AWS.Status.Data) return AWS.Response.Data;

end User_Interface;
