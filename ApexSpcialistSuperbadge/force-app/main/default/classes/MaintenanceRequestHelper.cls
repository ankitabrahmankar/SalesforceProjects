public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> caseList) {
        //List to store the newly created cases
        List<Case> newCases = new List<Case>();
        
        //Map to store due date for each case 
        Map<String,Integer> dueDateResult = getDueDate(caseList);
        //System.debug(dueDateResult);
        //List to store the list of equipment maintenance items for each case 
        List<Equipment_Maintenance_Item__c> equipmentMItemsList = new List<Equipment_Maintenance_Item__c>();
        
        //Map to store the caseId and associated maintenace items 
        Map<String,list<Equipment_Maintenance_Item__c>> resultItmes= getMaintainanceItems(caseList);
        for(Case c : caseList)
        {
            if(c.Status=='Closed')
            {
                if(c.Type=='Repair'||c.Type=='Routine Maintenance')
                {
                    Case newCaseObj = new Case();
                    newCaseObj.ParentId = c.Id;
                    newCaseObj.Type = 'Routine Maintenance';
                    newCaseObj.Status = 'New';
                    newCaseObj.Subject = 'Routine Maintenance of Vehicle test';
                    newCaseObj.Origin = 'Web';
                    newCaseObj.Vehicle__c=c.Vehicle__c;
                    newCaseObj.ProductId = c.ProductId;
                    newCaseObj.Date_Reported__c=Date.today();
                    System.debug('Inside if condition to create new case');
                    if(dueDateResult.get(c.Id) != null){
                        newCaseObj.Date_Due__c = Date.today() + dueDateResult.get(c.Id);
                    }
                    /*else{
                        newCaseObj.Date_Due__c = Date.today();
                    }*/
                    
                    newCases.add(newCaseObj);
                       
                }
            }
        }
        //Add remaining logic to insert new cases
        System.debug('size of newcases list');
        System.debug(newCases.size());
        if(newCases.size()>0){
            insert newCases;
            System.debug('Inside if condition checking size if condition');
            for(Case c : newCases){
                List<Equipment_Maintenance_Item__c> temp = resultItmes.get(c.ParentId);
                System.debug('Size of temporary list');
                System.debug(temp);
                System.debug(temp.size());
                if(temp != null){
                    for(Equipment_Maintenance_Item__c row : temp){
                        Equipment_Maintenance_Item__c  newItem = new Equipment_Maintenance_Item__c();
                        newItem.Equipment__c = row.Equipment__c;
                        newItem.Maintenance_Request__c = c.Id;
                        newItem.Quantity__c = row.Quantity__c;
                        equipmentMItemsList.add(newItem);
                    }
                }
            }
        }
        System.debug('Equipment maintenance list');
         System.debug(equipmentMItemsList);
        System.debug(equipmentMItemsList.size());
        if(equipmentMItemsList.size()>0){
            insert equipmentMItemsList;
        }
        System.debug(newCases);
	}
    
     public static Map<String, Integer> getDueDate(List<Case> caseList_v1){
         Map<String, Integer> dueDateResult = new Map<String, Integer>();
         Map<Id, Case> caseMap  = new Map<Id, Case>(caseList_v1);
         
         List<AggregateResult> minResult = [SELECT Maintenance_Request__r.ID cID ,
                                           min(Equipment__r.Maintenance_Cycle__c) cycle
                                           FROM Equipment_Maintenance_Item__c 
                                           WHERE Maintenance_Request__r.ID IN :caseMap.keySet() AND Equipment__r.Maintenance_Cycle__c != null
                                           GROUP BY Maintenance_Request__r.ID];
         for(AggregateResult res : minResult){
             Integer addDays = 0;
             if(res.get('cycle') != null){
                 addDays += Integer.valueOf(res.get('cycle'));
                 dueDateResult.put((String)res.get('cID'), addDays);
             }
         }
         return dueDateResult;	   
        }      
    
    public static  Map<String,list<Equipment_Maintenance_Item__c>> getMaintainanceItems(List<Case> caseList_v1){
        
        Map<String, list<Equipment_Maintenance_Item__c>> mapMaintenaceItems = new Map<String, list<Equipment_Maintenance_Item__c>>();
    	Map<Id, Case> caseMap  = new Map<Id, Case>(caseList_v1);
        
        List<Equipment_Maintenance_Item__c> listMaintenaceItems = new List<Equipment_Maintenance_Item__c>([SELECT Id, Maintenance_Request__c,Equipment__c,Quantity__c
                                                                                                          FROM Equipment_Maintenance_Item__c
                                                                                                          WHERE Maintenance_Request__r.ID IN :caseMap.keySet()]);
        for(Equipment_Maintenance_Item__c row : listMaintenaceItems){
            if(mapMaintenaceItems.containsKey(row.Maintenance_Request__c)){
                /*List<Equipment_Maintenance_Item__c> temp = mapMaintenaceItems.get(row.Maintenance_Request__c);
                 temp.add(row);
                mapMaintenaceItems.put(row.Maintenance_Request__c,temp);*/
            }
            else{
                mapMaintenaceItems.put(row.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c>{row});
            }
        }
        return mapMaintenaceItems;
	}
}