/*
 This file is part of BeeTee Project. It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution and at https://github.com/michaeldorner/BeeTee/blob/master/LICENSE. No part of BeeTee Project, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.
 */

import Foundation


public enum BeeTeeNotification: String {
    case PowerChanged               = "BluetoothPowerChangedNotification"
    case AvailabilityChanged        = "BluetoothAvailabilityChangedNotification"
    case DeviceDiscovered           = "BluetoothDeviceDiscoveredNotification"
    case DeviceRemoved              = "BluetoothDeviceRemovedNotification"
    case ConnectabilityChanged      = "BluetoothConnectabilityChangedNotification"
    case DeviceUpdated              = "BluetoothDeviceUpdatedNotification"
    case DiscoveryStateChanged      = "BluetoothDiscoveryStateChangedNotification"
    case DeviceConnectSuccess       = "BluetoothDeviceConnectSuccessNotification"
    case ConnectionStatusChanged    = "BluetoothConnectionStatusChangedNotification"
    case DeviceDisconnectSuccess    = "BluetoothDeviceDisconnectSuccessNotification"
    
    public static let allNotifications: [BeeTeeNotification] = [.PowerChanged, .AvailabilityChanged, .DeviceDiscovered, .DeviceRemoved, .ConnectabilityChanged, .DeviceUpdated, .DiscoveryStateChanged, .DeviceConnectSuccess, .ConnectionStatusChanged, .DeviceDisconnectSuccess]
}



public protocol BeeTeeDelegate: NSObjectProtocol {
    func receivedBeeTeeNotification(notification: BeeTeeNotification)
}



public class BeeTee {
    public weak var delegate: BeeTeeDelegate? = nil
    private let bluetoothManagerHandler = BluetoothManagerHandler.sharedInstance()!

    public init() {
        for beeTeeNotification in BeeTeeNotification.allNotifications {
            print("Registered \(beeTeeNotification)")
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: beeTeeNotification.rawValue), object: nil, queue: OperationQueue.main) { [unowned self] (notification) in
                let beeTeeNotification = BeeTeeNotification.init(rawValue: notification.name.rawValue)!

                if (self.delegate != nil) {
                    self.delegate?.receivedBeeTeeNotification(notification: beeTeeNotification)
                }
            }
        }
    }

    public static func debugLowLevel() {
        print("This is a dirty C hack and only for demonstration and deep debugging, but not for production.") // credits to http://stackoverflow.com/a/3738387/1864294
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        nil,
                                        { (_, _, name, _, _) in
                                            guard let name = name else { return }
                                            let n = name.rawValue as String
                                            if n.hasPrefix("B") { // notice only notification they are associated with the BluetoothManager.framework
                                               print("Received notification: \(name)")
                                            }
                                        },
                                        nil,
                                        nil,
                                        .deliverImmediately)
    }
}
