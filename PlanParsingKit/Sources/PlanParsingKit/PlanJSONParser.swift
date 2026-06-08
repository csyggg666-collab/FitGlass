import Foundation

public enum PlanParsingError: Error, LocalizedError, Equatable {
    case noJSONFound
    case decodingFailed(String)
    case emptyPlan

    public var errorDescription: String? {
        switch self {
        case .noJSONFound:
            return "No JSON object was found in the response. Make sure you copied Claude's full reply."
        case .decodingFailed(let detail):
            return "Couldn't read the plan JSON: \(detail)"
        case .emptyPlan:
            return "The plan had no title or no workouts."
        }
    }
}

/// Parses a Claude reply (which may contain code fences or surrounding prose) into a
/// `TrainingPlanDTO`. Robust to the model wrapping JSON in ```json fences or adding
/// chit-chat before/after the object.
public enum PlanJSONParser {

    public static func parse(_ raw: String) throws -> TrainingPlanDTO {
        let json = try extractJSONObject(from: raw)
        let decoder = JSONDecoder()
        let dto: TrainingPlanDTO
        do {
            dto = try decoder.decode(TrainingPlanDTO.self, from: Data(json.utf8))
        } catch {
            throw PlanParsingError.decodingFailed(String(describing: error))
        }
        guard !dto.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !dto.workouts.isEmpty else {
            throw PlanParsingError.emptyPlan
        }
        return dto
    }

    /// Returns the first balanced top-level `{ ... }` object found in `raw`,
    /// after unwrapping a fenced code block if one is present.
    static func extractJSONObject(from raw: String) throws -> String {
        let text = strippedOfFences(raw)
        guard let start = text.firstIndex(of: "{") else { throw PlanParsingError.noJSONFound }

        var depth = 0
        var inString = false
        var escaped = false
        var idx = start
        while idx < text.endIndex {
            let ch = text[idx]
            if inString {
                if escaped { escaped = false }
                else if ch == "\\" { escaped = true }
                else if ch == "\"" { inString = false }
            } else {
                switch ch {
                case "\"": inString = true
                case "{": depth += 1
                case "}":
                    depth -= 1
                    if depth == 0 { return String(text[start...idx]) }
                default: break
                }
            }
            idx = text.index(after: idx)
        }
        throw PlanParsingError.noJSONFound
    }

    /// If the text contains a ``` fenced block, return its inner contents
    /// (dropping an optional `json` language hint). Otherwise return the text unchanged.
    private static func strippedOfFences(_ text: String) -> String {
        guard let open = text.range(of: "```") else { return text }
        let afterOpen = text[open.upperBound...]
        guard let close = afterOpen.range(of: "```") else { return text }
        var inner = String(afterOpen[..<close.lowerBound])
        if let nl = inner.firstIndex(of: "\n") {
            let firstLine = inner[..<nl].trimmingCharacters(in: .whitespaces).lowercased()
            if firstLine == "json" || firstLine.isEmpty {
                inner = String(inner[inner.index(after: nl)...])
            }
        }
        return inner
    }
}
