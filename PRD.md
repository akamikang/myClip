# myClip Chrome Extension - Product Requirements Document (PRD)

## 1. Product Overview

### 1.1 Product Name
myClip - Web Content Clipping Chrome Extension

### 1.2 Product Vision
웹 브라우징 중 유용한 콘텐츠를 빠르게 수집하고 이메일로 전송할 수 있는 Chrome 확장 프로그램

### 1.3 Target Users
- 웹 리서치를 자주 하는 사용자
- 유용한 콘텐츠를 수집하고 보관하려는 사용자
- 선택한 텍스트를 이메일로 쉽게 공유하려는 사용자

## 2. Core Features

### 2.1 텍스트 선택 및 컨텍스트 메뉴
**기능**: 웹페이지에서 텍스트 블록 선택 후 우클릭으로 myClip 실행
- 사용자가 웹페이지에서 텍스트 선택
- 우클릭 시 "Save to myClip" 컨텍스트 메뉴 표시
- 클릭하면 확장 프로그램 팝업 실행

### 2.2 콘텐츠 편집 팝업
**기능**: 선택된 콘텐츠 확인 및 제목 추가
- 선택된 텍스트 자동 표시
- 현재 웹페이지 URL 자동 설정
- 사용자 정의 제목 입력 필드
- 저장하기 버튼

### 2.3 EmailJS 통합
**기능**: 설정된 이메일 주소로 콘텐츠 전송
- EmailJS 서비스를 통한 이메일 발송
- 미리 정의된 HTML 템플릿 사용
- 실시간 전송 상태 표시

### 2.4 설정 관리
**기능**: EmailJS 연동 정보 관리
- 기본 EmailJS 설정값 제공
- 사용자 맞춤 설정 수정 가능
- Chrome Storage API를 통한 설정 저장

## 3. Technical Specifications

### 3.1 Chrome Extension Architecture
- **Manifest V3** 사용
- **Service Worker** 기반 백그라운드 스크립트
- **Content Scripts** for 텍스트 선택 감지
- **Popup** 인터페이스
- **Options** 설정 페이지

### 3.2 Required Permissions
- `contextMenus`: 우클릭 메뉴 생성
- `activeTab`: 현재 탭 정보 접근
- `storage`: 사용자 설정 저장

### 3.3 EmailJS Default Configuration
```javascript
{
  service_id: "service_xru7eg8",
  template_id: "template_qslbpku", 
  public_key: "7eX6GLgodFTAfym7j"
}
```

### 3.4 Email Template Structure
```html
<div style="font-family: system-ui, sans-serif, Arial; font-size: 12px">
  <div>A message by {{name}} has been received. Kindly respond at your earliest convenience.</div>
  <div style="margin-top: 20px; padding: 15px 0; border-width: 1px 0; border-style: dashed; border-color: lightgrey;">
    <table role="presentation">
      <tr>
        <td style="vertical-align: top">
          <div style="padding: 6px 10px; margin: 0 10px; background-color: aliceblue; border-radius: 5px; font-size: 26px" role="img">
            👤
          </div>
        </td>
        <td style="vertical-align: top">
          <div style="color: #2c3e50; font-size: 16px">
            <strong>{{name}}</strong>
          </div>
          <div style="color: #cccccc; font-size: 13px">{{time}}</div>
          <p style="font-size: 16px">{{message}}</p>
        </td>
      </tr>
    </table>
  </div>
</div>
```

## 4. User Flow

### 4.1 Main Use Case
1. 사용자가 웹페이지에서 관심 있는 텍스트 선택
2. 우클릭하여 "Save to myClip" 메뉴 클릭
3. 팝업이 열리며 선택된 텍스트와 URL이 자동 입력됨
4. 사용자가 제목을 추가 입력
5. "저장하기" 버튼 클릭
6. EmailJS를 통해 설정된 이메일로 전송
7. 전송 완료 메시지 표시

### 4.2 Settings Configuration
1. 확장 프로그램 아이콘 우클릭 → "옵션"
2. EmailJS 설정 페이지 열림
3. Service ID, Template ID, Public Key, Email 주소 수정
4. 설정 저장

## 5. Data Structure

### 5.1 Clip Data
```javascript
{
  title: String,        // 사용자 입력 제목
  content: String,      // 선택된 텍스트 블록
  url: String,         // 소스 웹페이지 URL  
  timestamp: Date      // 저장 시간
}
```

### 5.2 Settings Data
```javascript
{
  serviceId: String,    // EmailJS Service ID
  templateId: String,   // EmailJS Template ID  
  publicKey: String,    // EmailJS Public Key
  emailAddress: String  // 수신자 이메일 주소
}
```

## 6. File Structure

```
myClip/
├── manifest.json         # Extension configuration
├── background.js         # Service worker
├── content.js           # Content script  
├── popup.html           # Main popup interface
├── popup.js             # Popup logic
├── options.html         # Settings page
├── options.js           # Settings logic
├── styles.css           # Styling
└── icons/              # Extension icons
    ├── icon16.png
    ├── icon48.png
    └── icon128.png
```

## 7. Success Criteria

### 7.1 Functional Requirements
- ✅ 텍스트 선택 및 컨텍스트 메뉴 정상 작동
- ✅ 팝업에서 콘텐츠 확인 및 제목 추가 가능
- ✅ EmailJS를 통한 이메일 전송 성공
- ✅ 설정 페이지에서 EmailJS 정보 수정 가능
- ✅ Chrome Storage를 통한 설정 저장/로드

### 7.2 Non-Functional Requirements
- 응답 시간: 팝업 로딩 < 1초
- 호환성: Chrome 88+ 버전 지원
- 보안: 민감 정보 로컬 저장 금지
- 사용성: 직관적이고 간단한 UI

## 8. Future Enhancements

- 다중 이메일 주소 지원
- 클립 히스토리 관리
- 태그 및 카테고리 기능
- 다양한 이메일 템플릿 옵션
- 클립 내용 미리보기 기능