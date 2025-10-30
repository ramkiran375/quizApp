public without sharing class GenerateOTPAction {

    // Wrapper class to return multiple values
    public class OTPWrapper {
        @InvocableVariable(label='OTP')
        public String otp;

        @InvocableVariable(label='Expiry Time')
        public DateTime expiry;
    }

    @InvocableMethod(label='Generate OTP')
    public static List<OTPWrapper> generateOTP(List<String> dummy) {
        List<OTPWrapper> result = new List<OTPWrapper>();
        
        OTPWrapper wrapper = new OTPWrapper();
        
        // Generate random 6-digit OTP
        Integer otpValue = Math.round(Math.random() * 900000) + 100000;
        wrapper.otp = String.valueOf(otpValue);
        
        // Set expiry time (10 minutes from now)
        wrapper.expiry = System.now().addMinutes(10);
        
        result.add(wrapper);
        return result;
    }
}