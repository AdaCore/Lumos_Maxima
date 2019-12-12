with AWS.Config;
with AWS.Server;
with AWS.Services.Dispatchers.URI;
with VKS;

procedure Web_Server is
   H    : AWS.Services.Dispatchers.URI.Handler;
   WS   : AWS.Server.HTTP;

   use AWS.Services;

begin
   --  as documented in https://keys.openpgp.org/about/api

   Dispatchers.URI.Register (H, "/vks/v1/by-fingerprint", VKS.By_Fingerprint'Access);
   Dispatchers.URI.Register (H, "/vks/v1/by-keyid", VKS.By_Keyid'Access);
   Dispatchers.URI.Register (H, "/vks/v1/by-email", VKS.By_Email'Access);
   Dispatchers.URI.Register (H, "/vks/v1/upload", VKS.Upload'Access);
   Dispatchers.URI.Register (H, "/vks/v1/request-verify", VKS.Request_Verify'Access);

   AWS.Server.Start (WS, Dispatcher => H, Config => AWS.Config.Get_Current);
   delay 60.0;
   AWS.Server.Shutdown (WS);
end Web_Server;
