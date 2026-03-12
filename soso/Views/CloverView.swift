//
//  CloverView.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import SwiftUI

// MARK: - 클로버 색상 (이미지 스타일: 파스텔 그린, 은은한 하이라이트)
struct CloverColors {
    static let main = Color(red: 0.61, green: 0.81, blue: 0.55)      // #9BCF8D
    static let shadow = Color(red: 0.52, green: 0.71, blue: 0.48)    // #85B57A
    static let highlight = Color(red: 0.65, green: 0.86, blue: 0.63)  // #A7DCA1
    static let stem = Color(red: 0.46, green: 0.49, blue: 0.44)       // #757E6F
}

/// 세잎클로버 (이미지 스타일: 부드러운 파스텔, 하이라이트, 줄기)
struct CloverView: View {
    var size: CGFloat = 24
    
    var body: some View {
        ZStack {
            // 메인 잎
            ThreeLeafCloverShape()
                .fill(CloverColors.main)
                .frame(width: size, height: size)
            
            // 잎 하이라이트 (각 잎 중앙, 은은한 하이라이트)
            CloverHighlightShape()
                .fill(CloverColors.highlight)
                .frame(width: size, height: size)
                .opacity(0.7)
            
            // 잎 내부 라인 (맥락 느낌)
            ThreeLeafCloverVeinsShape()
                .stroke(CloverColors.shadow, lineWidth: IllustrationStyle.lineWidth * 0.5)
                .frame(width: size, height: size)
            
            // 줄기
            CloverStemShape()
                .fill(CloverColors.stem)
                .frame(width: size, height: size)
            
            // 테두리 (유리병과 선 두께 통일)
            ThreeLeafCloverShape()
                .stroke(CloverColors.shadow, lineWidth: IllustrationStyle.lineWidth)
                .frame(width: size, height: size)
        }
    }
}

/// 세잎클로버 Shape (3개의 둥근 잎)
struct ThreeLeafCloverShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let leafRadius = min(rect.width, rect.height) * 0.38
        
        var path = Path()
        
        for i in 0..<3 {
            let angle = CGFloat(i) * (2 * .pi / 3) - .pi / 2
            let cx = center.x + cos(angle) * leafRadius * 0.5
            let cy = center.y + sin(angle) * leafRadius * 0.5
            path.addEllipse(in: CGRect(x: cx - leafRadius, y: cy - leafRadius * 0.7, width: leafRadius * 2, height: leafRadius * 1.4))
        }
        
        return path
    }
}

/// 세 잎 중앙 하이라이트 (부드러운 반짝임)
struct CloverHighlightShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) * 0.12
        
        var path = Path()
        for i in 0..<3 {
            let angle = CGFloat(i) * (2 * .pi / 3) - .pi / 2
            let cx = center.x + cos(angle) * min(rect.width, rect.height) * 0.35
            let cy = center.y + sin(angle) * min(rect.width, rect.height) * 0.35
            path.addEllipse(in: CGRect(x: cx - r, y: cy - r * 0.6, width: r * 2, height: r * 1.2))
        }
        return path
    }
}

/// 잎맥 라인
struct ThreeLeafCloverVeinsShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) * 0.15
        
        var path = Path()
        for i in 0..<3 {
            let angle = CGFloat(i) * (2 * .pi / 3) - .pi / 2
            let endX = center.x + cos(angle) * r
            let endY = center.y + sin(angle) * r
            path.move(to: center)
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        return path
    }
}

/// 줄기
struct CloverStemShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let stemLength = min(rect.width, rect.height) * 0.25
        let stemWidth = min(rect.width, rect.height) * 0.08
        
        var path = Path()
        path.addEllipse(in: CGRect(
            x: center.x - stemWidth / 2,
            y: center.y + stemLength * 0.2,
            width: stemWidth,
            height: stemLength
        ))
        return path
    }
}

#Preview {
    ZStack {
        Color.white
        CloverView(size: 48)
    }
    .padding()
}
