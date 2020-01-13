with Ada.Text_IO;
with AWS.Config;
with AWS.Config.Set;
with AWS.Server;
with User_Interface;

procedure Web_Server is
   WS   : AWS.Server.HTTP;

   Config : AWS.Config.Object := AWS.Config.Get_Current;
begin
   --  as documented in https://keys.openpgp.org/about/api

   AWS.Config.Set.Reuse_Address (Config, True);

   AWS.Server.Start (WS, User_Interface.Get'Access, Config => Config);
   Ada.Text_IO.Put_Line ("Now, please connect to");
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("  http://localhost:8080/");
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Type q to stop the server.");
   AWS.Server.Wait (Mode => AWS.Server.Q_Key_Pressed);
end Web_Server;
