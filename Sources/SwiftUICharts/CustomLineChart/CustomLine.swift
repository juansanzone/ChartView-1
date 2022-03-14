//
//  CustomLine.swift
//
//  Created by Juan Sanzone
//  Copyright © 2022. All rights reserved.
//

import SwiftUI

public struct CustomLine: View {
    @ObservedObject var data: ChartData
    @Binding var frame: CGRect
    @Binding var touchLocation: CGPoint
    @Binding var showIndicator: Bool
    @Binding var minDataValue: Double?
    @Binding var maxDataValue: Double?
    @Binding var currentIndex: Int
    @State private var showFull: Bool = false
    @State var showBackground: Bool = true
    var gradient: GradientColor = GradientColor(start: Colors.GradientPurple, end: Colors.GradientNeonBlue)
    var index:Int = 0
    let padding:CGFloat = 30
    var curvedLines: Bool = true
    var stepWidth: CGFloat {
        if data.points.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.points.count-1)
    }
    var stepHeight: CGFloat {
        var min: Double?
        var max: Double?
        let points = self.data.onlyPoints()
        if minDataValue != nil && maxDataValue != nil {
            min = minDataValue!
            max = maxDataValue!
        }else if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        }else {
            return 0
        }
        if let min = min, let max = max, min != max {
            if (min <= 0){
                return (frame.size.height-padding) / CGFloat(max - min)
            }else{
                return (frame.size.height-padding) / CGFloat(max - min)
            }
        }
        return 0
    }
    
    var backgroundLinePath: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadCurvedPathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue) : Path.linePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    private let backgroundLineColor = Color(hexString: "EBEBEB")
    
    var backgroundPath: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadClosedCurvedPathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue) : Path.closedLinePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    private let backgroundGradientColor = LinearGradient(gradient: Gradient(colors: [Color(hexString: "#F9F8F7"), Color.white]), startPoint: .bottom, endPoint: .top)
    
    var userSelectionLinePath: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadCurvedPathWithPoints(points: Array(points.suffix(currentIndex)), step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue) : Path.linePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    
    var userSelectionBackgroundPath: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadClosedCurvedPathWithPoints(points: Array(points.suffix(currentIndex)), step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue) : Path.closedLinePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    private let userSelectionBackgroundGradientColor = LinearGradient(gradient: Gradient(colors: [Color(hexString: "#7733EE"), Color.white]), startPoint: .bottom, endPoint: .top)

    public var body: some View {
        
        ZStack {
            self.backgroundPath
                .fill(backgroundGradientColor)
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .transition(.opacity)
                .animation(.easeIn(duration: 1.6))
            
            self.userSelectionBackgroundPath
                .fill(userSelectionBackgroundGradientColor)
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .transition(.opacity)
                .animation(.easeIn(duration: 1.6))
            
            self.backgroundLinePath
                .trim(from: 0, to: 1)
                .stroke(
                    backgroundLineColor,
                    style: StrokeStyle(lineWidth: 2, lineJoin: .round)
                )
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

            self.userSelectionLinePath
                .trim(from: 0, to: showFull ? 1:0)
                .stroke(Color(hexString: "#7733EE"), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .animation(Animation.easeOut(duration: 1.2).delay(Double(self.index)*0.4))
                .onAppear {
                    showFull = true
                } .onDisappear {
                    showFull = false
                }
            
            if showIndicator {
                CustomIndicatorPoint()
                    .position(getClosestPointOnPath(touchLocation: touchLocation))
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
    
    func getClosestPointOnPath(touchLocation: CGPoint) -> CGPoint {
        let closest = self.userSelectionLinePath.point(to: touchLocation.x)
        return closest
    }
}
