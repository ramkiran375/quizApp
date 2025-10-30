import { LightningElement, track, api } from 'lwc';
import getQuestionsByExamId from '@salesforce/apex/QuestionController.getQuestionsByExamId';
import saveOrUpdateResponse from '@salesforce/apex/QuestionController.saveOrUpdateResponse';
import evaluateExamResult from '@salesforce/apex/QuestionController.evaluateExamResult';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ExamStartScreen extends LightningElement {
    @api AttendeId;
    @api examId;

    @track questions = [];
    @track currentQuestionIndex = 0;
    @track unansweredQuestionNumbers = [];
    @track showResult = false;
    @track result = '';
    @track correct = 0;
    @track wrong = 0;

    questionList = false;
    minutes = 2;
    seconds = 0;
    timerInterval;

    // Lifecycle hook
    connectedCallback() {
        if (this.examId) {
            this.loadQuestions();
            this.startTimer();
        }
    }

    // Load questions from Apex
    loadQuestions() {
        getQuestionsByExamId({ examId: this.examId })
            .then(result => {
                this.questionList = true;
                const labels = ['A', 'B', 'C', 'D'];

                this.questions = result.map((q, index) => ({
                    questionId: q.questionId,
                    questionText: q.questionText,
                    optionList: q.options.map((opt, i) => ({
                        label: `${labels[i]}: ${opt}`,
                        value: opt,
                        checked: false,
                        cssClass: 'option'
                    })),
                    badgeClass: 'badge unanswered',
                    questionNumber: index + 1,
                    reviewed: false
                }));

                console.log('Questions loaded:', this.questions);
            })
            .catch(error => {
                console.error('Error loading questions:', error);
            });
    }

    // Handle option selection
    handleOptionChange(event) {
        const selectedOption = event.target.dataset.option;
        const question = this.questions[this.currentQuestionIndex];

        question.optionList.forEach(opt => {
            opt.checked = (opt.value === selectedOption);
            opt.cssClass = opt.checked ? 'option selected' : 'option';
        });
// Update badge class based on selection and review status
if (question.optionList.some(opt => opt.checked)) {
    if (question.reviewed) {
        question.reviewed = false; // Clear review flag if answered
    }
    question.badgeClass = 'badge answered';
} else {
    question.badgeClass = question.reviewed ? 'badge review' : 'badge unanswered';
}
        this.updateUnansweredTracking();

        // Save response to Apex
        const selected = question.optionList.find(opt => opt.checked);
        if (selected) {
            const labelPrefix = selected.label.split(':')[0].trim();

            saveOrUpdateResponse({
                attendeeId: this.AttendeId,
                questionId: question.questionId,
                selectedAnswer: labelPrefix,
                examName: this.examId
            })
            .then(() => {
                console.log(`Saved response for Q${question.questionNumber}: ${labelPrefix}`);
            })
            .catch(error => {
                console.error('Error saving response:', error);
            });
        }
    }

    // Mark question for review
    handleReview() {
        const question = this.questions[this.currentQuestionIndex];
        question.reviewed = true;
        question.badgeClass = 'badge review';
    }

    // Track unanswered questions
    updateUnansweredTracking() {
        const question = this.questions[this.currentQuestionIndex];
        const questionNumber = this.currentQuestionIndex + 1;

        if (!question.optionList.some(opt => opt.checked)) {
            if (!this.unansweredQuestionNumbers.includes(questionNumber)) {
                this.unansweredQuestionNumbers.push(questionNumber);
            }
        } else {
            this.unansweredQuestionNumbers = this.unansweredQuestionNumbers.filter(num => num !== questionNumber);
        }
    }

    // Navigation
    handleNext() {
        this.updateUnansweredTracking();
        if (this.currentQuestionIndex < this.questions.length - 1) {
            this.currentQuestionIndex++;
        }
    }

    handlePrevious() {
        this.updateUnansweredTracking();
        if (this.currentQuestionIndex > 0) {
            this.currentQuestionIndex--;
        }
    }

    // Submit exam
    handleSubmit() {
        clearInterval(this.timerInterval);
        this.unansweredQuestionNumbers = [];

        let selectedAnswersWithIds = [];

        this.questions.forEach((question, index) => {
            const selected = question.optionList.find(opt => opt.checked);
            if (!selected) {
                this.unansweredQuestionNumbers.push(index + 1);
            } else {
                const labelPrefix = selected.label.split(':')[0].trim();
                selectedAnswersWithIds.push({
                    questionId: question.questionId,
                    selectedLabel: labelPrefix
                });
            }
        });

        if (this.unansweredQuestionNumbers.length > 0) {
            console.warn('Unanswered questions:', this.unansweredQuestionNumbers);
            return;
        }

        this.questionList = false;
        this.showNotification();

        evaluateExamResult({
            attendeeId: this.AttendeId,
            examName: this.examId
        })
        .then(resultData => {
            this.result = resultData.result;
            this.correct = resultData.correctAnswers;
            this.wrong = resultData.incorrectAnswers;
            this.showResult = true;

            console.log('Exam evaluated:', resultData);
        })
        .catch(error => {
            console.error('Error evaluating exam:', error);
            alert('There was an error submitting your exam. Please try again.');
        });
    }

    // Timer logic
    startTimer() {
        this.timerInterval = setInterval(() => {
            if (this.seconds === 0) {
                if (this.minutes === 0) {
                    clearInterval(this.timerInterval);
                    this.handleTimeUp();
                } else {
                    this.minutes--;
                    this.seconds = 59;
                }
            } else {
                this.seconds--;
            }
        }, 1000);
    }

    handleTimeUp() {
        alert('Time is up! Submitting your exam.');
        this.handleSubmit();
        this.showNotification();
    }

    // Toast notification
    showNotification() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Quiz submitted successfully! View your score on the results screen',
            variant: 'success',
        }));
    }

    // Badge click navigation
    handleBadgeClick(event) {
        const index = parseInt(event.target.dataset.index, 10);
        if (!isNaN(index)) {
            this.currentQuestionIndex = index - 1;
        }
    }

    // Getters for UI
    get currentQuestionNumber() {
        return this.currentQuestionIndex + 1;
    }

    get currentQuestion() {
        return this.questions[this.currentQuestionIndex];
    }

    get showPrevious() {
        return this.currentQuestionIndex > 0;
    }

    get showSubmit() {
        return this.currentQuestionIndex === this.questions.length - 1;
    }

    get allQuestionsAnswered() {
        return this.questions.length > 0 &&
            this.questions.every(q => q.optionList.some(opt => opt.checked));
    }

    get isSubmitDisabled() {
        return !this.allQuestionsAnswered;
    }
}