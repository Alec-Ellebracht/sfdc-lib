/**
 * @author      Alec Ellebracht
 * @date        7/5/2019
 * @description Class to make assigning FLS easy and scriptable, example at the bottom
 */

public without sharing class FieldPermissionService {

    /***********************************************************************************************
    *
    * Props
    *
    ***********************************************************************************************/

    private List<PermissionGrant> grants = new List<PermissionGrant>();


    /***********************************************************************************************
    *
    * Public Methods
    *
    ***********************************************************************************************/

    // assigns fls for the provided fields to the provided profiles
    public void assignToProfile (String fieldName, String profileName, String access) {

        System.assert( !String.isBlank(fieldName), 
            'Uh oh, you must provide a field name.');

        System.assert( !String.isBlank(fieldName.substringBefore('.')), 
            'Uh oh, you must provide a field with the object name as well.');

        System.assert( !String.isBlank(profileName), 
            'Uh oh, you must provide a profile name.');

        System.assert( !String.isBlank(access), 
            'Uh oh, you must provide a level of access to grant.');

        ACCESS_TYPE accessType = getAccessType( access );

        PermissionGrant grant = new PermissionGrant();
            grant.grantType = GRANT_TYPE.PROFILE;
            grant.accessType = accessType;
            grant.fieldName = fieldName;
            grant.sobjectName = fieldName.substringBefore('.');
            grant.profileOrPermName = profileName;

        this.grants.add( grant );
    }

    // assigns fls for the provided fields to the provided permission sets
    public void assignToPermSet (String fieldName, String permSetName, String access) {

        System.assert( !String.isBlank(fieldName), 
            'Uh oh, you must provide a field name.');

        System.assert( !String.isBlank(fieldName.substringBefore('.')), 
            'Uh oh, you must provide a field with the object name as well.');

        System.assert( !String.isBlank(permSetName), 
            'Uh oh, you must provide a perm set name name.');

        System.assert( !String.isBlank(access), 
            'Uh oh, you must provide a level of access to grant.');

        ACCESS_TYPE accessType = getAccessType( access );

        PermissionGrant grant = new PermissionGrant();
            grant.grantType = GRANT_TYPE.PERMISSION_SET;
            grant.accessType = accessType;
            grant.fieldName = fieldName;
            grant.sobjectName = fieldName.substringBefore('.');
            grant.profileOrPermName = permSetName;

        this.grants.add( grant );
    }

    // executes the logic to assing all the perms
    public void doAssignments () {

        FieldPermissionService.addPermSetsToGrants( this.grants );
        FieldPermissionService.addExistingFieldPermissions( this.grants );

        List<FieldPermissions> fieldPermsToUpsert = 
            getFieldPermissionsToUpsert( this.grants );

        if (fieldPermsToUpsert.size() > 0) {

            System.debug('~~~ updating ' +fieldPermsToUpsert.size()+ ' field permissions..');
            upsert fieldPermsToUpsert;
        }
    }


    /***********************************************************************************************
    *
    * Private Methods
    *
    ***********************************************************************************************/

    // this queries the relevant permission sets add attaches them to the permission grant wrappers
    private static void addPermSetsToGrants (List<PermissionGrant> grants) {

        Set<String> profileNames = new Set<String>();
        Set<String> permSetNames = new Set<String>();

        for (PermissionGrant grant : grants) {

            if (grant.grantType == GRANT_TYPE.PROFILE) {
                profileNames.add(grant.profileOrPermName);
            }
            else if (grant.grantType == GRANT_TYPE.PERMISSION_SET) {
                permSetNames.add(grant.profileOrPermName);
            }
        }

        // query the perm sets and add the relevant one to the perm grant wrappers
        Map<String,PermissionSet> profilePermissionSets = getPermSetsFromProfiles(profileNames);
        Map<String,PermissionSet> permissionSets = getPermSetsFromNames(permSetNames);

        for (PermissionGrant grant : grants) {

            if (grant.grantType == GRANT_TYPE.PROFILE) {

                grant.permSet = profilePermissionSets.get(grant.profileOrPermName);
            }
            else if (grant.grantType == GRANT_TYPE.PERMISSION_SET) {

                grant.permSet = permissionSets.get(grant.profileOrPermName);
            }
        }
    }

    // this grabs existing field permission so that they can be updated,
    // duplicate field permission are not allow so we must query and update the existing ones
    private static void addExistingFieldPermissions (List<PermissionGrant> grants) {

        Set<Id> permSetIds = new Set<Id>();
        Set<String> fieldNames = new Set<String>();

        for (PermissionGrant grant : grants) {

            permSetIds.add(grant.permSet.Id);
            fieldNames.add(grant.fieldName);
        }

        List<FieldPermissions> fieldPerms = 
            getFieldPermissions(fieldNames, permSetIds);

        // go through all the grants and populate the existing field perms
        // this is important because creating duplicate field permissions is not allowed
        for (FieldPermissions fieldPerm : fieldPerms) {
            for (PermissionGrant grant : grants) {

                if (fieldPerm.ParentId == grant.permSet.Id
                    && fieldPerm.Field == grant.fieldName) {

                    grant.fieldPerm = fieldPerm;
                    break;
                }
            }
        }
    }

    // this returns a list of all updated or newly created field permission records
    // note that if a field permission does not need to be updated because it 
    // is already correct then it will not be returned from this method
    private static List<FieldPermissions> getFieldPermissionsToUpsert (List<PermissionGrant> grants) {

        List<FieldPermissions> fieldPermsToUpsert = new List<FieldPermissions>();

        for (PermissionGrant grant : grants) {

            // either update the existing field permission
            // or create a new one
            if (grant.fieldPerm != null) {

                FieldPermissions updateFieldPerm = 
                    updateFieldLevelSecurity(grant.fieldPerm, grant);

                if (updateFieldPerm != null) {

                    fieldPermsToUpsert.add(updateFieldPerm);
                }
            }
            else {

                FieldPermissions newFieldPerm = 
                    buildFieldLevelSecurity(grant);

                fieldPermsToUpsert.add(newFieldPerm);
            }
        }

        return fieldPermsToUpsert;
    }

    // this updates existing field permissions with the newly requested access
    // note that marking something as read_only will remove edit access
    private static FieldPermissions updateFieldLevelSecurity (FieldPermissions fieldPerm, PermissionGrant grant) {

        if (grant.accessType == ACCESS_TYPE.READ_ONLY
            && (fieldPerm.PermissionsRead == false
                || fieldPerm.PermissionsEdit == true)) {

            fieldPerm.PermissionsRead = true;
            fieldPerm.PermissionsEdit = false;

            return fieldPerm; 
        }
        else if (grant.accessType == ACCESS_TYPE.READ_WRITE
            && (fieldPerm.PermissionsRead == false
                || fieldPerm.PermissionsEdit == false)) {

            fieldPerm.PermissionsRead = true;
            fieldPerm.PermissionsEdit = true;

            return fieldPerm;
        }
        else {

            // return null if the access is already correct
            return null;
        }
    }

    // this creates a new field permission from the request if one does not exist
    private static FieldPermissions buildFieldLevelSecurity (PermissionGrant grant) {

        FieldPermissions fieldPerm = new FieldPermissions();

        fieldPerm.Field = grant.fieldName;
        fieldPerm.SobjectType = grant.sobjectName;
        fieldPerm.ParentId = grant.permSet.Id;

        if (grant.accessType == ACCESS_TYPE.READ_ONLY) {

            fieldPerm.PermissionsRead = true;
            fieldPerm.PermissionsEdit = false;
        }
        else if (grant.accessType == ACCESS_TYPE.READ_WRITE) {

            fieldPerm.PermissionsRead = true;
            fieldPerm.PermissionsEdit = true;
        }

        return fieldPerm;
    }

    // this checks to make sure the caller is requesting a level of
    // access that we expect ex: READ_ONLY or READ_WRITE
    // and returns an enum for later use
    private static ACCESS_TYPE getAccessType (String access) {

        access = access.toUpperCase();

        System.assert( ACCESS_TYPES.keySet().contains(access),
            'Uh oh, we dont recognize the access you are trying to grant. '
            + 'Please use either \"READ_ONLY\" or \"READ_WRITE\"' );

        return ACCESS_TYPES.get( access );
    }


    /***********************************************************************************************
    *
    * Query Utils
    *
    ***********************************************************************************************/

    // this queries for existing field permission record to be updated
    private static List<FieldPermissions> getFieldPermissions (Set<String> fieldNames, Set<Id> permissionIds) {
        return [
            SELECT SobjectType, 
                Field, 
                PermissionsRead, 
                PermissionsEdit, 
                Parent.ProfileId,
                ParentId
            FROM FieldPermissions 
            WHERE ParentId IN :permissionIds
            AND Field IN :fieldNames ];
    }

    // this queries permission sets and returns a map indexed by perm set name
    private static Map<String,PermissionSet> getPermSetsFromNames (Set<String> permSetNames) {

        Map<String,PermissionSet> permSets = new Map<String,PermissionSet>();

        for (PermissionSet permSet : [
            SELECT Id, Name, 
                ProfileId,
                Profile.Name
            FROM PermissionSet 
            WHERE Name in :permSetNames ]) {

            permSets.put(permSet.Name, permSet);
        }

        return permSets;
    }

    // this queries permission sets that are related to profiles 
    // and returns a map indexed by profile name
    // note : all profiles are actually permission sets
    private static Map<String,PermissionSet> getPermSetsFromProfiles (Set<String> profileNames) {

        Map<String,PermissionSet> permSets = new Map<String,PermissionSet>();

        for (PermissionSet permSet : [
            SELECT Id, Name, 
                ProfileId,
                Profile.Name
            FROM PermissionSet 
            WHERE Profile.Name in :profileNames ]) {

            permSets.put(permSet.Profile.Name, permSet);
        }

        return permSets;
    }


    /***********************************************************************************************
    *
    * Classes
    *
    ***********************************************************************************************/

    // a wrapper to organize things
    public class PermissionGrant {

        public GRANT_TYPE grantType;
        public ACCESS_TYPE accessType; 
        public String fieldName;
        public String sobjectName;
        public String profileOrPermName; 

        public PermissionSet permSet; 
        public FieldPermissions fieldPerm; 

    }

    /***********************************************************************************************
    *
    * Enums & such
    *
    ***********************************************************************************************/

    public Enum GRANT_TYPE { 
        PROFILE, 
        PERMISSION_SET
    }

    public Enum ACCESS_TYPE { 
        READ_ONLY, 
        READ_WRITE
    }

    public static final Map<String,ACCESS_TYPE> ACCESS_TYPES = 
        new Map<String,ACCESS_TYPE>{ 
            ACCESS_TYPE.READ_ONLY.name() => ACCESS_TYPE.READ_ONLY, 
            ACCESS_TYPE.READ_WRITE.name() => ACCESS_TYPE.READ_WRITE
        };

    /***********************************************************************************************
    *
    * Example
    *
    ***********************************************************************************************/

    // FieldPermissionService service = new FieldPermissionService();

    // // profiles
    // service.assignToProfile( 'Account.Some_New_Field__c', 'Developer', 'READ_WRITE' );
    // service.assignToProfile( 'Account.Some_New_Field__c', 'Analytics', 'READ_ONLY' );

    // // perm sets
    // service.assignToPermSet( 'Account.Some_New_Field__c', 'Administrator', 'READ_ONLY' );
    // service.assignToPermSet( 'Account.Some_Other_Field__c', 'Administrator', 'READ_WRITE' );

    // service.doAssignments();
}