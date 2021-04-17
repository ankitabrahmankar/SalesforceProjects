@isTest
private class BillingCalloutServiceTest {
  //Implement mock callout tests here
  @testSetup
    public static void dataSetup(){
        ServiceCredentials__c creds = new ServiceCredentials__c();
        creds.Name = 'BillingServiceCredential';
        creds.Username__c = 'testUserName';
        creds.Password__c = '123';
        insert creds;
        
        List<Account> accList = new List<Account>();
        for(Integer i=0; i< 50; i++){
            Account newAcc = new Account();
            newAcc.Name = 'Test'+i;
            accList.add(newAcc);
            
        }
        insert accList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Account acc : accList){
            Opportunity opp = new Opportunity();
            opp.CloseDate = Date.today().addDays(3);
            opp.StageName = 'prospecting';
            opp.Name = 'Test'+ acc.Name;
            opp.AccountId =  acc.Id;
            opp.Amount = 100;
            oppList.add(opp);
        }
        insert oppList;
        
        List<Project__c> projectList =  new List<Project__c>();
        for(Opportunity opp : oppList ){
            Project__c pro = new Project__c();
            pro.Name = 'test'+ opp.Name;
            pro.Status__c = 'Running';
            pro.Opportunity__c = opp.Id;
            pro.ProjectRef__c = 'test' + opp.Name;
            pro.Billable_Amount__c = 100;
            projectList.add(pro);
        }
        insert projectList;
    }
    
    @isTest
    public static void testBillingCalloutServiceSuccess(){
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        Test.startTest();
        List<Project__c> prodList =  new List<Project__c>([Select Id, Status__c from Project__c]);
        for(Project__c pro : prodList){
            pro.Status__c = 'Billable';
        }
        update prodList;
        Test.stopTest();    
    }
    
    
     @isTest
    public static void testBillingCalloutServiceFailure(){
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        Test.startTest();
        List<Project__c> prodList =  new List<Project__c>([Select Id, Status__c from Project__c]);
        for(Project__c pro : prodList){
            pro.Status__c = 'Running';
        }
        update prodList;
        Test.stopTest();  
        System.assertEquals('Running', prodList[0].status__c);
    }
    
}