global class WarehouseSyncSchedule implements Schedulable {

    global void execute (SchedulableContext sc) {
        System.enqueueJob(New WarehouseCalloutService());
    }
    //execute this in dev console to run the class
    //WarehouseSyncSchedule s = new WarehouseSyncSchedule();
    //s.execute(null);
}