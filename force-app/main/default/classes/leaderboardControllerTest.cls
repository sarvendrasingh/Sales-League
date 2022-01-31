@isTest(SeeAllData=true)
public class leaderboardControllerTest {

    @isTest
    public static void testCase1(){

        List<Date> testList = new List<Date>();
        Period periodQuery = Database.query('SELECT StartDate, EndDate FROM Period WHERE Id != NULL AND Type=\'Year\' AND StartDate = THIS_FISCAL_YEAR');
        testList.add(Date.parse(periodQuery.StartDate.format())); 
        testList.add(Date.parse(periodQuery.EndDate.format())); 
        System.assertEquals(leaderboardController.currentFY(), testList);

        Period currentQuarter = [SELECT Number FROM Period WHERE Type='Quarter' AND StartDate = THIS_FISCAL_QUARTER];
        Integer currentQuarterValue = currentQuarter.Number;
        List<Date> testList2 = new List<Date>();
        periodQuery = Database.query('SELECT StartDate, EndDate FROM Period WHERE Id != NULL AND Type=\'Quarter\' AND StartDate = THIS_FISCAL_YEAR AND Number =: currentQuarterValue');
        testList2.add(Date.parse(periodQuery.StartDate.format())); 
        testList2.add(Date.parse(periodQuery.EndDate.format())); 
        System.assertEquals(leaderboardController.targetQuarterRange(String.valueOf(currentQuarterValue)), testList2);

        Map<String, String> dateEnds = new Map<String, String>{
            '1' => 'st',
            '2' => 'nd',
            '3' => 'rd',
            '4' => 'th',
            '5' => 'th'
        };
        String key = String.valueOf(currentQuarterValue) + dateEnds.get(String.valueOf(currentQuarterValue))+ ' FQ - (current)';
        String currentReturnedQuarter = leaderboardController.targetQuarterOptions().get(key);
        System.assertEquals(currentReturnedQuarter, String.valueOf(currentQuarterValue));

        Map<String, String> testMap = leaderboardController.awardFYDateRanges();
        List<String> mapValues = testMap.values();
        String FYRange;
        for (Integer i = 0; i < mapValues.size(); i++) {
            FYRange = mapValues[i];
        }
        String[] tempDates = FYRange.split('=');
        List<Date> testList3 = new List<Date>();
        testList3.add(Date.valueOf(tempDates[0]));
        testList3.add(Date.valueOf(tempDates[1]));
        System.assertEquals(testList3, testList);

        testMap.clear();
        List<Period> periods = [SELECT StartDate, EndDate, Number FROM Period WHERE Type = 'Quarter' AND (StartDate >= :testList3[0] AND EndDate <= :testList3[1]) AND StartDate <= THIS_FISCAL_QUARTER];        
        for(Period tempPeriod : periods) {            
            testMap.put(tempPeriod.StartDate.format()+' - '+tempPeriod.EndDate.format(), tempPeriod.StartDate+'='+tempPeriod.EndDate);
        }
        System.assertEquals(leaderboardController.awardFQDateRanges(FYRange),testMap);
    }
}
