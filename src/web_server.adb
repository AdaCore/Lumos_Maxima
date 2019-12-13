with Ada.Text_IO;
with AWS.Config;
with AWS.Config.Set;
with AWS.Server;
with AWS.Services.Dispatchers.URI;
with VKS;
with User_Interface;

procedure Web_Server is
   H    : AWS.Services.Dispatchers.URI.Handler;
   WS   : AWS.Server.HTTP;

   use AWS.Services;

   Config : AWS.Config.Object := AWS.Config.Get_Current;
begin
   --  as documented in https://keys.openpgp.org/about/api

   Dispatchers.URI.Register (H, "/vks/v1/by-fingerprint", VKS.By_Fingerprint'Access);
   Dispatchers.URI.Register (H, "/vks/v1/by-keyid", VKS.By_Keyid'Access);
   Dispatchers.URI.Register (H, "/vks/v1/by-email", VKS.By_Email'Access);
   Dispatchers.URI.Register (H, "/vks/v1/upload", VKS.Upload'Access);
   Dispatchers.URI.Register (H, "/vks/v1/request-verify", VKS.Request_Verify'Access);

   --  entry points for end users
   Dispatchers.URI.Register (H, "/user_add", User_Interface.User_Add'Access);

   AWS.Config.Set.Reuse_Address (Config, True);

   AWS.Server.Start (WS, Dispatcher => H, Config => Config);
   Ada.Text_IO.Put_Line ("Now, please connect to");
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("  http://localhost:8080/user_add");
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Type q to stop the server.");
   AWS.Server.Wait (Mode => AWS.Server.Q_Key_Pressed);
end Web_Server;
