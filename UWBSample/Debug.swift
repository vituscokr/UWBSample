//
//  Debug.swift
//  fixStore
//
//  Created by Kyungtae Nam on 2020/12/11.
//

import Foundation

class Debug {
    enum DebugLineType {
        case signle
        case double
        case plus
    }
    class func line(type:DebugLineType){
        #if DEBUG
        switch(type) {
        case .signle:
            print("----------------------------------------------------------------------------")
        case .double:
            print("============================================================================")
        case .plus:
            print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        }
        #else
        #endif
    }
    class func log(_ str:String) {

        #if DEBUG
        print(str)
        #else
        #endif
    }
    

    class func log(_ object:Any) {
        #if DEBUG
            print(object)
        #else
        #endif
    }
}
