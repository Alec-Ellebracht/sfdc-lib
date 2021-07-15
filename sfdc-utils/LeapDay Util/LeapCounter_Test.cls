/**
 * @author : Alec Ellebracht
 * @date : 07/14/2021
 * @description : Test class for the LeapCounter utility
**/

@isTest
public without sharing class LeapCounter_Test {

    /**********************************************************************************************
    *
    * Unit Tests
    *
    ***********************************************************************************************/

    // tests the correct number of days are counted between two dates
    @IsTest
    public static void testDaysBetween () {

        Date startDate = Date.newInstance(2020, 2, 28);
        Date endDate = Date.newInstance(2020, 3, 28);

        Test.startTest();

            Decimal numDays = LeapCounter.daysBetweenWithoutLeapDays(startDate, endDate);

        Test.stopTest();

        System.assertEquals( 28, numDays,
            'Uh oh, it looks like the count of days is incorrect.');
    }

    // tests the correct number of leap days are counted when range is less than a year
    // in a leap year when the leap day is between the two dates
    @IsTest
    public static void testLeapDaysSameYearWithLeapDay () {

        Date startDate = Date.newInstance(2020, 1, 1);
        Date endDate = Date.newInstance(2020, 3, 1);

        Test.startTest();

            Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

        Test.stopTest();

        System.assertEquals( 1, leapDays,
            'Uh oh, it looks like the count of leap days is incorrect.');
    }

    // tests the correct number of leap days are counted when range is less than a year
    // in a leap year but the leap day has already passed
    @IsTest
    public static void testLeapDaysSameYearWithoutLeapDay () {

        Date startDate = Date.newInstance(2020, 3, 1);
        Date endDate = Date.newInstance(2020, 5, 1);

        Test.startTest();

            Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

        Test.stopTest();

        System.assertEquals( 0, leapDays,
            'Uh oh, it looks like the count of leap days is incorrect.');
    }

    // tests the correct number of leap days are counted when range includes century dates
    @IsTest
    public static void testLeapDaysWithCenturyDates () {

        Date startDate = Date.newInstance(1900, 1, 1);
        Date endDate = Date.newInstance(2000, 4, 1);

        Test.startTest();

            Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

        Test.stopTest();

        System.assertEquals( 25, leapDays,
            'Uh oh, it looks like the count of leap days is incorrect.');
    }

    // tests the correct number of leap days are counted when dates are the same
    @IsTest
    public static void testLeapDaysForSameDate () {

        Date startDate = Date.newInstance(2020, 1, 1);
        Date endDate = Date.newInstance(2020, 1, 1);

        Test.startTest();

            Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

        Test.stopTest();

        System.assertEquals( 0, leapDays,
            'Uh oh, it looks like the count of leap days is incorrect.');
    }

    // tests that an error is thrown if an invalid date range in provided
    @IsTest
    public static void testLeapDaysWithBadDates () {

        Date startDate = Date.newInstance(2021, 1, 1);
        Date endDate = Date.newInstance(2020, 1, 1);

        Test.startTest();

            Boolean errorReceived = false;
            Integer leapDays;
            try {

                leapDays = LeapCounter.leapDaysBetween(startDate, endDate);
            }
            catch (LeapCounter.LeapCounterException lcex) {

                errorReceived = true;
            }

        Test.stopTest();

        System.assertEquals( true, errorReceived,
            'Uh oh, it looks like the caller did not receive an error.');
    }

}
