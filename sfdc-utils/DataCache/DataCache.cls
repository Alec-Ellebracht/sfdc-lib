/**
 * @author : Alec Ellebracht
 * @date : 10/15/2019
 * @description : Abstract class that can be extended to create data caches for objects
**/

public abstract class DataCache {

    /***********************************************************************************************
    *
    * Abstract Methods
    *
    ***********************************************************************************************/

    /**
     * @description : 
     * For extensions to provide an instance of a data cache that will be used to get records from.
     * Extensions should implement a singleton pattern to prevent unnecessary queries.
     *
     * @return: { DataCache } - a data cache instance
     */
    abstract DataCache getInstance ();

    /**
     * @description : For each extensions to provide a unique query
     *
     * @param: { Set<Id> } nonLoadedIds - a set of ids that have not previously been queried
     * @return: { List<Sobject> } - a list of sobject that have been queried
     */
    abstract List<Sobject> queryRecords (Set<Id> nonLoadedIds);

    /***********************************************************************************************
    *
    * Protected Methods
    *
    ***********************************************************************************************/

    /**
     * @description : This method returns a map of Id to Sobjects
     *
     * @param: { Set<Id> } setIds - a set of ids to get data for
     * @return: { Map<Id, Sobject> } - map of ids to Sobjects from the cache
     */
    protected virtual Map<Id, Sobject> buildMap (Set<Id> setIds) {

        // new map of paired down entries to be returned
        Map<Id, Sobject> newMap = new Map<Id, Sobject>();

        // lazy-load objects
        Map<Id, Sobject> masterMap = this.getInstance().loadMap( setIds );

        // pair down the results to just the requested id entries
        for (Id thisId : setIds) {
            if (masterMap.containsKey( thisId )) {
                newMap.put( thisId, masterMap.get( thisId ) );
            }
        }
        return newMap;
    }

    /**
     * @description : 
     * Lazy loads a mapping from id to Sobject and stores the mapping
     * so that it doesn't have to re-query every time.
     *
     * @param: { Set<Id> } setIds - a set of ids to get data for
     * @return: { Map<Id, Sobject> } - map of ids to Sobjects from the cache
     */
    protected Map<Id, Sobject> cachedMap;
    protected virtual Map<Id, Sobject> loadMap (Set<Id> setIds) {

        DataCache instance = this.getInstance();

        if (instance.cachedMap == null) {
            instance.cachedMap = new Map<Id, Sobject>();
        }

        if (setIds == null || setIds.isEmpty()) {
            return instance.cachedMap;
        }

        // Gather Ids we haven't loaded yet
        Set<Id> nonLoadedIds = new Set<Id>();

        // check for unloaded object ids
        for (Id thisId : setIds) {
            if (!instance.cachedMap.containsKey( thisId )) {
                nonLoadedIds.add( thisId );
            }
        }

        // If there are some non-loaded ids, load them
        if (!nonLoadedIds.isEmpty()) {

            // extension classes must override the getRecords method
            // and query the records with the provided Ids
            for (Sobject mappingEntry : instance.queryRecords(nonLoadedIds)) {

                instance.cachedMap.put( mappingEntry.Id, mappingEntry );
            }
        }
        return instance.cachedMap;
    }
}