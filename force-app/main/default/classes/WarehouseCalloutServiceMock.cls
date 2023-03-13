@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request){
        
        System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());

		HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
		response.setBody('[{"_id":"55d66226726b711100aaf741","replacement":false,"quantity":6,"name":"Pulser 2300 kW","maintenanceperiod":123,"lifespan":25,"cost":154440,"sku":"145453"}]');
        response.setStatusCode(200);
        return response;
    }
}