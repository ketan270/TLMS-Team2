import SwiftUI
import Combine

struct LearnerQuizView: View {
    @Environment(\.dismiss) private var dismiss
    let lesson: Lesson
    @Binding var isPresented: Bool
    
    // MARK: - State
    @State private var currentIndex = 0
    @State private var selectedOptionIndices: Set<Int> = []
    @State private var descriptiveAnswer: String = ""
    @State private var answers: [UUID: QuizAnswer] = [:] // Map question ID to answer
    
    @State private var remainingTime: Int = 0
    @State private var isTimerRunning = false
    @State private var navigateToResult = false
    @State private var submission: QuizSubmission?
    
    // Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Data
    private var questions: [Question] {
        lesson.quizQuestions ?? []
    }
    
    private var currentQuestion: Question? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }
    
    // MARK: - Initialization
    private func initializeQuiz() {
        // Set time limit: Use lesson limit (in minutes) or default to 1 min per question
        if let limitMinutes = lesson.quizTimeLimit, limitMinutes > 0 {
            remainingTime = limitMinutes * 60
        } else {
            remainingTime = questions.count * 60
        }
        isTimerRunning = true
    }
    
    // MARK: - UI
    var body: some View {
        VStack(spacing: 0) {
            
            // Header: Timer & Progress
            HStack {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(timeString(from: remainingTime))
                        .monospacedDigit()
                }
                .font(.headline)
                .foregroundColor(remainingTime < 60 ? AppTheme.errorRed : AppTheme.primaryBlue)
            }
            .padding()
            .background(AppTheme.groupedBackground)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    if let question = currentQuestion {
                        
                        // Question Text
                        Text(question.text)
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.primaryText)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Options
                        if question.type == .descriptive {
                            TextEditor(text: $descriptiveAnswer)
                                .frame(minHeight: 150)
                                .padding()
                                .background(AppTheme.secondaryGroupedBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        } else {
                            VStack(spacing: 12) {
                                ForEach(question.options.indices, id: \.self) { index in
                                    optionButton(
                                        text: question.options[index],
                                        index: index,
                                        isSelected: selectedOptionIndices.contains(index)
                                    )
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            
            Divider()
            
            // Footer: Navigation Buttons
            HStack(spacing: 20) {
                // Previous Button
                Button(action: handlePrevious) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.headline)
                    .foregroundColor(currentIndex > 0 ? AppTheme.primaryText : Color.gray.opacity(0.3))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(12)
                }
                .disabled(currentIndex == 0)
                
                // Next/Submit Button
                Button(action: handleNextOrSubmit) {
                    HStack {
                        Text(currentIndex == questions.count - 1 ? "Submit Quiz" : "Next")
                        if currentIndex != questions.count - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.primaryBlue)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(AppTheme.groupedBackground)
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Lock Screen
        .interactiveDismissDisabled(true)    // Lock Screen
        .onAppear(perform: initializeQuiz)
        .onReceive(timer) { _ in
            if isTimerRunning && remainingTime > 0 {
                remainingTime -= 1
            } else if isTimerRunning && remainingTime == 0 {
                submitQuiz()
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let submission = submission {
                LearnerQuizResultView(
                    submission: submission,
                    quizTitle: lesson.title,
                    onHome: {
                        isPresented = false
                    }
                )
            }
        }
    }
    
    // MARK: - Logic
    
    private func handlePrevious() {
        saveCurrentAnswer()
        if currentIndex > 0 {
            currentIndex -= 1
            loadAnswer(for: currentIndex)
        }
    }
    
    private func handleNextOrSubmit() {
        saveCurrentAnswer()
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            loadAnswer(for: currentIndex)
        } else {
            submitQuiz()
        }
    }
    
    private func saveCurrentAnswer() {
        guard let question = currentQuestion else { return }
        
        // Determine correctness immediately for local storage
        let isCorrect: Bool
        let points: Int
        
        if question.type == .descriptive {
            // Manual grading required, assume 0 points for auto-score but mark as needs grading if supported
            isCorrect = false
            points = 0
        } else {
            // Compare sets of indices
            let correctSet = Set(question.correctAnswerIndices)
            isCorrect = (selectedOptionIndices == correctSet)
            points = isCorrect ? question.points : 0
        }
        
        let answer = QuizAnswer(
            questionID: question.id,
            selectedOptionIndices: Array(selectedOptionIndices),
            textAnswer: question.type == .descriptive ? descriptiveAnswer : nil,
            isCorrect: isCorrect,
            pointsEarned: points
        )
        
        answers[question.id] = answer
    }
    
    private func loadAnswer(for index: Int) {
        guard questions.indices.contains(index) else { return }
        let question = questions[index]
        
        if let savedAnswer = answers[question.id] {
            selectedOptionIndices = Set(savedAnswer.selectedOptionIndices)
            descriptiveAnswer = savedAnswer.textAnswer ?? ""
        } else {
            selectedOptionIndices = []
            descriptiveAnswer = ""
        }
    }
    
    private func submitQuiz() {
        isTimerRunning = false
        saveCurrentAnswer() // Save the last question's answer
        
        // Generate Submission
        let finalAnswers = questions.compactMap { answers[$0.id] }
        let score = finalAnswers.reduce(0) { $0 + $1.pointsEarned }
        let totalPoints = questions.reduce(0) { $0 + $1.points }
        
        // Create Submission Object
        let newSubmission = QuizSubmission(
            quizID: lesson.id, // Using Lesson ID as Quiz ID since they are 1:1 here
            learnerID: UUID(), // Placeholder, real app would get from AuthService
            answers: finalAnswers,
            score: score,
            totalPoints: totalPoints,
            status: .submitted,
            submittedAt: Date()
        )
        
        self.submission = newSubmission
        self.navigateToResult = true
    }
    
    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Components
    
    private func optionButton(text: String, index: Int, isSelected: Bool) -> some View {
        Button(action: {
            if let question = currentQuestion {
                if question.type == .multipleChoice {
                    if selectedOptionIndices.contains(index) {
                        selectedOptionIndices.remove(index)
                    } else {
                        selectedOptionIndices.insert(index)
                    }
                } else if question.type == .singleChoice {
                    // Radio button behavior: only one selected
                    selectedOptionIndices = [index]
                } else {
                    // Fallback for others if any
                    selectedOptionIndices = [index]
                }
            }
        }) {
            HStack {
                // UI based on question type
                if let question = currentQuestion, question.type == .multipleChoice {
                     // Square Checkbox for Multiple Choice
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .foregroundColor(isSelected ? AppTheme.primaryBlue : AppTheme.secondaryText)
                } else {
                    // Circle Radio for Single Choice
                    Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                        .foregroundColor(isSelected ? AppTheme.primaryBlue : AppTheme.secondaryText)
                }
                
                Text(text)
                    .font(.body)
                    .foregroundColor(AppTheme.primaryText)
                
                Spacer()
            }
            .padding()
            .background(
                isSelected ? AppTheme.primaryBlue.opacity(0.1) : AppTheme.secondaryGroupedBackground
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.primaryBlue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

