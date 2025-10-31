@IsTest
public class TestDataFactory {

    /**
     * Creates and inserts an Exam__c record.
     */
    public static Exam__c createExam(String name) {
        Exam__c exam = new Exam__c(Name = name);
        insert exam;
        return exam;
    }

    /**
     * Creates and inserts an Attendee__c record.
     */
    public static Attendee__c createAttendee(String name) {
        Attendee__c attendee = new Attendee__c(Name = name);
        insert attendee;
        return attendee;
    }

    /**
     * Creates and inserts multiple Question__c records related to an Exam.
     */
    public static List<Question__c> createQuestions(Exam__c exam, Integer count) {
        List<Question__c> questions = new List<Question__c>();

        for (Integer i = 1; i <= count; i++) {
            questions.add(new Question__c(
                Question__c = 'What is Question ' + i + '?',
                Option_A__c = 'Option A' + i,
                Option_B__c = 'Option B' + i,
                Option_C__c = 'Option C' + i,
                Option_D__c = 'Option D' + i,
                Correct_Answer__c = 'Option A' + i,
                Exam_Name__c = exam.Id
            ));
        }

        insert questions;
        return questions;
    }

    /**
     * Creates and inserts Response__c records.
     * Alternates between correct and incorrect answers.
     */
    public static List<Response__c> createResponses(Attendee__c attendee, List<Question__c> questions) {
        List<Response__c> responses = new List<Response__c>();
        Integer i = 0;

        for (Question__c q : questions) {
            String answer;
            // ✅ Use Math.mod() instead of %
            if (Math.mod(i, 2) == 0) {
                answer = q.Correct_Answer__c;
            } else {
                answer = 'Wrong Answer';
            }

            responses.add(new Response__c(
                Attendee_Name__c = attendee.Id,
                Question_Name__c = q.Id,
                Selected_Answer__c = answer
            ));

            i++;
        }

        insert responses;
        return responses;
    }
     /**
     * Returns a dummy input list for GenerateOTPAction.
     */
    public static List<String> createDummyOTPInput() {
        return new List<String>{'dummyValue'};
    }
}