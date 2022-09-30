using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Apim.Demo
{
    public static class DemoTriggers
    {
        [FunctionName("DemoTrigger")]
        public static async Task<IActionResult> DemoTrigger(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "demo")] HttpRequest req,
            ILogger log)
        {
            return new OkObjectResult("It works!");
        }
    }
}
