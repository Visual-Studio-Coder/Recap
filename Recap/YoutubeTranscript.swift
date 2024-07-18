import Foundation

public class YouTubeTranscript {
    
    // Define possible errors
    public enum YouTubeTranscriptError: Error {
        case invalidURL
        case networkError(Error)
        case parsingError
        case extractionError
        case unknownError
    }
    
    // Fetch transcript for a given video ID
    public static func fetchTranscript(for videoId: String) async throws -> String {
        guard let videoURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)") else {
            throw YouTubeTranscriptError.invalidURL
        }
        
        var videoRequest = URLRequest(url: videoURL)
        videoRequest.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36", forHTTPHeaderField: "User-Agent")
        
        do {
            let (videoData, _) = try await URLSession.shared.data(for: videoRequest)
            
            guard let videoPageContent = String(data: videoData, encoding: .utf8) else {
                throw YouTubeTranscriptError.parsingError
            }
            
            // Extract the timedtext URL from the video page content
            guard let timedtextURL = extractTimedtextURL(from: videoPageContent) else {
                throw YouTubeTranscriptError.extractionError
            }
            
            // Decode the extracted URL
            guard let decodedURL = decodeURL(timedtextURL) else {
                throw YouTubeTranscriptError.extractionError
            }
            
            var transcriptRequest = URLRequest(url: decodedURL)
            transcriptRequest.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36", forHTTPHeaderField: "User-Agent")
            
            let (transcriptData, _) = try await URLSession.shared.data(for: transcriptRequest)
            
            // Print out the raw request data for debugging
            if let rawString = String(data: transcriptData, encoding: .utf8) {
                print("Raw request data: \(rawString)")
            } else {
                print("Failed to convert raw data to string")
            }
            
            guard let transcript = parseTranscript(from: transcriptData) else {
                throw YouTubeTranscriptError.parsingError
            }
            return transcript
        } catch {
            throw YouTubeTranscriptError.networkError(error)
        }
    }
    
    // Extract the timedtext URL from the video page content
    private static func extractTimedtextURL(from content: String) -> String? {
        let pattern = "\"(https://www.youtube.com/api/timedtext[^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = content as NSString
        let results = regex?.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results?.first, let range = Range(match.range(at: 1), in: content) {
            let urlString = String(content[range])
            return urlString
        }
        return nil
    }
    
    // Decode the URL
    private static func decodeURL(_ urlString: String) -> URL? {
        let decodedString = urlString.replacingOccurrences(of: "\\u0026", with: "&")
        return URL(string: decodedString)
    }
    
    // Parse the transcript from the data
    private static func parseTranscript(from data: Data) -> String? {
        // Parse the XML data to extract the transcript text
        let parser = XMLParser(data: data)
        let transcriptParserDelegate = TranscriptParserDelegate()
        parser.delegate = transcriptParserDelegate
        
        if parser.parse() {
            return transcriptParserDelegate.transcript
        } else {
            return nil
        }
    }
}

// XML Parser Delegate to handle parsing of YouTube transcript XML
private class TranscriptParserDelegate: NSObject, XMLParserDelegate {
    var transcript: String = ""
    private var currentElement = ""
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "text" {
            transcript += string + " "
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = ""
    }
}