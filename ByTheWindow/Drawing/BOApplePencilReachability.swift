/*
 
 Copyright 2017 Daniel Bocksteger
 
 BOApplePencilReachability.swift
 from https://gitlab.com/DanielBocksteger/BOApplePencilReachability
 
 Inspiration from Answer on the following question
 https://stackoverflow.com/questions/32542250/detect-whether-apple-pencil-is-connected-to-an-ipad-pro/41264961#41264961
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Foundation
import CoreBluetooth

@objc public class BOApplePencilReachability: NSObject {
    public typealias BOApplePencilCallback = ((_ isAvailable: Bool) -> Void)
    
    // fileprivate let bgQueue = DispatchQueue.global(qos: .background)
    fileprivate let centralManager: CBCentralManager
    fileprivate let stateDidChangeCallback: BOApplePencilCallback
    fileprivate var checkIntervalTimer: Timer?
    
    public var isPencilReachable = false
    
    @objc public init(didChangeClosure:@escaping BOApplePencilCallback) {
        // FIXME: Why have these lines to stand above of super.init() ?!
        self.stateDidChangeCallback = didChangeClosure
        self.centralManager = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        
        super.init()
        
        self.centralManager.delegate = self
    }
    
    /// Notify the callee
    fileprivate func notify() {
        DispatchQueue.main.async {
            self.stateDidChangeCallback(self.isPencilReachable)
        }
    }
}

// MARK: CoreBluetooth stuff
extension BOApplePencilReachability {
    
    @objc fileprivate func checkReachability() {
        if centralManager.state != .poweredOff {
            let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: "180A")])
            let wasPencilReachable = isPencilReachable
            
            isPencilReachable = peripherals.contains(where: isApplePencil)
            
            if wasPencilReachable != isPencilReachable {
                self.notify()
            }
            
            if isPencilReachable {
                checkIntervalTimer?.invalidate()
            }
        } else {
            isPencilReachable = false

            checkIntervalTimer?.invalidate()

            self.notify()
        }
    }
    
    fileprivate func isApplePencil(_ peripheral: CBPeripheral) -> Bool {
        // FIXME: Regarding to comments of 'hnh' on SO, maybe checking against Service-UUIDs would make more sense.
        return peripheral.name == "Apple Pencil"
    }
}

// MARK: CBCentralManagerDelegate
extension BOApplePencilReachability: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            checkIntervalTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(BOApplePencilReachability.checkReachability), userInfo: nil, repeats: true)
        } else {
            isPencilReachable = false

            checkIntervalTimer?.invalidate()

            self.notify()
        }
    }
}

