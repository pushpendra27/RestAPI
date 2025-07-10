@RestResource(urlMapping='/test/*')
//Connected App_(B)_
//String baseURL = URL.getOrgDomainURL().toExternalForm(); 
//System.debug('Salesforce Base URL: ' + baseURL);
//Authorization Session Berear Token Id: system.debug(system.UserInfo.getSessionId().substring(15));
global class MySecondOrg {    
    
     @HttpGet     
    global static list<Case> getCase() {
        /*RestRequest request = RestContext.request;
        // grab the caseId from the end of the URL
        String caseId = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);*/
        list<Case> result =  [SELECT CaseNumber,Subject,Status,Origin,Priority FROM Case limit 10];
        return result;
    }
    

 @HttpPost
global static ID createCase(String subject, String status,
    String origin, String priority) {

    // Check for existing Case with same Subject
    List<Case> existingCases = [SELECT Id FROM Case WHERE Subject = :subject LIMIT 1];

    if (!existingCases.isEmpty()) {
        // Throw a meaningful error
        throw new AuraHandledException('Duplicate Case found with the same Subject: "' + subject + '"');
    }

    // Proceed to create new Case
    Case thisCase = new Case(
        Subject = subject,
        Status = status,
        Origin = origin,
        Priority = priority
    );
    insert thisCase;
    return thisCase.Id;
}
    
    
    
    @HttpDelete
    global static void deleteCase() {
        RestRequest request = RestContext.request;
        String caseId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Case thisCase = [SELECT Id FROM Case WHERE Id = :caseId];
        delete thisCase;
    }     
    @HttpPut
    global static ID upsertCase(String subject, String status,
        String origin, String priority, String id) {
        Case thisCase = new Case(
                Id=id,
                Subject=subject,
                Status=status,
                Origin=origin,
                Priority=priority);
        // Match case by Id, if present.
        // Otherwise, create new case.
        upsert thisCase;
        // Return the case ID.
        return thisCase.Id;
    }
    @HttpPatch
    global static ID updateCaseFields() {
        RestRequest request = RestContext.request;
        String caseId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Case thisCase = [SELECT Id FROM Case WHERE Id = :caseId];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
            // Set the field and value on the Case sObject
            thisCase.put(fieldName, params.get(fieldName));
        }
        update thisCase;
        return thisCase.Id;
    }    

}