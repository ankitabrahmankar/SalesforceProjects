global class ProjectCalloutServiceMock implements HttpCalloutMock {
   //Implement http mock callout here
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatus('OK');
        res.setStatusCode(200);
        
        return res;
        
    }
 
}