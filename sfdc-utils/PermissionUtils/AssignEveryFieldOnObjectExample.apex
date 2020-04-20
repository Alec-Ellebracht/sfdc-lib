// Example to assign every field on an object to a profile
// uses schema describes to check for fields that can be assigned
// NOTE: running this on large objects will likely time out

// START SCRIPT //
giveAccessTo('Standard User');
giveAccessTo('System Admin');

// helper for giving access
void giveAccessTo (String profileName) {

    FieldPermissionService service = new FieldPermissionService();

    assignPermsForObject(Opportunity.sObjectType, profileName, service);

    service.doAssignments();
}

void assignPermsForObject (Schema.SObjectType obj, String profileName, FieldPermissionService service) {

    Schema.DescribeSObjectResult describeObj = obj.getDescribe(); 
    Map<String, Schema.SObjectField> fields = describeObj.fields.getMap();

    for (Schema.sObjectField field : fields.values()) { 

        Schema.DescribeFieldResult describeField = field.getDescribe();

        if (describeField.isPermissionable()) {

            String fullFieldPath = describeObj.getName() + '.' + String.valueOf(field);

            if (fieldsForEdit.contains(fullFieldPath)) {

                System.debug('~~~ giving edit access to '+ profileName +' for '+ fullFieldPath );

                service.assignToProfile( fullFieldPath, profileName, 'READ_WRITE' );
            }
            else {

                System.debug('~~~ giving read access to '+ profileName +' for '+ fullFieldPath );

                service.assignToProfile( fullFieldPath, profileName, 'READ_ONLY' );
            }
        }
        else {

            System.debug('~~~ '+ field +' is not permissionable');
        }
    }
}