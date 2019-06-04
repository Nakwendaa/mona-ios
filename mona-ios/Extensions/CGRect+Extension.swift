//
//  CGRect+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-01.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreGraphics

extension CGRect {
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.remainder.origin.x += 1
            slices.remainder.size.width -= 1
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += 1
            slices.remainder.size.height -= 1
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
    
    func divided(numberOfSlices: Int, spacing: CGFloat, from fromEdge: CGRectEdge) -> [CGRect] {
        let dimension: CGFloat
        let totalSpacing = CGFloat(numberOfSlices - 1) * spacing
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width - totalSpacing
        case .minYEdge, .maxYEdge:
            dimension = self.size.height - totalSpacing
        }
        
        let fraction = CGFloat(1.0) / CGFloat(numberOfSlices)
        let distance = (dimension * fraction).rounded(.up)
        
        var result = [CGRect]()
        for i in 0..<numberOfSlices {
            let rect : CGRect
            switch fromEdge {
            case .minXEdge, .maxXEdge:
                rect = CGRect(x: x + CGFloat(i) * (distance + spacing), y: y, width: distance, height: height)
            case .minYEdge, .maxYEdge:
                rect = CGRect(x: x, y: y + CGFloat(i) * (distance + spacing), width: width, height: distance)
            }
            result.append(rect)
        }
        
        switch fromEdge {
        case .maxXEdge, .maxYEdge:
            return result.reversed()
        case .minXEdge, .minYEdge:
            return result
        }
        
    }
}
