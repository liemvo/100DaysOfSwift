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

extension UIView {
	func bounceOut(duration: TimeInterval) {
		UIView.animate(withDuration: duration) { [unowned self] in
			self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
		}
	}
}

extension Int {
	func times(closure: () -> Void) {
		guard self > 0 else { return }
		for _ in 0 ..< self {
			closure()
		}
	}
}

extension Array where Element: Comparable {
	mutating func remove(item: Element){
		if let location = self.firstIndex(of: item)  {
			self.remove(at: location)
		}
	}
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 60))
view.backgroundColor = .blue
view.bounceOut(duration: 24.0)


5.times {
	print("hello there")
}

var numbers = [4, 5, 6, 4, 9, 2]

numbers.remove(item: 4)

