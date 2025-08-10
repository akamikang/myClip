document.addEventListener('DOMContentLoaded', async () => {
  const form = document.getElementById('settingsForm');
  const serviceIdInput = document.getElementById('serviceId');
  const templateIdInput = document.getElementById('templateId');
  const publicKeyInput = document.getElementById('publicKey');
  const emailAddressInput = document.getElementById('emailAddress');
  const saveBtn = document.getElementById('saveBtn');
  const resetBtn = document.getElementById('resetBtn');
  const status = document.getElementById('status');

  const defaultSettings = {
    serviceId: "service_xru7eg8",
    templateId: "template_qslbpku", 
    publicKey: "7eX6GLgodFTAfym7j",
    emailAddress: ""
  };

  await loadSettings();

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    await saveSettings();
  });

  resetBtn.addEventListener('click', async () => {
    await resetToDefaults();
  });

  async function loadSettings() {
    try {
      const settings = await chrome.storage.sync.get([
        'serviceId', 
        'templateId', 
        'publicKey', 
        'emailAddress'
      ]);

      serviceIdInput.value = settings.serviceId || defaultSettings.serviceId;
      templateIdInput.value = settings.templateId || defaultSettings.templateId;
      publicKeyInput.value = settings.publicKey || defaultSettings.publicKey;
      emailAddressInput.value = settings.emailAddress || defaultSettings.emailAddress;
    } catch (error) {
      console.error('Error loading settings:', error);
      showStatus('설정을 불러오는 중 오류가 발생했습니다.', 'error');
    }
  }

  async function saveSettings() {
    const settings = {
      serviceId: serviceIdInput.value.trim(),
      templateId: templateIdInput.value.trim(),
      publicKey: publicKeyInput.value.trim(),
      emailAddress: emailAddressInput.value.trim()
    };

    if (!settings.serviceId || !settings.templateId || !settings.publicKey) {
      showStatus('모든 EmailJS 설정 항목을 입력하세요.', 'error');
      return;
    }

    // 이메일 주소는 EmailJS 템플릿에서 관리하므로 필수가 아님
    if (settings.emailAddress && !isValidEmail(settings.emailAddress)) {
      showStatus('올바른 이메일 주소 형식을 입력하세요.', 'error');
      return;
    }

    try {
      await chrome.storage.sync.set(settings);
      showStatus('✅ 설정이 저장되었습니다!', 'success');
    } catch (error) {
      console.error('Error saving settings:', error);
      showStatus('❌ 설정 저장 중 오류가 발생했습니다.', 'error');
    }
  }

  async function resetToDefaults() {
    if (confirm('기본 설정으로 복원하시겠습니까? (이메일 주소는 유지됩니다)')) {
      try {
        const currentEmail = emailAddressInput.value.trim();
        const resetSettings = {
          ...defaultSettings,
          emailAddress: currentEmail
        };
        
        await chrome.storage.sync.set(resetSettings);
        await loadSettings();
        showStatus('🔄 기본 설정으로 복원되었습니다.', 'success');
      } catch (error) {
        console.error('Error resetting settings:', error);
        showStatus('❌ 설정 복원 중 오류가 발생했습니다.', 'error');
      }
    }
  }

  function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  function showStatus(message, type) {
    status.textContent = message;
    status.className = `status ${type}`;
    status.classList.remove('hidden');
    
    setTimeout(() => {
      status.classList.add('hidden');
    }, 4000);
  }
});