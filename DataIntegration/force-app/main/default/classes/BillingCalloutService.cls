public class BillingCalloutService {
    //Implement business and callout logic methods here
    //
    public static void callBillingService(List<Project__c> newList, Map<Id, Project__c> newMap, List<Project__c> oldList, Map<Id, Project__c> oldMap){
        if(!newList.isEmpty()){
            Project__c project = newList[0];
            if(project.Status__c == 'Billable'){
                ServiceCredentials__c bscredentials = ServiceCredentials__c.getInstance('BillingServiceCredential');
                projectBilling(project.projectRef__c, project.Billable_Amount__c, bscredentials.Username__c, bscredentials.Password__c);
                
            }
        }
    }
        
        
	@Future(callout = true)
    private static void projectBilling(String projectRef, Decimal billAmount, String username, String password){
        BillingServiceProxy.project project = new  BillingServiceProxy.project();
        List<Project__c> projectList = new List<Project__c>();
        project.billAmount = billAmount;
        project.username =  username;
        project.password = password;
        project.projectid = projectRef;
        
        BillingServiceProxy.InvoicesPortSoap11 invoice  = new BillingServiceProxy.InvoicesPortSoap11();
        String res = invoice.billProject(project);
        
        if(res.equalsIgnoreCase('OK')){
            projectList = [SELECT Id, Status__c from Project__c where ProjectRef__c =: projectRef];
            if(!projectList.isEmpty()){
                projectList[0].Status__c = 'Billed';
            }
        }
        update projectList;
    }
    
}