// Font Size Control Script
// Allows users to adjust font size with persistence

(function() {
  'use strict';

  const FONT_SIZE_KEY = 'sw-lab-font-size';
  const MIN_SIZE = 100;  // 100% minimum
  const MAX_SIZE = 190;  // 190% maximum
  const STEP = 10;       // 10% increments
  const DEFAULT_SIZE = 150;

  function getStoredSize() {
    const stored = localStorage.getItem(FONT_SIZE_KEY);
    return stored ? parseInt(stored, 10) : DEFAULT_SIZE;
  }

  function setStoredSize(size) {
    localStorage.setItem(FONT_SIZE_KEY, size.toString());
  }

  function applySize(size) {
    // Only apply to post content, not the whole page
    document.documentElement.style.removeProperty('font-size');
    var postContent = document.querySelector('.post-content');
    if (postContent) {
      postContent.style.fontSize = size + '%';
    }
    // Also apply to home page post list
    var postList = document.querySelector('.post-list');
    if (postList) {
      postList.style.fontSize = size + '%';
    }
    updateButtons(size);
  }

  function updateButtons(size) {
    const decreaseBtn = document.getElementById('font-decrease');
    const increaseBtn = document.getElementById('font-increase');
    const resetBtn = document.getElementById('font-reset');

    if (decreaseBtn) {
      decreaseBtn.disabled = size <= MIN_SIZE;
    }
    if (increaseBtn) {
      increaseBtn.disabled = size >= MAX_SIZE;
    }
    if (resetBtn) {
      resetBtn.style.fontWeight = size === DEFAULT_SIZE ? 'normal' : 'bold';
    }
  }

  function changeSize(delta) {
    let size = getStoredSize() + delta;
    size = Math.max(MIN_SIZE, Math.min(MAX_SIZE, size));
    setStoredSize(size);
    applySize(size);
  }

  function resetSize() {
    setStoredSize(DEFAULT_SIZE);
    applySize(DEFAULT_SIZE);
  }

  function initFontSize() {
    const size = getStoredSize();
    applySize(size);
  }

  function initButtons() {
    const decreaseBtn = document.getElementById('font-decrease');
    const increaseBtn = document.getElementById('font-increase');
    const resetBtn = document.getElementById('font-reset');

    if (decreaseBtn) {
      decreaseBtn.addEventListener('click', function() {
        changeSize(-STEP);
      });
    }
    if (increaseBtn) {
      increaseBtn.addEventListener('click', function() {
        changeSize(STEP);
      });
    }
    if (resetBtn) {
      resetBtn.addEventListener('click', resetSize);
    }
  }

  function init() {
    initFontSize();
    initButtons();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Expose for debugging
  window.resetFontSize = resetSize;
})();
