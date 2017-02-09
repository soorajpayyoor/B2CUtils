#r"Newtonsoft.JSON"
using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Web.Http;
using Newtonsoft.Json.Linq;


static string customerId = "<OMS Customer ID>";
static string sharedKey = "OMS Shared Key";
static string LogName = "B2CUserJourney";
static string TimeStampField = "";

static TraceWriter logger;

public static void LogtoLogAnalytics(string ToLog,TraceWriter log)
{
    logger = log;
    
    ToLog = addCorrIDtoAll(ToLog);

    var datestring = DateTime.UtcNow.ToString("r");
    string stringToHash = "POST\n" + ToLog.Length + "\napplication/json\n" + "x-ms-date:" + datestring + "\n/api/logs";
    string hashedString = BuildSignature(stringToHash, sharedKey);
    string signature = "SharedKey " + customerId + ":" + hashedString;

    PostData(signature, datestring, ToLog);

}

public static string addCorrIDtoAll(string ToLog)
{
    dynamic jsonObj = Newtonsoft.Json.JsonConvert.DeserializeObject(ToLog);
    String CorrID = jsonObj[0]["Content"]["CorrelationId"].Value;

    JArray newArr = new JArray();
    foreach (dynamic obj in jsonObj)
    {
        if (obj["Kind"].Value != "Headers")
        {
            obj["CorrelationId"] = CorrID;

        }
        newArr.Add(obj);
    }
    return newArr.ToString();

}

public static string BuildSignature(string message, string secret)
{
    var encoding = new System.Text.ASCIIEncoding();
    byte[] keyByte = Convert.FromBase64String(secret);
    byte[] messageBytes = encoding.GetBytes(message);
    using (var hmacsha256 = new HMACSHA256(keyByte))
    {
        byte[] hash = hmacsha256.ComputeHash(messageBytes);
        return Convert.ToBase64String(hash);
    }
}

// Send a request to the POST API endpoint
public static void PostData(string signature, string date, string json)
{
    string url = "https://" + customerId + ".ods.opinsights.azure.com/api/logs?api-version=2016-04-01";
    logger.Info("Sending data to : " + url);
    using (var client = new WebClient())
    {
        client.Headers.Add(HttpRequestHeader.ContentType, "application/json");
        client.Headers.Add("Log-Type", LogName);
        client.Headers.Add("Authorization", signature);
        client.Headers.Add("x-ms-date", date);
        client.Headers.Add("time-generated-field", TimeStampField);
        client.UploadString(new Uri(url), "POST", json);
    }

}