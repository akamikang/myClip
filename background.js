let selectedText = '';
let currentUrl = '';

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: "saveToMyClip",
    title: "Save to myClip",
    contexts: ["selection"]
  });
  
  chrome.storage.sync.set({
    serviceId: "service_xru7eg8",
    templateId: "template_qslbpku", 
    publicKey: "7eX6GLgodFTAfym7j",
    emailAddress: ""
  });
});

chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  if (info.menuItemId === "saveToMyClip") {
    selectedText = info.selectionText;
    currentUrl = tab.url;
    
    console.log('[Background] Context menu clicked:', { text: selectedText, url: currentUrl });
    
    try {
      // content script에 메시지 전송 (선택사항)
      await chrome.tabs.sendMessage(tab.id, {
        action: "textSelected",
        text: selectedText,
        url: currentUrl
      });
    } catch (error) {
      console.log('[Background] Content script message failed (this is OK):', error);
    }
    
    // 팝업 열기
    try {
      await chrome.action.openPopup();
    } catch (error) {
      console.log('[Background] Could not open popup automatically:', error);
    }
  }
});

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log('[Background] Received message:', message);
  
  if (message.action === "getSelectedData") {
    console.log('[Background] Sending selected data:', { text: selectedText, url: currentUrl });
    sendResponse({
      text: selectedText,
      url: currentUrl
    });
    return true; // 비동기 응답을 위해 필요
  }
  
  if (message.action === "clearSelectedData") {
    console.log('[Background] Clearing selected data');
    selectedText = '';
    currentUrl = '';
    sendResponse({ success: true });
    return true;
  }
});