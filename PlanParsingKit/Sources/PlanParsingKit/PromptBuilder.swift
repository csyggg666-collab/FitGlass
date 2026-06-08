import Foundation

/// Builds the prompt the user hands to the Claude app. The prompt pins Claude to a
/// strict JSON contract (matching `TrainingPlanDTO`) so the reply can be pasted back
/// and parsed by `PlanJSONParser` with no extra UI plumbing.
public enum PromptBuilder {

    /// Prompt for generating a brand-new plan from the intake form.
    public static func generatePlanPrompt(from intake: PlanIntake) -> String {
        let language = displayLanguage(intake.language)
        let equipment = intake.equipment.isEmpty ? "bodyweight only" : intake.equipment.joined(separator: ", ")
        let focus = intake.focusAreas.isEmpty ? "balanced full body" : intake.focusAreas.joined(separator: ", ")

        return """
        You are a certified strength & conditioning coach. Design a personalized, progressive training plan.

        ATHLETE BRIEF:
        - Goal: \(intake.goal)
        - Experience level: \(intake.level)
        - Training days per week: \(intake.daysPerWeek)
        - Time per session: about \(intake.sessionMinutes) minutes
        - Plan length: \(intake.weeks) weeks
        - Available equipment: \(equipment)
        - Focus areas: \(focus)
        - Limitations / injuries: \(intake.limitations?.isEmpty == false ? intake.limitations! : "none")
        - Write every human-readable string (title, summary, focus, notes) in \(language).

        \(schemaSection(language: intake.language))

        Design rules:
        - Provide exactly \(intake.daysPerWeek) workouts, one per training day, ordered by "day" (1...\(intake.daysPerWeek)).
        - Choose exercises that fit the available equipment and respect the stated limitations.
        - Keep each session within the time budget.
        """
    }

    /// Prompt for turning the raw text of an imported PDF/Word plan into the JSON contract.
    public static func structureImportedTextPrompt(rawText: String, language: String) -> String {
        let lang = displayLanguage(language)
        let clipped = String(rawText.prefix(12_000)) // keep prompts within a sane size
        return """
        Below is the raw text of a training plan a user imported from a PDF or Word document.
        Convert it into structured data. Keep the original exercises, sets, reps and order; do not invent content.
        Translate human-readable strings into \(lang) only if they are not already in that language.

        \(schemaSection(language: language))

        RAW PLAN TEXT:
        \"\"\"
        \(clipped)
        \"\"\"
        """
    }

    // MARK: - Shared schema block

    private static func schemaSection(language: String) -> String {
        """
        OUTPUT FORMAT — return ONLY a single JSON object. No markdown, no code fences, no text before or after it. Match this shape exactly:
        {
          "title": "string",
          "summary": "string",
          "goal": "string",
          "level": "string",
          "weeks": 0,
          "daysPerWeek": 0,
          "language": "\(language)",
          "workouts": [
            {
              "day": 1,
              "title": "string",
              "focus": "string",
              "estimatedMinutes": 0,
              "exercises": [
                { "name": "string", "sets": 0, "reps": "string", "restSeconds": 0, "weight": "string", "notes": "string" }
              ]
            }
          ]
        }
        Notes:
        - "reps" MUST be a string so ranges ("8-12"), "AMRAP", or timed work ("30s") are allowed.
        - "weight" is a string ("bodyweight", "20kg", "RPE 8"). Use empty string "" when not applicable.
        - Output valid JSON and nothing else.
        """
    }

    private static func displayLanguage(_ code: String) -> String {
        code.hasPrefix("zh") ? "Simplified Chinese" : "English"
    }
}
