import Foundation
import CoreGraphics

protocol Layerable : class {
    var position: CGPoint { get }
    var bounds: CGRect { get }
    var anchorPoint: CGPoint { get }
    var transform: Transform3D { get }
    var parentLayerable: Layerable? { get }
}

extension Layerable {
    func convert(_ point: CGPoint, to layerable: Layerable) -> CGPoint? {
        guard let t = transform(to: layerable) else {
            return nil
        }
        
        let p = t * Point3D((point.x, point.y, 0.0))
        
        return CGPoint(x: p.x, y: p.y)
    }
    
    func convert(_ point: CGPoint, from layerable: Layerable) -> CGPoint? {
        guard let t = transform(from: layerable) else {
            return nil
        }
        
        let p = t * Point3D((point.x, point.y, 0.0))
        
        return CGPoint(x: p.x, y: p.y)
    }
    
    func transform(to layerable: Layerable?) -> Transform3D? {
        guard let layerable = layerable else {
            return transformToAncestor(nil)
        }
        
        guard let ancestor = sharedAncestor(with: layerable) else {
            return nil
        }
        
        if self === ancestor {
            guard self !== layerable else {
                return Transform3D.identity
            }
            
            return self.transformToDescendant(layerable)
        }
        
        if layerable === ancestor {
            return self.transformToAncestor(layerable)
        }
        
        // layerable and self are not in a direct chain
        let transformUp   = transformToAncestor(ancestor)
        let transformDown = ancestor.transformToDescendant(layerable)
        
        return transformDown * transformUp
    }
    
    func transform(from layerable: Layerable?) -> Transform3D? {
        guard let layerable = layerable else {
            return transformFromAncestor(nil)
        }
        
        guard let ancestor = sharedAncestor(with: layerable) else {
            return nil
        }
        
        if self === ancestor {
            guard self !== layerable else {
                return Transform3D.identity
            }
            
            return layerable.transformToAncestor(self)
        }
        
        if layerable === ancestor {
            return layerable.transformFromDescendant(self)
        }
        
        // layerable and self are not in a direct chain
        let transformUp   = layerable.transformToAncestor(ancestor)
        let transformDown = ancestor.transformToDescendant(self)
        
        return transformDown * transformUp
    }
    
    func transformToAncestor(_ ancestor: Layerable?) -> Transform3D {
        let layerable = self
        var transform = layerable.transformToParent()
        var parent = layerable.parentLayerable
        while parent !== ancestor && parent != nil {
            transform = parent!.transformToParent() * transform
            parent = parent!.parentLayerable
        }
        
        return transform
    }
    
    func transformFromAncestor(_ ancestor: Layerable?) -> Transform3D {
        return transformToAncestor(ancestor).inverted()!
    }
    
    func transformToDescendant(_ descendant: Layerable) -> Transform3D {
        let ancestor = self
        
        var layerable = descendant
        var transform = layerable.transformFromParent()
        while layerable !== ancestor {
            guard let parent = layerable.parentLayerable else {
                fatalError("transformToDescendant called with a layerable that is not actually a descendant")
            }
            
            layerable = parent
            transform = transform * layerable.transformFromParent()
        }
        
        return transform
    }
    
    func transformFromDescendant(_ descendant: Layerable) -> Transform3D {
        return transformToDescendant(descendant).inverted()!
    }
    
    func transformToParent() -> Transform3D {
        let t1 = Transform3D(translationX: position.x, y: position.y, z: 0.0)
        let t2 = Transform3D(translationX: -anchorPoint.x * bounds.width, y: -anchorPoint.y * bounds.height, z: 0.0)
        
        return t1 * transform * t2
    }
    
    func transformFromParent() -> Transform3D {
        guard let inverse = transform.inverted() else {
            fatalError("Could not invert transform")
        }
        
        let t1 = Transform3D(translationX: anchorPoint.x * bounds.size.width, y: anchorPoint.y * bounds.size.height, z: 0.0)
        let t2 = Transform3D(translationX: -position.x, y: -position.y, z: 0.0)
        
        return t1 * inverse * t2
    }
    
    func sharedAncestor(with layerable: Layerable) -> Layerable? {
        if self === layerable {
            return self
        }
        
        if let superlayer = layerable.parentLayerable {
            if self === superlayer {
                return superlayer
            }
        }
        
        if let parent = self.parentLayerable {
            if layerable === parent {
                return parent
            }
        }
        
        var layerable1: Layerable? = self.parentLayerable
        while layerable1 != nil {
            var layerable2: Layerable? = layerable
            while layerable2 != nil {
                if layerable1 === layerable2 {
                    return layerable1
                }
                
                layerable2 = layerable2?.parentLayerable
            }
            layerable1 = layerable1?.parentLayerable
        }
        
        return nil
    }

}
