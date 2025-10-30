public  class QuestionController {

    @AuraEnabled(cacheable=true)
    public static List<QuestionWrapper> getQuestionsByExamId(String examId) {
        List<Question__c> questionRecords = [
            SELECT Id, Question__c, Option_A__c, Option_B__c, Option_C__c, Option_D__c, Correct_Answer__c
            FROM Question__c
            WHERE Exam_Name__r.Name = :examId
        ];

        questionRecords = QuestionController.shuffleQuestions(questionRecords);

        List<QuestionWrapper> questions = new List<QuestionWrapper>();
        for (Question__c q : questionRecords) {
            List<String> options = new List<String>();
            if (q.Option_A__c != null) options.add(q.Option_A__c);
            if (q.Option_B__c != null) options.add(q.Option_B__c);
            if (q.Option_C__c != null) options.add(q.Option_C__c);
            if (q.Option_D__c != null) options.add(q.Option_D__c);

            questions.add(new QuestionWrapper(q.Id, q.Question__c, options));
        }

        return questions;
    }

    private static List<Question__c> shuffleQuestions(List<Question__c> questions) {
        List<Question__c> shuffled = new List<Question__c>();
        while (!questions.isEmpty()) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), questions.size());
            shuffled.add(questions.remove(randomIndex));
        }
        return shuffled;
    }

    public class QuestionWrapper {
        @AuraEnabled public Id questionId;
        @AuraEnabled public String questionText;
        @AuraEnabled public List<String> options;

        public QuestionWrapper(Id questionId, String questionText, List<String> options) {
            this.questionId = questionId;
            this.questionText = questionText;
            this.options = options;
        }
    }
@AuraEnabled
public static void saveOrUpdateResponse(Id attendeeId, Id questionId, String selectedAnswer) {
    List<Response__c> existingResponses = [
        SELECT Id FROM Response__c
        WHERE Attendee_Name__c = :attendeeId AND Question_Name__c = :questionId
        LIMIT 1
    ];
System.debug('response'+existingResponses);
    if (!existingResponses.isEmpty()) {
        Response__c response = existingResponses[0];
        response.Selected_Answer__c = selectedAnswer;
        update response;
    } else {
        Response__c newResponse = new Response__c();
        newResponse.Attendee_Name__c = attendeeId;
        newResponse.Question_Name__c = questionId;
        newResponse.Selected_Answer__c	 = selectedAnswer;
        insert newResponse;
    }
}
@AuraEnabled
public static Map<String, Integer> evaluateExamResult(Id attendeeId, String examName) {
    // Step 1: Get all responses for this Exam_Attendee__c
    List<Response__c> responses = [
        SELECT Id, AnswerCorrect__c
        FROM Response__c
        WHERE Attendee_Name__c = :attendeeId 
        AND Question_Name__r.Exam_Name__r.Name = :examName
    ];

    Integer correctCount = 0;
    Integer incorrectCount = 0;

    // Step 2: Count correct and incorrect answers
    for (Response__c r : responses) {
        if (r.AnswerCorrect__c == true) {
            correctCount++;
        } else {
            incorrectCount++;
        }
    }

    // Step 3: Return as a map
    return new Map<String, Integer>{
        'correctAnswers' => correctCount,
        'incorrectAnswers' => incorrectCount
    };
}


}