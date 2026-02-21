"""
output/posts/ 의 .md 파일을 Selenium으로 티스토리에 자동 포스팅.

- 최초 실행: Chrome에서 수동 카카오 로그인 → cookies.json 저장
- 이후 실행: cookies.json 로드 → 자동 로그인 → 글쓰기
- 필요: pip install selenium (가상환경 활성화 후)
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

import requests
from dotenv import load_dotenv
try:
    from selenium import webdriver
    from selenium.common.exceptions import (
        NoSuchElementException,
        TimeoutException,
        WebDriverException,
    )
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.common.action_chains import ActionChains
    from selenium.webdriver.common.by import By
    from selenium.webdriver.common.keys import Keys
    from selenium.webdriver.support import expected_conditions as EC
    from selenium.webdriver.support.ui import WebDriverWait
except ImportError:
    print("selenium 없음 → 설치 시도 중...")
    try:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "selenium>=4.20.0"],
            check=True,
            capture_output=True,
        )
        print("selenium 설치 완료. 스크립트를 다시 실행합니다.")
        os.execv(sys.executable, [sys.executable] + sys.argv)
    except (subprocess.CalledProcessError, OSError):
        print("selenium 자동 설치 실패. 수동 실행:")
        print("  source .venv/bin/activate")
        print('  pip install "selenium>=4.20.0"')
        sys.exit(1)

load_dotenv()

SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = SCRIPT_DIR.parent.parent / "teams/content/workspace/blog"
POSTS_DIR = OUTPUT_DIR / "drafts"
DONE_DIR = OUTPUT_DIR / "published"
def _debug_print(msg: str) -> None:
    """디버그 출력."""
    print(f"  [DBG] {msg}")
IMAGES_DIR = OUTPUT_DIR / "images"
COOKIES_FILE = SCRIPT_DIR / "cookies.json"

BLOG_NAME = os.environ.get("TISTORY_BLOG_NAME", "geekbrox").strip()
TISTORY_EMAIL = os.environ.get("TISTORY_EMAIL", "").strip()
TISTORY_PASSWORD = os.environ.get("TISTORY_PASSWORD", "").strip()
TELEGRAM_BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
TELEGRAM_CHAT_ID = os.environ.get("TELEGRAM_CHAT_ID", "").strip()

IS_MAC = sys.platform == "darwin"
MOD_KEY = Keys.COMMAND if IS_MAC else Keys.CONTROL

NEWPOST_URL = f"https://{BLOG_NAME}.tistory.com/manage/newpost"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Telegram
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def tg_send(text: str) -> None:
    if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHAT_ID:
        print(f"[TG 미설정] {text}")
        return
    try:
        r = requests.post(
            f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage",
            json={"chat_id": TELEGRAM_CHAT_ID, "text": text},
            timeout=15,
        )
        data = r.json()
        if not data.get("ok"):
            print(f"Telegram 전송 실패 (API 오류): {data.get('description', data)}")
        else:
            print(f"[TG 전송] {text[:60]}")
    except requests.RequestException as e:
        print(f"Telegram 전송 실패 (네트워크): {e}")


def tg_wait_keyword(keyword: str, timeout_sec: int = 600) -> bool:
    """getUpdates 폴링으로 keyword 포함 메시지를 받을 때까지 대기. 성공 시 True.

    주의: 호출 시점보다 이전 메시지는 무시하기 위해 최초 호출 시 현재 update_id를 스킵.
    """
    if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHAT_ID:
        input("Telegram 미설정. 직접 완료 후 Enter ▶ ")
        return True

    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getUpdates"
    deadline = time.monotonic() + timeout_sec

    # ── 첫 폴: 현재까지 쌓인 메시지의 최신 update_id를 파악해 offset 설정 ──
    # 이렇게 해야 함수 호출 전에 이미 보낸 '인증완료' 메시지로 즉시 통과되는 것을 방지
    offset: int | None = None
    try:
        r = requests.get(url, params={"timeout": 0, "limit": 100}, timeout=10)
        data = r.json()
        if data.get("ok") and data.get("result"):
            last_id = data["result"][-1]["update_id"]
            offset = last_id + 1  # 이 이후 메시지부터 처리
            print(f"  TG 대기 시작 (offset={offset}, 이전 메시지 무시)")
        else:
            print("  TG 대기 시작 (기존 메시지 없음)")
    except Exception as e:
        print(f"  TG 초기 폴링 실패: {e}")

    print(f"  '{keyword}' 입력 대기 중...")
    while time.monotonic() < deadline:
        params: dict = {"timeout": 25}
        if offset is not None:
            params["offset"] = offset
        try:
            r = requests.get(url, params=params, timeout=35)
            data = r.json()
        except requests.RequestException as e:
            print(f"  TG 폴링 오류: {e}")
            time.sleep(5)
            continue

        if not data.get("ok"):
            print(f"  TG getUpdates 실패: {data.get('description', data)[:100]}")
            time.sleep(5)
            continue

        for upd in data.get("result", []):
            offset = upd["update_id"] + 1
            msg = upd.get("message") or {}
            chat_id = str(msg.get("chat", {}).get("id"))
            text = (msg.get("text") or "").strip()
            if chat_id != TELEGRAM_CHAT_ID:
                print(f"  TG chat_id 불일치: 수신={chat_id}, 설정={TELEGRAM_CHAT_ID}")
                continue
            print(f"  TG 수신: {text[:40]!r}")
            if keyword in text:
                tg_send(f"✅ '{keyword}' 수신했습니다. 진행합니다.")
                return True

        time.sleep(2)

    print(f"  '{keyword}' 타임아웃")
    return False


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 쿠키 저장 / 로드
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def save_cookies(driver: webdriver.Chrome) -> None:
    """현재 페이지 + tistory.com + 서브도메인 쿠키를 모두 수집해 저장."""
    all_cookies: list[dict] = []
    seen: set[str] = set()

    # 현재 페이지 쿠키
    for c in driver.get_cookies():
        key = f"{c.get('domain')}:{c.get('name')}"
        if key not in seen:
            seen.add(key)
            all_cookies.append(c)

    # tistory.com 도메인 쿠키 (서브도메인에서 저장하면 메인 도메인 쿠키 누락 방지)
    try:
        driver.get("https://www.tistory.com")
        time.sleep(1)
        for c in driver.get_cookies():
            key = f"{c.get('domain')}:{c.get('name')}"
            if key not in seen:
                seen.add(key)
                all_cookies.append(c)
    except Exception:
        pass

    # 블로그 서브도메인 쿠키
    try:
        driver.get(f"https://{BLOG_NAME}.tistory.com")
        time.sleep(1)
        for c in driver.get_cookies():
            key = f"{c.get('domain')}:{c.get('name')}"
            if key not in seen:
                seen.add(key)
                all_cookies.append(c)
    except Exception:
        pass

    COOKIES_FILE.write_text(json.dumps(all_cookies, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"쿠키 저장 완료 ({len(all_cookies)}개) → {COOKIES_FILE}")


def load_cookies(driver: webdriver.Chrome) -> None:
    cookies = json.loads(COOKIES_FILE.read_text(encoding="utf-8"))
    loaded = 0
    for c in cookies:
        c.pop("sameSite", None)
        try:
            driver.add_cookie(c)
            loaded += 1
        except Exception:
            pass
    print(f"쿠키 로드 완료 ({loaded}/{len(cookies)}개)")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 브라우저 유틸
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def make_driver() -> webdriver.Chrome:
    opts = Options()
    opts.add_argument("--disable-notifications")
    opts.add_argument("--start-maximized")
    opts.add_argument("--lang=ko-KR")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")  # Docker/CI 환경 대응
    opts.add_argument("--disable-software-rasterizer")
    try:
        return webdriver.Chrome(options=opts)
    except WebDriverException as e:
        raise RuntimeError("Chrome WebDriver 실행 실패") from e


def dismiss_alert_if_present(driver: webdriver.Chrome) -> None:
    """alert/confirm 팝업 처리. '이어서 작성' 안내는 accept(예), 나머지는 dismiss."""
    for _ in range(5):
        try:
            alert = driver.switch_to.alert
            text = (alert.text or "").strip()
            # 새 글 작성 페이지: 저장된 글 이어서 작성 안내 → 예 선택해야 에디터 로드
            if "이어서 작성" in text or "저장된 글이 있습니다" in text or ("이어서" in text and "작성" in text):
                print(f"  [alert 감지] 이어서 작성 안내 → accept (예)")
                alert.accept()
                time.sleep(1.5)
            else:
                print(f"  [alert 감지] {text[:60]!r} → dismiss")
                alert.dismiss()
                time.sleep(0.8)
        except Exception:
            break


def safe_get(driver: webdriver.Chrome, url: str, wait: float = 3) -> None:
    """URL 이동 후 alert가 있으면 처리."""
    driver.get(url)
    time.sleep(wait)
    dismiss_alert_if_present(driver)


def _find_title_input(driver: webdriver.Chrome, timeout: int) -> bool:
    """제목 입력란 존재 여부. 메인 문서 + iframe 내부 순서로 여러 셀렉터 시도."""
    title_selectors = [
        "input#post-title-inp",
        "input[name='title']",
        "#post-title-inp",
        "input.post-title-inp",
    ]
    for sel in title_selectors:
        try:
            WebDriverWait(driver, timeout).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, sel))
            )
            return True
        except TimeoutException:
            continue
    # iframe 내부 확인 (티스토리 에디터가 iframe인 경우)
    try:
        iframes = driver.find_elements(By.CSS_SELECTOR, "iframe")
        for i, _ in enumerate(iframes):
            driver.switch_to.default_content()
            driver.switch_to.frame(i)
            for sel in title_selectors:
                try:
                    WebDriverWait(driver, min(timeout, 5)).until(
                        EC.presence_of_element_located((By.CSS_SELECTOR, sel))
                    )
                    return True
                except TimeoutException:
                    continue
    except Exception:
        pass
    finally:
        try:
            driver.switch_to.default_content()
        except Exception:
            pass
    return False


def _dismiss_custom_continue_modal(driver: webdriver.Chrome) -> None:
    """커스텀 모달(div)에서 '이어서 작성'·'예' 버튼 클릭 시도. 네이티브 alert가 아닌 경우용."""
    for xpath in [
        "//button[contains(., '이어서 작성')]",
        "//a[contains(., '이어서 작성')]",
        "//button[contains(., '예')]",
        "//a[contains(., '예')]",
        "//*[@role='dialog']//button[contains(., '예')]",
        "//*[@role='dialog']//button[contains(., '이어서')]",
    ]:
        try:
            el = driver.find_element(By.XPATH, xpath)
            if el.is_displayed():
                el.click()
                print("  [커스텀 모달] 이어서 작성/예 클릭")
                time.sleep(1.5)
                return
        except Exception:
            continue


def wait_for_editor(driver: webdriver.Chrome, timeout: int = 25) -> bool:
    """에디터 로딩 대기. alert/커스텀 모달 처리 후 제목 입력란 대기. 성공 시 True."""
    try:
        WebDriverWait(driver, timeout).until(
            lambda d: d.execute_script("return document.readyState") == "complete"
        )
    except Exception:
        pass
    time.sleep(1)

    # 네이티브 alert 반복 처리 (이어서 작성 → accept)
    for _ in range(4):
        dismiss_alert_if_present(driver)
        _dismiss_custom_continue_modal(driver)
        time.sleep(0.8)

    time.sleep(2)

    # 에디터 제목 입력칸 로딩 대기 (여러 셀렉터 + iframe 시도)
    found = _find_title_input(driver, timeout)
    if not found:
        dismiss_alert_if_present(driver)
        _dismiss_custom_continue_modal(driver)
        time.sleep(2)
        found = _find_title_input(driver, min(timeout, 15))
    dismiss_alert_if_present(driver)
    return found


def click_first(driver: webdriver.Chrome, locators: list[tuple[str, str]], timeout: int = 5):
    """locators를 순서대로 시도해 클릭 가능한 첫 번째 요소 클릭. 모두 실패 시 TimeoutException."""
    for by, val in locators:
        try:
            el = WebDriverWait(driver, timeout).until(EC.element_to_be_clickable((by, val)))
            el.click()
            return
        except Exception:
            pass
    raise TimeoutException(f"클릭 대상 없음: {locators}")


def clipboard_paste(driver: webdriver.Chrome, element, text: str, clear_first: bool = True) -> None:
    """텍스트를 OS 클립보드에 복사한 뒤 element에 Cmd/Ctrl+V 붙여넣기.
    clear_first: True면 기존 내용 삭제 후 붙여넣기 (이어서 작성 시 이전 초안과 섞이는 것 방지).
    """
    if IS_MAC:
        subprocess.run(["pbcopy"], input=text.encode("utf-8"), check=True)
    else:
        try:
            subprocess.run(["xclip", "-selection", "clipboard"], input=text.encode("utf-8"), check=True)
        except FileNotFoundError:
            subprocess.run(["xsel", "--clipboard", "--input"], input=text.encode("utf-8"), check=True)

    element.click()
    time.sleep(0.3)
    if clear_first:
        # input 요소: clear() / contenteditable: 전체 선택 후 붙여넣기로 덮어쓰기
        try:
            tag = element.tag_name.lower()
            if tag == "input" or tag == "textarea":
                element.clear()
            else:
                ActionChains(driver).key_down(MOD_KEY).send_keys("a").key_up(MOD_KEY).perform()
                time.sleep(0.2)
        except Exception:
            ActionChains(driver).key_down(MOD_KEY).send_keys("a").key_up(MOD_KEY).perform()
            time.sleep(0.2)
    ActionChains(driver).key_down(MOD_KEY).send_keys("v").key_up(MOD_KEY).perform()
    time.sleep(0.5)


def is_on_newpost(driver: webdriver.Chrome) -> bool:
    """현재 URL이 newpost 에디터 페이지인지 확인."""
    url = driver.current_url or ""
    return "tistory.com/manage/newpost" in url


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 로그인
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# redirectUrl은 로그인 성공 후 이동할 블로그 newpost URL (BLOG_NAME 반영)
LOGIN_URL = (
    "https://www.tistory.com/auth/login"
    f"?redirectUrl=https%3A%2F%2F{BLOG_NAME}.tistory.com%2Fmanage%2Fnewpost"
)


def _auto_login(driver: webdriver.Chrome) -> None:
    """자동 카카오 로그인 → 추가인증 필요 시 TG 대기."""
    print("자동 카카오 로그인 시도")

    # 1) 티스토리 로그인 페이지 접속
    safe_get(driver, LOGIN_URL, wait=3)

    # 2) 카카오계정으로 로그인 버튼 클릭
    try:
        click_first(
            driver,
            [
                (By.CSS_SELECTOR, "a[href*='kakao']"),
                (By.XPATH, "//a[contains(., '카카오')]"),
                (By.XPATH, "//button[contains(., '카카오')]"),
            ],
            timeout=10,
        )
    except TimeoutException:
        print("  카카오 로그인 버튼 미발견 - 이미 카카오 페이지로 리다이렉트됐을 수 있음")
    time.sleep(3)

    # 3) 이메일/비밀번호 입력
    try:
        email_el = driver.find_element(By.CSS_SELECTOR, "input#loginId")
    except NoSuchElementException:
        try:
            email_el = driver.find_element(By.CSS_SELECTOR, "input[name='loginId']")
        except NoSuchElementException:
            email_el = None

    if email_el:
        email_el.clear()
        email_el.send_keys(TISTORY_EMAIL)
        time.sleep(1)

        try:
            pw_el = driver.find_element(By.CSS_SELECTOR, "input#password")
        except NoSuchElementException:
            pw_el = driver.find_element(By.CSS_SELECTOR, "input[type='password']")
        pw_el.clear()
        pw_el.send_keys(TISTORY_PASSWORD)
        time.sleep(1)

        try:
            click_first(
                driver,
                [
                    (By.CSS_SELECTOR, "button[type='submit']"),
                    (By.CSS_SELECTOR, "button#loginBtn"),
                    (By.XPATH, "//button[contains(., '로그인')]"),
                ],
                timeout=10,
            )
        except TimeoutException:
            print("  로그인 버튼 미발견")
    else:
        print("  이메일 입력칸 미발견 - 이미 로그인됐거나 페이지 구조가 다름")

    time.sleep(5)
    dismiss_alert_if_present(driver)

    # 4) URL로 로그인 성공 여부 판단
    url = driver.current_url or ""
    if "tistory.com/manage" in url:
        print("로그인 성공 → 관리 페이지 도달")
        save_cookies(driver)
        return

    # 5) 추가인증 필요 → TG 알림 후 대기
    print(f"추가 인증 필요 감지 (현재: {url})")
    tg_send(
        "⚠️ 추가 인증이 필요합니다.\n"
        "휴대폰에서 인증 완료 후 '인증완료' 를 입력해주세요. (최대 10분 대기)"
    )
    print("Telegram '인증완료' 대기 중 (최대 10분)...")

    ok = tg_wait_keyword("인증완료", timeout_sec=600)
    if not ok:
        raise RuntimeError("인증완료 타임아웃 (10분)")

    # ── 인증 후 tistory 관리 페이지 도달까지 처리 ──
    # 카카오 2단계 인증 후 흐름:
    #   accounts.kakao.com → kauth.kakao.com/oauth/authorize (계정 선택 필요)
    #   → www.tistory.com/auth/kakao/redirect → geekbrox.tistory.com/manage/newpost
    # "계정 선택" 화면이 뜨면 자동 클릭해야 진행됨

    for attempt in range(20):
        time.sleep(3)
        dismiss_alert_if_present(driver)
        url = driver.current_url or ""
        print(f"  [{attempt+1}/20] URL: {url[:80]}")

        # 성공: tistory 관리 페이지 도달
        if "tistory.com/manage" in url:
            break

        # kauth.kakao.com 또는 accounts.kakao.com: "계속하기" 확인 화면 또는 계정 선택 화면
        if "kauth.kakao.com" in url or "accounts.kakao.com" in url:
            # 현재 페이지 DOM 스냅샷 출력 (디버깅)
            try:
                page_btns = driver.execute_script("""
                    var els = document.querySelectorAll('button, a, [role="button"], li[class*="item"], div[class*="item"]');
                    var out = [];
                    for (var i = 0; i < Math.min(els.length, 30); i++) {
                        var e = els[i];
                        out.push(e.tagName + '.' + (e.className||'').split(' ')[0] + '#' + (e.id||'') + ' → ' + (e.innerText||'').trim().slice(0,30));
                    }
                    return out.join('\\n');
                """)
                print(f"  [카카오 DOM]\n{page_btns}")
            except Exception:
                pass
            try:
                click_first(
                    driver,
                    [
                        # 계속하기 버튼 (가장 일반적)
                        (By.XPATH, "//button[normalize-space(.)='계속하기']"),
                        (By.XPATH, "//a[normalize-space(.)='계속하기']"),
                        (By.XPATH, "//button[contains(normalize-space(.), '계속하기')]"),
                        (By.XPATH, "//a[contains(normalize-space(.), '계속하기')]"),
                        # 카카오 계정 선택 화면 (select_account) - 실제 클래스명
                        (By.CSS_SELECTOR, ".link_account"),       # 계정 항목 링크
                        (By.CSS_SELECTOR, "a.link_account"),
                        (By.CSS_SELECTOR, ".item_account"),       # 계정 항목
                        (By.CSS_SELECTOR, "li.item_account a"),
                        (By.CSS_SELECTOR, ".btn_account"),        # 계정 선택 버튼
                        (By.CSS_SELECTOR, ".wrap_account a"),
                        (By.CSS_SELECTOR, ".list_account li:first-child a"),
                        (By.CSS_SELECTOR, ".list_account li:first-child button"),
                        # 허용/확인 버튼
                        (By.XPATH, "//button[normalize-space(.)='확인']"),
                        (By.XPATH, "//button[normalize-space(.)='동의하고 계속하기']"),
                        (By.XPATH, "//button[contains(., '동의')]"),
                        (By.CSS_SELECTOR, "button[type='submit']"),
                        # 계정 선택 - 첫 번째 항목 클릭 (fallback)
                        (By.XPATH, "//ul[contains(@class,'list') or contains(@class,'account')]//li[1]//a"),
                        (By.XPATH, "//ul[contains(@class,'list') or contains(@class,'account')]//li[1]//button"),
                    ],
                    timeout=5,
                )
                print("  카카오 화면 클릭 완료 (계속하기/계정 선택)")
                time.sleep(5)
                dismiss_alert_if_present(driver)
                continue
            except TimeoutException:
                print(f"  카카오 버튼 미발견 (attempt {attempt+1}) - 자동 진행 대기 중")
            continue

        # tistory.com/auth/login: 로그인 페이지에 다시 떨어짐 → LOGIN_URL 재시도
        if "/auth/login" in url:
            print("  로그인 페이지 감지 → LOGIN_URL 재접속")
            safe_get(driver, LOGIN_URL, wait=5)
            continue

    # 최종 로그인 상태 확인
    dismiss_alert_if_present(driver)
    url = driver.current_url or ""
    if "tistory.com/manage" in url:
        print(f"로그인 성공 확인 → {url[:60]}")
        _debug_print("로그인 성공")
        save_cookies(driver)
    else:
        _debug_print(f"로그인 실패 (최종 URL: {url[:80]})")
        print(f"⚠️ 로그인 실패 (URL: {url})")
        raise RuntimeError(f"카카오 인증 완료 후에도 tistory 로그인 실패. 현재 URL: {url}")


def login(driver: webdriver.Chrome) -> None:
    """cookies.json 유무에 따라 쿠키 로드 또는 자동 로그인. 쿠키 만료 시 재로그인."""

    if COOKIES_FILE.exists():
        print("cookies.json 발견 → 쿠키 로드")

        # www.tistory.com 도메인에 쿠키를 심기 위해 먼저 방문
        safe_get(driver, "https://www.tistory.com", wait=2)
        load_cookies(driver)

        # 서브도메인에도 쿠키 심기
        safe_get(driver, f"https://{BLOG_NAME}.tistory.com", wait=2)
        load_cookies(driver)

        driver.refresh()
        time.sleep(3)
        dismiss_alert_if_present(driver)

        # newpost 페이지로 이동해 실제 로그인 확인
        safe_get(driver, NEWPOST_URL, wait=4)
        url = driver.current_url or ""

        if (
            "tistory.com/manage" in url
            and "accounts.kakao.com" not in url
            and "/auth/login" not in url
        ):
            print("쿠키 로그인 성공")
            _debug_print("쿠키 로그인 성공")
            return

        print(f"쿠키 만료됨 (현재 URL: {url}) → 재로그인")
        dismiss_alert_if_present(driver)
        driver.delete_all_cookies()
        COOKIES_FILE.unlink(missing_ok=True)

    _auto_login(driver)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 글쓰기
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def read_first_post() -> tuple[str, str, Path, Path | None]:
    """drafts/ 폴더에서 첫 번째 .md 파일 하나만 읽어 (제목, 본문, 파일경로, 이미지경로) 반환.

    이미지는 md 파일 내 ![...](../images/xxx) 패턴에서 추출하고,
    없으면 images/ 폴더에서 파일명 stem이 같은 이미지를 자동 탐색.
    """
    if not POSTS_DIR.exists():
        raise FileNotFoundError(f"posts 폴더 없음: {POSTS_DIR}")
    md_files = sorted(POSTS_DIR.glob("*.md"))
    if not md_files:
        raise FileNotFoundError(f"posts 폴더에 .md 없음: {POSTS_DIR}")

    p = md_files[0]
    raw = p.read_text(encoding="utf-8")
    lines = raw.splitlines()
    title = p.stem
    if lines and lines[0].startswith("# "):
        title = lines[0][2:].strip()

    body = "\n".join(lines[1:]).lstrip() if lines and lines[0].startswith("# ") else "\n".join(lines)

    # ── 이미지 경로 추출 ──
    img_path: Path | None = None
    # 1) md 본문에서 ![...](../images/xxx) 패턴 탐색
    img_match = re.search(r"!\[[^\]]*\]\(\.\./images/([^)]+)\)", raw)
    if img_match:
        img_name = img_match.group(1)
        candidate = IMAGES_DIR / img_name
        if candidate.exists():
            img_path = candidate
    # 2) md 본문에서 못 찾으면 파일명 stem으로 images 폴더 탐색
    if not img_path:
        for ext in (".png", ".jpg", ".jpeg", ".gif", ".webp"):
            candidate = IMAGES_DIR / (p.stem + ext)
            if candidate.exists():
                img_path = candidate
                break
    if img_path:
        print(f"  이미지 파일 발견: {img_path.name}")
    else:
        print(f"  이미지 파일 없음 (images/{p.stem}.*)")

    # 본문에서 이미지 마크다운 라인 제거 (Selenium으로 별도 업로드)
    body = re.sub(r"^!\[[^\]]*\]\(\.\./images/[^)]+\)\s*\n?", "", body, flags=re.MULTILINE).lstrip()
    return title, body, p, img_path


def generate_hashtags(title: str, body: str) -> str:
    """제목/본문 내용을 바탕으로 애니 관련 해시태그 10개 생성.
    Claude API 없이 키워드 기반으로 생성하고, 본문에서 장르/작품명 추출.
    반환값: '#태그1 #태그2 ...' 형식의 문자열
    """
    tags: list[str] = []
    combined = (title + " " + body).lower()

    # 기본 공통 태그 (애니 블로그 필수)
    common = ["애니메이션", "애니추천", "일본애니", "2025애니", "애니리뷰"]
    tags.extend(common)

    # 장르 키워드 감지
    genre_map = {
        "액션": "액션애니",
        "판타지": "판타지애니",
        "로맨스": "로맨스애니",
        "개그": "개그애니",
        "코미디": "개그애니",
        "호러": "호러애니",
        "공포": "호러애니",
        "미스터리": "미스터리애니",
        "스포츠": "스포츠애니",
        "isekai": "이세계애니",
        "이세계": "이세계애니",
        "마법": "마법소녀",
        "학원": "학원물",
        "음악": "음악애니",
    }
    for keyword, tag in genre_map.items():
        if keyword in combined and tag not in tags:
            tags.append(tag)
            if len(tags) >= 9:
                break

    # 작품명을 제목에서 추출해 태그로
    # 제목에서 []나 「」 안의 텍스트 또는 콜론 앞 작품명
    work_name = re.sub(r"\[.*?\]|\(.*?\)|【.*?】|「.*?」", "", title).strip()
    work_name = re.sub(r"\s*[-:：|]\s*.*$", "", work_name).strip()
    if work_name and len(work_name) <= 30:
        # 작품명 태그 (공백 제거)
        clean = work_name.replace(" ", "").replace("/", "")
        if clean and clean not in tags:
            tags.append(clean)

    # 계절 태그
    if "2026" in combined:
        tags.append("2026년애니")
    elif "2025" in combined:
        tags.append("2025년애니")

    # 시즌 태그
    if "겨울" in combined or "winter" in combined:
        tags.append("겨울애니")
    elif "봄" in combined or "spring" in combined:
        tags.append("봄애니")
    elif "여름" in combined or "summer" in combined:
        tags.append("여름애니")
    elif "가을" in combined or "autumn" in combined or "fall" in combined:
        tags.append("가을애니")

    # 중복 제거 후 10개로 제한
    seen: set[str] = set()
    final: list[str] = []
    for t in tags:
        if t not in seen:
            seen.add(t)
            final.append(t)
        if len(final) >= 10:
            break

    # 부족하면 보충
    fallbacks = ["애니감상", "오타쿠", "신작애니", "애니정보", "만화"]
    for fb in fallbacks:
        if len(final) >= 10:
            break
        if fb not in seen:
            seen.add(fb)
            final.append(fb)

    return " ".join(f"#{t}" for t in final[:10])


def set_category(driver: webdriver.Chrome, category_name: str = "애니소개 및 리뷰") -> bool:
    """발행 사이드패널 또는 글쓰기 에디터에서 카테고리를 선택. 성공 시 True."""
    # 티스토리 신 에디터: 우측 사이드패널에 카테고리 드롭다운이 있음
    # 패널이 열려 있어야 동작 (publish-layer-btn 클릭 후 호출 권장)
    category_selectors = [
        # 카테고리 셀렉트박스
        (By.CSS_SELECTOR, "select#category"),
        (By.CSS_SELECTOR, "select[name='category']"),
        (By.CSS_SELECTOR, ".tt_category select"),
        (By.CSS_SELECTOR, "[data-role='category'] select"),
        # 카테고리 드롭다운 버튼 (커스텀 UI)
        (By.CSS_SELECTOR, ".btn-category"),
        (By.CSS_SELECTOR, "[class*='category'] button"),
        (By.XPATH, "//button[contains(@class,'category')]"),
        (By.XPATH, "//select[contains(@id,'categ') or contains(@name,'categ')]"),
    ]

    for by, sel in category_selectors:
        try:
            el = WebDriverWait(driver, 3).until(EC.presence_of_element_located((by, sel)))
            tag = el.tag_name.lower()
            if tag == "select":
                from selenium.webdriver.support.ui import Select
                s = Select(el)
                # 텍스트로 옵션 선택
                try:
                    s.select_by_visible_text(category_name)
                    print(f"  카테고리 선택 완료: {category_name}")
                    return True
                except Exception:
                    # 부분 일치 시도
                    for opt in s.options:
                        if category_name in opt.text or opt.text in category_name:
                            s.select_by_visible_text(opt.text)
                            print(f"  카테고리 선택 완료 (부분일치): {opt.text}")
                            return True
            else:
                # 드롭다운 버튼 클릭 후 옵션 선택
                el.click()
                time.sleep(1)
                for opt_xpath in [
                    f"//li[normalize-space(.)='{category_name}']",
                    f"//a[normalize-space(.)='{category_name}']",
                    f"//option[contains(.,'{category_name}')]",
                    f"//*[contains(text(),'{category_name}')]",
                ]:
                    try:
                        opt = WebDriverWait(driver, 3).until(
                            EC.element_to_be_clickable((By.XPATH, opt_xpath))
                        )
                        opt.click()
                        print(f"  카테고리 선택 완료: {category_name}")
                        return True
                    except TimeoutException:
                        continue
        except (TimeoutException, NoSuchElementException):
            continue

    print(f"  ⚠️ 카테고리 드롭다운 미발견 - 발행 패널 열기 후 재시도")
    return False


def switch_to_markdown_mode(driver: webdriver.Chrome) -> bool:
    """티스토리 에디터 모드를 '마크다운'으로 전환. 성공 시 True.
    
    티스토리 에디터는 우측 상단에 '기본모드/마크다운/HTML' 모드 선택 드롭다운이 있음.
    Markdown 문법(##, **, [] 등)이 올바르게 렌더링되려면 마크다운 모드로 전환 필요.
    """
    print("  에디터 모드 → 마크다운 전환 시도")
    
    # 1단계: 모드 선택 드롭다운 버튼 찾기 및 클릭
    mode_button_selectors = [
        # 텍스트로 찾기
        (By.XPATH, "//button[contains(., '기본모드')]"),
        (By.XPATH, "//button[contains(., '모드')]"),
        (By.XPATH, "//div[contains(@class, 'mode')]//button"),
        # class/id로 찾기
        (By.CSS_SELECTOR, "button[class*='mode']"),
        (By.CSS_SELECTOR, "button[class*='editor-mode']"),
        (By.CSS_SELECTOR, "[class*='mode-selector'] button"),
        (By.CSS_SELECTOR, "[class*='mode-dropdown'] button"),
        # aria-label로 찾기
        (By.CSS_SELECTOR, "button[aria-label*='모드']"),
        (By.CSS_SELECTOR, "button[aria-label*='에디터']"),
        # 드롭다운 트리거 일반 패턴
        (By.CSS_SELECTOR, "[role='button'][class*='mode']"),
        (By.CSS_SELECTOR, ".editor-toolbar button"),
    ]
    
    mode_btn = None
    for by, sel in mode_button_selectors:
        try:
            btn = WebDriverWait(driver, 3).until(EC.presence_of_element_located((by, sel)))
            # 버튼이 화면에 보이고 클릭 가능한지 확인
            if btn.is_displayed() and btn.is_enabled():
                mode_btn = btn
                print(f"    모드 버튼 발견: {sel}")
                break
        except (TimeoutException, NoSuchElementException):
            continue
    
    if not mode_btn:
        print("  ⚠️ 모드 선택 버튼 미발견 - 기본 모드로 진행")
        return False
    
    # 드롭다운 열기
    try:
        driver.execute_script("arguments[0].scrollIntoView({block:'center'});", mode_btn)
        time.sleep(0.3)
        mode_btn.click()
        time.sleep(1.5)
        print("    모드 드롭다운 열림")
    except Exception as e:
        print(f"  ⚠️ 모드 버튼 클릭 실패: {e}")
        return False
    
    # 2단계: '마크다운' 옵션 찾기 및 클릭
    markdown_option_selectors = [
        # 텍스트 정확히 일치
        (By.XPATH, "//button[normalize-space(.)='마크다운']"),
        (By.XPATH, "//a[normalize-space(.)='마크다운']"),
        (By.XPATH, "//li[normalize-space(.)='마크다운']"),
        (By.XPATH, "//div[normalize-space(.)='마크다운']"),
        # 텍스트 부분 일치
        (By.XPATH, "//button[contains(., '마크다운')]"),
        (By.XPATH, "//a[contains(., '마크다운')]"),
        (By.XPATH, "//li[contains(., '마크다운')]"),
        (By.XPATH, "//*[@role='option' and contains(., '마크다운')]"),
        (By.XPATH, "//*[@role='menuitem' and contains(., '마크다운')]"),
        # data 속성으로 찾기
        (By.CSS_SELECTOR, "[data-mode='markdown']"),
        (By.CSS_SELECTOR, "[data-value='markdown']"),
        (By.CSS_SELECTOR, "button[value='markdown']"),
        # class로 찾기
        (By.CSS_SELECTOR, ".mode-markdown"),
        (By.CSS_SELECTOR, "[class*='markdown']"),
    ]
    
    for by, sel in markdown_option_selectors:
        try:
            opt = WebDriverWait(driver, 3).until(EC.element_to_be_clickable((by, sel)))
            opt.click()
            time.sleep(1)
            print("  ✅ 마크다운 모드로 전환 완료")
            return True
        except (TimeoutException, NoSuchElementException):
            continue
    
    # JS 폴백: DOM에서 '마크다운' 텍스트를 가진 클릭 가능 요소 탐색
    try:
        md_el = driver.execute_script("""
            var all = document.querySelectorAll('button, a, li, div, span, [role="option"], [role="menuitem"]');
            for (var i = 0; i < all.length; i++) {
                var t = (all[i].innerText || all[i].textContent || '').trim();
                if (t === '마크다운' || t === 'Markdown' || t === 'markdown') {
                    if (all[i].offsetParent !== null) return all[i];
                }
            }
            return null;
        """)
        if md_el:
            md_el.click()
            time.sleep(1)
            print("  ✅ 마크다운 모드로 전환 완료 (JS 폴백)")
            return True
    except Exception:
        pass
    
    print("  ⚠️ 마크다운 옵션 미발견 - 기본 모드로 진행")
    return False


def upload_image_to_editor(driver: webdriver.Chrome, img_path: Path) -> bool:
    """에디터 본문 맨 앞에 이미지를 삽입. Tistory TinyMCE 에디터 이미지 업로드 UI 활용.
    성공 시 True.

    Tistory 에디터는 TinyMCE(keditor) 기반으로, 이미지 업로드는 메인 DOM에 존재하는
    hidden 파일 input (#attach-image, accept="image/*")에 직접 경로를 보내는 방식으로 동작.
    toolbar의 이미지 버튼(attach-layer-btn)은 visible=false / rect={w:0,h:0}이므로 클릭 불가.
    """
    if not img_path or not img_path.exists():
        print(f"  이미지 없음: {img_path}")
        return False

    abs_path = str(img_path.resolve())
    print(f"  이미지 업로드 시도: {img_path.name}")

    def _make_file_input_visible(file_input) -> None:
        """hidden 파일 input을 Selenium send_keys 가능한 상태로 만들기."""
        driver.execute_script("""
            arguments[0].style.display = 'block';
            arguments[0].style.visibility = 'visible';
            arguments[0].style.opacity = '1';
            arguments[0].style.position = 'fixed';
            arguments[0].style.top = '0';
            arguments[0].style.left = '0';
            arguments[0].style.width = '1px';
            arguments[0].style.height = '1px';
            arguments[0].removeAttribute('hidden');
        """, file_input)

    def _try_confirm_dialog() -> None:
        """업로드 후 나타나는 확인/삽입 다이얼로그 버튼 처리."""
        for confirm_sel in [
            (By.XPATH, "//button[normalize-space(.)='확인']"),
            (By.XPATH, "//button[normalize-space(.)='삽입']"),
            (By.XPATH, "//button[contains(., '삽입') or contains(., '업로드') or contains(., '확인')]"),
            (By.CSS_SELECTOR, ".btn-confirm, .btn-insert, .btn-upload"),
        ]:
            try:
                conf = WebDriverWait(driver, 3).until(EC.element_to_be_clickable(confirm_sel))
                conf.click()
                time.sleep(2)
                print("  이미지 삽입 확인 클릭")
                break
            except TimeoutException:
                continue

    # ── 방법 1 (주력): TinyMCE iframe body#tinymce에 DataTransfer 드롭 이벤트 ──
    # 실제 포스팅 테스트에서 이미지 삽입 성공이 확인된 방식.
    # Tistory keditor의 fileUpload/kImage 플러그인이 drop 이벤트를 처리해 이미지 업로드.
    try:
        driver.switch_to.default_content()
        iframe_found = False
        for by, sel in [
            (By.ID, "editor-tistory_ifr"),
            (By.CSS_SELECTOR, "iframe[id*='tistory']"),
            (By.CSS_SELECTOR, "iframe[id*='editor']"),
            (By.CSS_SELECTOR, "iframe.mce-edit-area"),
        ]:
            try:
                iframe = WebDriverWait(driver, 5).until(EC.presence_of_element_located((by, sel)))
                driver.switch_to.frame(iframe)
                iframe_found = True
                break
            except (TimeoutException, NoSuchElementException):
                continue

        if iframe_found:
            editor_body = None
            for body_sel in ("body#tinymce", "body.mce-content-body", "body[contenteditable='true']", "body"):
                try:
                    editor_body = driver.find_element(By.CSS_SELECTOR, body_sel)
                    if editor_body:
                        break
                except NoSuchElementException:
                    continue

            if editor_body:
                import base64
                with open(img_path, "rb") as f:
                    img_b64 = base64.b64encode(f.read()).decode()
                suffix = img_path.suffix.lower()
                mime = "image/png" if suffix == ".png" else ("image/gif" if suffix == ".gif" else "image/jpeg")
                driver.execute_script(f"""
                    var b64 = '{img_b64}';
                    var binary = atob(b64);
                    var ab = new ArrayBuffer(binary.length);
                    var ua = new Uint8Array(ab);
                    for (var i = 0; i < binary.length; i++) ua[i] = binary.charCodeAt(i);
                    var blob = new Blob([ab], {{type: '{mime}'}});
                    var file = new File([blob], '{img_path.name}', {{type: '{mime}'}});
                    var dt = new DataTransfer();
                    dt.items.add(file);
                    var ev = new DragEvent('drop', {{bubbles: true, cancelable: true, dataTransfer: dt}});
                    arguments[0].focus();
                    arguments[0].dispatchEvent(ev);
                """, editor_body)
                time.sleep(4)  # 업로드 처리 대기
                print(f"  ✅ 이미지 업로드 완료 (방법1 DataTransfer drop): {img_path.name}")
                driver.switch_to.default_content()
                return True

        driver.switch_to.default_content()
    except Exception as e:
        print(f"  방법1 실패 (DataTransfer drop): {e}")
        try:
            driver.switch_to.default_content()
        except Exception:
            pass

    # ── 방법 2: 첨부 버튼 JS 클릭 → #attach-image 동적 생성 후 send_keys ──
    # DOM 분석 확인:
    #   - div[aria-label="첨부"] JS click() → #attach-image input 동적 생성
    #   - ⚠️ toggle 방식: 두 번 클릭하면 input이 사라짐 → 재클릭 절대 금지
    #   - ⚠️ TinyMCE iframe 포커스가 있어야 첨부 버튼 정상 작동
    try:
        driver.switch_to.default_content()

        # iframe 포커스 활성화
        try:
            iframe = WebDriverWait(driver, 5).until(
                EC.presence_of_element_located((By.ID, "editor-tistory_ifr"))
            )
            driver.switch_to.frame(iframe)
            driver.find_element(By.CSS_SELECTOR, "body").click()
            time.sleep(0.5)
            driver.switch_to.default_content()
            print("  에디터 iframe 포커스 활성화")
        except Exception:
            try:
                driver.switch_to.default_content()
            except Exception:
                pass

        clicked = driver.execute_script("""
            var parent = document.querySelector('[aria-label="첨부"]');
            if (parent) { parent.click(); return true; }
            var btn = document.getElementById('attach-layer-btn');
            if (btn) { btn.click(); return true; }
            return false;
        """)
        if clicked:
            print("  attach-layer-btn(첨부) 클릭 완료")
            time.sleep(2)
            file_input = WebDriverWait(driver, 8).until(
                EC.presence_of_element_located((By.ID, "attach-image"))
            )
            _make_file_input_visible(file_input)
            time.sleep(0.3)
            file_input.send_keys(abs_path)
            print(f"  #attach-image input에 파일 경로 전달: {img_path.name}")
            time.sleep(5)
            _try_confirm_dialog()
            dismiss_alert_if_present(driver)
            time.sleep(1)
            print(f"  ✅ 이미지 업로드 완료 (방법2 attach-layer-btn): {img_path.name}")
            return True
        else:
            print("  첨부 버튼 미발견")
    except (TimeoutException, NoSuchElementException) as e:
        print(f"  방법2 실패 (attach-layer-btn → #attach-image): {type(e).__name__}")
        try:
            driver.switch_to.default_content()
        except Exception:
            pass

    # ── 방법 3: 메인 DOM file input 직접 탐색 ──
    for sel in ["#attach-image", "input[type='file'][accept*='image']", "input[type='file']"]:
        try:
            driver.switch_to.default_content()
            file_input = WebDriverWait(driver, 3).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, sel))
            )
            _make_file_input_visible(file_input)
            time.sleep(0.3)
            file_input.send_keys(abs_path)
            time.sleep(4)
            print(f"  파일 input({sel}) 직접 전달 완료: {img_path.name}")
            _try_confirm_dialog()
            dismiss_alert_if_present(driver)
            time.sleep(1)
            print(f"  ✅ 이미지 업로드 완료 (방법3 직접): {img_path.name}")
            return True
        except (TimeoutException, NoSuchElementException):
            continue

    print("  ⚠️ 이미지 업로드 실패 - 모든 방법 시도 완료")
    return False


def write_post(driver: webdriver.Chrome, title: str, body: str,
               img_path: Path | None = None, category: str = "애니소개 및 리뷰") -> bool:
    """새 글쓰기: 카테고리 설정 → 이미지 업로드 → 제목/본문 입력 → 해시태그 → 임시저장 → TG 확인 → 발행.
    성공 시 True, 실패 시 False 반환.
    """

    # ── newpost 페이지 진입 및 에디터 확인 ──
    _debug_print("write_post: newpost 이동")
    safe_get(driver, NEWPOST_URL, wait=3)
    editor_ready = wait_for_editor(driver)

    if not editor_ready or not is_on_newpost(driver):
        print(f"  에디터 로딩 실패 (현재 URL: {driver.current_url})")
        tg_send(f"❌ 에디터 로딩 실패: {title}\n현재 URL: {driver.current_url}")
        return False

    print(f"  에디터 준비 완료 (URL: {driver.current_url})")
    _debug_print("에디터 준비 완료")

    # ── 카테고리 설정 (에디터 로드 직후 - 사이드패널이 기본 표시된 상태) ──
    dismiss_alert_if_present(driver)
    if category:
        cat_ok = set_category(driver, category)
        if not cat_ok:
            print(f"  ⚠️ 카테고리 설정 실패 - 계속 진행")
        time.sleep(1)

    # ── 에디터 모드 → 마크다운 전환 ──
    dismiss_alert_if_present(driver)
    switch_to_markdown_mode(driver)
    time.sleep(1)

    # ── 이미지 업로드 (본문 맨 앞에 삽입) ──
    if img_path and img_path.exists():
        img_ok = upload_image_to_editor(driver, img_path)
        if not img_ok:
            print("  ⚠️ 이미지 업로드 실패 - 본문만 작성 계속")
        time.sleep(1)
        dismiss_alert_if_present(driver)
    else:
        print("  이미지 없음 - 본문만 작성")

    # ── 제목 입력 (클립보드 방식) ──
    dismiss_alert_if_present(driver)
    title_el = None
    for sel in ("input#post-title-inp", "input[name='title']", "#post-title-inp", "input.post-title-inp"):
        try:
            title_el = driver.find_element(By.CSS_SELECTOR, sel)
            break
        except NoSuchElementException:
            continue

    if title_el:
        clipboard_paste(driver, title_el, title)
        # 입력 확인
        actual = title_el.get_attribute("value") or ""
        if actual:
            print(f"  제목 입력 완료: {actual[:40]}")
        else:
            print(f"  제목 클립보드 붙여넣기 후 값 비어있음 → send_keys 재시도")
            title_el.click()
            title_el.send_keys(title)
    else:
        print("  제목 입력칸(input#post-title-inp) 미발견")
        tg_send(f"❌ 제목 입력칸 미발견: {title}")
        return False
    time.sleep(2)

    # ── 본문 입력 (클립보드 방식) ──
    dismiss_alert_if_present(driver)
    time.sleep(1)
    # 본문 에디터가 늦게 로드될 수 있으므로 최대 10초 대기
    for sel in ("div.ProseMirror", "[contenteditable='true']", ".toast-ui-editor-contents"):
        try:
            WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CSS_SELECTOR, sel)))
            time.sleep(0.5)
            break
        except TimeoutException:
            continue
    body_el = None
    body_in_iframe = False
    body_selectors = (
        ".ke-content",
        "[data-ke-type='editor']",
        "div[data-ke-editor]",
        ".ke-editor-content",
        "div.ProseMirror",
        "div.te-editor",
        ".toast-ui-editor-contents",
        ".toast-ui-editor-md-container",
        "div.ql-editor",
        ".inner-editor",
        "[contenteditable='true']",
        "div[contenteditable='true']",
        ".se-component-content",
        ".editor-content",
    )
    for selector in body_selectors:
        try:
            els = driver.find_elements(By.CSS_SELECTOR, selector)
            visible = 0
            for el in els:
                if el.is_displayed() and el.is_enabled():
                    visible += 1
                    try:
                        h = el.rect.get("height", 0) if hasattr(el, "rect") else 0
                        if selector in ("[contenteditable='true']", "div[contenteditable='true']") and h < 80:
                            continue
                        if el.get_attribute("contenteditable") == "true" or "ProseMirror" in (el.get_attribute("class") or ""):
                            body_el = el
                            break
                        if selector in (".ke-content", "[data-ke-type='editor']", "div.ProseMirror", "div.te-editor", ".toast-ui-editor-contents", "div.ql-editor"):
                            body_el = el
                            break
                    except Exception:
                        continue
            if body_el:
                break
        except NoSuchElementException:
            continue
    if not body_el and body_selectors:
        try:
            body_el = driver.find_element(By.XPATH, "//div[@contenteditable='true' and (contains(@class,'editor') or contains(@class,'content') or contains(@class,'ProseMirror'))]")
        except NoSuchElementException:
            pass
    if not body_el:
        try:
            candidates = []
            for el in driver.find_elements(By.CSS_SELECTOR, "[contenteditable='true']"):
                try:
                    if el.is_displayed() and el.is_enabled():
                        rect = el.rect
                        if rect.get("height", 0) > 80:
                            candidates.append((el, rect.get("height", 0)))
                except Exception:
                    continue
            if candidates:
                body_el = max(candidates, key=lambda x: x[1])[0]
        except Exception:
            pass
    if not body_el:
        try:
            title_bottom = 0
            for sel in ("input#post-title-inp", "input[name='title']", "#post-title-inp"):
                try:
                    t = driver.find_element(By.CSS_SELECTOR, sel)
                    title_bottom = t.rect.get("y", 0) + t.rect.get("height", 0)
                    break
                except NoSuchElementException:
                    continue
            below_title = []
            for el in driver.find_elements(By.CSS_SELECTOR, "[contenteditable='true']"):
                try:
                    if el.is_displayed() and el.is_enabled():
                        r = el.rect
                        if r.get("y", 0) >= title_bottom - 30 and r.get("height", 0) > 60:
                            below_title.append((el, r.get("height", 0)))
                except Exception:
                    continue
            if below_title:
                body_el = max(below_title, key=lambda x: x[1])[0]
        except Exception:
            pass
    if not body_el:
        try:
            iframes = driver.find_elements(By.CSS_SELECTOR, "iframe")
            for i in range(len(iframes)):
                try:
                    driver.switch_to.default_content()
                    driver.switch_to.frame(i)
                    for sel in ("div.ProseMirror", ".toast-ui-editor-contents", "[contenteditable='true']", "div.ql-editor"):
                        try:
                            els = driver.find_elements(By.CSS_SELECTOR, sel)
                            for el in els:
                                if el.is_displayed() and el.is_enabled():
                                    body_el = el
                                    body_in_iframe = True
                                    break
                            if body_el:
                                break
                        except Exception:
                            continue
                    if body_el:
                        break
                except Exception:
                    continue
        except Exception:
            pass
        finally:
            if not body_el:
                try:
                    driver.switch_to.default_content()
                except Exception:
                    pass
    if body_el:
        try:
            driver.execute_script("arguments[0].scrollIntoView({block:'center'});", body_el)
            time.sleep(0.5)
        except Exception:
            pass
        clipboard_paste(driver, body_el, body)
        time.sleep(1)
        # 본문이 실제로 들어갔는지 확인
        inner = body_el.text or ""
        if len(inner) > 10:
            print(f"  본문 입력 완료 ({len(inner)}자)")
            _debug_print(f"본문 입력 완료 ({len(inner)}자)")
        else:
            print(f"  본문 클립보드 붙여넣기 후 내용 부족({len(inner)}자) → send_keys 재시도")
            body_el.click()
            ActionChains(driver).send_keys(body).perform()
        if body_in_iframe:
            try:
                driver.switch_to.default_content()
            except Exception:
                pass
    else:
        # JS fallback: 브라우저 내부에서 에디터 찾아 텍스트 삽입 (메인 + iframe)
        js_insert = """
            var text = arguments[0];
            var sel = document.querySelectorAll('[contenteditable="true"], div.ProseMirror, .ke-content, .toast-ui-editor-contents');
            var best = null, bestH = 80;
            for (var i = 0; i < sel.length; i++) {
                var el = sel[i];
                var h = el.offsetHeight;
                if (h > bestH && el.offsetParent !== null) { best = el; bestH = h; }
            }
            if (!best) return false;
            best.focus();
            try {
                if (document.execCommand && document.execCommand('insertText', false, text)) return true;
            } catch (e) {}
            best.innerText = text;
            best.dispatchEvent(new Event('input', { bubbles: true }));
            best.dispatchEvent(new Event('change', { bubbles: true }));
            return true;
        """
        inserted = False
        try:
            inserted = driver.execute_script(js_insert, body)
        except Exception:
            pass
        if not inserted:
            try:
                for i in range(len(driver.find_elements(By.CSS_SELECTOR, "iframe"))):
                    try:
                        driver.switch_to.default_content()
                        driver.switch_to.frame(i)
                        inserted = driver.execute_script(js_insert, body)
                        if inserted:
                            driver.switch_to.default_content()
                            break
                    except Exception:
                        continue
                if not inserted:
                    driver.switch_to.default_content()
            except Exception:
                try:
                    driver.switch_to.default_content()
                except Exception:
                    pass
        if inserted:
            print("  본문 입력 완료 (JS fallback)")
            _debug_print("본문 입력 완료 (JS fallback)")
        else:
            print("  본문 입력칸 미발견")
            _debug_print("본문 입력칸 미발견")
            tg_send(f"❌ 본문 입력칸 미발견: {title}")
            return False
    time.sleep(2)

    # ── 해시태그 10개 본문 하단에 추가 ──
    dismiss_alert_if_present(driver)
    hashtags = generate_hashtags(title, body)
    print(f"  해시태그 생성: {hashtags}")
    hashtag_text = "\n\n" + hashtags  # 본문과 줄바꿈 2개 간격

    # Tistory 에디터는 TinyMCE 기반 → editor-tistory_ifr iframe 내부의 body#tinymce 사용
    # 먼저 iframe 내부 시도, 실패 시 메인 DOM contenteditable 시도
    ht_ok = False
    try:
        driver.switch_to.default_content()
        # ── 우선: TinyMCE iframe 내부 body#tinymce 시도 ──
        iframe_sels = [
            (By.ID, "editor-tistory_ifr"),
            (By.CSS_SELECTOR, "iframe[id*='tistory']"),
            (By.CSS_SELECTOR, "iframe[id*='editor']"),
            (By.CSS_SELECTOR, "iframe.mce-edit-area"),
        ]
        ht_el_iframe = None
        for by, sel in iframe_sels:
            try:
                iframe = WebDriverWait(driver, 5).until(EC.presence_of_element_located((by, sel)))
                driver.switch_to.frame(iframe)
                for body_sel in ("body#tinymce", "body.mce-content-body", "body[contenteditable='true']", "body"):
                    try:
                        ht_el_iframe = driver.find_element(By.CSS_SELECTOR, body_sel)
                        if ht_el_iframe:
                            break
                    except NoSuchElementException:
                        continue
                if ht_el_iframe:
                    break
                driver.switch_to.default_content()
            except (TimeoutException, NoSuchElementException):
                try:
                    driver.switch_to.default_content()
                except Exception:
                    pass
                continue

        if ht_el_iframe:
            # iframe 내 editor에서 Cmd/Ctrl+End로 맨 끝 이동 후 클립보드 붙여넣기
            ht_el_iframe.click()
            time.sleep(0.3)
            ActionChains(driver).key_down(MOD_KEY).send_keys(Keys.END).key_up(MOD_KEY).perform()
            time.sleep(0.3)
            clipboard_paste(driver, ht_el_iframe, hashtag_text, clear_first=False)
            print("  해시태그 삽입 완료 (TinyMCE iframe)")
            ht_ok = True
            try:
                driver.switch_to.default_content()
            except Exception:
                pass

        if not ht_ok:
            # ── fallback: 메인 DOM contenteditable 시도 ──
            driver.switch_to.default_content()
            ht_el = None
            for sel in ("div.ProseMirror", ".ke-content", "[contenteditable='true']", "div.te-editor"):
                try:
                    els = driver.find_elements(By.CSS_SELECTOR, sel)
                    for el in els:
                        if el.is_displayed() and el.is_enabled():
                            h = el.rect.get("height", 0) if hasattr(el, "rect") else 0
                            if h > 80 or sel not in ("[contenteditable='true']",):
                                ht_el = el
                                break
                    if ht_el:
                        break
                except Exception:
                    continue

            if ht_el:
                ht_el.click()
                time.sleep(0.3)
                ActionChains(driver).key_down(MOD_KEY).send_keys(Keys.END).key_up(MOD_KEY).perform()
                time.sleep(0.3)
                clipboard_paste(driver, ht_el, hashtag_text, clear_first=False)
                print("  해시태그 삽입 완료 (메인 DOM)")
                ht_ok = True
            else:
                print("  ⚠️ 해시태그 삽입 에디터 미발견 - 건너뜀")

    except Exception as e:
        print(f"  ⚠️ 해시태그 삽입 실패: {e}")
        try:
            driver.switch_to.default_content()
        except Exception:
            pass
    time.sleep(1)

    # ── 임시저장 ──
    dismiss_alert_if_present(driver)
    saved = False
    for selector in ("button.btn-save", "button[data-t='save']", "button.saveBtn"):
        try:
            save_btn = driver.find_element(By.CSS_SELECTOR, selector)
            dismiss_alert_if_present(driver)
            save_btn.click()
            time.sleep(3)
            saved = True
            print("  임시저장 완료")
            break
        except NoSuchElementException:
            continue

    if not saved:
        print("  임시저장 버튼 미발견 - 임시저장 없이 발행 진행")

    preview = body[:100].replace("\n", " ")
    tg_send(
        f"📝 {'임시저장' if saved else '글쓰기'} 완료: {title}\n"
        f"미리보기: {preview}\n\n"
        "포스팅하려면 '포스팅' 이라고 입력하세요"
    )
    print("Telegram에서 '포스팅' 대기 중 (최대 10분)...")
    _debug_print("포스팅 대기 시작")
    # ── '포스팅' 수신 대기 ──
    ok = tg_wait_keyword("포스팅", timeout_sec=600)
    if not ok:
        raise RuntimeError("포스팅 확인 타임아웃 (10분)")

    # ── 발행 ──
    dismiss_alert_if_present(driver)
    pre_publish_url = driver.current_url
    try:
        publish_btn = None

        # 1단계: 발행 사이드패널 열기 (publish-layer-btn)
        # 티스토리 신 에디터: 우측 상단 "발행" 버튼 클릭 시 사이드패널 열림
        panel_opened = False
        for layer_id in ["publish-layer-btn", "publish-layer-btn-open", "publish-layer-btn-open-btn"]:
            try:
                layer_btn = WebDriverWait(driver, 3).until(EC.element_to_be_clickable((By.ID, layer_id)))
                driver.execute_script("arguments[0].scrollIntoView({block:'center'});", layer_btn)
                time.sleep(0.5)
                layer_btn.click()
                time.sleep(2)
                panel_opened = True
                print(f"  발행 패널 열기: #{layer_id}")
                break
            except (NoSuchElementException, TimeoutException):
                continue

        # 2단계: 패널 내 공개 설정 (open20 라디오버튼)
        if panel_opened:
            for open_sel in [
                (By.ID, "open20"),
                (By.CSS_SELECTOR, "input[value='20']"),
                (By.XPATH, "//label[contains(.,'공개')]//input"),
                (By.XPATH, "//input[@type='radio' and (@value='20' or @id='open20')]"),
            ]:
                try:
                    open_btn = WebDriverWait(driver, 3).until(EC.element_to_be_clickable(open_sel))
                    driver.execute_script("arguments[0].click();", open_btn)
                    time.sleep(1)
                    print("  공개 설정 선택")
                    break
                except (NoSuchElementException, TimeoutException):
                    continue

        # 3단계: 발행 버튼 탐색
        for idx, (by, val) in enumerate([
            (By.ID, "publish-btn"),          # 신 에디터 발행 버튼
            (By.CSS_SELECTOR, "button.btn-publish"),
            (By.XPATH, "//button[normalize-space(.)='발행']"),
            (By.XPATH, "//button[normalize-space(.)='발행하기']"),
            (By.XPATH, "//button[normalize-space(.)='지금 발행']"),
            (By.XPATH, "//a[normalize-space(.)='발행']"),
            (By.XPATH, "//button[contains(@class,'publish') and not(contains(@id,'layer'))]"),
            (By.XPATH, "//a[contains(@class,'publish') and not(contains(@id,'layer'))]"),
            (By.XPATH, "//*[@role='button' and normalize-space(.)='발행']"),
            (By.CSS_SELECTOR, "[data-action='publish'], .publish-btn"),
            (By.XPATH, "//button//span[normalize-space(.)='발행']/.."),
            (By.XPATH, "//*[contains(.,'발행') and (self::button or self::a or @role='button')]"),
            (By.CSS_SELECTOR, "[data-testid*='publish'], [aria-label*='발행']"),
            (By.CSS_SELECTOR, ".publish-area button, .post-publish-btn"),
            (By.CSS_SELECTOR, "[id*='publish']:not([id*='layer'])"),
        ]):
            try:
                publish_btn = WebDriverWait(driver, 5).until(EC.element_to_be_clickable((by, val)))
                driver.execute_script("arguments[0].scrollIntoView({block:'center', behavior:'instant'});", publish_btn)
                time.sleep(0.5)
                _debug_print(f"발행 버튼 발견 (셀렉터 {idx + 1}/21): {str(val)[:50]}")
                break
            except (NoSuchElementException, TimeoutException):
                continue
        if not publish_btn:
            # JS 폴백: 페이지 내 '발행'/'공개'/'게시' 텍스트를 가진 클릭 가능 요소 탐색 (Shadow DOM 포함)
            try:
                publish_btn = driver.execute_script("""
                    function findInRoot(root) {
                        var sel = 'button, a, [role="button"], div[onclick], span[onclick], [class*="btn"], [class*="button"], [id*="publish"]';
                        var candidates = root.querySelectorAll(sel);
                        for (var i = 0; i < candidates.length; i++) {
                            var el = candidates[i];
                            var t = (el.innerText || el.textContent || '').trim();
                            if (/발행|공개|게시|지금/.test(t) && el.offsetParent !== null) return el;
                            if (el.id && /publish/i.test(el.id) && el.offsetParent !== null) return el;
                        }
                        var all = root.querySelectorAll('div, span, button, a');
                        for (var i = 0; i < Math.min(all.length, 300); i++) {
                            var el = all[i];
                            if (el.offsetParent === null || el.children.length > 3) continue;
                            var t = (el.innerText || '').trim();
                            if (t === '발행' || t === '지금 발행' || t === '공개하기' || (t.length < 20 && /발행/.test(t))) return el;
                        }
                        var walk = root.querySelectorAll('*');
                        for (var i = 0; i < Math.min(walk.length, 50); i++) {
                            if (walk[i].shadowRoot) {
                                var found = findInRoot(walk[i].shadowRoot);
                                if (found) return found;
                            }
                        }
                        return null;
                    }
                    return findInRoot(document);
                """)
                if publish_btn:
                    _debug_print("발행 버튼 발견 (JS 폴백)")
            except Exception:
                pass
        if not publish_btn:
            # iframe 내부 검색
            try:
                iframes = driver.find_elements(By.TAG_NAME, "iframe")
                for i in range(len(iframes)):
                    try:
                        driver.switch_to.default_content()
                        driver.switch_to.frame(i)
                        publish_btn = driver.execute_script("""
                            var c = document.querySelectorAll('button, a, [role="button"]');
                            for (var j = 0; j < c.length; j++) {
                                var t = (c[j].innerText || c[j].textContent || '').trim();
                                if (/발행|공개|게시/.test(t)) return c[j];
                            }
                            return null;
                        """)
                        if publish_btn:
                            _debug_print("발행 버튼 발견 (iframe 내부)")
                            try:
                                publish_btn.click()
                            except WebDriverException:
                                driver.execute_script("arguments[0].click();", publish_btn)
                            driver.switch_to.default_content()
                            time.sleep(3)
                            dismiss_alert_if_present(driver)
                            # 확인 팝업 처리 후 URL 변경 대기
                            for by, val in [
                                (By.XPATH, "//button[contains(., '확인')]"),
                                (By.XPATH, "//button[contains(., '완료')]"),
                            ]:
                                try:
                                    btn = WebDriverWait(driver, 5).until(EC.element_to_be_clickable((by, val)))
                                    btn.click()
                                    time.sleep(3)
                                    break
                                except TimeoutException:
                                    pass
                            if driver.current_url != pre_publish_url:
                                print(f"  발행 성공 → {driver.current_url}")
                                tg_send(f"✅ 포스팅 완료: {title}\n{driver.current_url}")
                                return True
                            publish_btn = None
                        break
                    except Exception:
                        continue
                try:
                    driver.switch_to.default_content()
                except Exception:
                    pass
            except Exception:
                try:
                    driver.switch_to.default_content()
                except Exception:
                    pass
        if not publish_btn:
            # Tab+Enter 폴백: Tab으로 발행 버튼에 포커스 후 Enter
            try:
                body_tag = driver.find_element(By.TAG_NAME, "body")
                for _ in range(25):
                    body_tag.send_keys(Keys.TAB)
                    time.sleep(0.1)
                    focused = driver.execute_script("return document.activeElement && (document.activeElement.innerText || '').trim();")
                    if focused and ("발행" in focused or "공개" in focused or "게시" in focused):
                        body_tag.send_keys(Keys.ENTER)
                        time.sleep(3)
                        dismiss_alert_if_present(driver)
                        if driver.current_url != pre_publish_url:
                            print(f"  발행 성공 (Tab+Enter) → {driver.current_url}")
                            tg_send(f"✅ 포스팅 완료: {title}\n{driver.current_url}")
                            return True
                        break
            except Exception:
                pass
        if not publish_btn:
            # 키보드 단축키 폴백: Ctrl/Cmd+Enter (일부 에디터에서 발행)
            try:
                body_tag = driver.find_element(By.TAG_NAME, "body")
                body_tag.send_keys(Keys.chord(MOD_KEY, Keys.ENTER))
                time.sleep(3)
                dismiss_alert_if_present(driver)
                if driver.current_url != pre_publish_url:
                    print(f"  발행 성공 (단축키) → {driver.current_url}")
                    tg_send(f"✅ 포스팅 완료: {title}\n{driver.current_url}")
                    return True
                # 확인 팝업 처리
                for by, val in [(By.XPATH, "//button[contains(., '확인')]"), (By.XPATH, "//button[contains(., '완료')]")]:
                    try:
                        btn = WebDriverWait(driver, 5).until(EC.element_to_be_clickable((by, val)))
                        btn.click()
                        time.sleep(3)
                        if driver.current_url != pre_publish_url:
                            print(f"  발행 성공 (단축키+확인) → {driver.current_url}")
                            tg_send(f"✅ 포스팅 완료: {title}\n{driver.current_url}")
                            return True
                        break
                    except TimeoutException:
                        pass
            except Exception:
                pass
        if not publish_btn:
            # DOM 덤프: 페이지 내 버튼/링크 목록 저장 (셀렉터 수정용)
            dump = None
            try:
                driver.switch_to.default_content()
                dump = driver.execute_script("""
                    var out = [];
                    var els = document.querySelectorAll('button, a, [role="button"], [onclick], [class*="btn"], [class*="button"], [class*="publish"], [class*="Publish"]');
                    for (var i = 0; i < Math.min(els.length, 120); i++) {
                        var e = els[i];
                        var t = (e.innerText || e.textContent || '').trim().slice(0, 50);
                        out.push({tag: e.tagName, class: (e.className||'').slice(0,120), text: t, id: (e.id||'').slice(0,80)});
                    }
                    return JSON.stringify(out, null, 2);
                """)
                for dump_path in [OUTPUT_DIR / "publish_button_dump.json", Path.cwd() / "publish_button_dump.json"]:
                    try:
                        dump_path.parent.mkdir(parents=True, exist_ok=True)
                        dump_path.write_text(dump or "[]", encoding="utf-8")
                        _debug_print(f"DOM 덤프 저장: {dump_path}")
                        break
                    except Exception:
                        continue
                if dump:
                    preview = dump.replace("\n", " ")[:250]
                    _debug_print(f"버튼 샘플: {preview}")
            except Exception as e:
                _debug_print(f"DOM 덤프 실패: {str(e)[:80]}")
            _debug_print("발행 버튼 18개 셀렉터 + JS 폴백 + iframe 모두 실패")
            # 실패 시 스크린샷 저장 (디버깅용)
            try:
                for shot_path in [OUTPUT_DIR / "publish_fail_screenshot.png", Path.cwd() / "publish_fail_screenshot.png"]:
                    try:
                        shot_path.parent.mkdir(parents=True, exist_ok=True)
                        driver.save_screenshot(str(shot_path))
                        _debug_print(f"스크린샷 저장: {shot_path}")
                        break
                    except Exception:
                        continue
            except Exception:
                pass
            print("  발행 실패: 발행 버튼을 찾을 수 없습니다.")
            tg_send(f"⚠️ 발행 실패: {title}\n발행 버튼을 찾을 수 없습니다.")
            return False

        dismiss_alert_if_present(driver)
        try:
            publish_btn.click()
        except WebDriverException:
            driver.execute_script("arguments[0].click();", publish_btn)
        time.sleep(4)
        dismiss_alert_if_present(driver)

        # 발행 확인 팝업 처리
        for by, val in [
            (By.XPATH, "//button[contains(., '확인')]"),
            (By.XPATH, "//button[contains(., '완료')]"),
            (By.XPATH, "//button[contains(., '발행하기')]"),
            (By.XPATH, "//button[contains(., '발행')]"),
            (By.XPATH, "//div[contains(@class,'modal')]//button[contains(., '확인') or contains(., '발행')]"),
        ]:
            try:
                btn = WebDriverWait(driver, 5).until(EC.element_to_be_clickable((by, val)))
                try:
                    btn.click()
                except WebDriverException:
                    driver.execute_script("arguments[0].click();", btn)
                time.sleep(3)
                break
            except TimeoutException:
                pass

        # 실제 게시 완료 확인: URL이 newpost에서 벗어나면 성공
        WebDriverWait(driver, 20).until(lambda d: d.current_url != pre_publish_url)
        print(f"  발행 성공 → {driver.current_url}")
        tg_send(f"✅ 포스팅 완료: {title}\n{driver.current_url}")
        return True

    except (NoSuchElementException, TimeoutException, WebDriverException) as e:
        err_msg = getattr(e, "msg", None) or str(e)
        _debug_print(f"발행 예외: {type(e).__name__} | {err_msg[:200]}")
        print(f"  발행 실패: {e}")
        tg_send(f"⚠️ 발행 실패: {title}\n수동으로 블로그를 확인해 주세요.")
        return False


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# main
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def move_to_done(md_path: Path) -> None:
    """완료된 .md 파일을 published/ 폴더로 이동."""
    DONE_DIR.mkdir(parents=True, exist_ok=True)
    dest = DONE_DIR / md_path.name
    shutil.move(str(md_path), str(dest))
    print(f"파일 이동: {md_path.name} → published/")


def main() -> None:
    title, body, md_path, img_path = read_first_post()
    print(f"포스팅 대상: {md_path.name} ({title})")
    print(f"  [스크립트] {Path(__file__).resolve()}")
    if img_path:
        print(f"  [이미지] {img_path}")
    driver = make_driver()
    try:
        login(driver)

        success = write_post(driver, title, body, img_path=img_path, category="애니소개 및 리뷰")

        if success:
            move_to_done(md_path)
            print("완료")
        else:
            print("포스팅 실패 → 파일 이동하지 않음 (재시도 가능)")
    finally:
        try:
            driver.quit()
        except Exception:
            pass


def dump_publish_dom() -> None:
    """디버깅용: 로그인 후 newpost 페이지의 발행 관련 DOM 덤프 수집 (Telegram 불필요)."""
    print("  [--dump-dom] DOM 덤프 모드: 로그인 → newpost → DOM 저장 → 종료")
    driver = make_driver()
    try:
        login(driver)
        safe_get(driver, NEWPOST_URL, wait=5)
        if not wait_for_editor(driver):
            print("  에디터 로딩 실패")
            return
        driver.switch_to.default_content()
        dump = driver.execute_script("""
            var out = [];
            var els = document.querySelectorAll('button, a, [role="button"], [onclick], [class*="btn"], [class*="button"], [class*="publish"], [class*="Publish"]');
            for (var i = 0; i < Math.min(els.length, 120); i++) {
                var e = els[i];
                var t = (e.innerText || e.textContent || '').trim().slice(0, 50);
                out.push({tag: e.tagName, class: (e.className||'').slice(0,120), text: t, id: (e.id||'').slice(0,80)});
            }
            return JSON.stringify(out, null, 2);
        """)
        for p in [OUTPUT_DIR / "publish_button_dump.json", Path.cwd() / "publish_button_dump.json"]:
            try:
                p.parent.mkdir(parents=True, exist_ok=True)
                p.write_text(dump or "[]", encoding="utf-8")
                print(f"  DOM 덤프 저장: {p}")
                break
            except Exception:
                continue
        print("  완료. output/publish_button_dump.json 확인")
    finally:
        try:
            driver.quit()
        except Exception:
            pass


if __name__ == "__main__":
    if "--dump-dom" in sys.argv:
        dump_publish_dom()
    else:
        main()
