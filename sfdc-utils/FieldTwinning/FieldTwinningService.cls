/**
 * @author:      Alec Ellebracht
 * @date:        May 31, 2018
 * @description: Service to copy fields with identical api names from one object to another
**/

public class FieldTwinningService {

    /*
     * @description : Twins fields with the same api name from one object to the other
     *
     * @param : SObject fromObj - object to copy values from
     * @param : SObject toObj - object to copy values to
     */ 
    public static void twin( SObject fromObj, SObject toObj ) {

        if( fromObj == null || toObj == null ) return;

        Schema.SObjectType fromObjType = fromObj.getSObjectType();
        Schema.SObjectType toObjType = toObj.getSObjectType();

        Map<String, Schema.DescribeFieldResult> fromObjFieldDescribes = 
                FieldTwinningService.getAllCustomFieldDescribes( fromObjType );

        Map<String, Schema.DescribeFieldResult> toObjFieldDescribes = 
                FieldTwinningService.getUpdateableCustomFieldDescribes( toObjType );

        for( String thisField : toObjFieldDescribes.keyset() ){
            if( fromObjFieldDescribes.keyset().contains(thisField) ){

                // try/catch so that if the field wasn't queried for
                try { toObj.put( thisField, fromObj.get(thisField) ); }
                catch(Exception e) { continue; }
            }
        }
    } 

    // gets all field describes for the given object type
    private static Map<String, Schema.DescribeFieldResult> getAllCustomFieldDescribes( Schema.SObjectType objType ) {

        Map<String, Schema.DescribeFieldResult> objFieldDescribes = new Map<String, Schema.DescribeFieldResult>();
        List<Schema.SObjectField> fieldList = objType.getDescribe().fields.getMap().values();

        for( Schema.SObjectField thisField : fieldList ){
            
            Schema.DescribeFieldResult thisDescribe = thisField.getDescribe();
            if( thisDescribe.isCustom() )
                objFieldDescribes.put( thisDescribe.getName().toUpperCase(), thisDescribe );
        }

        return objFieldDescribes;
    }

    // gets all updateable and custom fields for the given object type
    private static Map<String, Schema.DescribeFieldResult> getUpdateableCustomFieldDescribes( Schema.SObjectType objType ) {

        Map<String, Schema.DescribeFieldResult> objFieldDescribes = new Map<String, Schema.DescribeFieldResult>();
        List<Schema.SObjectField> fieldList = objType.getDescribe().fields.getMap().values();

        for( Schema.SObjectField thisField : fieldList ){
            
            Schema.DescribeFieldResult thisDescribe = thisField.getDescribe();
            if( thisDescribe.isUpdateable() && thisDescribe.isCustom() )
                objFieldDescribes.put( thisDescribe.getName().toUpperCase(), thisDescribe );
        }

        return objFieldDescribes;
    }
}
