import Foundation
import CoreGraphics

private extension CGFloat {
    func isEqual( _ other: CGFloat, withinTolerance tolerance: CGFloat) -> Bool {
        return abs(self - other) < tolerance
    }
}

public struct Transform3D
{
    static let identity = Transform3D(((1.0, 0.0, 0.0, 0.0),
                                       (0.0, 1.0, 0.0, 0.0),
                                       (0.0, 0.0, 1.0, 0.0),
                                       (0.0, 0.0, 0.0, 1.0)))

    var m: ((CGFloat, CGFloat, CGFloat, CGFloat),
            (CGFloat, CGFloat, CGFloat, CGFloat),
            (CGFloat, CGFloat, CGFloat, CGFloat),
            (CGFloat, CGFloat, CGFloat, CGFloat))
    
    init(_ m: ((CGFloat, CGFloat, CGFloat, CGFloat),
               (CGFloat, CGFloat, CGFloat, CGFloat),
               (CGFloat, CGFloat, CGFloat, CGFloat),
               (CGFloat, CGFloat, CGFloat, CGFloat)))
    {
        self.m = m
    }
    
    init(translationX x: CGFloat, y: CGFloat, z: CGFloat) {
        self.init((
            (1.0, 0.0, 0.0, x),
            (0.0, 1.0, 0.0, y),
            (0.0, 0.0, 1.0, z),
            (0.0, 0.0, 0.0, 1.0)
        ))
    }

    init(scaleX x: CGFloat, y: CGFloat, z: CGFloat) {
        self.init((
            (x,   0.0, 0.0, 0.0),
            (0.0,   y, 0.0, 0.0),
            (0.0, 0.0,   z, 0.0),
            (0.0, 0.0, 0.0, 1.0)
        ))
    }

    init(rotationAngle angle: CGFloat, axis rotationAxis: Point3D)
    {
        let s: CGFloat = sin(-angle)
        let c: CGFloat = cos(-angle)
        let c1 = 1.0 - c
        let v = rotationAxis.normalized().v
        
        self.init((
            (c + c1 * v.0 * v.0, c1 * v.0 * v.1 + v.2 * s, c1 * v.0 * v.2 - v.1 * s, CGFloat(0.0)),
            (c1 * v.0 * v.1 - v.2 * s, c + c1 * v.1 * v.1, c1 * v.1 * v.2 + v.0 * s, CGFloat(0.0)),
            (c1 * v.0 * v.2 + v.1 * s, c1 * v.1 * v.2 - v.0 * s, c + c1 * v.2 * v.2, CGFloat(0.0)),
            (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(1.0))
        ))
    }
    
    init(xRotationAngle angle: CGFloat) {
        let s: CGFloat = sin(angle)
        let c: CGFloat = cos(angle)

        self.init((
            (1.0, 0.0, 0.0, 0.0),
            (0.0,   c,  -s, 0.0),
            (0.0,   s,   c, 0.0),
            (0.0, 0.0, 0.0, 1.0)
        ))
    }

    init(yRotationAngle angle: CGFloat) {
        let s: CGFloat = sin(angle)
        let c: CGFloat = cos(angle)

        self.init((
            (  c, 0.0,   s, 0.0),
            (0.0, 1.0, 0.0, 0.0),
            ( -s, 0.0,   c, 0.0),
            (0.0, 0.0, 0.0, 1.0)
        ))
    }

    init(zRotationAngle angle: CGFloat) {
        let s: CGFloat = sin(angle)
        let c: CGFloat = cos(angle)
        
        self.init((
            (  c,  -s, 0.0, 0.0),
            (  s,   c, 0.0, 0.0),
            (0.0, 0.0, 1.0, 0.0),
            (0.0, 0.0, 0.0, 1.0)
        ))
    }
    
    static func ==(_ lhs: Transform3D, rhs: Transform3D) -> Bool {
        return (
            lhs.m.0 == rhs.m.0 &&
            lhs.m.1 == rhs.m.1 &&
            lhs.m.2 == rhs.m.2 &&
            lhs.m.3 == rhs.m.3
        )
    }
    
    func translatedBy(x: CGFloat, y: CGFloat, z: CGFloat) -> Transform3D {
        return self * Transform3D(translationX: x, y: y, z: z)
    }

    func rotatedBy(angle: CGFloat, axis: Point3D) -> Transform3D {
        return self * Transform3D(rotationAngle: angle, axis: axis)
    }

    func scaledBy(x: CGFloat, y: CGFloat, z: CGFloat) -> Transform3D {
        return self * Transform3D(scaleX: x, y: y, z: z)
    }
    
    func isEqual(_ other: Transform3D, withinTolerance tolerance: CGFloat) -> Bool {
        return (self.m.0.0.isEqual(other.m.0.0, withinTolerance: tolerance) &&
                self.m.0.1.isEqual(other.m.0.1, withinTolerance: tolerance) &&
                self.m.0.2.isEqual(other.m.0.2, withinTolerance: tolerance) &&
                self.m.0.3.isEqual(other.m.0.3, withinTolerance: tolerance) &&
    
                self.m.1.0.isEqual(other.m.1.0, withinTolerance: tolerance) &&
                self.m.1.1.isEqual(other.m.1.1, withinTolerance: tolerance) &&
                self.m.1.2.isEqual(other.m.1.2, withinTolerance: tolerance) &&
                self.m.1.3.isEqual(other.m.1.3, withinTolerance: tolerance) &&

                self.m.2.0.isEqual(other.m.2.0, withinTolerance: tolerance) &&
                self.m.2.1.isEqual(other.m.2.1, withinTolerance: tolerance) &&
                self.m.2.2.isEqual(other.m.2.2, withinTolerance: tolerance) &&
                self.m.2.3.isEqual(other.m.2.3, withinTolerance: tolerance) &&

                self.m.3.0.isEqual(other.m.3.0, withinTolerance: tolerance) &&
                self.m.3.1.isEqual(other.m.3.1, withinTolerance: tolerance) &&
                self.m.3.2.isEqual(other.m.3.2, withinTolerance: tolerance) &&
                self.m.3.3.isEqual(other.m.3.3, withinTolerance: tolerance)
        )
    }
    
    func is3x3() -> Bool {
        return m.3.0 == 0.0 && m.3.1 == 0.0 && m.3.2 == 0.0 && m.3.3 == 1.0
    }
    
    func is2x2() -> Bool {
        return (is3x3() && m.2.0 == 0.0 && m.2.1 == 0.0 && m.2.2 == 1.0 && m.2.3 == 0.0 &&
                m.0.2 == 0.0 && m.1.2 == 0)
    }
    
    var determinant: CGFloat {
        if is3x3() {
            return (  m.0.0 * m.1.1 * m.2.2 + m.1.0 * m.2.1 * m.0.2 + m.2.0 * m.0.1 * m.1.2
                    - m.0.2 * m.1.1 * m.2.0 - m.1.2 * m.2.1 * m.0.0 - m.2.2 * m.0.1 * m.1.0)
        }
        else {
            fatalError("4x4 determinant not yet implemented")
        }
    }

    func column3(_ i: Int) -> Point3D {
        switch i {
        case 0: return Point3D((m.0.0, m.1.0, m.2.0))
        case 1: return Point3D((m.0.1, m.1.1, m.2.1))
        case 2: return Point3D((m.0.2, m.1.2, m.2.2))
        case 3: return Point3D((m.0.3, m.1.3, m.2.3))
            
        default:
            fatalError("Column \(i) is out of range 0...3")
        }
    }
    
    // Decompose transform into Rotation, Scale and Translation
    func decompose() -> (Transform3D, Point3D, Point3D) {
        let translation = Point3D((m.0.3, m.1.3, m.2.3))
        
        let sx = column3(0).length
        let sy = column3(1).length
        let sz = column3(2).length
        
        let scale = Point3D((sx, sy, sz))
        
        let rsx = 1.0 / sx
        let rsy = 1.0 / sy
        let rsz = 1.0 / sz

        let rotation = Transform3D(((m.0.0 * rsx, m.0.1 * rsy, m.0.2 * rsz, 0.0),
                                    (m.1.0 * rsx, m.1.1 * rsy, m.1.2 * rsz, 0.0),
                                    (m.2.0 * rsx, m.2.1 * rsy, m.2.2 * rsz, 0.0),
                                    (        0.0,         0.0,         0.0, 1.0)))
        
        return (rotation, scale, translation)
    }
    
    // Return the angle of rotation about the x-axis
    func xAngle() -> CGFloat
    {
        return atan2(m.2.1, m.2.2)
    }

    // Return the angle of rotation about the y-axis
    func yAngle() -> CGFloat
    {
        return atan2(-m.2.0, sqrt(m.2.1 * m.2.1 + m.2.2 * m.2.2))
    }

    // Return the angle of rotation about the z-axis
    func zAngle() -> CGFloat
    {
        return atan2(m.1.0, m.0.0)
    }
    
    func transposed() -> Transform3D {
        return Transform3D(((m.0.0, m.1.0, m.2.0, m.3.0),
                            (m.0.1, m.1.1, m.2.1, m.3.1),
                            (m.0.2, m.1.2, m.2.2, m.3.2),
                            (m.0.3, m.1.3, m.2.3, m.3.3)))
    }
    
    func inverted() -> Transform3D? {
        if is3x3() {
            if is2x2()
            {
                // 2x2
                let det = m.0.0 * m.1.1 - m.1.0 * m.0.1
                if det == 0.0 {
                    return nil
                }
                
                let recpDet = 1.0 / det
                let a =  m.1.1 * recpDet
                let b = -m.0.1 * recpDet
                let c = -m.1.0 * recpDet
                let d =  m.0.0 * recpDet
                
                return Transform3D(((  a,   b, 0.0, -(a * m.0.3 + b * m.1.3)),
                                    (  c,   d, 0.0, -(c * m.0.3 + d * m.1.3)),
                                    (0.0, 0.0, 1.0, -m.2.3),
                                    (0.0, 0.0, 0.0,    1.0)))
            }
            else {
                // 3x3
                let det = self.determinant
                if det == 0.0 {
                    return nil
                }
                
                let recpDet = 1.0 / det
                let a =  (m.1.1 * m.2.2 - m.2.1 * m.1.2) * recpDet
                let b = -(m.0.1 * m.2.2 - m.0.2 * m.2.1) * recpDet
                let c =  (m.0.1 * m.1.2 - m.0.2 * m.1.1) * recpDet
                let d = -(m.1.0 * m.2.2 - m.1.2 * m.2.0) * recpDet
                let e =  (m.0.0 * m.2.2 - m.0.2 * m.2.0) * recpDet
                let f = -(m.0.0 * m.1.2 - m.0.2 * m.1.0) * recpDet
                let g =  (m.1.0 * m.2.1 - m.1.1 * m.2.0) * recpDet
                let h = -(m.0.0 * m.2.1 - m.0.1 * m.2.0) * recpDet
                let i =  (m.0.0 * m.1.1 - m.0.1 * m.1.0) * recpDet
                
                let inverse3x3 = Transform3D(((a, b, c, 0.0),
                                              (d, e, f, 0.0),
                                              (g, h, i, 0.0),
                                              (0.0, 0.0, 0.0, 1.0)))
                
                let translation = Point3D((m.0.3, m.1.3, m.2.3))
                
                let inverseTranslation = inverse3x3 * translation
                
                return Transform3D(((a, b, c, -inverseTranslation.x),
                                    (d, e, f, -inverseTranslation.y),
                                    (g, h, i, -inverseTranslation.z),
                                    (0.0, 0.0, 0.0, 1.0)))
            }
        }
        else {
            fatalError("4x4 inverse not yet implemented")
        }
    }
    
    static func *(t: Transform3D, a: CGFloat) -> Transform3D {
        return Transform3D(((t.m.0.0 * a, t.m.0.1 * a, t.m.0.2 * a, t.m.0.3 * a),
                            (t.m.1.0 * a, t.m.1.1 * a, t.m.1.2 * a, t.m.1.3 * a),
                            (t.m.2.0 * a, t.m.2.1 * a, t.m.2.2 * a, t.m.2.3 * a),
                            (t.m.3.0 * a, t.m.3.1 * a, t.m.3.2 * a, t.m.3.3 * a)))
    }

    static func *(a: CGFloat, t: Transform3D) -> Transform3D {
        return t * a
    }
    
    static prefix func -(t: Transform3D) -> Transform3D {
        return Transform3D(((-t.m.0.0, -t.m.0.1, -t.m.0.2, -t.m.0.3),
                            (-t.m.1.0, -t.m.1.1, -t.m.1.2, -t.m.1.3),
                            (-t.m.2.0, -t.m.2.1, -t.m.2.2, -t.m.2.3),
                            (-t.m.3.0, -t.m.3.1, -t.m.3.2, -t.m.3.3)))
    }
}

public struct Point3D
{
    var v: (CGFloat, CGFloat, CGFloat)
    
    var x: CGFloat {
        get { return v.0 }
        set { v.0 = newValue }
    }
    
    var y: CGFloat {
        get { return v.1 }
        set { v.1 = newValue }
    }
    
    var z: CGFloat {
        get { return v.2 }
        set { v.2 = newValue }
    }

    init(_ v: (CGFloat, CGFloat, CGFloat))
    {
        self.v = v
    }
    
    init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat)
    {
        self.init((x, y, z))
    }
    
    var length: CGFloat {
        return sqrt(v.0 * v.0 + v.1 * v.1 + v.2 * v.2)
    }
    
    func normalized() -> Point3D {
        return self / length
    }
    
    static func *(_ p: Point3D, _ a: CGFloat) -> Point3D {
        return Point3D((p.v.0 * a, p.v.1 * a, p.v.2 * a))
    }

    static func *(_ a: CGFloat, _ p: Point3D) -> Point3D {
        return p * a
    }

    static func /(_ p: Point3D, _ a: CGFloat) -> Point3D {
        let recp = 1.0 / a
        return p * recp
    }
    
    static func +(_ lhs: Point3D, _ rhs: Point3D) -> Point3D {
        return Point3D((lhs.x + rhs.x, lhs.y + rhs.y, lhs.z - rhs.z))
    }

    static func -(_ lhs: Point3D, _ rhs: Point3D) -> Point3D {
        return Point3D((lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z))
    }

    static func ==(_ lhs: Point3D, rhs: Point3D) -> Bool {
        return lhs.v == rhs.v
    }
}


public struct Point4D
{
    var v: (CGFloat, CGFloat, CGFloat, CGFloat)
    
    var x: CGFloat {
        get { return v.0 }
        set { v.0 = newValue }
    }
    
    var y: CGFloat {
        get { return v.1 }
        set { v.1 = newValue }
    }
    
    var z: CGFloat {
        get { return v.2 }
        set { v.2 = newValue }
    }

    var w: CGFloat {
        get { return v.3 }
        set { v.3 = newValue }
    }

    init(_ v: (CGFloat, CGFloat, CGFloat, CGFloat))
    {
        self.v = v
    }
    
    init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat, _ w: CGFloat)
    {
        self.init((x, y, z, w))
    }
    
    static func *(_ p: Point4D, _ a: CGFloat) -> Point4D {
        return Point4D((p.v.0 * a, p.v.1 * a, p.v.2 * a, p.v.3 * a))
    }
    
    static func *(_ a: CGFloat, _ p: Point4D) -> Point4D {
        return p * a
    }

    static func ==(_ lhs: Point4D, rhs: Point4D) -> Bool {
        return lhs.v == rhs.v
    }
}

func *(_ t1: Transform3D, _ t2: Transform3D) -> Transform3D {
    return Transform3D(((t1.m.0.0 * t2.m.0.0 + t1.m.0.1 * t2.m.1.0 + t1.m.0.2 * t2.m.2.0 + t1.m.0.3 * t2.m.3.0,
                         t1.m.0.0 * t2.m.0.1 + t1.m.0.1 * t2.m.1.1 + t1.m.0.2 * t2.m.2.1 + t1.m.0.3 * t2.m.3.1,
                         t1.m.0.0 * t2.m.0.2 + t1.m.0.1 * t2.m.1.2 + t1.m.0.2 * t2.m.2.2 + t1.m.0.3 * t2.m.3.2,
                         t1.m.0.0 * t2.m.0.3 + t1.m.0.1 * t2.m.1.3 + t1.m.0.2 * t2.m.2.3 + t1.m.0.3 * t2.m.3.3),
                        
                        (t1.m.1.0 * t2.m.0.0 + t1.m.1.1 * t2.m.1.0 + t1.m.1.2 * t2.m.2.0 + t1.m.1.3 * t2.m.3.0,
                         t1.m.1.0 * t2.m.0.1 + t1.m.1.1 * t2.m.1.1 + t1.m.1.2 * t2.m.2.1 + t1.m.1.3 * t2.m.3.1,
                         t1.m.1.0 * t2.m.0.2 + t1.m.1.1 * t2.m.1.2 + t1.m.1.2 * t2.m.2.2 + t1.m.1.3 * t2.m.3.2,
                         t1.m.1.0 * t2.m.0.3 + t1.m.1.1 * t2.m.1.3 + t1.m.1.2 * t2.m.2.3 + t1.m.1.3 * t2.m.3.3),
                        
                        (t1.m.2.0 * t2.m.0.0 + t1.m.2.1 * t2.m.1.0 + t1.m.2.2 * t2.m.2.0 + t1.m.2.3 * t2.m.3.0,
                         t1.m.2.0 * t2.m.0.1 + t1.m.2.1 * t2.m.1.1 + t1.m.2.2 * t2.m.2.1 + t1.m.2.3 * t2.m.3.1,
                         t1.m.2.0 * t2.m.0.2 + t1.m.2.1 * t2.m.1.2 + t1.m.2.2 * t2.m.2.2 + t1.m.2.3 * t2.m.3.2,
                         t1.m.2.0 * t2.m.0.3 + t1.m.2.1 * t2.m.1.3 + t1.m.2.2 * t2.m.2.3 + t1.m.2.3 * t2.m.3.3),
                        
                        (t1.m.3.0 * t2.m.0.0 + t1.m.3.1 * t2.m.1.0 + t1.m.3.2 * t2.m.2.0 + t1.m.3.3 * t2.m.3.0,
                         t1.m.3.0 * t2.m.0.1 + t1.m.3.1 * t2.m.1.1 + t1.m.3.2 * t2.m.2.1 + t1.m.3.3 * t2.m.3.1,
                         t1.m.3.0 * t2.m.0.2 + t1.m.3.1 * t2.m.1.2 + t1.m.3.2 * t2.m.2.2 + t1.m.3.3 * t2.m.3.2,
                         t1.m.3.0 * t2.m.0.3 + t1.m.3.1 * t2.m.1.3 + t1.m.3.2 * t2.m.2.3 + t1.m.3.3 * t2.m.3.3)))
}

func *(_ t: Transform3D, _ p: Point4D) -> Point4D {
    return Point4D((t.m.0.0 * p.v.0 + t.m.0.1 * p.v.1 + t.m.0.2 * p.v.2 + t.m.0.3 * p.v.3,
                    t.m.1.0 * p.v.0 + t.m.1.1 * p.v.1 + t.m.1.2 * p.v.2 + t.m.1.3 * p.v.3,
                    t.m.2.0 * p.v.0 + t.m.2.1 * p.v.1 + t.m.2.2 * p.v.2 + t.m.2.3 * p.v.3,
                    t.m.3.0 * p.v.0 + t.m.3.1 * p.v.1 + t.m.3.2 * p.v.2 + t.m.3.3 * p.v.3))
}

func *(_ t: Transform3D, _ p: Point3D) -> Point3D {
    let p4 = t * Point4D((p.v.0, p.v.1, p.v.2, 1.0))
    
    let recpW = 1.0 / p4.w
    return Point3D((p4.v.0, p4.v.1, p4.v.2)) * recpW
}
