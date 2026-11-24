(function () {
  'use strict';

  var REPO_BASE = 'https://github.com/pvkarthikk/illam-app/blob/main/docs/';

  function effectiveTheme() {
    var explicit = document.documentElement.dataset.theme;
    if (explicit === 'light' || explicit === 'dark') {
      return explicit;
    }
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function syncThemeButton(btn) {
    if (!btn) return;
    var isDark = effectiveTheme() === 'dark';
    btn.setAttribute('aria-pressed', String(isDark));
    btn.setAttribute('aria-label', isDark ? 'Switch to light theme' : 'Switch to dark theme');
  }

  function initThemeToggle() {
    var btn = document.getElementById('theme-toggle');
    if (!btn) return;
    syncThemeButton(btn);
    btn.addEventListener('click', function () {
      var next = effectiveTheme() === 'dark' ? 'light' : 'dark';
      document.documentElement.dataset.theme = next;
      try {
        localStorage.setItem('illam-theme', next);
      } catch (_) {}
      syncThemeButton(btn);
    });
  }

  function initMobileNav() {
    var toggle = document.getElementById('menu-toggle');
    var drawer = document.getElementById('mobile-nav');
    if (!toggle || !drawer) return;

    function setOpen(open) {
      toggle.setAttribute('aria-expanded', String(open));
      drawer.hidden = !open;
    }

    toggle.addEventListener('click', function () {
      var isOpen = toggle.getAttribute('aria-expanded') === 'true';
      setOpen(!isOpen);
    });

    drawer.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        setOpen(false);
      });
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') {
        setOpen(false);
        toggle.focus();
      }
    });

    window.addEventListener('resize', function () {
      if (window.innerWidth > 768 && toggle.getAttribute('aria-expanded') === 'true') {
        setOpen(false);
      }
    });
  }

  function initPhoneTabs() {
    var tabs = Array.prototype.slice.call(document.querySelectorAll('[data-phone-tab]'));
    var panels = Array.prototype.slice.call(document.querySelectorAll('[data-phone-panel]'));
    if (!tabs.length || !panels.length) return;

    function activateTab(tab, moveFocus) {
      var targetName = tab.getAttribute('data-phone-tab');
      tabs.forEach(function (t) {
        var active = t === tab;
        t.setAttribute('aria-selected', String(active));
        t.setAttribute('tabindex', active ? '0' : '-1');
      });
      panels.forEach(function (p) {
        var active = p.getAttribute('data-phone-panel') === targetName;
        p.hidden = !active;
        p.classList.toggle('is-active', active);
      });
      if (moveFocus) {
        tab.focus();
      }
    }

    tabs.forEach(function (tab, index) {
      tab.addEventListener('click', function () {
        activateTab(tab, false);
      });

      tab.addEventListener('keydown', function (event) {
        var nextIndex = null;
        if (event.key === 'ArrowRight') {
          nextIndex = (index + 1) % tabs.length;
        } else if (event.key === 'ArrowLeft') {
          nextIndex = (index - 1 + tabs.length) % tabs.length;
        }
        if (nextIndex !== null) {
          event.preventDefault();
          activateTab(tabs[nextIndex], true);
        }
      });
    });
  }

  function initCopyButton() {
    var btn = document.getElementById('copy-url-btn');
    var status = document.getElementById('copy-status');
    if (!btn) return;

    var timerId = null;
    function showCopied() {
      var original = 'Copy URL';
      btn.textContent = 'Copied!';
      if (status) {
        status.textContent = 'Repository URL copied to clipboard.';
      }
      if (timerId) clearTimeout(timerId);
      timerId = setTimeout(function () {
        btn.textContent = original;
        if (status) status.textContent = '';
      }, 2400);
    }

    btn.addEventListener('click', function () {
      var text = btn.getAttribute('data-copy-url') || '';
      if (!text) return;
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(showCopied).catch(function () {
          fallbackCopy(text, showCopied);
        });
      } else {
        fallbackCopy(text, showCopied);
      }
    });
  }

  function fallbackCopy(text, onSuccess) {
    var area = document.createElement('textarea');
    area.value = text;
    area.setAttribute('readonly', '');
    area.style.position = 'fixed';
    area.style.opacity = '0';
    document.body.appendChild(area);
    area.select();
    try {
      document.execCommand('copy');
      onSuccess();
    } catch (_) {}
    document.body.removeChild(area);
  }

  function escapeHtml(str) {
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function renderInline(escaped) {
    var text = escaped;
    text = text.replace(/`([^`]+)`/g, '<code>$1</code>');
    text = text.replace(/\[([^\]]+)\]\((https?:\/\/[^\s)]+|(?:\.\.?\/)[^\s)]+)\)/g, function (_, label, url) {
      return '<a href="' + url + '" target="_blank" rel="noopener noreferrer">' + label + '</a>';
    });
    text = text.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
    text = text.replace(/\*([^*]+)\*/g, '<em>$1</em>');
    return text;
  }

  function renderMarkdown(md) {
    var lines = md.replace(/\r\n/g, '\n').split('\n');
    var html = [];
    var i = 0;
    var inCode = false;
    var codeLines = [];
    var listType = null;
    var para = [];

    function flushPara() {
      if (!para.length) return;
      html.push('<p>' + renderInline(escapeHtml(para.join(' '))) + '</p>');
      para = [];
    }

    function closeList() {
      if (!listType) return;
      html.push('</' + listType + '>');
      listType = null;
    }

    while (i < lines.length) {
      var line = lines[i];
      if (line.trim().indexOf('```') === 0) {
        flushPara();
        closeList();
        if (inCode) {
          html.push('<pre><code>' + escapeHtml(codeLines.join('\n')) + '</code></pre>');
          codeLines = [];
          inCode = false;
        } else {
          inCode = true;
        }
        i++;
        continue;
      }

      if (inCode) {
        codeLines.push(line);
        i++;
        continue;
      }

      var trimmed = line.trim();
      if (!trimmed) {
        flushPara();
        closeList();
        i++;
        continue;
      }

      if (/^---+$/.test(trimmed)) {
        flushPara();
        closeList();
        html.push('<hr>');
        i++;
        continue;
      }

      var headingMatch = trimmed.match(/^(#{1,4})\s+(.*)$/);
      if (headingMatch) {
        flushPara();
        closeList();
        var level = headingMatch[1].length;
        html.push('<h' + level + '>' + renderInline(escapeHtml(headingMatch[2])) + '</h' + level + '>');
        i++;
        continue;
      }

      if (trimmed.indexOf('> ') === 0) {
        flushPara();
        closeList();
        html.push('<blockquote>' + renderInline(escapeHtml(trimmed.slice(2))) + '</blockquote>');
        i++;
        continue;
      }

      var ulMatch = trimmed.match(/^[-*]\s+(.*)$/);
      var olMatch = trimmed.match(/^\d+\.\s+(.*)$/);
      if (ulMatch || olMatch) {
        flushPara();
        var nextType = ulMatch ? 'ul' : 'ol';
        if (listType && listType !== nextType) {
          closeList();
        }
        if (!listType) {
          listType = nextType;
          html.push('<' + listType + '>');
        }
        var content = (ulMatch || olMatch)[1];
        html.push('<li>' + renderInline(escapeHtml(content)) + '</li>');
        i++;
        continue;
      }

      closeList();
      para.push(trimmed);
      i++;
    }

    flushPara();
    closeList();
    if (inCode && codeLines.length) {
      html.push('<pre><code>' + escapeHtml(codeLines.join('\n')) + '</code></pre>');
    }
    return html.join('\n');
  }

  function initDocModal() {
    var modal = document.getElementById('doc-modal');
    var titleEl = document.getElementById('doc-modal-title');
    var bodyEl = document.getElementById('doc-modal-body');
    var rawLink = document.getElementById('doc-modal-raw');
    var ghLink = document.getElementById('doc-modal-gh');
    var closeBtn = document.getElementById('doc-modal-close');
    if (!modal || !bodyEl || typeof modal.showModal !== 'function') return;

    function closeModal() {
      if (modal.open) modal.close();
    }

    if (closeBtn) closeBtn.addEventListener('click', closeModal);
    modal.addEventListener('click', function (event) {
      if (event.target === modal) closeModal();
    });

    var links = document.querySelectorAll('[data-doc-link]');
    links.forEach(function (link) {
      link.addEventListener('click', function (event) {
        if (
          event.defaultPrevented ||
          event.button !== 0 ||
          event.metaKey ||
          event.ctrlKey ||
          event.shiftKey ||
          event.altKey
        ) {
          return;
        }
        if (window.location.protocol !== 'http:' && window.location.protocol !== 'https:') {
          return;
        }

        var href = link.getAttribute('href');
        if (!href) return;
        event.preventDefault();

        var docTitle = link.getAttribute('data-doc-title') || link.textContent || 'Documentation';
        if (titleEl) titleEl.textContent = docTitle;
        if (rawLink) rawLink.setAttribute('href', href);
        if (ghLink) ghLink.setAttribute('href', REPO_BASE + href.replace(/^\.\//, ''));
        bodyEl.innerHTML = '<p>Loading document&hellip;</p>';
        modal.showModal();

        fetch(href)
          .then(function (res) {
            if (!res.ok) throw new Error('HTTP ' + res.status);
            return res.text();
          })
          .then(function (text) {
            bodyEl.innerHTML = renderMarkdown(text);
          })
          .catch(function () {
            closeModal();
            window.location.href = href;
          });
      });
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initThemeToggle();
    initMobileNav();
    initPhoneTabs();
    initCopyButton();
    initDocModal();
  });
})();
