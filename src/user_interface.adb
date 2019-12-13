with AWS.MIME;

package body User_Interface is


   function User_Add (Request : Status.Data) return Response.Data is
   begin
      return AWS.Response.File
        (Content_Type => AWS.MIME.Text_HTML,
         Filename     => "user_add.html");
   end User_Add;

end User_Interface;
