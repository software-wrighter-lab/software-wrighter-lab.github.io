// Theme Toggle Script
// Handles dark/light mode switching with OS preference and localStorage persistence

(function() {
  'use strict';

  const THEME_KEY = 'sw-lab-theme';

  // Get the stored theme or null if not set
  function getStoredTheme() {
    return localStorage.getItem(THEME_KEY);
  }

  // Set the theme in localStorage
  function setStoredTheme(theme) {
    localStorage.setItem(THEME_KEY, theme);
  }

  // Get the OS preference
  function getOSPreference() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    return 'light';
  }

  // Get the current effective theme
  function getCurrentTheme() {
    const stored = getStoredTheme();
    if (stored) {
      return stored;
    }
    return getOSPreference();
  }

  // Apply theme to document
  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    updateToggleIcon(theme);
  }

  // Update the toggle button icon and tooltip
  function updateToggleIcon(theme) {
    const toggleBtn = document.querySelector('.theme-toggle');
    if (!toggleBtn) return;

    const sunIcon = toggleBtn.querySelector('.sun-icon');
    const moonIcon = toggleBtn.querySelector('.moon-icon');
    const oppositeTheme = theme === 'dark' ? 'light' : 'dark';
    const tooltip = 'Switch to ' + oppositeTheme + ' mode';

    toggleBtn.setAttribute('title', tooltip);
    toggleBtn.setAttribute('aria-label', tooltip);

    if (theme === 'dark') {
      if (sunIcon) sunIcon.style.display = 'block';
      if (moonIcon) moonIcon.style.display = 'none';
    } else {
      if (sunIcon) sunIcon.style.display = 'none';
      if (moonIcon) moonIcon.style.display = 'block';
    }
  }

  // Toggle between light and dark
  function toggleTheme() {
    const current = getCurrentTheme();
    const newTheme = current === 'dark' ? 'light' : 'dark';
    setStoredTheme(newTheme);
    applyTheme(newTheme);
  }

  // Initialize theme on page load
  function initTheme() {
    // Apply stored theme or OS preference immediately
    const theme = getCurrentTheme();
    applyTheme(theme);

    // Listen for OS preference changes
    if (window.matchMedia) {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
        // Only auto-switch if user hasn't manually set a preference
        if (!getStoredTheme()) {
          applyTheme(e.matches ? 'dark' : 'light');
        }
      });
    }
  }

  // Set up toggle button click handler
  function initToggleButton() {
    const toggleBtn = document.querySelector('.theme-toggle');
    if (toggleBtn) {
      toggleBtn.addEventListener('click', toggleTheme);
    }
  }

  // Initialize when DOM is ready
  function init() {
    initTheme();
    initToggleButton();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Expose toggle function globally for debugging
  window.toggleTheme = toggleTheme;
})();
