global class ProjectCalloutServiceMockFailure implements HttpCalloutMock {
   //Implement http mock callout failure here 
    global HttpResponse respond(HttpRequest request){
         HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatus('Failure');
        res.setStatusCode(400);
        
        return res;
    }
   
}