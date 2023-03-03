global class WarehouseSyncSchedule implements Schedulable {
    global void execute (SchedulableContext sc) {
        System.enqueueJob(New WarehouseCalloutService());
        String cron = '00 00 01 * * ?';  //second minute hour dayM(all) month(all) dayW(not specified since day of month is)
        System.schedule('WarehouseSyncScheduleJob', cron, new WarehouseSyncSchedule());
    }
    //execute this in dev console to run the class
    //WarehouseSyncSchedule s = new WarehouseSyncSchedule();
    //s.execute(null);
}