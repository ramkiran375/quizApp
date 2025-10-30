public class QuizExamService {
    
    @AuraEnabled(cacheable=true)
    public static List<Question__c> fetchQuestionsByExam(String examName) {
        if (String.isBlank(examName)) {
            throw new AuraHandledException('Exam name must not be blank.');
        }
        
        List<Question__c> questions = [SELECT Id, Question__c, Exam_Name__c, Exam_Name__r.Name, Option_A__c, Option_B__c,
                                       Option_C__c, Option_D__c, Correct_Answer__c FROM Question__c
                                       WHERE Exam_Name__r.Name = :examName
                                      ];
        
        System.debug('Fetched questions for exam "' + examName + '": ' + questions);
        return questions;
    }
}