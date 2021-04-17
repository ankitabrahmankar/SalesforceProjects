@isTest
private class ProjectCalloutServiceTest {
  //Implement mock callout tests here
  
  @TestSetup
    public static void testingDate(){
        //service token setup
        ServiceTokens__c sToken =  new ServiceTokens__c();
        sToken.Name= 'ProjectServiceToken';
        sToken.Token__c = 'carcatdog';
        insert sToken;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'test1';
        opp1.Type = 'New Project';
        opp1.Amount = 100;
        opp1.CloseDate = Date.today();
        opp1.StageName = 'Submitted Project';
        insert opp1;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test2';
        opp2.Type = 'New Project';
        opp2.Amount = 100;
        opp2.CloseDate = Date.today();
        opp2.StageName = 'Resubmit Project';
        insert opp2;

    }
    
    @isTest
    public static void testSuccess(){
        Opportunity opp = [SELECT Id, Name from Opportunity where Name = 'test1'];
        List<Id> oppList = new List<Id>();
        oppList.add(opp.Id);
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        Test.startTest();
        	ProjectCalloutService.postOpportunityToPMS(oppList);
        Test.stopTest();
        
        List<Opportunity> updateOpps = [SELECT Id, Name, StageName from Opportunity where Name = 'test1'];
        System.assertEquals('Submitted Project', updateOpps[0].StageName);
    }
    
    @isTest
    public static void testFailure(){
        Opportunity opp = [SELECT Id, Name from Opportunity where Name = 'test2'];
        List<Id> oppList = new List<Id>();
        oppList.add(opp.Id);
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        Test.startTest();
        	ProjectCalloutService.postOpportunityToPMS(oppList);
        Test.stopTest();
        
        List<Opportunity> updateOpps = [SELECT Id, Name,StageName from Opportunity where Name = 'test2'];
        System.assertEquals('Resubmit Project', updateOpps[0].StageName);
    }
}