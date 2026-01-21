import SwiftUI

struct LearnerQuizResultView: View {
    @Environment(\.dismiss) private var dismiss
    let submission: QuizSubmission
    let quizTitle: String
    var onHome: () -> Void
    
    var body: some View {
        // Calculate Pass/Fail
        let percentage = submission.percentageScore
        let isPassed = percentage >= 75.0
        let statusText = isPassed ? "Passed" : "Failed"
        let statusColor = isPassed ? AppTheme.successGreen : AppTheme.errorRed
        
        ZStack {
            AppTheme.groupedBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: isPassed ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .font(.system(size: 64))
                            .foregroundColor(statusColor)
                            .padding(.top, 40)
                        
                        Text(quizTitle)
                            .font(.title2.bold())
                            .foregroundColor(AppTheme.primaryText)
                            .multilineTextAlignment(.center)
                        
                        Text("Quiz Submitted")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    
                    // Score Card
                    VStack(spacing: 20) {
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(String(format: "%.0f", percentage))%")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                            
                        }
                        
                        Text(statusText)
                            .font(.headline)
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(statusColor.opacity(0.1))
                            .cornerRadius(20)
                        
                        Divider()
                        
                        HStack(spacing: 40) {
                            statItem(
                                title: "Score",
                                value: "\(submission.score)/\(submission.totalPoints)",
                                color: AppTheme.primaryText
                            )
                            
                            statItem(
                                title: "Correct",
                                value: String(submission.answers.filter { $0.isCorrect == true }.count),
                                color: AppTheme.successGreen
                            )
                            
                            statItem(
                                title: "Incorrect",
                                value: String(submission.answers.filter { $0.isCorrect == false }.count),
                                color: AppTheme.errorRed
                            )
                        }
                    }
                    .padding(24)
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    if submission.answers.contains(where: { $0.isCorrect == nil }) {
                        Text("Some answers require manual grading.")
                            .font(.caption)
                            .foregroundColor(AppTheme.warningOrange)
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onHome()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryBlue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 24)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)
        }
    }
}

