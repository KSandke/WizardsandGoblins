//
//  CGExtensions.swift
//  WizardsandGoblins
//

import CoreGraphics

extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        return length > 0 ? CGVector(dx: dx / length, dy: dy / length) : .zero
    }
}

extension CGPoint {
    /// Returns a point that is a given distance towards a target point.
    func pointTowards(target: CGPoint, distance: CGFloat) -> CGPoint {
        let dx = target.x - self.x
        let dy = target.y - self.y
        let length = sqrt(dx * dx + dy * dy)

        guard length > 0 else { return self }

        let scale = distance / length
        let newX = self.x + dx * scale
        let newY = self.y + dy * scale

        return CGPoint(x: newX, y: newY)
    }

    /// Returns the distance between this point and another point.
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Returns a normalized vector (length of 1) pointing in the same direction.
    func normalized() -> CGPoint {
        let length = sqrt(self.x * self.x + self.y * self.y)
        guard length > 0 else { return CGPoint.zero }
        return CGPoint(x: self.x / length, y: self.y / length)
    }

    /// Adds two CGPoint values and returns the result as a new CGPoint.
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    /// Subtracts one CGPoint from another and returns the result as a new CGPoint.
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
}