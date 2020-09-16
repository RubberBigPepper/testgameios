//
//  scnvector3extension.swift
//  testgame
//
//  Created by Albert on 16.09.2020.
//  Copyright © 2020 Albert. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3{//странно, что простейших операторов над векторами не реализовали. Реализуем сами!
    static func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z) //I think it's faster than left+(-right)
    }
    
    static prefix func -(right: SCNVector3) -> SCNVector3 {
        return right*(-1.0)
    }
    
    static func *(left: SCNVector3, right: Float) -> SCNVector3 {
        return SCNVector3(left.x * right, left.y * right, left.z * right)
    }
    
    static func *(left: Float, right: SCNVector3) -> SCNVector3 {
        return right*left
    }
    
    static func *(left: SCNVector3, right: Int) -> SCNVector3 {
        return left*Float(right)
    }
    
    static func *(left: Int, right: SCNVector3) -> SCNVector3 {
        return right*left
    }
    
    static func *(left: SCNVector3, right: Double) -> SCNVector3 {
        return left*Float(right)
    }
    
    static func *(left: Double, right: SCNVector3) -> SCNVector3 {
        return right*left
    }
    
    static func *(left: SCNVector3, right: SCNVector3) -> Float {//scalar multipling
        return left.x * right.x + left.y * right.y + left.z * right.z
    }
    
    static func /(left: SCNVector3, right: Float) -> SCNVector3 {
        return left*(1.0/right)//only one dividing and three multipling is faster than three dividing
//        return SCNVector3(left.x / right, left.y * right, left.z * right)
    }
    
    static func /(left: SCNVector3, right: Double) -> SCNVector3 {
        return left/Float(right)
    }
    
    static func /(left: SCNVector3, right: Int) -> SCNVector3 {
        return left/Float(right)
    }
    
    var length: Float{
        get{
            return pow(x*x+y*y+z*z,0.5)
        }
        set{
            let curLeng=length //current leng of vector
            if curLeng==0.0 {//Zero leng vector
                let coords = newValue / pow(3, 0.5)
                x=coords
                y=coords
                z=coords
            }
            else{//shrink current vector
                let multipler=newValue/curLeng
                x*=multipler
                y*=multipler
                z*=multipler
            }
        }
    }
}
