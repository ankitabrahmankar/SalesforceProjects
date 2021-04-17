global with sharing class WarehouseSyncSchedule implements Schedulable {
    // implement scheduled code here
    global void execute (SchedulableContext sc){
        System.enqueueJob(new WarehouseCalloutService());
        /*WarehouseCalloutService.runWarehouseEquipmentSync();
        String sch =  '00 00 01 ?';
        System.schedule('WarehouseSyncScheduleTest', sch, new WarehouseSyncSchedule());
         //System.abortJob(sch); */
    }
}