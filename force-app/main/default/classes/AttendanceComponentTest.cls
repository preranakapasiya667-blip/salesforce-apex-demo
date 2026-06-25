@isTest
private class AttendanceComponentTest {

    @testSetup
    static void setupTestData() {
        Employee__c emp = new Employee__c(
            Name = 'Test Employee',
            OwnerId = UserInfo.getUserId(),
            Employee_Login_User__c = UserInfo.getUserId(),
            Employee_Id__c = 'AC001',
			Date_of_Birth__c = Date.today(),
            Date_Of_Joining__c = Date.today(),
			Active__c = true
        );
        insert emp;
        Date todayDate = Date.today();
        Attendance__c att = new Attendance__c(
            Name = 'Test Employee',
            Employee__c = emp.Id,
            Date__c = todayDate,
            StartTime__c = Time.newInstance(9, 0, 0, 0),
            EndTime__c = Time.newInstance(19, 30, 0, 0),
            Status__c = 'Present',
			OwnerId = UserInfo.getUserId()
        );
       insert att;
       Leave_Request__c leaveReq = new Leave_Request__c(
            OwnerId = UserInfo.getUserId(),
            Employee__c = emp.Id,
            Leave_Type__c = 'Sick Leave',
			Reason__c = 'Felling Not Good',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today()+1,
			Status__c = 'Pending'
        );
        insert leaveReq;
    }

    @IsTest
    static void testGetTodayAttendanceRecords() {
        Test.startTest();
        AttendanceComponent.AttendanceWrapper result =  AttendanceComponent.getTodayAttendanceRecords();
        Test.stopTest();
        System.assert(result.attendanceRecord.size() > 0);
    }


    @IsTest
    static void testFormatTime12Hour() {
        Time t = Time.newInstance(14, 15, 0, 0);
        String formattedTime =  AttendanceComponent.formatTime12Hour(t);
		System.assertEquals('2:15 PM', formattedTime);
    }

    @IsTest
    static void testSearchAttendenceRecord() {
        Test.startTest();
        AttendanceComponent.AttendanceWrapper result =  AttendanceComponent.searchAttendenceRecord('Test');
        Test.stopTest();
        System.assertEquals(  'Test Employee',  result.attendanceRecord[0].employeeName );
    }

    @IsTest
    static void testSearchAttendenceRecordBlank() {
        Test.startTest();
        AttendanceComponent.AttendanceWrapper result =  AttendanceComponent.searchAttendenceRecord('');
        Test.stopTest();
        System.assertEquals(0, result.attendanceRecord.size());
    }

    @IsTest
    static void testGetMonthlyAttendenceRecord() {
        Test.startTest();
        String csvResult = AttendanceComponent.getMonthlyAttendenceRecord();
        Test.stopTest();
        System.assert(csvResult.contains('Employee Name'));
    }

    @IsTest
    static void testEscapeCSV() {
        String result =  AttendanceComponent.escapeCSV('Test "Value"');
        System.assertEquals('"Test ""Value"""', result);
    }
    
    @IsTest
    static void testgetLeaveRequest() {
        Test.startTest();
        AttendanceComponent.LeaveWrapper leaveResult = AttendanceComponent.getLeaveRequest();
        Test.stopTest();
        
    }


}