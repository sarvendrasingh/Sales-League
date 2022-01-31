public class leaderboardController {

    @AuraEnabled(cacheable=true)
    public static List<Date> currentFY(){
        List<Date> returnList = new List<Date>();
        Date filterEndDate, filterStartDate;
        String periodQuery = 'SELECT StartDate, EndDate FROM Period WHERE Id != NULL ';
        periodQuery += ' AND Type=\'Year\' AND StartDate = THIS_FISCAL_YEAR';
        Period currentPeriod = Database.query(periodQuery);
        filterStartDate = Date.parse(currentPeriod.StartDate.format());
        filterEndDate = Date.parse(currentPeriod.EndDate.format());
        returnList.add(filterStartDate);
        returnList.add(filterEndDate);
        return returnList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> targetQuarterOptions(){
        Map<String, String> returnList = new Map<String, String>();
        Map<String, String> dateEnds = new Map<String, String>{
            '1' => 'st',
            '2' => 'nd',
            '3' => 'rd',
            '4' => 'th',
            '5' => 'th'
        };

        Period currentPeriod = [SELECT Number FROM Period WHERE Type='Quarter' AND StartDate = THIS_FISCAL_QUARTER];
        String currentQuarter = String.valueOf(currentPeriod.Number);
        for(Integer i=1; (i<=currentPeriod.Number && i<=4); i++) {  
            if(String.valueOf(i)==currentQuarter){
                returnList.put(i+dateEnds.get(String.valueOf(i))+ ' FQ'+ ' - (current)', String.valueOf(i));
            }else{
                returnList.put(i+dateEnds.get(String.valueOf(i))+ ' FQ', String.valueOf(i));
            }             
        }        
        return returnList; 
    }

    @AuraEnabled(cacheable=true)
    public static List<Date> targetQuarterRange(String targetQuarterSelected){
        List<Date> returnList = new List<Date>();
        Date filterEndDate, filterStartDate;
        String periodQuery = 'SELECT StartDate, EndDate FROM Period WHERE Id != NULL ';
        Integer periodNumber = Integer.valueOf(targetQuarterSelected);
        periodQuery += ' AND Type=\'Quarter\' AND StartDate = THIS_FISCAL_YEAR AND Number =: periodNumber';
        Period currentPeriod = Database.query(periodQuery);
        filterStartDate = Date.parse(currentPeriod.StartDate.format());
        filterEndDate = Date.parse(currentPeriod.EndDate.format());
        returnList.add(filterStartDate);
        returnList.add(filterEndDate);
        return returnList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> awardFYDateRanges(){
        Map<String,String> returnList = new Map<String,String>();
        List<Period> periods = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Year' AND (StartDate = LAST_N_YEARS:10 OR StartDate = THIS_FISCAL_YEAR)];
        for(Period tempPeriod : periods) { 
            returnList.put(tempPeriod.StartDate.format()+' - '+tempPeriod.EndDate.format(), tempPeriod.StartDate+'='+tempPeriod.EndDate);
        }
        return returnList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> awardFQDateRanges(String awardFYSelected){
        Map<String,String> returnList = new Map<String,String>();
        String[] tempDates = awardFYSelected.split('=');
        Date tempStartDate = Date.valueOf(tempDates[0]);
        Date tempEndDate = Date.valueOf(tempDates[1]);       
        List<Period> periods = [SELECT StartDate, EndDate, Number FROM Period WHERE Type = 'Quarter' AND (StartDate >= :tempStartDate AND EndDate <= :tempEndDate) AND StartDate <= THIS_FISCAL_QUARTER];        
        for(Period tempPeriod : periods) {            
            returnList.put(tempPeriod.StartDate.format()+' - '+tempPeriod.EndDate.format(), tempPeriod.StartDate+'='+tempPeriod.EndDate);
        }
        return returnList;
    }
}