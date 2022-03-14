//
//  CustomLineChartView.swift
//
//  Created by Juan Sanzone
//  Copyright © 2022. All rights reserved.
//

import SwiftUI

public struct CustomLineChartView: View {
  
    /// Privates - Let
    private let frame: CGSize
    private let style: ChartStyle = Styles.lineChartStyleOne
    
    /// States - State
    @State private var touchLocation: CGPoint = .zero
    @State private var showIndicatorDot: Bool = true
    @State private var currentIndex: Int = 0
    
    /// Public - Binding
    @ObservedObject var data: ChartData
    @Binding var currentValue: Double
    
    /// Init
    public init(
        data: [Double],
        currentValue: Binding<Double>,
        form: CGSize = ChartForm.extraLarge
    ) {
        self.data = ChartData(points: data)
        _currentValue = currentValue
        frame = CGSize(width: form.width, height: form.height/2)
    }
    
    /// View
    public var body: some View {
        
        ZStack(alignment: .center){
            VStack(alignment: .leading) {
                GeometryReader{ geometry in
                    CustomLine(
                        data: data,
                        frame: .constant(geometry.frame(in: .local)),
                        touchLocation: $touchLocation,
                        showIndicator: $showIndicatorDot,
                        minDataValue: .constant(nil),
                        maxDataValue: .constant(nil),
                        currentIndex: $currentIndex
                    )
                }
                //.frame(width: frame.width, height: frame.height)
                //.clipShape(RoundedRectangle(cornerRadius: 20))
                //.offset(x: 0, y: 0)
            } //.frame(width: self.formSize.width, height: self.formSize.height)
        }
        .gesture(DragGesture()
            .onChanged({ value in
                self.touchLocation = value.location
                self.showIndicatorDot = true
                self.getClosestDataPoint(
                    toPoint: value.location,
                    width:self.frame.width,
                    height: self.frame.height
                )
            }).onEnded({ value in
                self.showIndicatorDot = true
            })
        )
    }
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            currentValue = points[index]
            currentIndex = index
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        currentIndex = 0
        return .zero
    }
}
