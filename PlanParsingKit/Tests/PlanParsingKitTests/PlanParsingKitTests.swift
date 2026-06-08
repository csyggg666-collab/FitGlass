import XCTest
@testable import PlanParsingKit

final class PlanJSONParserTests: XCTestCase {
    private let cleanJSON = """
    {"title":"5x5 Strength","summary":"Linear progression","goal":"strength","level":"beginner","weeks":8,"daysPerWeek":3,"language":"en","workouts":[{"day":1,"title":"Day A","focus":"Full body","estimatedMinutes":50,"exercises":[{"name":"Back Squat","sets":5,"reps":"5","restSeconds":180,"weight":"barbell","notes":"brace"}]}]}
    """

    func testParsesCleanJSON() throws {
        let dto = try PlanJSONParser.parse(cleanJSON)
        XCTAssertEqual(dto.title, "5x5 Strength")
        XCTAssertEqual(dto.daysPerWeek, 3)
        XCTAssertEqual(dto.workouts.count, 1)
        XCTAssertEqual(dto.workouts.first?.exercises.first?.name, "Back Squat")
        XCTAssertEqual(dto.workouts.first?.exercises.first?.reps, "5")
    }

    func testParsesFencedJSON() throws {
        let fenced = "Sure, here is your plan:\n```json\n\(cleanJSON)\n```\nLet me know if you want changes!"
        let dto = try PlanJSONParser.parse(fenced)
        XCTAssertEqual(dto.title, "5x5 Strength")
    }

    func testParsesJSONWithSurroundingProse() throws {
        let prose = "Here you go: \(cleanJSON) — enjoy your training!"
        let dto = try PlanJSONParser.parse(prose)
        XCTAssertEqual(dto.workouts.count, 1)
    }

    func testHandlesBracesInsideStrings() throws {
        let tricky = #"{"title":"Plan {beta}","language":"en","workouts":[{"title":"A","exercises":[{"name":"Curl","notes":"superset with }{ symbols"}]}]}"#
        let dto = try PlanJSONParser.parse(tricky)
        XCTAssertEqual(dto.title, "Plan {beta}")
        XCTAssertEqual(dto.workouts.first?.exercises.first?.notes, "superset with }{ symbols")
    }

    func testCoercesNumericRepsAndStringSets() throws {
        // The model emitted reps as a number and sets as a string — both should coerce.
        let messy = #"{"title":"Coerce","workouts":[{"title":"A","exercises":[{"name":"Row","sets":"4","reps":10}]}]}"#
        let dto = try PlanJSONParser.parse(messy)
        let ex = try XCTUnwrap(dto.workouts.first?.exercises.first)
        XCTAssertEqual(ex.sets, 4)
        XCTAssertEqual(ex.reps, "10")
    }

    func testThrowsWhenNoJSON() {
        XCTAssertThrowsError(try PlanJSONParser.parse("I cannot help with that.")) { error in
            XCTAssertEqual(error as? PlanParsingError, .noJSONFound)
        }
    }

    func testThrowsOnEmptyPlan() {
        XCTAssertThrowsError(try PlanJSONParser.parse(#"{"title":"","workouts":[]}"#)) { error in
            XCTAssertEqual(error as? PlanParsingError, .emptyPlan)
        }
    }
}

final class PromptBuilderTests: XCTestCase {
    func testGeneratePromptIncludesIntakeAndSchema() {
        let intake = PlanIntake(
            goal: "hypertrophy", level: "intermediate", daysPerWeek: 4,
            sessionMinutes: 60, weeks: 6, equipment: ["dumbbells"],
            focusAreas: ["upper body"], limitations: "left knee", language: "zh-Hans"
        )
        let prompt = PromptBuilder.generatePlanPrompt(from: intake)
        XCTAssertTrue(prompt.contains("hypertrophy"))
        XCTAssertTrue(prompt.contains("left knee"))
        XCTAssertTrue(prompt.contains("Simplified Chinese"))
        XCTAssertTrue(prompt.contains("\"workouts\""))
        XCTAssertTrue(prompt.contains("\"language\": \"zh-Hans\""))
    }

    func testImportPromptEmbedsRawText() {
        let prompt = PromptBuilder.structureImportedTextPrompt(rawText: "Day 1: Bench 5x5", language: "en")
        XCTAssertTrue(prompt.contains("Day 1: Bench 5x5"))
        XCTAssertTrue(prompt.contains("English"))
    }
}

final class DocxBodyParserTests: XCTestCase {
    func testExtractsParagraphText() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:r><w:t>Push Day</w:t></w:r></w:p>
            <w:p><w:r><w:t>Bench Press</w:t></w:r><w:r><w:t xml:space="preserve"> 5x5</w:t></w:r></w:p>
            <w:p><w:r><w:t>Rest</w:t></w:r><w:r><w:tab/></w:r><w:r><w:t>90s</w:t></w:r></w:p>
          </w:body>
        </w:document>
        """
        let text = DocxBodyParser.plainText(fromDocumentXML: xml)
        XCTAssertEqual(text, "Push Day\nBench Press 5x5\nRest\t90s")
    }

    func testEmptyDocumentYieldsEmptyString() {
        let xml = "<w:document xmlns:w=\"x\"><w:body/></w:document>"
        XCTAssertEqual(DocxBodyParser.plainText(fromDocumentXML: xml), "")
    }
}
