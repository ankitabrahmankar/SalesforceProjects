@isTest
private class ProjectRESTServiceTest {
  //Implement Apex REST service tests here
	@testSetup
    public static void createData(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test1';
        opp.DeliveryInstallationStatus__c = 'In Progress';
        opp.StageName = 'Submitted Project';
        opp.CloseDate = Date.today();
        insert opp;
        
        Project__c project = new Project__c();
        project.Name = 'testProj';
        project.Opportunity__c = opp.Id;
        project.Start_Date__c = Date.today();
        project.End_Date__c = Date.today().addDays(3);
        project.Status__c = 'Running';
        project.ProjectRef__c = 'prjref';
        insert project;
            
    }
    
    @isTest
    public static void ProjectRESTServiceTestSuccess(){
        Project__c project = [SELECT ID from Project__c];
        Test.startTest();
        Opportunity opt = [SELECT Id from Opportunity];
         String returnMessage = ProjectRESTService.postProjectData('ProjectRef','ProjectName', opt.ID, Date.today(), Date.today().addDays(3),100,'Running');
        Test.stopTest();
        
        System.assertEquals('OK', returnMessage);
       
    }
    
    @isTest
    public static void ProjectRESTServiceTestFailure(){
        Project__c project = [SELECT ID from Project__c];
        Test.startTest();
        //Opportunity opt = [SELECT Id from Opportunity];
         String returnMessage = ProjectRESTService.postProjectData('ProjectRef','ProjectName', '', Date.today(), Date.today().addDays(3),100,'Running');
        Test.stopTest();
        
        //System.assertEquals('OK', returnMessage);
       
    }
}