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
    /// 기본 병 너비(원래 대비 약 20% 축소)
    static let bottleWidth: CGFloat = 140 * 0.8
    /// jar 에셋 비율(489 x 1497)을 기준으로 하되,
    /// 상·하단이 잘리지 않도록 여유를 조금 더 준 높이
    static let bottleHeight: CGFloat = bottleWidth * (1497.0 / 489.0) + 24
    static let cloverSize: CGFloat = 20
}
