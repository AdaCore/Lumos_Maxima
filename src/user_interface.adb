with AWS.MIME;

package body User_Interface is


   function User_Add (Request : Status.Data) return Response.Data is
   begin
      return AWS.Response.File
        (Content_Type => AWS.MIME.Text_HTML,
         Filename     => "resources/user_add.html");
   end User_Add;

   function Index (Request : Status.Data) return Response.Data is
   begin
      return AWS.Response.File
        (Content_Type => AWS.MIME.Text_HTML,
         Filename     => "resources/index.html");
   end Index;

   function Query (Request : Status.Data) return Response.Data is
   begin
      return AWS.Response.File
        (Content_Type => AWS.MIME.Text_HTML,
         Filename     => "resources/query.html");
   end Query;

end User_Interface;
