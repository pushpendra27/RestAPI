public class VerifyUserAPICallout {
    @InvocableMethod(label='Call Update User Status API' description='Makes Update User Status API request')
    public static List<ApiResponse> makeCallout(List<FlowInput> inputs) {
        List<ApiResponse> listApiResponse = new List<ApiResponse>();

        for (FlowInput input : inputs) {
            String userId = input.userId;
            String userStatus = input.picklistValue; // Assuming picklistValue holds status like "Approved"
			String recordId = input.recordId;
            
            System.debug('Processing userId: ' + userId + ' with status: ' + userStatus);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://cyz/appple');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-Api-Key', 'aabbbbbbccccccddddddd'); // Optional if required

            // Construct JSON payload
            Map<String, String> payload = new Map<String, String>{
                'userId' => userId,
                'userStatus' => userStatus
            };
            request.setBody(JSON.serialize(payload));

            try {
                HttpResponse response = http.send(request);
                ApiResponse output = new ApiResponse();

                if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    System.debug('Response Body: ' + response.getBody());
                    ApiResponse parsed = (ApiResponse) JSON.deserialize(response.getBody(), ApiResponse.class);
                    output.success = parsed.success;
                    output.message = parsed.message;
                } else {
                    output.success = 'false';
                    output.message = 'Error: ' + response.getStatusCode() + ' - ' + response.getBody();
                }

                listApiResponse.add(output);
            } catch (Exception e) {
                ApiResponse errorResponse = new ApiResponse();
                errorResponse.success = 'false';
                errorResponse.message = 'Exception: ' + e.getMessage();
                listApiResponse.add(errorResponse);
            }
        }

        return listApiResponse;
    }

    public class FlowInput {
        @InvocableVariable(required=true) public Id recordId;
        @InvocableVariable(required=true) public String picklistValue; // Used as userStatus
        @InvocableVariable(required=true) public String userId;
    }

    public class ApiResponse {
        @InvocableVariable public String success;
        @InvocableVariable public String message;
    }
}