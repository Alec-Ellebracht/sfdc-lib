/**
 * @author      Alec Ellebracht
 * @date        7/5/2019
 * @description Test class for the FieldPermissionService class
 */

@isTest
public without sharing class FieldPermissionService_Test {

    /***********************************************************************************************
    *
    * Constants
    *
    ***********************************************************************************************/    
    
    private static string SOME_FIELD = 'Account.Site';
    private static string SOME_SECOND_FIELD = 'Account.Website';

    private static string SOME_PROFILE_NAME = 'System Administrator';
    private static string SOME_PERMSET_NAME = 'SomeTestPermSet';

    /***********************************************************************************************
    *
    * Test Data Setup
    *
    ***********************************************************************************************/

    // Initial data setup
    @testSetup
    static void dataSetup() {

        // to avoid mixed dml
        System.runAs( new User( Id = UserInfo.getUserId() )) {

            PermissionSet newPermissionSet = new PermissionSet(
                Name = SOME_PERMSET_NAME,
                Label = SOME_PERMSET_NAME
            );

            insert newPermissionSet;

            FieldPermissions fieldPermReadOnly = 
                new FieldPermissions(
                    Field = SOME_FIELD,
                    SobjectType = SOME_FIELD.substringBefore('.'),
                    ParentId = newPermissionSet.Id,
                    PermissionsRead = true,
                    PermissionsEdit = false
                );
    
            insert fieldPermReadOnly;
        }
    }


    /***********************************************************************************************
    *
    * Unit Tests
    *
    ***********************************************************************************************/

    // test to make sure we can add fls for profiles and 
    // perm sets for both read only and read write
    @isTest
    static void fieldPermissionService_Test1() {

        // run the tests
        Test.startTest();

            FieldPermissionService service = new FieldPermissionService();

            service.assignToProfile( SOME_FIELD, SOME_PROFILE_NAME, 'READ_WRITE' );
            service.assignToPermSet( SOME_FIELD, SOME_PERMSET_NAME, 'READ_WRITE' );
            service.assignToPermSet( SOME_SECOND_FIELD, SOME_PERMSET_NAME, 'READ_ONLY' );

            try {

                service.doAssignments();
            }
            catch (Exception ex) {

                System.assert( false, ex.getMessage() );
            }
            
        Test.stopTest();

    }
}