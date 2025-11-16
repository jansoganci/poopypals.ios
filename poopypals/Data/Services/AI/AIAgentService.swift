import Foundation

/// Service for interacting with PoopyPals AI agents
class AIAgentService {

    // MARK: - Properties
    private let supabaseURL: String
    private let supabaseAnonKey: String

    // MARK: - Initialization
    init() {
        // Load from Config.plist
        guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: configPath) as? [String: Any],
              let url = config["SupabaseURL"] as? String,
              let key = config["SupabaseAnonKey"] as? String else {
            fatalError("Config.plist not found or missing keys")
        }

        self.supabaseURL = url
        self.supabaseAnonKey = key
    }

    // MARK: - Public Methods

    /// Query the Analytics Agent with natural language
    /// - Parameters:
    ///   - query: Natural language query (e.g., "What's my streak?")
    ///   - deviceId: Device UUID for data isolation
    /// - Returns: Agent response with data and message
    func queryAnalytics(query: String, deviceId: UUID) async throws -> AgentResponse {
        let request = AnalyticsRequest(
            device_id: deviceId.uuidString,
            query: query
        )

        return try await callEdgeFunction(
            functionName: "analytics-agent",
            body: request
        )
    }

    /// Call a specific analytics tool directly
    /// - Parameters:
    ///   - tool: Tool name (calculate_streak, fetch_logs, get_stats)
    ///   - params: Tool parameters
    ///   - deviceId: Device UUID
    /// - Returns: Agent response
    func callAnalyticsTool(
        tool: String,
        params: [String: Any] = [:],
        deviceId: UUID
    ) async throws -> AgentResponse {
        let request = AnalyticsRequest(
            device_id: deviceId.uuidString,
            query: "",
            tool: tool,
            params: params
        )

        return try await callEdgeFunction(
            functionName: "analytics-agent",
            body: request
        )
    }

    // MARK: - Convenience Methods

    /// Get current streak
    func getStreak(deviceId: UUID) async throws -> Int {
        let response = try await callAnalyticsTool(
            tool: "calculate_streak",
            deviceId: deviceId
        )

        guard let data = response.data as? [String: Any],
              let streak = data["streak"] as? Int else {
            throw AIAgentError.invalidResponse
        }

        return streak
    }

    /// Get logs for a date range
    func getLogs(
        startDate: Date,
        endDate: Date,
        deviceId: UUID
    ) async throws -> [PoopLog] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        let params: [String: Any] = [
            "start_date": formatter.string(from: startDate),
            "end_date": formatter.string(from: endDate)
        ]

        let response = try await callAnalyticsTool(
            tool: "fetch_logs",
            params: params,
            deviceId: deviceId
        )

        guard let data = response.data as? [String: Any],
              let logsData = data["logs"] as? [[String: Any]] else {
            throw AIAgentError.invalidResponse
        }

        // Convert to PoopLog models
        return try logsData.compactMap { logDict in
            let jsonData = try JSONSerialization.data(withJSONObject: logDict)
            return try JSONDecoder().decode(PoopLog.self, from: jsonData)
        }
    }

    /// Get statistics summary
    func getStats(deviceId: UUID) async throws -> StatsResponse {
        let response = try await callAnalyticsTool(
            tool: "get_stats",
            params: ["metric": "summary"],
            deviceId: deviceId
        )

        guard let data = response.data as? [String: Any] else {
            throw AIAgentError.invalidResponse
        }

        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(StatsResponse.self, from: jsonData)
    }

    // MARK: - Private Methods

    private func callEdgeFunction<T: Encodable>(
        functionName: String,
        body: T
    ) async throws -> AgentResponse {
        let url = URL(string: "\(supabaseURL)/functions/v1/\(functionName)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIAgentError.networkError
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIAgentError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(AgentResponse.self, from: data)
    }
}

// MARK: - Models

struct AnalyticsRequest: Encodable {
    let deviceId: String
    let query: String
    let tool: String?
    let params: [String: Any]?

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case query
        case tool
        case params
    }

    init(
        device_id: String,
        query: String,
        tool: String? = nil,
        params: [String: Any]? = nil
    ) {
        self.deviceId = device_id
        self.query = query
        self.tool = tool
        self.params = params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(query, forKey: .query)
        try container.encodeIfPresent(tool, forKey: .tool)

        // Handle Any dictionary encoding
        if let params = params {
            let jsonData = try JSONSerialization.data(withJSONObject: params)
            let jsonString = String(data: jsonData, encoding: .utf8)
            // Note: This is a simplification - in production, use a proper encoding strategy
        }
    }
}

struct AgentResponse: Decodable {
    let success: Bool
    let data: Any?
    let error: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case success
        case data
        case error
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        message = try container.decodeIfPresent(String.self, forKey: .message)

        // Decode data as dictionary
        if let dataDict = try? container.decode([String: Any].self, forKey: .data) {
            data = dataDict
        } else {
            data = nil
        }
    }
}

struct StatsResponse: Decodable {
    let totalLogs: Int
    let avgDuration: Int?
    let avgDurationFormatted: String?
    let ratingDistribution: [String: Int]?
    let mostCommonRating: String?
}

enum AIAgentError: Error, LocalizedError {
    case networkError
    case httpError(statusCode: Int)
    case invalidResponse
    case missingConfiguration

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .httpError(let code):
            return "Server error: \(code)"
        case .invalidResponse:
            return "Invalid response from AI agent"
        case .missingConfiguration:
            return "Missing configuration"
        }
    }
}

// MARK: - Dictionary Decoding Extension

extension KeyedDecodingContainer {
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

struct JSONCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
