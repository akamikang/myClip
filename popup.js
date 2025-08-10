document.addEventListener('DOMContentLoaded', async () => {
  const titleInput = document.getElementById('title');
  const contentTextarea = document.getElementById('content');
  const urlInput = document.getElementById('url');
  const saveBtn = document.getElementById('saveBtn');
  const settingsBtn = document.getElementById('settingsBtn');
  const status = document.getElementById('status');
  const form = document.getElementById('clipForm');

  await loadSelectedData();
  
  settingsBtn.addEventListener('click', () => {
    chrome.runtime.openOptionsPage();
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    await saveClip();
  });

  async function loadSelectedData() {
    try {
      const response = await chrome.runtime.sendMessage({action: "getSelectedData"});
      
      if (response && response.text) {
        contentTextarea.value = response.text;
        urlInput.value = response.url || '';
        titleInput.focus();
      } else {
        contentTextarea.value = '텍스트를 선택한 후 우클릭하여 "Save to myClip"을 클릭하세요.';
        saveBtn.disabled = true;
      }
    } catch (error) {
      console.error('Error loading selected data:', error);
    }
  }

  async function saveClip() {
    const title = titleInput.value.trim();
    const content = contentTextarea.value.trim();
    const url = urlInput.value.trim();

    console.log('[myClip Debug] Starting email send process...');
    console.log('[myClip Debug] Title:', title);
    console.log('[myClip Debug] Content length:', content.length);
    console.log('[myClip Debug] URL:', url);

    if (!title) {
      console.log('[myClip Debug] Error: No title provided');
      showStatus('제목을 입력하세요.', 'error');
      return;
    }

    if (!content || content === '텍스트를 선택한 후 우클릭하여 "Save to myClip"을 클릭하세요.') {
      console.log('[myClip Debug] Error: No content provided');
      showStatus('저장할 콘텐츠가 없습니다.', 'error');
      return;
    }

    saveBtn.disabled = true;
    saveBtn.textContent = '전송 중...';
    
    try {
      console.log('[myClip Debug] Loading settings from Chrome storage...');
      const settings = await chrome.storage.sync.get([
        'serviceId', 
        'templateId', 
        'publicKey', 
        'emailAddress'
      ]);

      console.log('[myClip Debug] Settings loaded:', {
        serviceId: settings.serviceId || 'NOT SET',
        templateId: settings.templateId || 'NOT SET',
        publicKey: settings.publicKey ? '***SET***' : 'NOT SET',
        emailAddress: settings.emailAddress || 'NOT SET'
      });

      if (!settings.serviceId || !settings.templateId || !settings.publicKey) {
        console.log('[myClip Debug] Error: Missing EmailJS configuration');
        showStatus('EmailJS 설정이 완전하지 않습니다. 설정을 확인하세요.', 'error');
        return;
      }

      console.log('[myClip Debug] Initializing EmailJS...');
      emailjs.init(settings.publicKey);

      const templateParams = {
        name: title,
        time: new Date().toLocaleString('ko-KR'),
        message: `${content}\n\n출처: ${url}`
      };

      console.log('[myClip Debug] Template params:', {
        name: templateParams.name,
        time: templateParams.time,
        message_length: templateParams.message.length
      });

      console.log('[myClip Debug] Sending email via EmailJS...');
      const response = await emailjs.send(
        settings.serviceId,
        settings.templateId,
        templateParams
      );

      console.log('[myClip Debug] EmailJS response:', response);
      showStatus('✅ 이메일이 성공적으로 전송되었습니다!', 'success');
      
      chrome.runtime.sendMessage({action: "clearSelectedData"});
      
      setTimeout(() => {
        window.close();
      }, 2000);

    } catch (error) {
      console.error('[myClip Debug] Email sending failed:', error);
      
      // EmailJS v4 에러 객체 처리
      let errorDetails = {};
      if (error && typeof error === 'object') {
        errorDetails = {
          status: error.status || 'unknown',
          text: error.text || error.message || 'unknown',
          name: error.name || 'unknown'
        };
      } else if (typeof error === 'string') {
        errorDetails = { message: error };
      }
      
      console.error('[myClip Debug] Error details:', errorDetails);
      
      let errorMessage = '❌ 이메일 전송에 실패했습니다.';
      
      if (error.status === 400) {
        errorMessage += ' EmailJS 템플릿 설정을 확인하세요.';
      } else if (error.status === 401) {
        errorMessage += ' EmailJS Public Key를 확인하세요.';
      } else if (error.status === 403) {
        errorMessage += ' EmailJS 권한을 확인하세요.';
      } else if (error.status === 404) {
        errorMessage += ' EmailJS Service ID 또는 Template ID를 확인하세요.';
      } else if (error.text && error.text.includes('rate')) {
        errorMessage += ' 전송 한도를 초과했습니다. 잠시 후 다시 시도하세요.';
      } else {
        const errorText = error.text || error.message || '알 수 없는 오류';
        errorMessage += ` (${errorText})`;
      }
      
      showStatus(errorMessage, 'error');
    } finally {
      saveBtn.disabled = false;
      saveBtn.textContent = '저장하기';
    }
  }

  function showStatus(message, type) {
    status.textContent = message;
    status.className = `status ${type}`;
    status.classList.remove('hidden');
    
    setTimeout(() => {
      status.classList.add('hidden');
    }, 5000);
  }
});