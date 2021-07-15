# Example using apex to count the number of leap days between two dates

```java

Date startDate = Date.newInstance(2020, 2, 1);
Date endDate = Date.newInstance(2020, 3, 1);

Decimal daysBetween = LeapCounter.daysBetweenWithoutLeapDays(startDate, endDate);

System.assertEquals( 28, daysBetween,
    'Uh oh, it looks like the count of days is incorrect.');

// or if you just want the number of days 

Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

System.assertEquals( 1, leapDays,
    'Uh oh, it looks like the count of leap days is incorrect.');
    
    
```
