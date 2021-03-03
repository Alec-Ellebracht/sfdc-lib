# Example using the data cache for accounts

```java

Set<Id> acctIds = new Set<Id>{
    '0015400000a1U5O'
};

Map<Id,Account> relatedAccts = 
    AccountDataCache.getRecords(acctIds);

for (Id acctId : relatedAccts.keySet()) {

    Account cacheAcct = relatedAccts.get(acctId);
    System.debug('~~~ Got account '+cacheAcct.Name+' from the data cache!');
}

// call purge to clear out all the data in the cache
AccountDataCache.purge();

// call refresh to requery all the data in the cache
AccountDataCache.refresh();
```
