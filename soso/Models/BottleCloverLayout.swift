//
//  BottleCloverLayout.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import CoreGraphics

/// 유리병 내부 클로버 100개 고정 위치
/// - 스윙탑 유리병 형태에 맞춘 원통형 내부
/// - 아래쪽부터 위쪽으로 차곡차곡 쌓이는 구조
struct BottleCloverLayout {
    static let maxClovers = 100
    static let bottleWidth: CGFloat = 140
    static let bottleHeight: CGFloat = 220
    static let cloverSize: CGFloat = 20
    
    /// 유리병 내부에 배치될 100개 좌표 (인덱스 0 = 바닥 근처, 99 = 목 근처)
    /// 스윙탑 병: 원통형 몸통, 아래 넓고 목으로 좁아짐
    static let positions: [CGPoint] = {
        var result: [CGPoint] = []
        let w = bottleWidth
        let h = bottleHeight
        
        // 병 내부: y 0.15(목) ~ 0.95(바닥), x는 y에 따라 변함 (원통형)
        let rowConfigs: [(cols: Int, yRatio: CGFloat)] = [
            (5, 0.92), (5, 0.88), (5, 0.84), (5, 0.80), (5, 0.76),
            (5, 0.72), (5, 0.68), (5, 0.64), (5, 0.60), (5, 0.56),
            (5, 0.52), (5, 0.48), (5, 0.44), (5, 0.40), (5, 0.36),
            (5, 0.32), (5, 0.28), (5, 0.24), (5, 0.20), (5, 0.18)
        ]
        
        for (_, config) in rowConfigs.enumerated() {
            let baseY = h * config.yRatio
            let cols = config.cols
            // 원통형: 아래(y 큼)가 넓고, 위(y 작음)가 좁음
            let widthRatio = 0.32 + config.yRatio * 0.45
            let leftMargin = w * (1 - widthRatio) / 2
            let rightMargin = w - leftMargin
            let stepX = (rightMargin - leftMargin) / CGFloat(cols + 1)
            
            for col in 0..<cols {
                var x = leftMargin + stepX * CGFloat(col + 1)
                var y = baseY
                let idx = result.count
                let offsetX = CGFloat((idx * 7 % 11) - 5) * 1.0
                let offsetY = CGFloat((idx * 13 % 7) - 3) * 0.6
                x += offsetX
                y += offsetY
                result.append(CGPoint(x: x, y: y))
                if result.count >= maxClovers { break }
            }
            if result.count >= maxClovers { break }
        }
        
        return Array(result.prefix(maxClovers))
    }()
    
    static func position(for index: Int) -> CGPoint? {
        guard index >= 0, index < positions.count else { return nil }
        return positions[index]
    }
}
