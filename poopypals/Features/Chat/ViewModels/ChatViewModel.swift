import Foundation

@MainActor
class ChatViewModel: ObservableObject {

    // MARK: - Published State
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var errorAlert: ErrorAlert?

    // MARK: - Dependencies
    private let aiAgentService: AIAgentService
    private let deviceService: DeviceIdentificationService

    // MARK: - Initialization
    init(
        aiAgentService: AIAgentService = AIAgentService(),
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        self.aiAgentService = aiAgentService
        self.deviceService = deviceService

        // Add welcome message
        messages.append(ChatMessage(
            id: UUID(),
            text: "Hi! I'm your PoopyPals assistant. Ask me about your bathroom habits! 💩",
            isUser: false,
            timestamp: Date()
        ))
    }

    // MARK: - Public Methods

    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let userMessage = inputText
        inputText = ""

        // Add user message
        messages.append(ChatMessage(
            id: UUID(),
            text: userMessage,
            isUser: true,
            timestamp: Date()
        ))

        isLoading = true
        defer { isLoading = false }

        do {
            // Get device ID
            let deviceId = try await deviceService.getDeviceId()

            // Query AI agent
            let response = try await aiAgentService.queryAnalytics(
                query: userMessage,
                deviceId: deviceId
            )

            // Add AI response
            let responseText = response.message ?? "I processed your request."
            messages.append(ChatMessage(
                id: UUID(),
                text: responseText,
                isUser: false,
                timestamp: Date(),
                data: response.data
            ))

            // Haptic feedback
            HapticManager.shared.success()

        } catch {
            handleError(error)
        }
    }

    func askQuickQuestion(_ question: String) async {
        inputText = question
        await sendMessage()
    }

    // MARK: - Private Methods

    private func handleError(_ error: Error) {
        errorAlert = ErrorAlert(
            title: "Oops!",
            message: "I couldn't process that request. Try again?"
        )
        HapticManager.shared.error()
    }
}

// MARK: - Models

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    let data: Any?

    init(
        id: UUID,
        text: String,
        isUser: Bool,
        timestamp: Date,
        data: Any? = nil
    ) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.data = data
    }
}

