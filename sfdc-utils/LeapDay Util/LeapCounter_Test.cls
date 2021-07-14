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

    // tests the correct number of leap days are counted when range is less than a year
    // in a leap year when the leap day is between the two dates
    @IsTest
    public static void testLeapDaysSameYearWithLeapDay () {

        Date startDate = Date.parse('01/01/2020');
        Date endDate = Date.parse('03/01/2020');

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

        Date startDate = Date.parse('03/01/2020');
        Date endDate = Date.parse('05/01/2020');

        Test.startTest();

            Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

        Test.stopTest();

        System.assertEquals( 0, leapDays,
            'Uh oh, it looks like the count of leap days is incorrect.');
    }

    // tests the correct number of leap days are counted when range includes century dates
    @IsTest
    public static void testLeapDaysWithCenturyDates () {

        Date startDate = Date.parse('01/01/1900');
        Date endDate = Date.parse('04/01/2000');

        Test.startTest();

            Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

        Test.stopTest();

        System.assertEquals( 25, leapDays,
            'Uh oh, it looks like the count of leap days is incorrect.');
    }

    // tests the correct number of leap days are counted when dates are the same
    @IsTest
    public static void testLeapDaysForSameDate () {

        Date startDate = Date.parse('01/01/2020');
        Date endDate = Date.parse('01/01/2020');

        Test.startTest();

            Integer leapDays = LeapCounter.leapDaysBetween(startDate, endDate);

        Test.stopTest();

        System.assertEquals( 0, leapDays,
            'Uh oh, it looks like the count of leap days is incorrect.');
    }

    // tests that an error is thrown if an invalid date range in provided
    @IsTest
    public static void testLeapDaysWithBadDates () {

        Date startDate = Date.parse('01/01/2021');
        Date endDate = Date.parse('01/01/2020');

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