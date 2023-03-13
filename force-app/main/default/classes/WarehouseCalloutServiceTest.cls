@isTest

private class WarehouseCalloutServiceTest {   
    @isTest  
    static void testWareHouseCallout(){
        Test.startTest();
        // implement mock callout test here
        Test.setMock(HTTPCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService q = new WarehouseCalloutService();
        system.enqueueJob(q);
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM Product2]);
    }     
}