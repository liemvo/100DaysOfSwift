import UIKit

extension String {
	subscript(i: Int) -> String {
		return String(self[index(startIndex, offsetBy: i)])
	}
	
	func deletingPrefix(_ prefix: String) -> String {
		guard self.hasPrefix(prefix) else { return self }
		return String(self.dropFirst(prefix.count))
	}
	
	func deletingSuffix(_ suffix: String) -> String {
		guard self.hasSuffix(suffix) else { return self }
		return String(self.dropLast(suffix.count))
	}
	
	var capitalizedFirst: String {
		guard let firstLetter =  self.first else { return "" }
		return firstLetter.uppercased() + self.dropLast()
	}
	
	func containsAny(of array: [String]) -> Bool {
		for item in array {
			if self.contains(item) {
				return true
			}
		}
		
		return false
	}
	
	func withPrefix(_ prefix: String) -> String {
		if self.hasPrefix(prefix) { return self }
		return prefix+self
	}
	
	func isNumeric() -> Bool {
		guard Double(self) != nil else { return false }
		return true
	}
	
	func toArrayByLine() -> [String] {
		return self.components(separatedBy: "\n")
	}
}

