public with sharing class SalesforceConnect {
    
    public static void getCases(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:PushpendraOrgConnectNC/services/apexrest/test/');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        // Deserialize the JSON string into collections of primitive data types.
        List<Object> results = (List<Object>) JSON.deserializeUntyped(res.getBody());
        for(Object obj : results){
            Map<String, Object> caseProps = (Map<String, Object>)obj;
            System.debug(caseProps.get('CaseNumber')+'-'+caseProps.get('Subject'));
        }
        System.debug(res.getBody());
    }
    
    
    public static void createCase()
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:PushpendraOrgConnectNC/services/apexrest/test/');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json;charset=UTF-8');        
        req.setBody('{"subject": "PostmanTestign3","status": "Closed","origin": "Phone","priority": "High"}');                    
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
}