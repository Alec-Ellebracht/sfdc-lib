# Example using apex to count the number of leap days between two dates

```java

Date startDate = Date.parse('01/01/2020');
Date endDate = Date.parse('03/01/2020');

Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

System.assertEquals( 1, leapDays,
    'Uh oh, it looks like the count of leap days is incorrect.');
```
