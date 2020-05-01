/**
 * @author : Alec Ellebracht
 * @date : 10/15/2019
 * @description : A data cache for accounts
**/

public without sharing class ExampleAccountDataCache extends DataCache {

    /***********************************************************************************************
    *
    * Props
    *
    ***********************************************************************************************/

    // auto-initialize an instance
    @TestVisible
    private static ExampleAccountDataCache instance = new ExampleAccountDataCache();

    /***********************************************************************************************
    *
    * Public Methods
    *
    ***********************************************************************************************/

    // a static method to fetch requested records from the data cache
    public static Map<Id,Account> getRecords (Set<Id> setIds) {
        return new Map<Id,Account>((List<Account>)instance.buildMap(setIds).values());
    }

    /***********************************************************************************************
    *
    * Implemented Abstract Methods
    *
    ***********************************************************************************************/

    // to provide access to the appropriate instance
    private DataCache getInstance () { return instance; }

    // the query that the data cache uses to fetch data
    // NOTE : the 'where' clause should not be modified
    private List<Sobject> queryRecords (Set<Id> nonLoadedIds) {
        
        System.debug('~~~ account data cache querying '+nonLoadedIds.size()+' records...');

        return new List<Account>([
            SELECT Id, Name,
                OwnerId,
                RecordTypeId
            FROM Account
            WHERE Id in :nonLoadedIds
        ]);
    }
}