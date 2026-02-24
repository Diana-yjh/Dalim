# 프로젝트 개요: Dalim
Dalim은 러닝/피트니스 목표 관리를 위한 SwiftUI를 기반으로 한 iOS 앱입니다.
iOS 17.0+, Swift 6.0+, Xcode 16.2 를 기반으로 합니다.

## 기술 스택
- 언어: Swift 6.0+
- UI: SwiftUI
- 데이터베이스: SwiftData 사용
- 데이터 연동: HealthKit(심박수, 걸음수, 활동 링 데이터 연동)
- 위치정보: CoreLocation
- 비동기 처리: Swift Concurrency(Async/Await), Combine
- 기능별로 **//MARK: -**을 사용하여 코드 블록 구분
- 복잡한 View의 경우 **private var ...: some View**로 분리하여 가독성 유지

## 아키텍처
Clean Architecture 패턴으로 세 개의 레이어로 구성:
- **Data/** — 데이터 레이어 (리포지토리 구현, 네트워크, 영속성)
- **Domain/** — 도메인 레이어 (엔티티, 유스케이스, 리포지토리 프로토콜)
- **Presentation/** — UI 레이어, 기능별 구성: `Dashboard/`, `Goals/`, `Running/`, `MyPage/`, `Theme/`

## 주의사항
- 개인정보 보호: HealthKit 및 위치 정보 접근 시 반드시 Info.plist에 권한 설정 문구를 포함하고 반드시 사용자 동의를 구할 것
- 테스트: 반드시 주요 로직에 대한 Unit Test를 작성할 것

