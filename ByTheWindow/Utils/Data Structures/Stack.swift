//
//  Stack.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/13.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import Foundation

struct Stack<T> {
    private var array = [T]()
    
    public var isEmpty: Bool {
        array.isEmpty
    }
    
    public var count: Int {
        array.count
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        array.popLast()
    }
    
    public var top: T? {
        array.first
    }
}
