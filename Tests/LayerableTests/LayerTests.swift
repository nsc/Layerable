import XCTest

@testable import Layerable

class LayerTests: XCTestCase {

    func test_sharedAncestor_whenLayersAreTheSame_returnsThatLayer() {
        let layer = Layer()
        let layer2 = layer
        
        let ancestor = layer.sharedAncestor(with: layer2)
        
        XCTAssert(ancestor != nil && ancestor! === layer)
    }

    func test_sharedAncestor_withUnrelatedLayers_returnsNil() {
        let layer = Layer()
        let layer2 = Layer()
        
        let ancestor = layer.sharedAncestor(with: layer2)
        
        XCTAssert(ancestor == nil)
    }

    func test_sharedAncestor_withDirectCommonSuperlayer_returnsSuperlayer() {
        let layer = Layer()
        let layer2 = Layer()
        let superlayer = Layer()
        superlayer.addSublayer(layer)
        superlayer.addSublayer(layer2)
        
        let ancestor = layer.sharedAncestor(with: layer2)
        
        XCTAssert(ancestor != nil && ancestor! === superlayer)
    }

    func test_sharedAncestor_withOneBeingTheSuperlayerOfTheOther_returnsThatSuperlayer() {
        let sublayer = Layer()
        let superlayer = Layer()
        superlayer.addSublayer(sublayer)
        
        let ancestor = superlayer.sharedAncestor(with: sublayer)
        
        XCTAssert(ancestor != nil && ancestor! === superlayer)
    }
    
    func test_sharedAncestor_withOneBeingTheSublayerOfTheOther_returnsTheSuperlayer() {
        let sublayer = Layer()
        let superlayer = Layer()
        superlayer.addSublayer(sublayer)
        
        let ancestor = sublayer.sharedAncestor(with: superlayer)
        
        XCTAssert(ancestor != nil && ancestor! === superlayer)
    }

    func test_sharedAncestor_withTwoLayersDeepInAHierarchyWithDifferentDepths_returnsTheRootLayer() {
        let root = Layer()
        let sublayer1 = Layer()
        let sublayer2 = Layer()
        
        let a = Layer()
        let b = Layer()
        let c = Layer()

        root.addSublayer(a)
        a.addSublayer(b)
        b.addSublayer(sublayer1)
        
        root.addSublayer(c)
        c.addSublayer(sublayer2)
        
        let ancestor = sublayer1.sharedAncestor(with: sublayer2)
        
        XCTAssert(ancestor != nil && ancestor! === root)
    }

    func test_sharedAncestor_withTwoLayersDeepSharingMoreThanOneAncestor_returnsTheDeepestAncestor() {
        let root = Layer()
        let subroot = Layer()
        let sublayer1 = Layer()
        let sublayer2 = Layer()
        
        let a = Layer()
        let b = Layer()
        let c = Layer()
        
        subroot.addSublayer(a)
        a.addSublayer(b)
        b.addSublayer(sublayer1)
        
        subroot.addSublayer(c)
        c.addSublayer(sublayer2)
        
        root.addSublayer(subroot)
        
        let ancestor = sublayer1.sharedAncestor(with: sublayer2)
        
        XCTAssert(ancestor != nil && ancestor! === subroot)
    }

    func test_sharedAncestor_withTwoLayersDeepInTwoUnrelatedHierarchies_returnsNil() {
        let sublayer1 = Layer()
        let sublayer2 = Layer()
        
        let a = Layer()
        let b = Layer()
        let c = Layer()
        
        a.addSublayer(b)
        b.addSublayer(sublayer1)
        
        c.addSublayer(sublayer2)
        
        let ancestor = sublayer1.sharedAncestor(with: sublayer2)
        
        XCTAssert(ancestor == nil)
    }

}
