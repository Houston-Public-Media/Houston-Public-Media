//
//  Copyright © 2020 Axinom. All rights reserved.
//
//  Utils
//

import Foundation
import SwiftUI
import RegexBuilder

extension URLSession {
	func decode<T: Decodable>(
		_ type: T.Type = T.self,
		from url: URL,
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
		dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
		dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .custom({ decoder in
			var string = try! decoder.singleValueContainer().decode(String.self)
			string.append(contentsOf: "Z")
			return try! Date.ISO8601FormatStyle(includingFractionalSeconds: false).parse(string)
		})
	) async throws  -> T {
		let (data, _) = try await data(from: url)

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = keyDecodingStrategy
		decoder.dataDecodingStrategy = dataDecodingStrategy
		decoder.dateDecodingStrategy = dateDecodingStrategy

		let decoded = try decoder.decode(T.self, from: data)
		return decoded
	}
}

func nowPlayingCleanup(nowPlaying: NowPlayingStation) -> String {
	var output = ""
	if nowPlaying.artist.contains("Houston Public Media") {
		output += nowPlaying.title
	} else {
		output += nowPlaying.artist + " - " + nowPlaying.title
	}
	return output
}

extension String {
	func htmlToMarkDown() -> String {
		
		var text = self
		
		var loop = true

		// Replace HTML comments, in the format <!-- ... comment ... -->
		// Stop looking for comments when none is found
		while loop {
			
			// Retrieve hyperlink
			let searchComment = Regex {
				Capture {
					
					// A comment in HTML starts with:
					"<!--"
					
					ZeroOrMore(.any, .reluctant)
					
					// A comment in HTML ends with:
					"-->"
				}
			}
			if let match = text.firstMatch(of: searchComment) {
				let (_, comment) = match.output
				text = text.replacing(comment, with: "")
			} else {
				loop = false
			}
		}

		// Replace line feeds with nothing, which is how HTML notation is read in the browsers
		text = self.replacing("\n", with: "")
		
		// Line breaks
		//text = text.replacing(/<div([ a-zA-Z\-0-9:;'"]+)?>/, with: "\n")
		//text = text.replacing("</div>", with: "")
		text = text.replacing("<p>", with: "")
		text = text.replacing("</p>", with: "")
		text = text.replacing("<br>", with: "\n")
		text = text.replacing("<span>", with: "")
		text = text.replacing("</span>", with: "")

		// Text formatting
		text = text.replacing("<strong>", with: "**")
		text = text.replacing("</strong>", with: "**")
		text = text.replacing("<b>", with: "**")
		text = text.replacing("</b>", with: "**")
		text = text.replacing("<em>", with: "*")
		text = text.replacing("</em>", with: "*")
		text = text.replacing("<i>", with: "*")
		text = text.replacing("</i>", with: "*")
		
		// Replace hyperlinks block
		
		loop = true
		
		// Stop looking for hyperlinks when none is found
		while loop {
			
			// Retrieve hyperlink
			let searchHyperlink = Regex {

				// A hyperlink that is embedded in an HTML tag in this format: <a... href="<hyperlink>"....>
				"<a"

				// There could be other attributes between <a... and href=...
				// .reluctant parameter: to stop matching after the first occurrence
				ZeroOrMore(.any)
				
				// We could have href="..., href ="..., href= "..., href = "...
				"href"
				ZeroOrMore(.any)
				"="
				ZeroOrMore(.any)
				"\""
				
				// Here is where the hyperlink (href) is captured
				Capture {
					ZeroOrMore(.any)
				}
				
				"\""

				// After href="<hyperlink>", there could be a ">" sign or other attributes
				ZeroOrMore(.any)
				">"
				
				// Here is where the linked text is captured
				Capture {
					ZeroOrMore(.any, .reluctant)
				}
				One("</a>")
			}
			.repetitionBehavior(.reluctant)
			
			if let match = text.firstMatch(of: searchHyperlink) {
				let (hyperlinkTag, href, content) = match.output
				let markDownLink = "[" + content + "](" + href + ")"
				text = text.replacing(hyperlinkTag, with: markDownLink)
			} else {
				loop = false
			}
		}
		
		loop = true
		
		// Stop looking for hyperlinks when none is found
		while loop {
			
			// Retrieve hyperlink
			let searchDiv = Regex {

				// A hyperlink that is embedded in an HTML tag in this format: <a... href="<hyperlink>"....>
				"<div"

				// There could be other attributes between <a... and href=...
				// .reluctant parameter: to stop matching after the first occurrence
				ZeroOrMore(.any)
				
				">"
				
				Capture {
					ZeroOrMore(.any, .reluctant)
				}
				One("</div>")
			}
			.repetitionBehavior(.reluctant)
			
			if let match = text.firstMatch(of: searchDiv) {
				let (divTag, content) = match.output
				text = text.replacing(divTag, with: content)
			} else {
				loop = false
			}
		}

		return text
	}
	private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")
	public func convertedToSlug() -> String {
		if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
			let urlComponents = latin.components(separatedBy: String.slugSafeCharacters.inverted)
			let result = urlComponents.filter { $0 != "" }.joined(separator: "-")

			if result.count > 0 {
				return result
			}
		}
		return ""
	}
}

func wpDateFormatter(date: Date?) -> String {
	guard let date = date else {
		return ""
	}
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "EEE, MMM d, yyyy @ hh:mm a"
	dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")

	return dateFormatter.string(from: date)
}

func currentDate() -> String {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "MMM d, yyyy"

	return dateFormatter.string(from: Date())
}
