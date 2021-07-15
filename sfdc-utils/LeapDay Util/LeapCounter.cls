/**
 * @author : Alec Ellebracht
 * @date : 07/14/2021
 * @description : A utility for counting leap days and leap years
**/
public with sharing class LeapCounter {

    /**********************************************************************************************
    *
    * Constants
    *
    ***********************************************************************************************/

    private static final String INVALID_DATES_ERR = 'Start Date must be before End Date';

    /**********************************************************************************************
    *
    * Public Methods
    *
    ***********************************************************************************************/

    /*
     * @description : Provides the number of days between two dates excluding leap days
     *
     * @param : { Date } startDate - the start date for the range
     * @param : { Date } endDate - the end date for the range
     * @return : Integer - the number of days between two dates excluding leap days
     */
    public static Decimal daysBetweenWithoutLeapDays (Date startDate, Date endDate) {

        if (endDate < startDate) {
            throw new LeapCounterException(INVALID_DATES_ERR);
        }

        Decimal totalDays = (Decimal)startDate.daysBetween(endDate);
        Decimal leapDays = leapDaysBetween(startDate, endDate);

        return (totalDays - leapDays);
    }

    /*
     * @description : Provides the number of leap days between 2 dates
     *
     * @param : { Date } startDate - the start date for the range
     * @param : { Date } endDate - the end date for the range
     * @return : Integer - the number of leap days between the provided dates
     */
    public static Integer leapDaysBetween (Date startDate, Date endDate) {

        if (endDate < startDate) {
            throw new LeapCounterException(INVALID_DATES_ERR);
        }

        if (startDate == endDate) {
            return 0;
        }

        Integer leapDays = leapYearsBetween(startDate.year(), endDate.year());
    
        if (Date.isLeapYear(startDate.year())
            && startDate.month() > 2) {

            leapDays--;
        }
    
        if (Date.isLeapYear(endDate.year())
            && endDate.dayOfYear() < 60) {

            leapDays--;
        }
    
        return leapDays;
    }

    /*
     * @description : Provides the number of leap years between 2 years
     *
     * @param : { Integer } startYear - the start year for the range
     * @param : { Integer } endYear - the end year for the range
     * @return : Integer - the number of leap years between the provided years
     */
    public static Integer leapYearsBetween (Integer startYear, Integer endYear) {

        if (endYear < startYear) {
            throw new LeapCounterException(INVALID_DATES_ERR);
        }

        Integer check = startYear;
        Integer leapDays = 0;
    
        while (check <= endYear) {
    
            if (Date.isLeapYear(check)) {
    
                leapDays++;
            }
    
            check++;
        }

        return leapDays;
    }

    /**********************************************************************************************
    *
    * Exceptions
    *
    ***********************************************************************************************/

    public class LeapCounterException extends Exception {}

}
