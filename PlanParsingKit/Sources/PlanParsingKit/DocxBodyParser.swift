import Foundation

/// Extracts readable plain text from the bytes of a WordprocessingML `word/document.xml`.
///
/// The zip extraction (a `.docx` is a zip archive) lives in the app layer with
/// ZIPFoundation; this stays pure Foundation (XMLParser) so it is unit-testable on any
/// platform. WordprocessingML keeps run text in `<w:t>`, paragraphs in `<w:p>`,
/// tabs in `<w:tab/>` and line breaks in `<w:br/>`.
public enum DocxBodyParser {

    public static func plainText(fromDocumentXML data: Data) -> String {
        let delegate = Collector()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        return delegate.finishedText()
    }

    public static func plainText(fromDocumentXML xml: String) -> String {
        plainText(fromDocumentXML: Data(xml.utf8))
    }

    private final class Collector: NSObject, XMLParserDelegate {
        private var paragraphs: [String] = []
        private var current = ""
        private var capturing = false   // inside a <w:t> run

        func parser(_ parser: XMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: [String: String] = [:]) {
            switch localName(elementName) {
            case "t": capturing = true
            case "tab": current += "\t"
            case "br", "cr": current += "\n"
            default: break
            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            if capturing { current += string }
        }

        func parser(_ parser: XMLParser,
                    didEndElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?) {
            switch localName(elementName) {
            case "t":
                capturing = false
            case "p":
                paragraphs.append(current)
                current = ""
            default:
                break
            }
        }

        func finishedText() -> String {
            if !current.isEmpty { paragraphs.append(current); current = "" }
            return paragraphs
                .joined(separator: "\n")
                .replacingOccurrences(of: "[ \\t]+\\n", with: "\n", options: .regularExpression)
                .replacingOccurrences(of: "\\n{3,}", with: "\n\n", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        /// XMLParser reports namespaced tags as "w:t" (namespace processing is off by
        /// default); strip the prefix.
        private func localName(_ elementName: String) -> String {
            if let colon = elementName.firstIndex(of: ":") {
                return String(elementName[elementName.index(after: colon)...])
            }
            return elementName
        }
    }
}
