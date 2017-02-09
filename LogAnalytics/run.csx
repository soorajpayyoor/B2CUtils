#load "OMSUtils.csx"
using System.Net;

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info("Processed a B2C User Journey.");
    string jsonContent = await req.Content.ReadAsStringAsync();
    LogtoLogAnalytics(jsonContent,log);
    log.Info(jsonContent);
    return req.CreateResponse(HttpStatusCode.OK, "Got it Ta." );
    
}