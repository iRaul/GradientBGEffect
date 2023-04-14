//
//  ContentView.swift
//  GradientBGEffect
//
//  Created by Raul on 12.04.2023.
//

import SwiftUI

struct ContentView: View {
    private enum AnimationProperties {
        static let animationSpeed: Double = 4
        static let timerDuration: TimeInterval = 3
        static let blurRadius: CGFloat = 130
    }
    
    @State private var timer = Timer.publish(
        every: AnimationProperties.timerDuration,
        on: .main,
        in: .common).autoconnect()
    
    @ObservedObject private var animator = CircleAnimator(colors: GradientColors.all)
    
    var timeText: some View {
        Text("11:23")
            .font(.system(
                size: 88.0,
                weight: .medium,
                design: .rounded)
            )
            .padding(.top, 50)
    }
    
    var dateText: some View {
        Text("Wednesday, 12 April")
            .font(.system(
                size: 24.0,
                weight: .semibold,
                design: .rounded)
            )
    }

    var body: some View {
        ZStack {
            ZStack {
                ForEach(animator.circles) { circle in
                    MovingCircle(originOffset: circle.position)
                    .foregroundColor(circle.color)
                }
            }
            .blur(radius: AnimationProperties.blurRadius)
            
            VStack {
                
                timeText
                    .foregroundColor(.white)
                    .blendMode(.difference)
                    .overlay(timeText.blendMode(.hue))
                    .overlay(timeText.foregroundColor(.black).blendMode(.overlay))
                
                dateText
                    .foregroundColor(.white)
                    .blendMode(.difference)
                    .overlay(dateText.blendMode(.hue))
                    .overlay(dateText.foregroundColor(.black).blendMode(.overlay))
                
                Spacer()
                
                HStack {
                    ZStack{
                        Image(systemName: "flashlight.off.fill").font(.title2).foregroundColor(.white)
                            .padding(18)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .blendMode(.difference)
                    
                    Spacer()
                    
                    ZStack{
                        Image(systemName: "camera.fill").font(.title3).foregroundColor(.white)
                            .padding(16)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .blendMode(.difference)
                }
                .frame(width: 320)
            }
        }
        .background(GradientColors.backgroundColor)
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .onAppear {
            animateCircles()
            timer = Timer.publish(every: AnimationProperties.timerDuration, on: .main, in: .common).autoconnect()
        }
        .onReceive(timer) { _ in
            animateCircles()
        }
    }
    
    private func animateCircles() {
        withAnimation(.easeInOut(duration: AnimationProperties.animationSpeed)) {
            animator.animate()
        }
    }
}

private enum GradientColors {
    static var all: [Color] {
        [
            Color(#colorLiteral(red: 0.003799867816, green: 0.01174801588, blue: 0.07808648795, alpha: 1)),
            Color(#colorLiteral(red: 0.147772789, green: 0.08009552211, blue: 0.3809506595, alpha: 1)),
            Color(#colorLiteral(red: 0.5622407794, green: 0.4161503613, blue: 0.9545945525, alpha: 1)),
            Color(#colorLiteral(red: 0.7909697294, green: 0.7202591896, blue: 0.9798423648, alpha: 1)),
            Color(#colorLiteral(red: 0.7909697294, green: 0.7202591896, blue: 0.9798423648, alpha: 1)),
        ]
    }
    
    static var backgroundColor: Color {
        Color(#colorLiteral(
            red: 0.003799867816,
            green: 0.01174801588,
            blue: 0.07808648795,
            alpha: 1)
        )
    }
}

private struct MovingCircle: Shape {
    
    var originOffset: CGPoint
    
    var animatableData: CGPoint.AnimatableData {
        get {
            originOffset.animatableData
        }
        set {
            originOffset.animatableData = newValue
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let adjustedX = rect.width * originOffset.x
        let adjustedY = rect.height * originOffset.y
        let smallestDimension = min(rect.width, rect.height)
        path.addArc(center: CGPoint(x: adjustedX, y: adjustedY), radius: smallestDimension/2, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        return path
    }
}

private class CircleAnimator: ObservableObject {
    class Circle: Identifiable {
        internal init(position: CGPoint, color: Color) {
            self.position = position
            self.color = color
        }
        var position: CGPoint
        let id = UUID().uuidString
        let color: Color
    }
    
    @Published private(set) var circles: [Circle] = []
    
    
    init(colors: [Color]) {
        circles = colors.map({ color in
            Circle(position: CircleAnimator.generateRandomPosition(), color: color)
        })
    }
    
    func animate() {
        objectWillChange.send()
        for circle in circles {
            circle.position = CircleAnimator.generateRandomPosition()
        }
    }
    
    static func generateRandomPosition() -> CGPoint {
        CGPoint(x: CGFloat.random(in: 0 ... 1), y: CGFloat.random(in: 0 ... 1))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
