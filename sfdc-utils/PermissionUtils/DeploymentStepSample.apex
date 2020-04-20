// this is a simple script that can be added as a deployment step
// NOTE: Currently only Read and Read/Write can be assigned, this
// framework does not handle the removal of FLS

FieldPermissionService service = new FieldPermissionService();

// profiles
service.assignToProfile( 'Account.Some_New_Field__c', 'Developer', 'READ_WRITE' );
service.assignToProfile( 'Account.Some_New_Field__c', 'Analytics', 'READ_ONLY' );

// perm sets
service.assignToPermSet( 'Account.Some_New_Field__c', 'Administrator', 'READ_ONLY' );
service.assignToPermSet( 'Account.Some_Other_Field__c', 'Administrator', 'READ_WRITE' );

service.doAssignments();