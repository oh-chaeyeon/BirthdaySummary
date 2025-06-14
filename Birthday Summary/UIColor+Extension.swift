import UIKit

extension UIColor {
    func toHexString() -> String {
        guard let c = cgColor.components else { return "#000000" }
        let r = Int(c[0]*255), g = Int((c.count>1 ? c[1]:c[0])*255)
        let b = Int((c.count>2 ? c[2]:c[0])*255)
        return String(format:"#%02X%02X%02X", r,g,b)
    }

    convenience init?(hex: String) {
        var h = hex.trimmingCharacters(in:.whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let v = UInt32(h, radix:16) else { return nil }
        self.init(red: CGFloat((v>>16)&0xFF)/255,
                  green: CGFloat((v>>8)&0xFF)/255,
                  blue: CGFloat(v&0xFF)/255, alpha:1)
    }
}
