public with sharing class AccountController {
    
    public class AccountResponse {
        @InvocableVariable
        public List<AccountData> accountData;
    }

    public class AccountRequest {
        @InvocableVariable
        public String accountRequest;
    }

    public class AccountData {
        @InvocableVariable public String id;
        @InvocableVariable public String name;
        @InvocableVariable public String industry;
        @InvocableVariable public String phone;
    }

    @InvocableMethod(label='Get Accounts' description='Get Accounts')
    public static List<AccountResponse> getAccounts(List<AccountRequest> accountRequests) {
        
        List<AccountData> accountList = new List<AccountData>();

        for(Account acc : [  SELECT Id, Name, Industry, Phone FROM Account  ORDER BY CreatedDate DESC LIMIT 50]) {
            AccountData data = new AccountData();
            data.id = acc.Id;
            data.name = acc.Name;
            data.industry = acc.Industry;
            data.phone = acc.Phone;

            accountList.add(data);
        }

        AccountResponse response = new AccountResponse();
        response.accountData = accountList;
        
        return new List<AccountResponse>{ response };
    }

    @AuraEnabled(cacheable=true)
    public static List<Lead> getLeads() {
        return [
            SELECT Id, Name, Company, Email, Status
            FROM Lead
            ORDER BY CreatedDate DESC
        ];
    }

    public static void showError(List<Account> accList) {
        List<Account> accountList = new List<Account>();
        for (Account acc : accList) {
            if (acc.Rating == 'Hot') {
                acc.addError('Rating cannot be Hot');
            }
            else{
                acc.Name = acc.Name + ' - Valid';
                accountList.add(acc);
            }
        }
        if(!accountList.isEmpty()){
            update accountList;
        }
    }
}