using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Net.Http;
using Newtonsoft.Json;

namespace gateway.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private static HttpClient catalogHttpClient = new HttpClient();
        private static HttpClient inventoryHttpClient = new HttpClient();

        private static String catalogApiHost;
        private static String inventoryApiHost;

        public static string GetEnvironmentVariable(string name, string defaultValue)
            => Environment.GetEnvironmentVariable(name) is string v && v.Length > 0 ? v : defaultValue;
        public static void Config()
        {
            try
            {
                // discover the URL of the services we are going to call
                catalogApiHost = "http://" + 
                    GetEnvironmentVariable("COMPONENT_CATALOG_COOLSTORE_HOST", "catalog-coolstore") + ":" +
                    GetEnvironmentVariable("COMPONENT_CATALOG_COOLSTORE_PORT", "8080");                   
                
                inventoryApiHost = "http://" +
                    GetEnvironmentVariable("COMPONENT_INVENTORY_COOLSTORE_HOST", "inventory-coolstore") + ":" +
                    GetEnvironmentVariable("COMPONENT_INVENTORY_COOLSTORE_PORT", "8080");

                // set up the Http conection pools
                inventoryHttpClient.BaseAddress = new Uri(inventoryApiHost);
                catalogHttpClient.BaseAddress = new Uri(catalogApiHost);
            }
            catch(Exception e)
            {
                Console.WriteLine("Checking catalog api URL " + catalogApiHost);
                Console.WriteLine("Checking inventory api URL " + inventoryApiHost);
                Console.WriteLine("Failure to build location URLs for Catalog and Inventory services: " + e.Message);
                throw;
            }
        }

        
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ILogger<ProductsController> logger)
        {
            _logger = logger;

        }

        [HttpGet]
        public IEnumerable<Products> Get()
        {            
            try
            {
                // get the product list
                IEnumerable<Products> productsList = GetCatalog();

                // update each item with their inventory value
                foreach(Products p in productsList)
                {
                    Inventory inv = GetInventory(p.ItemId);
                    if (inv != null)
                        p.Availability = new Availability(inv);
                }    

                return productsList;
            }
            catch(Exception e)
            {
                Console.WriteLine("Using Catalog service: " + catalogApiHost + " and Inventory service: " + inventoryApiHost);
                Console.WriteLine("Failure to get service data: " + e.Message);
                // on failures return error
                throw;
            }
        }

        private IEnumerable<Products> GetCatalog()
        { 
            var data = catalogHttpClient.GetStringAsync("/api/catalog").Result;
            return JsonConvert.DeserializeObject<IEnumerable<Products>>(data);
        }
        private Inventory GetInventory(string itemId)
        {
            var data = inventoryHttpClient.GetStringAsync("/api/inventory/" + itemId).Result;
            return JsonConvert.DeserializeObject<Inventory>(data);
        }

    }
}
