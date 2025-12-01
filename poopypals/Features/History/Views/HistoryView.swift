//
//  HistoryView.swift
//  PoopyPals
//
//  History Screen - Calendar & Log List
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.ppGradient(PPGradients.lavenderPeach)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ScrollView {
                    VStack(spacing: PPSpacing.xl) {
                        // Calendar skeleton
                        VStack(alignment: .leading, spacing: PPSpacing.md) {
                            SkeletonView(width: 120, height: 20)
                            GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.2) {
                                VStack(spacing: PPSpacing.sm) {
                                    ForEach(0..<6) { _ in
                                        HStack(spacing: PPSpacing.sm) {
                                            ForEach(0..<7) { _ in
                                                SkeletonView(width: 40, height: 40, cornerRadius: PPCornerRadius.sm)
                                            }
                                        }
                                    }
                                }
                                .padding(PPSpacing.md)
                            }
                            .frame(height: 300)
                        }
                        
                        // Logs skeleton
                        VStack(alignment: .leading, spacing: PPSpacing.md) {
                            SkeletonView(width: 150, height: 20)
                            ForEach(0..<5) { _ in
                                SkeletonLogRow()
                            }
                        }
                    }
                    .padding(.top, PPSpacing.md)
                    .padding(.horizontal, PPSpacing.lg)
                    .padding(.bottom, PPSpacing.lg)
                }
            } else if viewModel.logs.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: PPSpacing.xl) {
                        // Calendar section
                        calendarSection
                        
                        // Logs list
                        logsListSection
                    }
                    .padding(.top, PPSpacing.md)
                    .padding(.horizontal, PPSpacing.lg)
                    .padding(.bottom, PPSpacing.lg)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .refreshable {
            await viewModel.loadLogs()
        }
        .alert(item: $viewModel.errorAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Subviews
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("Select Date")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)
            
            // Simple date picker with custom styling
            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .accentColor(.ppMain)
            .background(
                GlossyCard(gradient: PPGradients.peachPink, shadowIntensity: 0.3) {
                    EmptyView()
                }
            )
            .cornerRadius(PPCornerRadius.md)
        }
    }
    
    private var logsListSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            HStack {
                Text("Logs for \(formattedDate(viewModel.selectedDate))")
                    .font(.ppTitle3)
                    .foregroundColor(.ppTextPrimary)
                
                Spacer()
                
                Text("\(viewModel.logsForDate(viewModel.selectedDate).count)")
                    .font(.ppNumberSmall)
                    .foregroundColor(.ppAccent)
            }
            
            if viewModel.hasLogsForSelectedDate {
                ForEach(viewModel.logsForDate(viewModel.selectedDate)) { log in
                    LogRowCard(log: log)
                }
            } else {
                VStack(spacing: PPSpacing.sm) {
                    Text("📭")
                        .font(.ppEmojiLarge)
                    Text("No logs for this date")
                        .font(.ppBody)
                        .foregroundColor(.ppTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(PPSpacing.xl)
                .background(Color.ppSurfaceAlt)
                .cornerRadius(PPCornerRadius.md)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: PPSpacing.lg) {
            Text("📅")
                .font(.ppEmojiXL)
            
            Text("No History Yet")
                .font(.ppTitle1)
                .foregroundColor(.ppTextPrimary)
            
            Text("Start logging to see your history here!")
                .font(.ppBody)
                .foregroundColor(.ppTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PPSpacing.xl)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Log Row Card

struct LogRowCard: View {
    let log: PoopLog
    
    var body: some View {
        HStack(spacing: PPSpacing.md) {
            // Rating emoji
            Text(ratingEmoji)
                .font(.ppEmojiMedium)
            
            VStack(alignment: .leading, spacing: PPSpacing.xs) {
                // Time
                Text(timeString)
                    .font(.ppBody)
                    .foregroundColor(.ppTextPrimary)
                
                // Rating & duration
                HStack(spacing: PPSpacing.sm) {
                    Text(log.rating.rawValue.capitalized)
                        .font(.ppCaption)
                        .foregroundColor(.ppTextSecondary)
                    
                    if log.durationSeconds > 0 {
                        Text("•")
                            .foregroundColor(.ppTextTertiary)
                        Text("\(log.durationSeconds)s")
                            .font(.ppCaption)
                            .foregroundColor(.ppTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Flush funds earned
            if log.flushFundsEarned > 0 {
                HStack(spacing: PPSpacing.xxs) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.ppAccent)
                    Text("\(log.flushFundsEarned)")
                        .font(.ppNumberSmall)
                        .foregroundColor(.ppTextPrimary)
                }
            }
        }
        .padding(PPSpacing.md)
        .background(
            GlossyCard(gradient: PPGradients.mintLavender, shadowIntensity: 0.2) {
                EmptyView()
            }
        )
        .cornerRadius(PPCornerRadius.md)
    }
    
    private var ratingEmoji: String {
        switch log.rating {
        case .great: return "😊"
        case .good: return "🙂"
        case .okay: return "😐"
        case .bad: return "😕"
        case .terrible: return "😢"
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: log.loggedAt)
    }
}

#Preview {
    NavigationView {
        HistoryView()
    }
}

#Preview {
    NavigationView {
        HistoryView()
    }
}

