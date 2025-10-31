@IsTest
public class QuestionControllerTest {

    @IsTest
    static void testGetQuestionsByExamId() {
        // Setup
        Exam__c exam = TestDataFactory.createExam('Admin Exam');
        TestDataFactory.createQuestions(exam, 5);

        // Test
        Test.startTest();
        List<QuestionController.QuestionWrapper> questions =
            QuestionController.getQuestionsByExamId(exam.Name);
        Test.stopTest();

        // Assert
        System.assert(!questions.isEmpty(), 'Questions should be returned');
        System.assertNotEquals(null, questions[0].questionText, 'Question text should not be null');
        System.assert(questions[0].options.size() > 0, 'Options should not be empty');
    }

    @IsTest
    static void testSaveOrUpdateResponse_InsertAndUpdate() {
        // Setup
        Exam__c exam = TestDataFactory.createExam('Developer Exam');
        List<Question__c> questions = TestDataFactory.createQuestions(exam, 1);
        Attendee__c attendee = TestDataFactory.createAttendee('John Doe');
        Question__c q = questions[0];

        // Test both insert and update
        Test.startTest();
        QuestionController.saveOrUpdateResponse(attendee.Id, q.Id, 'Option A1');
        QuestionController.saveOrUpdateResponse(attendee.Id, q.Id, 'Option B1');
        Test.stopTest();

        // Assert
        Response__c resp = [SELECT Selected_Answer__c FROM Response__c LIMIT 1];
        System.assertEquals('Option B1', resp.Selected_Answer__c, 'Response should be updated');
    }

    @IsTest
    static void testEvaluateExamResult() {
        // Setup
        Exam__c exam = TestDataFactory.createExam('App Builder Exam');
        List<Question__c> questions = TestDataFactory.createQuestions(exam, 4);
        Attendee__c attendee = TestDataFactory.createAttendee('Jane Doe');

        // Create mix of correct/incorrect responses
        TestDataFactory.createResponses(attendee, questions);

        // Test
        Test.startTest();
        Map<String, Integer> result =
            QuestionController.evaluateExamResult(attendee.Id, exam.Name);
        Test.stopTest();

        // Assert
        System.assert(result.containsKey('correctAnswers'), 'Should contain correctAnswers key');
        System.assert(result.containsKey('incorrectAnswers'), 'Should contain incorrectAnswers key');
        System.assert(result.get('correctAnswers') >= 0, 'Correct count should be non-negative');
        System.assert(result.get('incorrectAnswers') >= 0, 'Incorrect count should be non-negative');
    }

    @IsTest
    static void testShuffleQuestionsMethod() {
        // Setup
        Exam__c exam = TestDataFactory.createExam('Integration Exam');
        List<Question__c> questions = TestDataFactory.createQuestions(exam, 5);
        Integer originalCount = questions.size();

        // Test shuffle
        Test.startTest();
        List<Question__c> shuffled = QuestionController.shuffleQuestions(new List<Question__c>(questions));
        Test.stopTest();

        // Assert
        System.assertEquals(originalCount, shuffled.size(), 'Shuffled list should match original size');
        System.assert(!shuffled.isEmpty(), 'Shuffled list should not be empty');
    }
}