public with sharing class AttendanceComponent {

    public class AttendanceWrapper {
        @AuraEnabled public List<AttendanceRecord> attendanceRecord { get; set; }
    }

    public class AttendanceRecord {
        @AuraEnabled public Date TodayDate { get; set; }
        @AuraEnabled public String TodayDay { get; set; }
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public String employeeName { get; set; }
        @AuraEnabled public String checkIn { get; set; }
        @AuraEnabled public String checkOut { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String workingHour { get; set; }
    }

     public class LeaveWrapper {
        @AuraEnabled public List<LeaveRecord> leaveRecord { get; set; }
    }

    public class LeaveRecord {
        @AuraEnabled public String leaveType { get; set; }
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public String employeeName { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Decimal numberofDays { get; set; }
        @AuraEnabled public Date endDate { get; set; }
        @AuraEnabled public Date startDate { get; set; }
    }

    @AuraEnabled
    public static AttendanceWrapper getTodayAttendanceRecords() {
        AttendanceWrapper wrapper = new AttendanceWrapper();
        wrapper.attendanceRecord = new List<AttendanceRecord>();

        try {
            Date todayDate = Date.today();
            String dayOfWeek = Datetime.newInstance(todayDate, Time.newInstance(0,0,0,0)).format('EEEE');

            List<Attendance__c> records = new List<Attendance__c>();
            records = [
                    SELECT Id, Name, StartTime__c, EndTime__c, Status__c, Date__c, Total_Working_Hour__c
                    FROM Attendance__c
                    WHERE Date__c = :todayDate
                    ORDER BY CreatedDate DESC
                ];


            if (records != null && !records.isEmpty()) {
                for (Attendance__c rec : records) {
                    AttendanceRecord wrap = new AttendanceRecord();

                    wrap.TodayDate = rec.Date__c;
                    wrap.TodayDay = dayOfWeek;
                    wrap.recordId = rec.Id;
                    wrap.employeeName = rec.Name != null ? rec.Name : '';
                    wrap.checkIn = rec.StartTime__c != null ? formatTime12Hour(rec.StartTime__c) : '';
                    wrap.checkOut = rec.EndTime__c != null ? formatTime12Hour(rec.EndTime__c) : '';
                    wrap.status = rec.Status__c != null ? rec.Status__c : '';
                    wrap.workingHour = rec.Total_Working_Hour__c != null ? rec.Total_Working_Hour__c : '';

                    wrapper.attendanceRecord.add(wrap);
                }
            }

        } catch (Exception e) {
            System.debug('Error in getAttendanceRecord: ' + e.getMessage());
        }

        return wrapper;
    }

    public static String formatTime12Hour(Time timeformat) {
        if (timeformat == null) return '';

        Integer hour = timeformat.hour();
        Integer minute = timeformat.minute();

        String ampm = (hour >= 12) ? 'PM' : 'AM';

        if (hour == 0) {
            hour = 12;
        } else if (hour > 12) {
            hour -= 12;
        }

        String minuteStr = (minute < 10) ? '0' + minute : String.valueOf(minute);

        return hour + ':' + minuteStr + ' ' + ampm;
    }

    @AuraEnabled(cacheable = true)
    public static AttendanceWrapper searchAttendenceRecord(String searchKey) {

        AttendanceWrapper wrapper = new AttendanceWrapper();
        wrapper.attendanceRecord = new List<AttendanceRecord>();

        try {
            if (String.isBlank(searchKey)) {
                return wrapper;
            }

            Date todayDate = Date.today();
            String dayOfWeek = Datetime.newInstance(todayDate, Time.newInstance(0,0,0,0)).format('EEEE');

            String searchTerm = '%' + String.escapeSingleQuotes(searchKey) + '%';

            List<Attendance__c> records = [
                SELECT Id, Name, StartTime__c, EndTime__c, Status__c, Date__c
                FROM Attendance__c
                WHERE Name LIKE :searchTerm
                AND Date__c = :todayDate
                LIMIT 1
            ];

            if (records != null && !records.isEmpty()) {
                for (Attendance__c rec : records) {
                    AttendanceRecord wrap = new AttendanceRecord();

                    wrap.TodayDate = rec.Date__c;
                    wrap.TodayDay = dayOfWeek;
                    wrap.recordId = rec.Id;
                    wrap.employeeName = rec.Name != null ? rec.Name : '';
                    wrap.checkIn = rec.StartTime__c != null ? formatTime12Hour(rec.StartTime__c) : '';
                    wrap.checkOut = rec.EndTime__c != null ? formatTime12Hour(rec.EndTime__c) : '';
                    wrap.status = rec.Status__c != null ? rec.Status__c : '';

                    wrapper.attendanceRecord.add(wrap);
                }
            }

        } catch (Exception e) {
            System.debug('Error in searchAttendenceRecord: ' + e.getMessage());
        }

        return wrapper;
    }
     @AuraEnabled(cacheable=true)
    public static String getMonthlyAttendenceRecord() {
        Date todayDate = Date.today(); 
        Integer currentMonth = todayDate.month();
        Integer currentYear = todayDate.year();
        Integer dayValue = todayDate.day();
        List<Employee__c> activeEmployeeList = [ SELECT Id, Name,(SELECT Id, Date__c, Status__c  FROM Attendances__r  WHERE CALENDAR_MONTH(Date__c) = :currentMonth
                                                                  ORDER BY Date__c) FROM Employee__c  WHERE Active__c = true ];
          
        String csv = '';
        csv += 'Employee Name';
        for (Integer i = 1; i <= dayValue; i++) {
            Date headerDate = Date.newInstance(currentYear, currentMonth, i);
            String formattedDate = headerDate.format(); 
            csv += ',' + formattedDate;
        }
        csv += '\n';
        for (Employee__c emp : activeEmployeeList) {

            Map<Integer, String> dayStatusMap = new Map<Integer, String>();

            if (emp.Attendances__r != null) {
                for (Attendance__c att : emp.Attendances__r) {
                    if (att.Date__c != null) {
                        dayStatusMap.put(att.Date__c.day(), att.Status__c);
                    }
                }
            }

            csv += escapeCSV(emp.Name);
            for (Integer i = 1; i <= dayValue; i++) {
                csv += ',';

                if (dayStatusMap.containsKey(i)) {
                    csv += escapeCSV(dayStatusMap.get(i));
                } else {
                    csv += '';
                }
            }
            csv += '\n';
        }
        System.debug('CSV: ' + csv);
        return csv;
    }

    public static String escapeCSV(String value) {
        if (value == null) return '';
        String result = value.replace('"', '""');
        return '"' + result + '"';
    }

    // @AuraEnabled
    // public static LeaveWrapper getLeaveRequest() {
    //     LeaveWrapper leaveWrapper = new LeaveWrapper();
    //     List<LeaveRecord> leaveRecords = new List<LeaveRecord>();
    //     List<Leave_Request__c> leaveRequests=  [SELECT Id, Name, Employee__r.Name, Leave_Type__c, Reason__c, Number_of_Days__c, End_Date__c, Start_Date__c, Status__c FROM Leave_Request__c  ORDER BY CreatedDate DESC ];
    //     for(Leave_Request__c leaveReq : leaveRequests){
    //         LeaveRecord leaveRecord = new LeaveRecord();
    //         leaveRecord.leaveType = leaveReq.Leave_Type__c;
    //         leaveRecord.recordId = leaveReq.Id;
    //         leaveRecord.employeeName = leaveReq.Employee__r.Name;
    //         leaveRecord.status = leaveReq.Status__c;
    //         leaveRecord.startDate = leaveReq.Start_Date__c;
    //         leaveRecord.endDate = leaveReq.End_Date__c;
    //         leaveRecord.numberofDays = leaveReq.Number_of_Days__c;
    //         leaveRecords.add(leaveRecord);
    //     }
    //     leaveWrapper.leaveRecord = leaveRecords;
    //     return leaveWrapper;
    // }

    @AuraEnabled(cacheable=true)
    public static List<Leave_Request__c> getLeaveRequest() {
        return [
            SELECT Id, Name, Employee__r.Name, Leave_Type__c, Reason__c, 
                Number_of_Days__c, End_Date__c, Start_Date__c, Status__c 
            FROM Leave_Request__c 
            ORDER BY CreatedDate DESC
        ];
    }

}