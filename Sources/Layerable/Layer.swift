import Foundation
import QuartzCore

class Layer : Layerable
{
    var position: CGPoint = CGPoint.zero
    var bounds: CGRect = CGRect.zero
    var anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var transform: Transform3D = Transform3D.identity
    var parentLayerable: Layerable? {
        return _superlayer
    }
    
    private weak var _superlayer: Layer?
    
    var sublayers: [Layer] = []
    
    func addSublayer(_ layer: Layer) {
        sublayers.append(layer)
        layer._superlayer = self
    }

    private var _caLayer: CALayer?
    var caLayer: CALayer {
        guard _caLayer == nil else {
            return _caLayer!
        }
        
        let layer = CALayer()
        
        layer.bounds = bounds
        layer.anchorPoint = anchorPoint
        layer.position = position
        let t = transform
        // CATransform3D is transposed relative to Transform3D
        layer.transform = CATransform3D(m11: t.m.0.0, m12: t.m.1.0, m13: t.m.2.0, m14: t.m.3.0,
                                        m21: t.m.0.1, m22: t.m.1.1, m23: t.m.2.1, m24: t.m.3.1,
                                        m31: t.m.0.2, m32: t.m.1.2, m33: t.m.2.2, m34: t.m.3.2,
                                        m41: t.m.0.3, m42: t.m.1.3, m43: t.m.2.3, m44: t.m.3.3)
        
        _caLayer = layer
        
        return layer
    }
}
