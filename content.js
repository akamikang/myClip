chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === "textSelected") {
    console.log("Text selected:", message.text);
    console.log("URL:", message.url);
  }
});

document.addEventListener('mouseup', () => {
  const selection = window.getSelection();
  if (selection.toString().trim().length > 0) {
    console.log("Text selection detected:", selection.toString());
  }
});