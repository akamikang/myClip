# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

myClip is a Chrome extension that allows users to select text blocks while web browsing, right-click to open the extension, add custom titles, and save the content along with the page URL. The saved data is then emailed via EmailJS to a configured email address.

## Core Architecture

### Chrome Extension Structure
- `manifest.json` - Extension configuration with permissions for contextMenus, activeTab, and storage
- `content.js` - Content script for text selection detection and communication with popup
- `popup.html/js` - Main extension interface for title input, content display, and email sending
- `background.js` - Service worker for context menu creation and inter-script communication
- `options.html/js` - Settings page for EmailJS configuration

### Key Components

#### Text Selection Flow
1. User selects text on any webpage
2. Right-click triggers context menu "Save to myClip"
3. Content script captures selected text and page URL
4. Popup opens with pre-filled content and URL
5. User adds custom title and saves

#### Email Integration (EmailJS)
- Service ID: `service_xru7eg8`
- Template ID: `template_qslbpku` 
- Public Key: `7eX6GLgodFTAfym7j`
- Template variables: `{{name}}`, `{{time}}`, `{{message}}`

#### Data Structure
```javascript
{
  title: String,        // User-defined title
  content: String,      // Selected text block
  url: String,         // Source webpage URL
  timestamp: Date      // When saved
}
```

## Development Commands

### Loading Extension
```bash
# Open Chrome and navigate to chrome://extensions/
# Enable "Developer mode"
# Click "Load unpacked" and select project directory
```

### Testing
```bash
# Manual testing required - no automated test framework
# Test on various websites with different text selections
# Verify email delivery through EmailJS dashboard
```

### Build Process
```bash
# No build process required for basic Chrome extension
# Files are loaded directly by Chrome in developer mode
```

## Chrome Extension Permissions Required

```json
{
  "permissions": [
    "contextMenus",
    "activeTab", 
    "storage"
  ]
}
```

## EmailJS Template Structure

The email template uses HTML formatting with the following structure:
- Header with sender name
- Styled content area with icon and message details
- Responsive table layout for proper email client display
- Template variables: name, time, message for dynamic content

## Settings Configuration

Users can modify EmailJS integration settings:
- Service ID (default: service_xru7eg8)
- Template ID (default: template_qslbpku)  
- Public Key (default: 7eX6GLgodFTAfym7j)
- Email address for receiving clips

## File Communication Flow

1. `content.js` → `background.js`: Selected text and URL data
2. `background.js` → `popup.js`: Data transfer via Chrome messaging
3. `popup.js` → EmailJS API: Send formatted email with clip data
4. `options.js` ↔ Chrome Storage: Save/retrieve user settings