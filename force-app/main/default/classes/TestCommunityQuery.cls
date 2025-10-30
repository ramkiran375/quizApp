@isTest
private class TestCommunityQuery {
    @isTest
    static void testCommunityUserQuery() {
        User communityUser = [
            SELECT Id FROM User WHERE Profile.Name = 'Quiz Profile' LIMIT 1
        ];

        System.runAs(communityUser) {
            List<Question__c> qs = [
                SELECT Id, Question__c, Exam_Name__r.Name
                FROM Question__c
                WHERE Exam_Name__r.Name = 'Salesforce CPQ'
            ];
            System.debug('Questions visible to community user: ' + qs.size());
        }
    }
}