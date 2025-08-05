@RestResource(urlMapping='/BusinessProfile/*')
global with sharing class QtBusinessProfile {

 	    global class BasicProfileRequest {
        public String title;
        public String businessTypeId;
    }

    global class ProfileUpdateRequest {
        public Integer stepId;
        public String id;
        public String businessId;
        public Profile profile;
        public List<ServiceDTO> services;
        public List<BusinessHours> businessHours;
    }    
    
        global class Profile {
        public String displayName;
        public String aboutMeShort;
        public String aboutMeLong;
        public String totalCustomersServed;
        public String totalYearsOfExperience;
        public String testimonial;
        public String educationalQualification;
        public String businessLogo;
        public String image;
        public String yourBestWork;
        public String carrierHighlight;
        public String awards;
        public String billingAddress;
        public String licenceNo;
        public List<Area> areas;
        public List<Keyword> keywords;
        public List<Language> languages;
        public List<SocialMediaLink> socialMediaLinks;
    }

    global class Area {
        public String id;
        public String title;
    }

    global class Language {
        public String id;
        public String title;
    }

    global class Keyword {
        public String id;
        public String name;
    }

    global class SocialMediaLink {
        public String socialMediaType;
        public String link;
        public String count;
    }

    global class ServiceDTO {
        public String serviceTypeId;
        public String serviceName;
        public String uniqueServiceId;
        public Integer keyId;
        public String duration;
        public String durationDays;
        public String type;
        public String price;
        public String isDiscountApplicable;
        public String discount;
        public String discountType;
        public String isServiceOnline;
        public String connection;
        public String tag;
        public String description;
        public String whatsAppAccessMethod;
        public String id;
        public String startDate;
        public String endDate;
        public String responseText;
        public String responseTime;
        public String locationName;
        public String latlngNumber;
        public String title;
        public Boolean isDefaultService;
        public Boolean isServiceFree;
        public String slots;
        public List<ConnectionShow> connectionShow;
        public ServiceLocation serviceLocation;
    }

    global class ConnectionShow {
        public String value;
        public String label;
        public String icon;
    }

    global class ServiceLocation {
        public Decimal latitude;
        public Decimal longitude;
        public String locationName;
    }

	//Business Hours -PUT
	global class BusinessHours {
        public String day;
        public Boolean active;
        public Boolean isOpened; 
        public String fromTime;
        public String to;  
        public List<Object> breakHours;
    }
 
    public static DateTime parseDateTime(String input) {
        if (String.isBlank(input)) return null;

        // Remove timezone offset like +05:30 or Z
        String cleaned = input.contains('+') ? input.substringBefore('+') :
                         input.contains('Z') ? input.substringBefore('Z') :
                         input;

        try {
            return DateTime.valueOf(cleaned);
        } catch (Exception e) {
            System.debug('Date parsing failed for: ' + input + ' | Error: ' + e.getMessage());
            return null;
        }
    }

    
    
    // POST: Create basic profile
    @HttpPost
    global static String createBasicProfile() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            BasicProfileRequest input = (BasicProfileRequest) JSON.deserialize(req.requestBody.toString(), BasicProfileRequest.class);

            if (String.isBlank(input.title) || String.isBlank(input.businessTypeId)) {
                res.statusCode = 400;
                return 'Missing required fields: title or businessTypeId';
            }

            Business__c businessProfile = new Business__c();
            businessProfile.Name = input.title;
            businessProfile.businessTypeId__c = input.businessTypeId;

            insert businessProfile;
            return businessProfile.Id;

        } catch (Exception e) {
            res.statusCode = 500;
            return 'Error: ' + e.getMessage();
        }
    }

    /******PUT Handling Below******/
    
    // PUT: Update profile based on stepId
    @HttpPut
	global static String updateDetailedProfile() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    String body = req.requestBody.toString();
    if (String.isBlank(body)) {
        res.statusCode = 400;
        return 'Request body is empty';
    }

    ProfileUpdateRequest input;
    try {
        input = (ProfileUpdateRequest) JSON.deserialize(body.replace('from','fromtime'), ProfileUpdateRequest.class);
    } catch (Exception e) {
        res.statusCode = 400;
        return 'Invalid JSON format';
    }

    // Step-specific validation
    if (input.stepId == null) {
        res.statusCode = 400;
        return 'Missing stepId';
    }        
     
    if (input.stepId == 2 && String.isBlank(input.id)) {
        res.statusCode = 400;
        return 'Missing id for step 2';
    }
    if (input.stepId == 3 && String.isBlank(input.businessId)) {
        res.statusCode = 400;
        return 'Missing businessId for step 3';
    }
    if (input.stepId == 4 && String.isBlank(input.businessId)) {
        res.statusCode = 400;
        return 'Missing businessId for step 4';
    }
        
        

    try {
        if (input.stepId == 2) {
            return updateDetails(input);
        } else if (input.stepId == 3) {
            return BusinessService(input);
        } else if (input.stepId == 4) {
            return updateBusinessHours(input);
        }else {
            res.statusCode = 400;
            return 'Invalid stepId';
        }
    } catch (Exception ex) {
        res.statusCode = 500;
        return 'Error processing request: ' + ex.getMessage();
    }
}

    // StepId 2: Update Profie Details PUT-1st
    private static String updateDetails(ProfileUpdateRequest input) {
        RestResponse res = RestContext.response;

        try {
            Business__c profile = new Business__c(Id = input.id);
            profile.Display_Name__c = input.profile.displayName;
            profile.About_Me__c = input.profile.aboutMeShort;
            profile.About_Me_Long__c = input.profile.aboutMeLong;
            //profile.Total_Customers_Served__c = input.profile.totalCustomersServed;
            //profile.Total_Years_of_Experience__c = input.profile.totalYearsOfExperience;
            profile.Total_Customers_Served__c = Decimal.valueOf(input.profile.totalCustomersServed);
			profile.Total_Years_of_Experience__c = Decimal.valueOf(input.profile.totalYearsOfExperience);
            profile.Career_Highlight__c = input.profile.carrierHighlight;
            profile.Billing_Address__c = input.profile.billingAddress;
            profile.Licence_Number__c = input.profile.licenceNo;

            // You can parse and store JSON strings like testimonial, awards, etc. into rich text or long text fields
            profile.Testimonials_JSON__c = input.profile.testimonial;
            profile.Awards_JSON__c = input.profile.awards;
            profile.Educational_Qualifications_JSON__c = input.profile.educationalQualification;
            profile.Social_Media_Links_JSON__c = JSON.serialize(input.profile.socialMediaLinks);
            profile.Business_Logo_JSON__c = input.profile.businessLogo;
            profile.Image_Gallery_JSON__c= input.profile.image;
            profile.Featured_Work_JSON__c= input.profile.yourBestWork;
            profile.Languages_JSON__c =JSON.serialize(input.profile.languages);
            profile.Areas_JSON__c = JSON.serialize(input.profile.areas);
            profile.Keywords_JSON__c = JSON.serialize(input.profile.keywords);
            
            update profile;

            res.statusCode = 200;
            return 'Business profile updated successfully for Id: ' + profile.Id;

        } catch (QueryException qe) {
            res.statusCode = 404;
            return 'Business profile not found for Id: ' + qe.getMessage();
        } catch (Exception e) {
            res.statusCode = 500;
            return 'Error: ' + e.getMessage();
        }
    } 

           
    
    // StepId 3: Business Services Update PUT-2nd
    private static String BusinessService(ProfileUpdateRequest input) {
    RestResponse res = RestContext.response;

    try {
        //List<Business__c> business = [SELECT Id, BusinessTypeId__c FROM Business__c WHERE BusinessTypeId__c =:input.businessId LIMIT 1];
        
        Business__c business = [SELECT Id, BusinessTypeId__c FROM Business__c WHERE BusinessTypeId__c = :input.businessId LIMIT 1];       

        List<Business_Service__c> serviceRecords = new List<Business_Service__c>();

        for (ServiceDTO dto : input.services) {
            Business_Service__c service = new Business_Service__c();
			service.Business__c = business.Id;
            service.Service_Type_Id__c = dto.serviceTypeId;
            service.Name= dto.serviceName;
            service.Unique_Service_Id__c = dto.uniqueServiceId;
            service.Key_Id__c = dto.keyId;
            service.Duration_Minutes__c = Decimal.valueOf(dto.duration);
            service.Duration_Days__c = Decimal.valueOf(dto.durationDays);
            service.Type__c = dto.type;
            service.Price__c = Decimal.valueOf(dto.price);
            service.Is_Discount_Applicable__c = dto.isDiscountApplicable == 'yes';
            service.Discount__c = dto.discountType;
            service.Is_Service_Online__c = dto.isServiceOnline;
            service.Connection__c = dto.connection;
            service.Tag__c = dto.tag;
            service.Description__c = dto.description;
            service.WhatsApp_Access_Method__c = dto.whatsAppAccessMethod;
            service.External_Service_Id__c = dto.id;
            service.Start_Date__c = QtBusinessProfile.parseDateTime(dto.startDate);
            service.End_Date__c = QtBusinessProfile.parseDateTime(dto.endDate);
            service.Response_Text__c = dto.responseText;
            service.Response_Time_Minutes__c = String.isNotBlank(dto.responseTime) ? Decimal.valueOf(dto.responseTime) : null;
            service.Location_Name__c = dto.locationName;
            service.LatLng_Number__c = dto.latlngNumber;
            service.Title__c = dto.title;
            service.Is_Default_Service__c = dto.isDefaultService;
            service.Is_Service_Free__c = dto.isServiceFree;
            service.Slots__c = Decimal.valueOf(dto.slots);
            service.Service_Location_JSON__c = JSON.serialize(dto.serviceLocation);
            service.Connection_Show_JSON__c = JSON.serialize(dto.connectionShow);

            serviceRecords.add(service);
        }

        upsert serviceRecords id;

        res.statusCode = 200;
        return serviceRecords.size() + ' services upserted successfully.';

    } catch (QueryException qe) {
        res.statusCode = 404;
        return 'Business record not found: ' + qe.getMessage();
    } catch (Exception e) {
        res.statusCode = 500;
        return 'Error: ' + e.getMessage();
    }
}

    // Step 4: Business Hours Update PUT-3nd
  		
        public static String updateBusinessHours(ProfileUpdateRequest input) {
        RestResponse res = RestContext.response;

        try {    
        // Fetch Business record
            Business__c business = [SELECT Id, BusinessTypeId__c FROM Business__c WHERE BusinessTypeId__c = :input.businessId LIMIT 1]; 
            List<Business_Hours__c> hoursRecords = new List<Business_Hours__c>();
            
            for (BusinessHours dto : input.businessHours) {
                Business_Hours__c hours = new Business_Hours__c();
                hours.Business__c = business.Id;
                hours.Name = dto.day;
                hours.Day__c = dto.day;
                hours.Active__c = dto.active;
                hours.Is_Opened__c = dto.isOpened;                
				hours.Time_To__c = parseTime(dto.to);
                hours.Time_From__c = parseTime(dto.fromTime);
                if (dto.breakHours != null && !dto.breakHours.isEmpty()) {
                    hours.Break_Hours__c = JSON.serialize(dto.breakHours);
                }

                hoursRecords.add(hours);
            }
			
            upsert hoursRecords;

            res.statusCode = 200;
            return hoursRecords.size() + ' business hours upserted successfully.';
        } catch (QueryException qe) {
            res.statusCode = 404;
            return 'Business record not found: ' + qe.getMessage();
        } catch (Exception e) {
            res.statusCode = 500;
            return 'Error: ' + e.getMessage();
        }
    }

    private static Time parseTime(String timeStr) {
        List<String> parts = timeStr.split(':');
        Integer hour = Integer.valueOf(parts[0]);
        Integer minute = Integer.valueOf(parts[1]);
        return Time.newInstance(hour, minute, 0, 0);
    }
 }