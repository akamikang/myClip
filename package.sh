#!/bin/bash

# myClip Chrome Extension Advanced Packaging Tool
# Version: 2.0.0
# Description: 완전 자동화된 Chrome 확장 프로그램 패키징 및 배포 도구

set -euo pipefail  # 엄격한 오류 처리

# 전역 변수
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME=$(basename "$0")
VERSION="2.0.0"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 색상 및 이모지 정의
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# 로그 레벨
readonly LOG_ERROR=1
readonly LOG_WARN=2
readonly LOG_INFO=3
readonly LOG_DEBUG=4
LOG_LEVEL=${LOG_LEVEL:-3}

# 설정 변수
PACKAGE_NAME=""
PACKAGE_VERSION=""
BUILD_TYPE="release"
OUTPUT_DIR="dist"
TEMP_DIR=""
VALIDATE_ONLY=false
FORCE_BUILD=false
OPEN_STORE=false
AUTO_INSTALL=false

# 로그 함수들
log() {
    local level=$1
    local message=$2
    local emoji=$3
    
    if [ "$level" -le "$LOG_LEVEL" ]; then
        echo -e "${emoji} ${message}" >&2
    fi
}

log_error() { log $LOG_ERROR "${RED}[ERROR]${NC} $1" "❌"; }
log_warn() { log $LOG_WARN "${YELLOW}[WARN]${NC} $1" "⚠️ "; }
log_info() { log $LOG_INFO "${BLUE}[INFO]${NC} $1" "ℹ️ "; }
log_success() { log $LOG_INFO "${GREEN}[SUCCESS]${NC} $1" "✅"; }
log_debug() { log $LOG_DEBUG "${PURPLE}[DEBUG]${NC} $1" "🐛"; }

# 도움말 출력
show_help() {
    cat << EOF
${WHITE}myClip Chrome Extension Packaging Tool v${VERSION}${NC}

${CYAN}사용법:${NC}
    $SCRIPT_NAME [옵션]

${CYAN}옵션:${NC}
    -h, --help              이 도움말을 표시합니다
    -v, --version           버전 정보를 표시합니다
    -t, --type TYPE         빌드 타입 (release|debug) [기본값: release]
    -o, --output DIR        출력 디렉토리 [기본값: dist]
    -n, --name NAME         패키지 이름 (기본값: manifest.json에서 추출)
    -f, --force             기존 파일을 강제로 덮어씁니다
    -c, --validate          유효성 검사만 수행하고 종료합니다
    -s, --store             패키징 완료 후 Chrome Web Store 열기
    -i, --install           패키징 완료 후 Chrome에 자동 설치
    -d, --debug             디버그 모드 활성화
    -q, --quiet             조용한 모드 (오류만 출력)

${CYAN}예제:${NC}
    $SCRIPT_NAME                           # 기본 릴리스 빌드
    $SCRIPT_NAME -t debug -d               # 디버그 빌드
    $SCRIPT_NAME -c                        # 유효성 검사만
    $SCRIPT_NAME -f -s                     # 강제 빌드 후 스토어 열기
    $SCRIPT_NAME -i --output build         # 빌드 후 자동 설치

${CYAN}지원 기능:${NC}
    • 자동 버전 감지 및 패키징
    • 파일 유효성 검증
    • 아이콘 자동 생성 (누락시)
    • 압축 최적화
    • Chrome Web Store 연동
    • 자동 설치 지원
    • 상세한 로그 및 오류 처리

EOF
}

# 버전 정보 출력
show_version() {
    echo "myClip Packaging Tool v${VERSION}"
    echo "Chrome Extension Builder"
}

# 명령행 인자 파싱
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -t|--type)
                BUILD_TYPE="$2"
                if [[ "$BUILD_TYPE" != "release" && "$BUILD_TYPE" != "debug" ]]; then
                    log_error "잘못된 빌드 타입: $BUILD_TYPE (release 또는 debug만 허용)"
                    exit 1
                fi
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -n|--name)
                PACKAGE_NAME="$2"
                shift 2
                ;;
            -f|--force)
                FORCE_BUILD=true
                shift
                ;;
            -c|--validate)
                VALIDATE_ONLY=true
                shift
                ;;
            -s|--store)
                OPEN_STORE=true
                shift
                ;;
            -i|--install)
                AUTO_INSTALL=true
                shift
                ;;
            -d|--debug)
                LOG_LEVEL=4
                shift
                ;;
            -q|--quiet)
                LOG_LEVEL=1
                shift
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                echo "도움말을 보려면 '$SCRIPT_NAME --help'를 실행하세요."
                exit 1
                ;;
        esac
    done
}

# 필수 도구 확인
check_dependencies() {
    log_info "필수 도구 확인 중..."
    
    local missing_tools=()
    
    # zip 명령어 확인
    if ! command -v zip >/dev/null 2>&1; then
        missing_tools+=("zip")
    fi
    
    # jq 확인 (JSON 파싱용)
    if ! command -v jq >/dev/null 2>&1; then
        log_warn "jq가 설치되지 않았습니다. JSON 파싱이 제한됩니다."
    fi
    
    # Python 확인 (아이콘 생성용)
    if ! command -v python3 >/dev/null 2>&1; then
        log_warn "Python3가 설치되지 않았습니다. 아이콘 자동 생성이 제한됩니다."
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "다음 도구들이 필요합니다: ${missing_tools[*]}"
        exit 1
    fi
    
    log_success "모든 필수 도구가 준비되었습니다"
}

# manifest.json 검증 및 정보 추출
validate_manifest() {
    log_info "manifest.json 검증 중..."
    
    if [ ! -f "manifest.json" ]; then
        log_error "manifest.json 파일을 찾을 수 없습니다"
        exit 1
    fi
    
    # JSON 유효성 검사
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty manifest.json 2>/dev/null; then
            log_error "manifest.json이 유효하지 않은 JSON 형식입니다"
            exit 1
        fi
        
        # 필수 필드 검증
        local required_fields=("manifest_version" "name" "version")
        for field in "${required_fields[@]}"; do
            if ! jq -e ".$field" manifest.json >/dev/null 2>&1; then
                log_error "manifest.json에 필수 필드가 누락되었습니다: $field"
                exit 1
            fi
        done
        
        # 정보 추출
        PACKAGE_VERSION=$(jq -r '.version' manifest.json)
        if [ -z "$PACKAGE_NAME" ]; then
            PACKAGE_NAME=$(jq -r '.name' manifest.json | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
        fi
    else
        # jq 없이 간단한 추출
        PACKAGE_VERSION=$(grep -o '"version":[[:space:]]*"[^"]*"' manifest.json | cut -d'"' -f4)
        if [ -z "$PACKAGE_NAME" ]; then
            PACKAGE_NAME="myClip"
        fi
    fi
    
    if [ -z "$PACKAGE_VERSION" ]; then
        log_error "manifest.json에서 버전 정보를 읽을 수 없습니다"
        exit 1
    fi
    
    log_success "manifest.json 검증 완료 (버전: $PACKAGE_VERSION)"
}

# 필수 파일 검증
validate_files() {
    log_info "필수 파일 검증 중..."
    
    local required_files=(
        "manifest.json"
        "background.js"
        "content.js"
        "popup.html"
        "popup.js"
        "options.html"
        "options.js"
        "styles.css"
        "emailjs.min.js"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        else
            log_debug "✓ $file"
        fi
    done
    
    # 아이콘 검증
    local icon_files=("icons/icon16.png" "icons/icon48.png" "icons/icon128.png")
    local missing_icons=()
    
    for icon in "${icon_files[@]}"; do
        if [ ! -f "$icon" ]; then
            missing_icons+=("$icon")
        else
            log_debug "✓ $icon"
        fi
    done
    
    # 누락된 파일 처리
    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "다음 필수 파일들이 누락되었습니다:"
        for file in "${missing_files[@]}"; do
            echo "  ❌ $file"
        done
        exit 1
    fi
    
    # 아이콘 자동 생성 시도
    if [ ${#missing_icons[@]} -gt 0 ]; then
        log_warn "누락된 아이콘이 있습니다: ${missing_icons[*]}"
        if [ "$FORCE_BUILD" = true ] && command -v python3 >/dev/null 2>&1; then
            generate_missing_icons
        else
            log_info "generate_icons.html을 브라우저에서 실행하여 아이콘을 생성하세요"
            log_info "또는 -f 옵션으로 자동 생성을 시도할 수 있습니다"
        fi
    fi
    
    log_success "파일 검증 완료"
}

# 누락된 아이콘 자동 생성
generate_missing_icons() {
    log_info "누락된 아이콘 자동 생성 중..."
    
    if [ ! -d "icons" ]; then
        mkdir -p icons
    fi
    
    python3 -c "
from PIL import Image, ImageDraw
import os

def create_icon(size):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 파란색 배경
    margin = 1
    draw.ellipse([margin, margin, size-margin, size-margin], 
                fill='#007bff', outline='#0056b3', width=1)
    
    # 클립 모양
    if size >= 32:
        center_x, center_y = size // 2, size // 2
        clip_width = size // 12
        clip_height = size // 2
        
        draw.rectangle([
            center_x - clip_width, center_y - clip_height//2,
            center_x, center_y + clip_height//2
        ], fill='white')
        
        draw.rectangle([
            center_x - clip_width//2, center_y - clip_height//2,
            center_x + clip_width, center_y - clip_height//3
        ], fill='white')
        
        draw.rectangle([
            center_x + clip_width//2, center_y - clip_height//3,
            center_x + clip_width, center_y + clip_width
        ], fill='white')
    else:
        center_x, center_y = size // 2, size // 2
        draw.rectangle([center_x-2, center_y-4, center_x-1, center_y+4], fill='white')
        draw.rectangle([center_x-2, center_y-4, center_x+2, center_y-3], fill='white')
        draw.rectangle([center_x+1, center_y-3, center_x+2, center_y+1], fill='white')
    
    return img

# 아이콘 생성
sizes = [16, 48, 128]
for size in sizes:
    filename = f'icons/icon{size}.png'
    if not os.path.exists(filename):
        icon = create_icon(size)
        icon.save(filename, 'PNG')
        print(f'Generated {filename}')
" 2>/dev/null && log_success "아이콘 자동 생성 완료" || log_warn "아이콘 자동 생성 실패"
}

# 빌드 디렉토리 준비
prepare_build_dir() {
    local build_name="${PACKAGE_NAME}_v${PACKAGE_VERSION}"
    if [ "$BUILD_TYPE" = "debug" ]; then
        build_name="${build_name}_debug"
    fi
    build_name="${build_name}_${TIMESTAMP}"
    
    TEMP_DIR="$OUTPUT_DIR/$build_name"
    
    log_info "빌드 디렉토리 준비 중: $TEMP_DIR"
    
    if [ -d "$OUTPUT_DIR" ] && [ "$FORCE_BUILD" != true ]; then
        if [ "$(ls -A "$OUTPUT_DIR" 2>/dev/null)" ]; then
            read -p "출력 디렉토리 '$OUTPUT_DIR'가 비어있지 않습니다. 계속하시겠습니까? [y/N]: " -r
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "빌드가 취소되었습니다"
                exit 0
            fi
        fi
    fi
    
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    log_success "빌드 디렉토리 준비 완료"
}

# 파일 복사 및 처리
copy_files() {
    log_info "파일 복사 및 처리 중..."
    
    # 필수 파일들 복사
    local files_to_copy=(
        "manifest.json"
        "background.js"
        "content.js"
        "popup.html"
        "popup.js"
        "options.html"
        "options.js"
        "styles.css"
        "emailjs.min.js"
    )
    
    for file in "${files_to_copy[@]}"; do
        if [ -f "$file" ]; then
            cp "$file" "$TEMP_DIR/"
            log_debug "복사됨: $file"
        fi
    done
    
    # 아이콘 디렉토리 복사
    if [ -d "icons" ]; then
        cp -r "icons" "$TEMP_DIR/"
        log_debug "복사됨: icons/"
    fi
    
    # 디버그 빌드 처리
    if [ "$BUILD_TYPE" = "debug" ]; then
        log_info "디버그 빌드 설정 적용 중..."
        # 디버그용 설정이나 파일 수정 로직 추가 가능
    fi
    
    log_success "파일 복사 완료"
}

# 패키지 크기 최적화
optimize_package() {
    log_info "패키지 최적화 중..."
    
    # 불필요한 파일 제거
    find "$TEMP_DIR" -name ".DS_Store" -delete 2>/dev/null || true
    find "$TEMP_DIR" -name "Thumbs.db" -delete 2>/dev/null || true
    find "$TEMP_DIR" -name "*.tmp" -delete 2>/dev/null || true
    
    # 파일 크기 확인
    local package_size=$(du -sh "$TEMP_DIR" 2>/dev/null | cut -f1 || echo "unknown")
    log_info "패키지 크기: $package_size"
    
    log_success "패키지 최적화 완료"
}

# ZIP 파일 생성
create_package() {
    local zip_filename="${PACKAGE_NAME}_v${PACKAGE_VERSION}"
    if [ "$BUILD_TYPE" = "debug" ]; then
        zip_filename="${zip_filename}_debug"
    fi
    zip_filename="${zip_filename}_${TIMESTAMP}.zip"
    
    local zip_path="$OUTPUT_DIR/$zip_filename"
    
    log_info "ZIP 파일 생성 중: $zip_filename"
    
    cd "$TEMP_DIR"
    if zip -r "../$zip_filename" . -x "*.DS_Store" "Thumbs.db" >/dev/null 2>&1; then
        cd "$SCRIPT_DIR"
        
        local zip_size=$(du -sh "$zip_path" 2>/dev/null | cut -f1 || echo "unknown")
        log_success "ZIP 파일 생성 완료!"
        log_info "파일 경로: $zip_path"
        log_info "파일 크기: $zip_size"
        
        # 패키지 내용 요약
        echo ""
        log_info "패키지 내용:"
        unzip -l "$zip_path" | grep -E '\.(js|html|css|json|png)$' | awk '{print "  📄 " $4}'
        
        return 0
    else
        cd "$SCRIPT_DIR"
        log_error "ZIP 파일 생성에 실패했습니다"
        return 1
    fi
}

# 정리 작업
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        log_debug "임시 파일 정리 중..."
        rm -rf "$TEMP_DIR"
    fi
}

# Chrome Web Store 열기
open_chrome_store() {
    if [ "$OPEN_STORE" = true ]; then
        log_info "Chrome Web Store Developer Dashboard 열기..."
        if command -v open >/dev/null 2>&1; then  # macOS
            open "https://chrome.google.com/webstore/developer/dashboard"
        elif command -v xdg-open >/dev/null 2>&1; then  # Linux
            xdg-open "https://chrome.google.com/webstore/developer/dashboard"
        else
            log_info "브라우저에서 다음 URL을 열어주세요:"
            echo "https://chrome.google.com/webstore/developer/dashboard"
        fi
    fi
}

# Chrome에 자동 설치
auto_install() {
    if [ "$AUTO_INSTALL" = true ]; then
        log_info "Chrome 확장 프로그램 페이지 열기..."
        if command -v open >/dev/null 2>&1; then  # macOS
            open "chrome://extensions/"
        elif command -v xdg-open >/dev/null 2>&1; then  # Linux
            xdg-open "chrome://extensions/"
        else
            log_info "Chrome에서 chrome://extensions/ 를 열고 '$SCRIPT_DIR' 폴더를 로드하세요"
        fi
    fi
}

# 성공 메시지 출력
show_success_message() {
    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}        패키징 완료! 🎉${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo -e "📦 패키지: ${WHITE}$PACKAGE_NAME v$PACKAGE_VERSION${NC}"
    echo -e "🏗️  빌드 타입: ${WHITE}$BUILD_TYPE${NC}"
    echo -e "📁 출력 위치: ${WHITE}$OUTPUT_DIR/${NC}"
    echo ""
    echo -e "${CYAN}다음 단계:${NC}"
    echo -e "1. 생성된 ZIP 파일을 Chrome Web Store에 업로드"
    echo -e "2. 확장 프로그램 정보 입력 및 스크린샷 추가"
    echo -e "3. 검토 제출 및 승인 대기"
    echo ""
    echo -e "${YELLOW}유용한 링크:${NC}"
    echo -e "• Chrome Web Store: https://chrome.google.com/webstore/developer/dashboard"
    echo -e "• 개발자 가이드: https://developer.chrome.com/docs/webstore/"
}

# 신호 처리 (Ctrl+C 등)
trap cleanup EXIT

# 메인 함수
main() {
    echo -e "${CYAN}"
    echo "========================================="
    echo "  myClip Extension Packaging Tool v${VERSION}"
    echo "========================================="
    echo -e "${NC}"
    
    # 인자 파싱
    parse_arguments "$@"
    
    # 현재 디렉토리 확인
    log_info "작업 디렉토리: $SCRIPT_DIR"
    log_info "빌드 타입: $BUILD_TYPE"
    
    # 의존성 확인
    check_dependencies
    
    # manifest.json 검증
    validate_manifest
    
    # 파일 검증
    validate_files
    
    # 유효성 검사만 수행하는 경우
    if [ "$VALIDATE_ONLY" = true ]; then
        log_success "모든 유효성 검사를 통과했습니다! ✨"
        exit 0
    fi
    
    # 빌드 디렉토리 준비
    prepare_build_dir
    
    # 파일 복사
    copy_files
    
    # 패키지 최적화
    optimize_package
    
    # ZIP 파일 생성
    if create_package; then
        # 성공 메시지
        show_success_message
        
        # 추가 작업
        open_chrome_store
        auto_install
    else
        log_error "패키징에 실패했습니다"
        exit 1
    fi
}

# 스크립트 실행
main "$@"