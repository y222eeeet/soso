//
//  BottleView.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import SwiftUI

// MARK: - 일러스트 스타일 상수 (유리병·클로버 통일)
struct IllustrationStyle {
    /// 선 두께 (일관된 moderate 두께)
    static let lineWidth: CGFloat = 1.8
    
    /// 유리병: 투명 유리 + 은은한 청록 틴트
    static let glassFill = Color(red: 0.92, green: 0.96, blue: 0.98).opacity(0.4)
    static let glassHighlight = Color.white.opacity(0.6)
    static let glassOutline = Color(red: 0.75, green: 0.82, blue: 0.88)
    
    /// 금속 클래스
    static let metalColor = Color(red: 0.7, green: 0.72, blue: 0.75)
}

struct BottleView: View {
    let cloverCount: Int
    var showNewCloverAnimation: Bool = false
    var onAnimationComplete: (() -> Void)?
    
    @State private var fallingCloverPosition: CGPoint = .zero
    @State private var hasTriggeredCompletion = false
    
    private let bottleWidth = BottleCloverLayout.bottleWidth
    private let bottleHeight = BottleCloverLayout.bottleHeight
    private let cloverSize = BottleCloverLayout.cloverSize
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 유리병 2D 일러스트 (스윙탑 병)
            JarIllustration()
            
            // 고정 위치에 배치된 클로버들
            ZStack {
                ForEach(0..<placedCloverCount, id: \.self) { index in
                    CloverView(size: cloverSize)
                        .position(BottleCloverLayout.positions[index])
                }
            }
            .frame(width: bottleWidth, height: bottleHeight)
            .mask(JarBodyShape())
            
            // 새로 추가되는 클로버: 병 입구에서 떨어져 지정 좌표로 고정
            if showNewCloverAnimation, cappedCloverCount > 0 {
                CloverView(size: cloverSize)
                    .position(fallingCloverPosition)
                    .frame(width: bottleWidth, height: bottleHeight)
                    .mask(JarBodyShape())
            }
        }
        .frame(width: bottleWidth, height: bottleHeight)
        .onChange(of: showNewCloverAnimation) { _, isShowing in
            if isShowing {
                startFallingAnimation()
            }
        }
        .onAppear {
            if showNewCloverAnimation {
                startFallingAnimation()
            }
        }
    }
    
    private var cappedCloverCount: Int {
        min(cloverCount, BottleCloverLayout.maxClovers)
    }
    
    private var placedCloverCount: Int {
        showNewCloverAnimation ? max(0, cappedCloverCount - 1) : cappedCloverCount
    }
    
    private func startFallingAnimation() {
        let targetIndex = cappedCloverCount - 1
        guard targetIndex >= 0, targetIndex < BottleCloverLayout.positions.count else {
            onAnimationComplete?()
            return
        }
        
        let targetPosition = BottleCloverLayout.positions[targetIndex]
        let startPosition = CGPoint(x: bottleWidth / 2, y: -30)
        
        fallingCloverPosition = startPosition
        
        withAnimation(.easeIn(duration: 1.0)) {
            fallingCloverPosition = targetPosition
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            if !hasTriggeredCompletion {
                hasTriggeredCompletion = true
                onAnimationComplete?()
            }
        }
    }
}

// MARK: - 스윙탑 유리병 2D 일러스트
struct JarIllustration: View {
    private let w = BottleCloverLayout.bottleWidth
    private let h = BottleCloverLayout.bottleHeight
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 병 몸통 채우기 (투명 유리 느낌)
            JarBodyShape()
                .fill(IllustrationStyle.glassFill)
                .frame(width: w, height: h)
            
            // 병 몸통 테두리
            JarBodyShape()
                .stroke(IllustrationStyle.glassOutline, lineWidth: IllustrationStyle.lineWidth)
                .frame(width: w, height: h)
            
            // 뚜껑 (돔 형태)
            JarLidShape()
                .fill(IllustrationStyle.glassFill)
                .frame(width: w, height: h)
            
            JarLidShape()
                .stroke(IllustrationStyle.glassOutline, lineWidth: IllustrationStyle.lineWidth)
                .frame(width: w, height: h)
            
            // 금속 클래스 (스윙탑)
            MetalClaspShape()
                .stroke(IllustrationStyle.metalColor, lineWidth: IllustrationStyle.lineWidth)
                .frame(width: w, height: h)
        }
        .frame(width: w, height: h)
    }
}

/// 병 몸통: 원통형 유리병, 어깨가 둥글게 목으로 이어짐 (스윙탑 병 형태)
struct JarBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // 왼쪽 경로 (아래→위): 평평한 바닥 → 둥근 몸통 → 목
        path.move(to: CGPoint(x: w * 0.28, y: h))
        path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.94))
        path.addQuadCurve(to: CGPoint(x: w * 0.24, y: h * 0.7), control: CGPoint(x: w * 0.18, y: h * 0.82))
        path.addQuadCurve(to: CGPoint(x: w * 0.30, y: h * 0.2), control: CGPoint(x: w * 0.22, y: h * 0.45))
        path.addQuadCurve(to: CGPoint(x: w * 0.36, y: h * 0.12), control: CGPoint(x: w * 0.28, y: h * 0.16))
        
        // 목 위쪽
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.12))
        path.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.2), control: CGPoint(x: w * 0.72, y: h * 0.16))
        path.addQuadCurve(to: CGPoint(x: w * 0.76, y: h * 0.7), control: CGPoint(x: w * 0.78, y: h * 0.45))
        path.addQuadCurve(to: CGPoint(x: w * 0.78, y: h * 0.94), control: CGPoint(x: w * 0.82, y: h * 0.82))
        path.addLine(to: CGPoint(x: w * 0.72, y: h))
        path.closeSubpath()
        
        return path
    }
}

/// 뚜껑: 약간 돔 형태의 원형
struct JarLidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let lidY = h * 0.06
        let lidRadius = w * 0.18
        let centerX = w / 2
        
        path.addEllipse(in: CGRect(x: centerX - lidRadius, y: lidY - lidRadius * 0.3, width: lidRadius * 2, height: lidRadius * 0.8))
        return path
    }
}

/// 금속 클래스 (스윙탑) - 단순화된 2D 라인
struct MetalClaspShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let neckY = h * 0.12
        let leftX = w * 0.36
        let rightX = w * 0.64
        
        // 왼쪽 고리
        path.addEllipse(in: CGRect(x: leftX - 3, y: neckY - 1, width: 6, height: 5))
        // 오른쪽 고리
        path.addEllipse(in: CGRect(x: rightX - 3, y: neckY - 1, width: 6, height: 5))
        // 바일 (열린 상태로 왼쪽으로 올라감)
        path.move(to: CGPoint(x: leftX, y: neckY + 2))
        path.addQuadCurve(to: CGPoint(x: w * 0.12, y: neckY - 8), control: CGPoint(x: w * 0.2, y: neckY + 4))
        
        return path
    }
}

#Preview {
    ZStack {
        Color(red: 0.95, green: 0.98, blue: 0.95)
            .ignoresSafeArea()
        BottleView(cloverCount: 5, showNewCloverAnimation: true)
    }
}
