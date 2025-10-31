public with sharing class SampleHelloWorld {
    
    // Simple method returning a greeting message
    public static String sayHello(String name) {
        if (String.isBlank(name)) {
            return 'Hello, Salesforce!';
        }
        return 'Hello, ' + name + '!';
    }
}