@IsTest
private class GenerateOTPActionTest {

    @IsTest
    static void generateOTP_validInput_returnsOTPWrapper() {
        // Arrange: use Test Data Factory
        List<String> dummyInput = TestDataFactory.createDummyOTPInput();

        // Act
        Test.startTest();
        List<GenerateOTPAction.OTPWrapper> otpResults = GenerateOTPAction.generateOTP(dummyInput);
        Test.stopTest();

        // Assert: only essential checks
        System.assertEquals(1, otpResults.size(), 'Should return exactly one OTP wrapper');

        GenerateOTPAction.OTPWrapper otpData = otpResults[0];
        System.assertNotEquals(null, otpData.otp, 'OTP should not be null');
        System.assertNotEquals(null, otpData.expiry, 'Expiry should not be null');
    }
}