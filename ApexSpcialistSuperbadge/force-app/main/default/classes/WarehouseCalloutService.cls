public with sharing class WarehouseCalloutService implements Queueable {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public static HttpResponse getResponse(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return response;    
    }
    
    @ future(callout = true)
    public static void runWarehouseEquipmentSync(){
        HttpResponse response = getResponse();
        if(response.getStatusCode() == 200){
            //Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            List<Product2> results = getProductsList(response);
            if(results.size()>0){
                System.debug('Inside the if loop to check results.size');
                upsert results;
                System.debug(results);
            }
        }
        
    }
    
    public static List<Product2> getProductsList(HttpResponse response){
        List<Object> externalObjects = (List<Object>)JSON.deserializeUntyped(response.getBody());
        
        List<Product2> newProducts = new List<Product2>();
        for(Object prod : externalObjects){
            Map<String, Object> productMap = (Map<String,Object>) prod;
            Product2 newProd = new Product2();
            
            newProd.Replacement_Part__c = (Boolean)productMap.get('replacement');
            newProd.Maintenance_Cycle__c = (Integer)productMap.get('maintenanceperiod');
            newProd.Current_Inventory__c = (Integer)productMap.get('quantity');
            newProd.Cost__c = (Integer)productMap.get('cost');
            newProd.Lifespan_Months__c = (Integer)productMap.get('lifespan');
            newProd.ProductCode=(String)productMap.get('_id');
            newProd.Name = (String)productMap.get('name');
            newProd.Warehouse_SKU__c = (String)productMap.get('sku');
            
            newProducts.add(newProd);
        }
        return newProducts;
    }
    
    public static void execute(QueueableContext context){
        runWarehouseEquipmentSync();
    }
}