public class BookCar {
	@InvocableMethod(label='Book a Car')
    public static List<Outputs> bookingACar(List<Inputs> input){
        List<Car_rental__c> carList = new List<Car_rental__c>();
        List<Outputs> output = new List<Outputs>();
        Integer codeInt = 0;
        String code = '';
        for(Inputs inp : input){
            codeInt = Math.mod(Math.abs(Crypto.getRandomInteger()), 1000000);
        	code = String.valueOf(codeInt).leftPad(6, '0');
            Car_rental__c car = new Car_rental__c();
            car.Name = inp.renter_name;
            car.rental_city__c = inp.city;
            car.rental_start__c = Date.valueOf(inp.start_date);
            car.rental_end__c = Date.valueOf(inp.end_date);
            car.car_confirmation__c = code;
            carList.add(car);
        }
        if(!carList.isEmpty()){
            insert carList;
            for(Car_rental__c car : carList){
                 Outputs out = new Outputs();
                 out.car_confirmation_number = car.car_confirmation__c;
                 out.success = true;
                output.add(out);
            }
           
        }
        return output;
        
            
    }
    
    public class Inputs{
        @InvocableVariable(required=true)
        public String city;
        @InvocableVariable(required=true)
        public String start_date;
        @InvocableVariable(required=true)
        public String end_date;
        @InvocableVariable(required=true)
        public String renter_name;
    }
    
    public class Outputs{
        @InvocableVariable(required=true)
        public String car_confirmation_number;
        @InvocableVariable(required=true)
        public Boolean success;

    }
}