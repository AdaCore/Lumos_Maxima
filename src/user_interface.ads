with AWS.Status;
with AWS.Response;

package User_Interface with SPARK_Mode => Off is

   function Get (Request : in AWS.Status.Data) return AWS.Response.Data;

end User_Interface;
