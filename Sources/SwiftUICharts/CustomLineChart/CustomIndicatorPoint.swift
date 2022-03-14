//
//  CustomIndicatorPoint.swift
//
//  Created by Juan Sanzone
//  Copyright © 2022. All rights reserved.
//

import SwiftUI

struct CustomIndicatorPoint: View {
    
    var body: some View {
        ZStack{
            
        
            HStack {
                Color(hexString: "7733EE")
            }.frame(width: 1, height: 500)
            
            Circle().fill(Color(hexString: "7733EE"))
        }.frame(width: 10, height: 10)
    }
}
