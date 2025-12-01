import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: PPSpacing.md) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        if viewModel.isLoading {
                            LoadingBubble()
                        }
                    }
                    .padding(.top, PPSpacing.md)
                    .padding(.horizontal, PPSpacing.md)
                    .padding(.bottom, PPSpacing.md)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Quick Questions
            if viewModel.messages.count == 1 {
                quickQuestionsSection
            }

            // Input Bar
            inputBar
        }
        .background(Color.ppBackground)
        .toolbar(.hidden, for: .navigationBar)
        .alert(item: $viewModel.errorAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK")) {
                    // Retry can be handled in view if needed
                }
            )
        }
    }

    // MARK: - Subviews

    private var quickQuestionsSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            Text("Try asking:")
                .font(.ppCaption)
                .foregroundColor(.ppTextSecondary)
                .padding(.horizontal, PPSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PPSpacing.sm) {
                    QuickQuestionButton(
                        text: "What's my streak?",
                        icon: "flame.fill"
                    ) {
                        Task {
                            await viewModel.askQuickQuestion("What's my streak?")
                        }
                    }

                    QuickQuestionButton(
                        text: "How many logs this week?",
                        icon: "calendar"
                    ) {
                        Task {
                            await viewModel.askQuickQuestion("How many logs this week?")
                        }
                    }

                    QuickQuestionButton(
                        text: "Average bathroom time?",
                        icon: "clock"
                    ) {
                        Task {
                            await viewModel.askQuickQuestion("What's my average bathroom time?")
                        }
                    }
                }
                .padding(.horizontal, PPSpacing.md)
            }
        }
        .padding(.vertical, PPSpacing.sm)
        .background(Color.ppSurfaceAlt)
    }

    private var inputBar: some View {
        HStack(spacing: PPSpacing.sm) {
            TextField("Ask about your bathroom habits...", text: $viewModel.inputText)
                .textFieldStyle(.plain)
                .padding(PPSpacing.sm)
                .background(Color.ppSurfaceAlt)
                .cornerRadius(PPCornerRadius.md)
                .focused($isInputFocused)
                .disabled(viewModel.isLoading)

            Button(action: {
                Task {
                    await viewModel.sendMessage()
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.ppIconLarge)
                    .foregroundColor(viewModel.inputText.isEmpty ? .ppTextTertiary : .ppMain)
            }
            .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
            .accessibilityLabel("Send message")
        }
        .padding(PPSpacing.md)
        .background(Color.ppBackground)
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: PPSpacing.xs) {
                Text(message.text)
                    .font(.ppBody)
                    .foregroundColor(message.isUser ? .ppTextPrimary : .ppTextPrimary)
                    .padding(PPSpacing.md)
                    .background(
                        message.isUser
                            ? Color.ppMain
                            : Color.ppSurfaceAlt
                    )
                    .cornerRadius(PPCornerRadius.md)

                Text(message.timestamp, style: .time)
                    .font(.ppCaption)
                    .foregroundColor(.ppTextTertiary)
                    .padding(.horizontal, PPSpacing.xs)
            }

            if !message.isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Loading Bubble

struct LoadingBubble: View {
    @State private var dotCount = 0

    var body: some View {
        HStack {
            HStack(spacing: PPSpacing.xs) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.ppTextSecondary)
                        .frame(width: 8, height: 8)
                        .opacity(index <= dotCount ? 1.0 : 0.3)
                }
            }
            .padding(PPSpacing.md)
            .background(Color.ppSurfaceAlt)
            .cornerRadius(PPCornerRadius.md)

            Spacer(minLength: 60)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                dotCount = (dotCount + 1) % 3
            }
        }
    }
}

// MARK: - Quick Question Button

struct QuickQuestionButton: View {
    let text: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: PPSpacing.xs) {
                Image(systemName: icon)
                    .font(.ppCaption)
                Text(text)
                    .font(.ppCaption)
            }
            .foregroundColor(.ppMain)
            .padding(.horizontal, PPSpacing.md)
            .padding(.vertical, PPSpacing.sm)
            .background(Color.ppMain.opacity(0.1))
            .cornerRadius(PPCornerRadius.full)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ChatView()
    }
}
