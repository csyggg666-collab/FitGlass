import Foundation
import PDFKit
import ZIPFoundation
import PlanParsingKit

enum DocumentImportError: Error, LocalizedError {
    case unsupported
    case unreadable
    case empty

    var errorDescription: String? {
        switch self {
        case .unsupported: return "Unsupported file type. Use PDF or Word (.docx)."
        case .unreadable:  return "Couldn't open the document."
        case .empty:       return "No readable text was found in the document."
        }
    }
}

/// Extracts plain text from an imported PDF or Word document. PDF uses PDFKit;
/// `.docx` is unzipped with ZIPFoundation and its `word/document.xml` is parsed by
/// the pure-Foundation `DocxBodyParser` in PlanParsingKit.
enum DocumentImporter {
    static func extractText(from url: URL) throws -> String {
        switch url.pathExtension.lowercased() {
        case "pdf":  return try extractPDF(url)
        case "docx": return try extractDocx(url)
        default:     throw DocumentImportError.unsupported
        }
    }

    private static func extractPDF(_ url: URL) throws -> String {
        guard let document = PDFDocument(url: url) else { throw DocumentImportError.unreadable }
        var text = ""
        for index in 0..<document.pageCount {
            if let page = document.page(at: index), let pageText = page.string {
                text += pageText + "\n"
            }
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DocumentImportError.empty }
        return trimmed
    }

    private static func extractDocx(_ url: URL) throws -> String {
        guard let archive = Archive(url: url, accessMode: .read) else {
            throw DocumentImportError.unreadable
        }
        guard let entry = archive["word/document.xml"] else {
            throw DocumentImportError.unreadable
        }
        var data = Data()
        _ = try archive.extract(entry) { data.append($0) }
        guard !data.isEmpty else { throw DocumentImportError.empty }
        let text = DocxBodyParser.plainText(fromDocumentXML: data)
        guard !text.isEmpty else { throw DocumentImportError.empty }
        return text
    }
}
