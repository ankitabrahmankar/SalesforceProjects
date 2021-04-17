@isTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here
    private static final String STATUS_NEW = 'New';
    private static final String WORKING = 'Working';
    private static final String CLOSED = 'Closed';
    private static final String REPAIR = 'Repair';
    private static final String REQUEST_ORIGIN = 'Web';
    private static final String REQUEST_TYPE = 'Routine Maintenance';
    private static final String REQUEST_SUBJECT = 'Testing Subject';
    
    private static Vehicle__c createVehicle(){
        Vehicle__c vehicle = new Vehicle__c( Name = 'SuperTruck');
        return vehicle;
    }
    private static Product2 createEquipment(){
        Product2 equipment = new Product2(Name = 'SuperEquipment',
                                         Lifespan_Months__c = 10,
                                         Maintenance_Cycle__c =10,
                                         Replacement_Part__c = true);
        return equipment;
    }
    
    private static case createMaintenanceRequest(Id vehicleId, Id equipmentId){
        case c = new Case(Type=REPAIR,
                          status=STATUS_NEW,
                          origin=REQUEST_ORIGIN,
                          subject=REQUEST_SUBJECT,
                          Equipment__c =equipmentId,
                          vehicle__c = vehicleId );
        return c;
    }
    private static Equipment_Maintenance_Item__c createEMI(Id equipmentId, Id requestId){
        Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c(Equipment__c = equipmentId,
                                                                             Maintenance_Request__c = requestId);
        return emi;
    }
    @isTest
    private static void testMaintenanceRequestPositive(){
    	Vehicle__c vehicle =  createVehicle();
        insert vehicle;
        Id vehicleId =  vehicle.id;
      
        Product2 equipment = createEquipment();
        insert equipment;
        Id equipmentId = equipment.id;
        
        Case testCase = createMaintenanceRequest(vehicleId,equipmentId);
        insert testCase;
        
        Equipment_Maintenance_Item__c emi = createEMI(equipmentId, testCase.Id);
        insert emi;
        
        Test.startTest();
        	testCase.Status = CLOSED;
        	update testCase;
        Test.stopTest();
        
        Case newReq = [SELECT Id,Subject, Type, Equipment__c, Date_Reported__c, Vehicle__c, Date_Due__c from Case where Status =: STATUS_NEW];
        //Equipment_Maintenance_Item__c workPart = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :newReq.id ];
        
        List<Equipment_Maintenance_Item__c> workPart = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :newReq.id ];
        
        System.assert(workPart != null);
        System.assert(newReq.Subject != null);
        System.assertEquals(newReq.Type, REQUEST_TYPE);
        //System.assertEquals(newReq.Equipment__c, equipmentId);
        System.assertEquals(workPart.size(), 1);
        System.assertEquals(newReq.Vehicle__c,vehicleId );
        System.assertEquals(newReq.Date_Reported__c,System.today());
        
        
    }
    @isTest
    private static void testMaintenanceRequestNegative(){
        Vehicle__c vehicle =  createVehicle();
        insert vehicle;
        Id vehicleId =  vehicle.id;
      
        Product2 equipment = createEquipment();
        insert equipment;
        Id equipmentId = equipment.id;
        
        Case emptyReq = createMaintenanceRequest(vehicleId,equipmentId);
        insert emptyReq;
        
        Equipment_Maintenance_Item__c emi = createEMI(equipmentId, emptyReq.Id);
        insert emi;
        
        Test.startTest();
        	emptyReq.Status = WORKING;
        	update emptyReq;
        Test.stopTest();
        
        List<Case> allRequest = [SELECT Id From Case];
        Equipment_Maintenance_Item__c workPart = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c =:emptyReq.Id ];
        System.assert(workPart!= null);
        System.assert(allRequest.size() == 1);
        
        
    }
    @isTest
    private static void testMaintenanceRequestBulk(){
        
        List<Vehicle__c> vehicleList = new List<Vehicle__c>();
        List<Product2> equipmentList = new List<Product2>();
        List<Equipment_Maintenance_Item__c> workPartList =  new List<Equipment_Maintenance_Item__c>();
        List<Case> requestList = new List<Case>();
        List<Id> oldRequestIds = new List<Id>();
        
        for(Integer i=0; i<300; i++){
            vehicleList.add(createVehicle());
            equipmentList.add(createEquipment());
        }
        insert vehicleList;
        insert equipmentList;
        
        for(Integer i=0; i<300; i++){
            requestList.add(createMaintenanceRequest(vehicleList.get(i).Id, equipmentList.get(i).Id));
            
        }
        insert requestList;
        
        for(Integer i=0; i<300; i++){
            workPartList.add(createEMI(equipmentList.get(i).Id, requestList.get(i).Id));
        }
        
        insert workPartList;
        
        Test.startTest();
            for(Case req : requestList){
                req.Status = CLOSED;
                oldRequestIds.add(req.Id);        
            }
        update requestList;
        Test.stopTest();
        
        List<Case> allRequest = [SELECT Id From Case where Status =:STATUS_NEW];
        
        List<Equipment_Maintenance_Item__c> workParts = [SELECT Id from Equipment_Maintenance_Item__c where Maintenance_Request__c IN: oldRequestIds];
        System.assert(allRequest.size() == 300);
        
    }
} 

/*@isTest
public  class MaintenanceRequestTest {
     static  List<case> caseList1 = new List<case>();
   static List<product2> prodList = new List<product2>();
       static List<Equipment_Maintenance_Item__c> wpList = new List<Equipment_Maintenance_Item__c>();
@testSetup
    static void getData(){
      caseList1= CreateData( 300,3,3,'Repair');
    }
    
    public static List<case>   CreateData( Integer numOfcase, Integer numofProd, Integer numofVehicle,
                                String type){
 List<case> caseList = new List<case>();
        //Create Vehicle       
        Vehicle__c vc = new Vehicle__c();
        vc.name='Test Vehicle';
        upsert vc;
        //Create Equiment
        for(Integer i=0;i<numofProd;i++){
            Product2 prod = new Product2();
            prod.Name='Test Product'+i;
            if(i!=0)
             prod.Maintenance_Cycle__c=i;
            prod.Replacement_Part__c=true;
            prodList.add(prod);
        }
        upsert  prodlist;
        //Create Case
        for(Integer i=0;i< numOfcase;i++){
            Case newCase = new Case();
           newCase.Status='New';
                 newCase.Origin='web';
            if( math.mod(i, 2) ==0)
             newCase.Type='Routine Maintenance';
            else
               newCase.Type='Repair'; 
            newCase.Subject='Routine Maintenance of Vehicle' +i;
            newCase.Vehicle__c=vc.Id;
            if(i<numofProd)
             newCase.Equipment__c=prodList.get(i).ID;
            else 
                newCase.Equipment__c=prodList.get(0).ID;
           caseList.add(newCase);
        }
    upsert caseList;       
     for(Integer i=0;i<numofProd;i++){                           
         Equipment_Maintenance_Item__c wp = new Equipment_Maintenance_Item__c();
          wp.Equipment__c   =prodlist.get(i).Id   ; 
          wp.Maintenance_Request__c=caseList.get(i).id;
          wplist.add(wp) ;
          }
    upsert wplist;
        return caseList;              
    }
   
   
    public static testmethod void testMaintenanceHelper(){        
        Test.startTest();
        getData();
            for(Case cas: caseList1)   
                 cas.Status ='Closed';      
        update caseList1;  
        Test.stopTest();
    }
}*/