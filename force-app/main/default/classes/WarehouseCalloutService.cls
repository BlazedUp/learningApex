public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public static void syncEquipment() {
		HttpResponse response = getResponse();
        if(response.getStatusCode() == 200)
        {
            List<Product2> updatedEquipment = processEquipment(response);
            if(updatedEquipment.size() >0) {
                upsert updatedEquipment Warehouse_SKU__c;
            }

        }
    }
        public static List<Product2> processEquipment(HttpResponse response)
        {
            List<Object> dataFromWarehouse = (List<Object>) (JSON.deserializeUntyped(response.getBody()));
            List<Product2> newEquipment = new List<Product2>();
                for(Object p : dataFromWarehouse)
                {
                    Map<String, Object> productMap = (Map<String, Object>) p;
                    Product2 pr = new Product2();
                    pr.Replacement_Part__c = Boolean.valueOf(productMap.get('replacement'));
                    pr.Cost__c = Integer.valueOf(productMap.get('cost'));
                    pr.Current_Inventory__c = Integer.valueOf(productMap.get('quantity'));
                    pr.Lifespan_Months__c = Integer.valueOf(productMap.get('lifespan')) ;
                    pr.Maintenance_Cycle__c = Integer.valueOf(productMap.get('maintenanceperiod'));
                    pr.Warehouse_SKU__c = String.valueOf(productMap.get('sku'));
                    pr.ProductCode = String.valueOf(productMap.get('_id'));
                    pr.Name = String.valueOf(productMap.get('name'));
                    newEquipment.add(pr);
                }
            return newEquipment;
            
        }

    public static HttpResponse getResponse() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return response;
    }
    public static void execute(QueueableContext context){
        syncEquipment();
    }
}