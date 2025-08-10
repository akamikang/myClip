# 📎 myClip Chrome Extension

웹 브라우징 중 유용한 콘텐츠를 선택하여 이메일로 전송하는 Chrome 확장 프로그램

## ✨ 주요 기능

- 🖱️ 텍스트 선택 후 우클릭으로 간편하게 저장
- ✍️ 사용자 정의 제목 추가
- 🌐 웹페이지 URL 자동 수집
- 📧 EmailJS를 통한 이메일 전송
- ⚙️ 사용자 맞춤 설정 관리

## 🚀 설치 방법

### 개발자 모드로 설치 (테스트용)
1. Chrome 브라우저에서 `chrome://extensions/` 접속
2. 우상단의 "개발자 모드" 활성화
3. "압축해제된 확장 프로그램을 로드합니다" 클릭
4. **중요**: `myClip` 프로젝트 루트 폴더를 선택 (package 폴더가 아님)
   ```
   선택할 폴더: ~/dev/afterLife/my_business/myClip
   ❌ 잘못된 폴더: ~/dev/afterLife/my_business/myClip/package
   ```

### 패키징된 확장 프로그램 설치
1. 아이콘 생성: `generate_icons.html` 파일을 브라우저에서 열고 아이콘 다운로드
2. 패키징 스크립트 실행: `./package.sh`
3. 생성된 ZIP 파일을 Chrome Web Store에 업로드

## 📝 사용 방법

### 1단계: 설정하기
1. 확장 프로그램 아이콘 우클릭 → "옵션" 선택
2. EmailJS 설정 정보 입력:
   - Service ID (기본값: ----)
   - Template ID (기본값: ---)
   - Public Key (기본값: ----)
   - 수신 이메일 주소
3. "설정 저장" 클릭

### 2단계: 콘텐츠 저장하기
1. 웹페이지에서 저장하고 싶은 텍스트 선택
2. 선택한 텍스트에서 우클릭 → "Save to myClip" 클릭
3. 팝업에서 제목 입력
4. "저장하기" 클릭
5. 설정한 이메일 주소로 콘텐츠 전송 완료!

## 🔧 EmailJS 설정

### EmailJS 계정 설정
1. [EmailJS](https://www.emailjs.com/) 가입
2. 새 서비스 생성 (Gmail, Outlook 등)
3. 이메일 템플릿 생성
4. Public Key 확인

### 템플릿 변수
- `{{name}}`: 사용자가 입력한 제목
- `{{time}}`: 저장 시간
- `{{message}}`: 선택된 텍스트 + URL

## 📁 프로젝트 구조

```
myClip/
├── manifest.json         # 확장 프로그램 설정
├── background.js         # 백그라운드 서비스 워커
├── content.js           # 콘텐츠 스크립트
├── popup.html           # 메인 팝업 인터페이스
├── popup.js             # 팝업 로직
├── options.html         # 설정 페이지
├── options.js           # 설정 로직
├── styles.css           # 스타일링
├── generate_icons.html  # 전문적인 아이콘 생성기
├── package.sh           # 자동 패키징 스크립트
├── icons/              # 확장 프로그램 아이콘
│   ├── icon16.png
│   ├── icon48.png
│   └── icon128.png
├── PRD.md              # 제품 요구사항 문서
├── CLAUDE.md           # 개발 가이드
└── README.md           # 이 파일
```

## 🔒 권한 설명

- `contextMenus`: 우클릭 메뉴에 "Save to myClip" 추가
- `activeTab`: 현재 탭의 URL 정보 접근
- `storage`: 사용자 설정 저장

## 🏪 Chrome Web Store 등록하기

### 등록 전 준비사항
1. **Google 개발자 계정 생성**
   - [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/developer/dashboard) 접속
   - Google 계정으로 로그인
   - 개발자 등록비 $5 결제 (일회성)

2. **확장 프로그램 패키징**
   ```bash
   # 프로젝트 폴더를 ZIP 파일로 압축
   # 다음 파일들이 포함되어야 함:
   # - manifest.json
   # - background.js, content.js, popup.js, options.js
   # - popup.html, options.html
   # - styles.css
   # - icons/ 폴더 (아이콘 파일들)
   ```

### 단계별 등록 절차

#### 1단계: 아이콘 생성 및 자동 패키징
1. **아이콘 생성**:
   ```bash
   # 브라우저에서 generate_icons.html 열기
   open generate_icons.html
   ```
   - 고품질 전문 아이콘을 자동 생성 및 다운로드
   - 다운로드한 아이콘 파일들을 `icons/` 폴더에 저장

2. **고급 자동 패키징** (v2.0.0):
   ```bash
   # 기본 릴리스 빌드
   ./package.sh
   
   # 유효성 검사만 수행
   ./package.sh --validate
   
   # 강제 빌드 (기존 파일 덮어쓰기)
   ./package.sh --force
   
   # 빌드 후 Chrome Web Store 자동 열기
   ./package.sh --store
   
   # 디버그 빌드 생성
   ./package.sh --type debug --debug
   
   # 도움말 보기
   ./package.sh --help
   ```
   
   **✨ 고급 기능:**
   - 🔍 자동 파일 검증 및 종속성 확인
   - 🎨 누락된 아이콘 자동 생성 (Python 필요)
   - 📦 지능형 패키지 최적화 (12KB로 압축)
   - 🚀 Chrome Web Store 연동
   - 🐛 상세한 로그 및 오류 처리
   - 📊 빌드 타입별 패키징 (release/debug)

#### 2단계: Chrome Web Store 업로드
1. [개발자 대시보드](https://chrome.google.com/webstore/developer/dashboard) 접속
2. "새 항목 추가" 클릭
3. `./package.sh` 로 생성된 ZIP 파일을 업로드 (dist/ 폴더 확인)
4. 기본 정보 입력:
   - **확장 프로그램 이름**: myClip
   - **요약**: 웹 콘텐츠를 선택하여 이메일로 전송하는 편리한 도구
   - **상세 설명**: 
     ```
     웹 브라우징 중 유용한 콘텐츠를 발견했을 때, 텍스트를 선택하고 우클릭만으로 
     간편하게 이메일로 전송할 수 있는 Chrome 확장 프로그램입니다.
     
     주요 기능:
     • 텍스트 선택 후 우클릭으로 즉시 저장
     • 사용자 정의 제목 추가 가능
     • 웹페이지 URL 자동 포함
     • EmailJS를 통한 안전한 이메일 전송
     • 개인 맞춤 설정 관리
     ```

#### 3단계: 스크린샷 및 이미지 준비
1. **스크린샷 (필수)**:
   - 1280x800 또는 640x400 크기
   - 확장 프로그램 사용 모습 캡처
   - 최소 1개, 최대 5개 업로드

2. **프로모션 이미지**:
   - 작은 타일: 440x280px
   - 큰 타일: 920x680px
   - 마퀴: 1400x560px

#### 4단계: 정책 및 개인정보
1. **카테고리**: 생산성 도구
2. **언어**: 한국어
3. **개인정보처리방침**: 
   ```
   이 확장 프로그램은 사용자가 선택한 텍스트와 웹페이지 URL만을 
   EmailJS를 통해 전송하며, 별도의 서버에 데이터를 저장하지 않습니다.
   모든 설정은 사용자의 Chrome 브라우저에만 저장됩니다.
   ```

#### 5단계: 검토 및 게시
1. **권한 정당화 설명**:
   - `contextMenus`: 우클릭 메뉴에 "Save to myClip" 옵션 추가
   - `activeTab`: 현재 탭의 URL 정보 수집
   - `storage`: 사용자 EmailJS 설정 저장

2. **테스트 계정** (선택사항):
   - EmailJS 테스트용 계정 정보 제공

3. **게시 옵션**:
   - 공개 범위: 공개 또는 비공개 선택
   - 지역 설정: 전 세계 또는 특정 국가

#### 6단계: 심사 대기
- 심사 기간: 보통 1-3일 (최대 7일)
- 거부 시 피드백을 받고 수정 후 재제출
- 승인 시 Chrome Web Store에 자동 게시

### 📋 심사 통과 팁
1. **명확한 설명**: 확장 프로그램의 기능을 명확히 설명
2. **권한 최소화**: 필요한 권한만 요청
3. **고품질 이미지**: 스크린샷과 아이콘의 품질 확보
4. **정책 준수**: Chrome Web Store 정책 숙지 및 준수
5. **테스트 완료**: 다양한 환경에서 충분한 테스트

### 💰 비용 정보
- **개발자 등록비**: $5 (일회성)
- **앱 게시비**: 무료
- **수익 분배**: Chrome Web Store는 수수료 없음

## 🐛 문제 해결

### 이메일이 전송되지 않는 경우
1. 설정에서 EmailJS 정보가 올바른지 확인
2. 수신 이메일 주소가 정확한지 확인
3. EmailJS 계정의 월간 전송 한도 확인

### 텍스트 선택이 안 되는 경우
1. 확장 프로그램이 활성화되어 있는지 확인
2. 페이지 새로고침 후 재시도
3. 텍스트를 정확히 선택했는지 확인

### Chrome Web Store 심사 거부 시
1. 거부 이유를 자세히 확인
2. 권한 사용 목적을 명확히 설명
3. 스크린샷과 설명을 더 상세하게 작성
4. 개인정보처리방침 링크 추가 고려

### 개발자 모드 로드 실패 시
1. **폴더 선택 확인**: 
   - ✅ 올바른 경로: `~/dev/afterLife/my_business/myClip`
   - ❌ 잘못된 경로: `~/dev/afterLife/my_business/myClip/package`
   
2. **필수 파일 확인**:
   ```bash
   ls -la ~/dev/afterLife/my_business/myClip/
   # manifest.json 파일이 있는지 확인
   ```

3. **아이콘 파일 확인**:
   ```bash
   ls -la ~/dev/afterLife/my_business/myClip/icons/
   # icon16.png, icon48.png, icon128.png 파일 확인
   ```

4. **Chrome 개발자 도구에서 오류 확인**:
   - `chrome://extensions/` → 개발자 모드 → "오류" 버튼 클릭
   - 콘솔 오류 메시지 확인

## 🔍 이메일 전송 오류 디버깅

### 설정 로그 확인 방법
1. **확장 프로그램 팝업에서**:
   - 확장 프로그램 아이콘 클릭 → 팝업 열기
   - `F12` 또는 `우클릭 → 검사` → 개발자 도구 열기
   - `Console` 탭에서 `[myClip Debug]` 로그 확인

2. **단계별 디버깅**:
   ```javascript
   // 콘솔에서 확인할 수 있는 로그들:
   [myClip Debug] Starting email send process...
   [myClip Debug] Loading settings from Chrome storage...
   [myClip Debug] Settings loaded: { serviceId: '...', ... }
   [myClip Debug] Initializing EmailJS...
   [myClip Debug] Template params: { ... }
   [myClip Debug] Sending email via EmailJS...
   [myClip Debug] EmailJS response: { ... }
   ```

### 일반적인 오류와 해결책

#### 1. "EmailJS 설정이 완전하지 않습니다"
**원인**: Service ID, Template ID, Public Key 중 하나 이상이 누락
**해결책**:
1. 확장 프로그램 아이콘 우클릭 → "옵션"
2. 모든 EmailJS 정보가 올바르게 입력되었는지 확인
3. [EmailJS Dashboard](https://dashboard.emailjs.com/)에서 정보 재확인

#### 2. HTTP 400 오류
**원인**: 잘못된 템플릿 변수 또는 설정
**해결책**:
- EmailJS 템플릿에 `{{name}}`, `{{time}}`, `{{message}}` 변수가 있는지 확인
- Service ID와 Template ID가 정확한지 확인

#### 3. HTTP 401/403 오류  
**원인**: 인증 오류
**해결책**:
- Public Key가 올바른지 확인
- EmailJS 계정에서 도메인 설정 확인 (chrome-extension:// 허용)

#### 4. Network 오류
**원인**: 인터넷 연결 문제 또는 방화벽
**해결책**:
- 인터넷 연결 확인
- 회사/학교 네트워크인 경우 방화벽 설정 확인

### EmailJS 설정 확인 체크리스트
```bash
# 1. EmailJS 계정 및 서비스 확인
# - https://dashboard.emailjs.com/ 접속
# - Service가 활성화되어 있는지 확인
# - 이메일 서비스 (Gmail, Outlook 등) 연결 상태 확인

# 2. 템플릿 확인 (중요!)
# - Template에 필수 변수들이 포함되어 있는지 확인:
#   {{name}}, {{time}}, {{message}}
# - 수신자 이메일은 템플릿에서 직접 설정 (To Email에 고정 주소 입력)

# 3. Public Key 확인  
# - Account → API Keys → Public Key 복사

# 4. 월간 전송 한도 확인
# - 무료 계정: 월 200회 제한
# - 한도 초과 시 업그레이드 필요
```

### ⚠️ 중요: EmailJS 템플릿 설정
EmailJS 템플릿에서 **"To Email"** 필드에 수신자 이메일 주소를 직접 입력하세요.
확장 프로그램에서는 to_email 파라미터를 전송하지 않으므로, 템플릿에서 수신자를 관리합니다.

### 일반적인 Chrome 확장 프로그램 오류

#### 5. "Could not establish connection" 오류
**원인**: background.js와 popup.js 간의 메시지 통신 실패
**해결책**: 
- 확장 프로그램을 새로고침 (`chrome://extensions/` → 새로고침 버튼)
- Chrome 브라우저 재시작

#### 6. "emailjs is not defined" 또는 SDK 버전 경고
**원인**: 구버전 EmailJS SDK 사용 또는 라이브러리 로딩 실패
**해결책**: 
- ✅ 이미 해결됨: EmailJS SDK v4로 업그레이드
- ✅ 로컬 `emailjs.min.js` 파일 사용 (CSP 호환)
- 확장 프로그램 새로고침 필요

#### 7. "Refused to load script" CSP 오류
**원인**: Content Security Policy에서 외부 스크립트 차단
**해결책**:
- ✅ 이미 해결됨: 모든 외부 의존성을 로컬 파일로 변경
- `manifest.json`에 필요한 `host_permissions` 추가

### 추가 디버깅 팁
1. **콘솔 로그 활성화**: 개발자 도구에서 `Verbose` 레벨까지 모든 로그 확인
2. **네트워크 탭 확인**: EmailJS API 호출이 성공하는지 확인
3. **배경 스크립트 로그**: `chrome://extensions/` → myClip → "서비스 워커" 클릭하여 background.js 로그 확인
4. **확장 프로그램 새로고침**: 코드 변경 후 반드시 확장 프로그램 새로고침
5. **EmailJS 테스트**: [EmailJS Playground](https://www.emailjs.com/docs/examples/reactjs/)에서 직접 테스트

## 📄 라이선스

이 프로젝트는 개인 및 교육 목적으로 자유롭게 사용할 수 있습니다.

## 🤝 기여하기

버그 리포트나 기능 제안은 이슈를 통해 알려주세요.

---

**개발자**: myClip Development Team  
**버전**: 1.0.0  
**최종 업데이트**: 2024-08-10
