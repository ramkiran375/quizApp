public with sharing class SendOtpHandler {
 /*   @AuraEnabled
    public static String sendOtp(String name, String email, String phone) {
        Integer otpNum = Math.abs(Crypto.getRandomInteger()) % 1000000;
        String otp = String.valueOf(otpNum).leftPad(6, '0');

        Attendee__c att;
        List<Attendee__c> existing = [SELECT Id FROM Attendee__c WHERE Email__c = :email LIMIT 1];
        if (!existing.isEmpty()) {
            att = existing[0];
            att.Name = name;
            att.Phone__c = phone;
        } else {
            att = new Attendee__c(Name = name, Email__c = email, Phone__c = phone);
        }

        att.OTP__c = otp;
        att.OTP_Expiry_Time__c = System.now().addMinutes(5);
        att.Verified__c = false;
        upsert att;

        // Send Email OTP
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { email });
        mail.setSubject('Your Quiz OTP');
        mail.setPlainTextBody('Hello ' + name + ',\n\nYour OTP is: ' + otp + '\nThis will expire in 5 minutes.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return 'SUCCESS';
    }*/
}