@isTest 
public with sharing class WarehouseSyncScheduleTest {
    
    @Istest 
    static void testSyncSchedule() {
        Test.setMock(HTTPCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        String cron = '00 00 01 * * ?';  //second minute hour dayM(all) month(all) dayW(not specified since day of month is)
        System.schedule('WarehouseSyncScheduleJobTest', cron, new WarehouseSyncSchedule());
        Test.stopTest();
                
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger limit 1]; 
        System.assertEquals(0, ct.TimesTriggered, 'No job found'); 

    }
}