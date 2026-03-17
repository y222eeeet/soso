//
//  BottleView.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import SwiftUI

// MARK: - 일러스트 공통 스타일 (유리병·클로버 선 두께 등)
struct IllustrationStyle {
    /// 선 두께 (병·클로버 모두에서 사용)
    static let lineWidth: CGFloat = 1.8
    
    /// 유리병 색상 계열
    static let glassFill = Color(red: 0.92, green: 0.96, blue: 0.98).opacity(0.4)
    static let glassHighlight = Color.white.opacity(0.6)
    static let glassOutline = Color(red: 0.75, green: 0.82, blue: 0.88)
    
    /// 금속 클래스 색상
    static let metalColor = Color(red: 0.7, green: 0.72, blue: 0.75)
}

struct BottleView: View {
    let cloverCount: Int
    var showNewCloverAnimation: Bool = false
    var onAnimationComplete: (() -> Void)?
    
    @State private var fallingCloverPosition: CGPoint = .zero
    @State private var hasTriggeredCompletion = false
    @State private var showOverlayImage = false
    @State private var overlayOpacity: Double = 0
    
    private let bottleWidth = BottleCloverLayout.bottleWidth
    private let bottleHeight = BottleCloverLayout.bottleHeight
    private let cloverSize = BottleCloverLayout.cloverSize
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 0~100개 상태에 따라 미리 준비된 유리병+클로버 이미지를 사용
            Image(baseImageName)
                .resizable()
                .frame(width: bottleWidth, height: bottleHeight)
            
            // 클로버 개수가 늘어날 때 이전 이미지 → 새로운 이미지로 부드럽게 교체
            if showOverlayImage, needsImageTransition {
                Image(targetImageName)
                    .resizable()
                    .frame(width: bottleWidth, height: bottleHeight)
                    .opacity(overlayOpacity)
            }
            
            // 새로 추가되는 클로버: 병 입구에서 떨어졌다가 채움 단계가 바뀌는 애니메이션
            if showNewCloverAnimation, cappedCloverCount > 0 {
                CloverView(size: cloverSize)
                    .position(fallingCloverPosition)
                    .frame(width: bottleWidth, height: bottleHeight)
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
    
    private var baseImageName: String {
        bottleImageName(for: baseCloverCount)
    }
    
    private var targetImageName: String {
        bottleImageName(for: cappedCloverCount)
    }
    
    /// 이미지가 실제로 바뀌는 경우에만 크로스페이드 애니메이션 적용
    private var needsImageTransition: Bool {
        baseImageName != targetImageName
    }
    
    /// 애니메이션 중에는 직전 상태를, 아니면 현재 개수를 사용
    private var baseCloverCount: Int {
        let capped = max(0, min(cappedCloverCount, BottleCloverLayout.maxClovers))
        if showNewCloverAnimation {
            return max(capped - 1, 0)
        }
        return capped
    }
    
    private func startFallingAnimation() {
        let startPosition = CGPoint(x: bottleWidth / 2, y: -30)
        let targetPosition = CGPoint(x: bottleWidth / 2, y: bottleHeight * 0.75)
        
        fallingCloverPosition = startPosition
        
        // 병 안 이미지 크로스페이드 설정 (필요한 경우에만)
        if needsImageTransition {
            showOverlayImage = true
            overlayOpacity = 0
        }
        
        withAnimation(.easeIn(duration: 1.0)) {
            fallingCloverPosition = targetPosition
        }
        
        // 클로버가 어느 정도 떨어진 뒤에 이미지가 서서히 바뀌도록 딜레이를 둠
        if needsImageTransition {
            withAnimation(.easeInOut(duration: 0.35).delay(0.55)) {
                overlayOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            if !hasTriggeredCompletion {
                hasTriggeredCompletion = true
                showOverlayImage = false
                overlayOpacity = 0
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

/// 병 내부 채움 정도를 10단계로 표현하는 레이어 (클로버 군집)
struct BottleFillLayer: View {
    let fillStep: Int   // 0 ~ 10
    
    private let w = BottleCloverLayout.bottleWidth
    private let h = BottleCloverLayout.bottleHeight
    
    var body: some View {
        GeometryReader { geo in
            let clampedStep = max(0, min(fillStep, 10))
            let ratio = heightRatio(for: clampedStep)
            
            FillBlobShape(fillRatio: ratio)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.65, green: 0.84, blue: 0.63),
                            Color(red: 0.52, green: 0.74, blue: 0.52)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .mask(JarBodyShape())
        }
        .frame(width: w, height: h)
    }
    
    /// 단계별 채움 높이 비율 (0.0 ~ 0.9 정도까지)
    private func heightRatio(for step: Int) -> CGFloat {
        switch step {
        case 0: return 0.0
        case 1: return 0.10
        case 2: return 0.18
        case 3: return 0.26
        case 4: return 0.34
        case 5: return 0.44
        case 6: return 0.54
        case 7: return 0.64
        case 8: return 0.74
        case 9: return 0.82
        case 10: return 0.9
        default: return 0.0
        }
    }
}

/// 병 안에서 아래에서 위로 차오르는 \"클로버 덩어리\" 모양
struct FillBlobShape: Shape {
    var fillRatio: CGFloat   // 0.0 ~ 0.9 정도
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let clamped = max(0, min(fillRatio, 0.95))
        let minTopRatio: CGFloat = 0.72  // 병 바닥에서 약간 위
        let topY = h * (1.0 - (minTopRatio + (1.0 - minTopRatio) * clamped))
        let bottomY = h * 0.96
        
        // 아래 둥근 바닥
        path.move(to: CGPoint(x: w * 0.18, y: bottomY))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.82, y: bottomY),
            control: CGPoint(x: w * 0.5, y: bottomY + h * 0.05)
        )
        
        // 오른쪽 벽 따라 위로
        path.addLine(to: CGPoint(x: w * 0.82, y: topY + 4))
        
        // 위쪽 물결 (세 개의 부드러운 곡선)
        let waveHeight: CGFloat = h * 0.02
        let segment = (w * 0.64)
        let startX = w * 0.18
        
        path.addCurve(
            to: CGPoint(x: startX + segment * 0.33, y: topY),
            control1: CGPoint(x: w * 0.76, y: topY - waveHeight),
            control2: CGPoint(x: w * 0.70, y: topY + waveHeight)
        )
        path.addCurve(
            to: CGPoint(x: startX + segment * 0.66, y: topY),
            control1: CGPoint(x: w * 0.46, y: topY - waveHeight),
            control2: CGPoint(x: w * 0.40, y: topY + waveHeight)
        )
        path.addCurve(
            to: CGPoint(x: startX, y: topY + 3),
            control1: CGPoint(x: w * 0.30, y: topY - waveHeight),
            control2: CGPoint(x: w * 0.24, y: topY + waveHeight)
        )
        
        // 왼쪽 벽 따라 아래로
        path.addLine(to: CGPoint(x: w * 0.18, y: bottomY))
        
        path.closeSubpath()
        return path
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

// MARK: - 상태별 병 이미지 이름 매핑
private func bottleImageName(for count: Int) -> String {
    let c = max(0, min(count, 100))
    switch c {
    case 0: return "jar_0"
    case 1: return "jar_1"
    case 2: return "jar_2"
    case 3: return "jar_3"
    case 4: return "jar_4"
    case 5: return "jar_5"
    case 6: return "jar_6"
    case 7: return "jar_7"
    case 8: return "jar_8"
    case 9: return "jar_9"
    case 10: return "jar_10"
        
    case 11...20: return "jar_15"
    case 21...30: return "jar_25"
    case 31...40: return "jar_35"
    case 41...50: return "jar_45"
    case 51...60: return "jar_55"
    case 61...70: return "jar_65"
    case 71...80: return "jar_75"
    case 81...90: return "jar_85"
    case 91...95: return "jar_95"
        
    case 96: return "jar_96"
    case 97: return "jar_97"
    case 98: return "jar_98"
    case 99: return "jar_99"
    case 100: return "jar_100"
    default: return "jar_0"
    }
}

#Preview {
    ZStack {
        Color(red: 0.95, green: 0.98, blue: 0.95)
            .ignoresSafeArea()
        BottleView(cloverCount: 5, showNewCloverAnimation: true)
    }
}
