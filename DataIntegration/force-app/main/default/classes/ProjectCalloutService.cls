public class ProjectCalloutService {
    //Complete the implementation for business and callout logic
    @InvocableMethod
	public static void postOpportunityToPMS(List<Id> opptyId){
        Opportunity oppty = [Select Id, Name, Account.Name, CloseDate, Amount From Opportunity where Id =: opptyId[0]];
        String sToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
        
        String jsonInput = '{ \n' +
                              '"opportunityId": "'+oppty.Id+'",\n'+
            				  '"opportunityName": "'+oppty.Name+'",\n'+
            				  '"accountName": "'+oppty.Account.Name+'",\n'+
            				  '"closeDate": "'+String.valueOf(oppty.CloseDate).mid(0,10)+'",\n'+
            				  '"amount": "'+oppty.amount+'",\n}';
        System.enqueueJob(new QueueablePMSCall(sToken,jsonInput,oppty.Id ));
                             
    }
    
     class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts {
         private String sToken;
         private String jsonInput;
         private Id opptyId;
         
         public QueueablePMSCall(String sToken, String jsonInput,  Id opptyId ){
             this.sToken = sToken;
             this.jsonInput = jsonInput;
             this.opptyId = opptyId;
         }
         public void execute(QueueableContext qc){
             postToPMS(sToken,jsonInput,opptyId);
         }  
        }
  		@Future(callout = true)
         private static void postToPMS(String sToken,String jsonInput, Id opptyId){
             HttpRequest request =  new HttpRequest();
             request.setEndpoint('callout:ProjectService');
             request.setMethod('POST');
             request.setHeader('token', sToken);
             request.setHeader('Content-Type', 'application/json;charset=UTF-8');
             request.setBody(jsonInput);
             
             HTTP http = new HTTP();
             HTTPResponse response =  http.send(request);
             
             Opportunity oppty = new Opportunity(Id = opptyId);
             if(response.getStatusCode() == 201){
                 oppty.StageName = 'Submitted Project';
             }
             else{
                  oppty.StageName = 'Resubmit Project';
             }
             update oppty;      
    }
}