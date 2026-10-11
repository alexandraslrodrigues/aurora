/* Aurora — page router (addresses like #/cognitive/report) and simple pages. */
(function (root) {
  "use strict";
  var A = root.Aurora, ui = A.ui, h = ui.h, P = A.content.pages, t = A.t;
  var app = document.getElementById("app");
  var HOME_TITLE = t(document.title);   // the title written in index.html (also what search engines show)

  var CATS = ["cognitive", "movement"];
  var TABS = [["report", "Aurora Report"], ["protocol", t("Protocol")], ["calculators", t("Calculators")]];

  // Calculators of each category (each has its own address)
  A.calculatorLinks = function (cat) {
    if (cat === "cognitive") {
      return A.atrophyCalcs.list.map(function (c) {
        return { slug: c.slug, title: c.title, rail: c.rail, short: c.short,
                 desc: c.desc, href: "#/cognitive/calculators/" + c.slug };
      });
    }
    return A.content.movement.calculators.map(function (c) {
      return { slug: c.slug, title: c.title, rail: c.rail, short: c.rail,
               desc: t("Formula: {formula}", { formula: A.content.movement.indices[c.index].formula }), href: "#/movement/calculators/" + c.slug };
    });
  };

  function parse() {
    var parts = (location.hash || "#/").replace(/^#\/?/, "").split("/").filter(Boolean);
    return parts;
  }

  function setNav(active) {
    document.querySelectorAll(".mainnav a").forEach(function (a) {
      a.classList.toggle("active", a.getAttribute("data-nav") === active);
    });
  }

  function page(cls) { var el = h("div", { class: "page " + (cls || "") }); app.appendChild(el); return el; }

  function home() {
    document.title = HOME_TITLE;
    var logo = h("div", { class: "home-logo" }, h("img", { src: "icons/icon-128.png", alt: "" }), h("span", null, "aurora"));
    var el = h("div", { class: "home" },
      h("div", { class: "home-hero" }, logo, h("p", { class: "tagline" }, P.tagline)),
      h("div", { class: "home-cards" }, CATS.map(function (cat) {
        var c = P.categories[cat];
        return h("a", { class: "home-card", href: "#/" + cat }, h("div", { class: "hc-title" }, c.title));
      })),
      // the home page has no top bar: Help and About are at the bottom
      h("nav", { class: "home-foot", "aria-label": t("More") }, h("a", { href: "#/help" }, t("Help")), h("a", { href: "#/about" }, t("About"))));
    app.appendChild(el);
    if (A.liveIcon) A.liveIcon(logo.querySelector("img"));
  }

  // Category landing (three choices) and its pages
  function category(cat, tab, sub) {
    var c = P.categories[cat];
    var pg = page();
    if (!tab) {
      document.title = c.title + " · Aurora";
      pg.classList.add("landing");
      pg.appendChild(h("div", { class: "landing-head" }, h("h1", null, c.title)));
      pg.appendChild(h("div", { class: "tiles" }, TABS.map(function (t) {
        // a part that is not ready yet (Movement disorders · Aurora Report) is shown greyed out, not clickable
        if (c.soon && c.soon.indexOf(t[0]) >= 0) {
          return h("div", { class: "tile disabled", "aria-disabled": "true" },
            h("span", { class: "tile-t" }, t[1]), h("span", { class: "tile-d" }, c.tiles[t[0]]));
        }
        return h("a", { class: "tile" + (t[0] === "report" ? " primary" : ""), href: "#/" + cat + "/" + t[0] },
          h("span", { class: "tile-t" }, t[1]), h("span", { class: "tile-d" }, c.tiles[t[0]]));
      })));
      return;
    }
    var current = TABS.filter(function (t) { return t[0] === tab; })[0];
    if (!current) return notFound();
    var headSlot = h("div", { class: "head-slot" });
    // One-line title: "Category / Section" (the category links back to its page)
    pg.classList.add("section-page");
    pg.appendChild(h("div", { class: "page-head" + ((tab === "report" && cat === "cognitive") || tab === "calculators" ? " sticky" : "") },
      h("h1", null,
        h("a", { class: "crumb", href: "#/" + cat }, c.title),
        h("span", { class: "crumb-sep", "aria-hidden": "true" }, "/"),
        h("span", null, current[1])),
      headSlot));

    if (tab === "report") {
      document.title = current[1] + " · " + c.title;
      if (cat === "cognitive") A.reportPage.render(pg, headSlot);
      else pg.appendChild(h("div", { class: "prose", html: P.movementReport }));
    } else if (tab === "protocol") {
      document.title = current[1] + " · " + c.title;
      if (!protocolPage(pg, headSlot, cat, sub)) return notFound();
    } else if (tab === "calculators") {
      // Calculators opens straight on the first one; the others are in the list next to it
      var links = A.calculatorLinks(cat);
      if (!sub) { sub = links[0].slug; history.replaceState(null, "", links[0].href); }
      var ok = cat === "movement" ? A.movementCalcs.render(pg, sub, headSlot) : A.atrophyCalcs.render(pg, sub, cat, headSlot);
      if (!ok) return notFound();
      var link = links.filter(function (l) { return l.slug === sub; })[0];
      document.title = link.short + " · " + c.title;
    }
  }

  // Protocol page: "Recommended protocol", then the protocol as one table in a grey box with the field strength
  // and abbreviations at the end. ⓘ next to the title opens the references on the right (a pop-up on phones).
  var ICON_INFO = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 11v6"/><circle cx="12" cy="7.6" r=".6" fill="currentColor"/></svg>';
  var ICON_X = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>';
  var protoRefsOpen = false;
  function protocolPage(pg, headSlot, cat, sub) {
    // keep "3 T", "1 mm", "20 ms" on one line
    function nb(t) { return String(t).replace(/(\d) (?=(T|mm|ms)\b)/g, "$1\u00a0"); }
    var PR = A.content.protocols;
    var list = ((PR && PR[cat]) || []).filter(function (p) { return !p.hidden; });
    if (!list.length) { pg.appendChild(h("div", { class: "prose", html: P.protocol[cat] })); return !sub; }
    var cur = sub ? list.filter(function (p) { return p.id === sub; })[0] : list[0];
    if (!cur) return false;
    if (list.length > 1) {
      headSlot.appendChild(h("div", { class: "rtabs", role: "tablist", "aria-label": t("Protocol") }, list.map(function (p) {
        return h("button", { type: "button", role: "tab", "aria-selected": p === cur ? "true" : "false",
          onclick: function () { if (p !== cur) location.hash = "#/" + cat + "/protocol/" + p.id; } }, p.tab);
      })));
    }

    // sections with the same columns share one table (column names once, "Core" / "Optional" as group rows)
    var tables = [];
    cur.sections.forEach(function (sec) {
      var last = tables[tables.length - 1];
      if (last && last.cols.join("|") === sec.cols.join("|")) last.sections.push(sec);
      else tables.push({ cols: sec.cols, colsEn: sec.colsEn || sec.cols, sections: [sec] });
    });
    var box = h("div", { class: "pr-box" },
      tables.map(function (t) {
        return h("table", { class: "pr-table cols-" + t.cols.length },
          h("thead", null, h("tr", null, t.cols.map(function (c) { return h("th", { scope: "col" }, c); }))),
          t.sections.map(function (sec) {
            return h("tbody", null,
              h("tr", { class: "pr-group" }, h("th", { colspan: t.cols.length, scope: "rowgroup" }, sec.title)),
              sec.rows.map(function (r) {
                return h("tr", null, r.map(function (v, i) {
                  return i === 0 ? h("th", { scope: "row" }, nb(v))
                                 : h("td", { "data-col": t.cols[i], class: t.colsEn[i] === "Look for" ? "look" : null }, nb(v));
                }));
              }));
          }));
      }),
      cur.field ? h("div", { class: "pr-end" }, h("h3", null, A.t("Field strength")), h("p", null, nb(cur.field))) : null,
      cur.abbreviations ? h("p", { class: "pr-abbr" }, A.t("Abbreviations: {list}.", { list: cur.abbreviations })) : null);

    // references (ⓘ)
    function refsNode() {
      return h("div", { class: "info-content pr-refs-list" },
        h("ul", null, (cur.refs || []).map(function (r) { return h("li", null, h("a", { href: r[1] }, r[0])); })),
        PR.updated ? h("p", { class: "pr-updated" }, t("Updated {date}", { date: PR.updated })) : null);
    }
    var ref = h("aside", { class: "ref-panel", "aria-label": t("References") });
    var infoBtn = h("button", { type: "button", class: "info-link", title: t("References"), "aria-label": t("References"),
      onclick: function () {
        if (root.innerWidth < 1024) { ui.openModal(t("References"), ui.externalLinks(refsNode())); return; }
        setOpen(!protoRefsOpen, true);
      } }, h("span", { class: "tab-ic", html: ICON_INFO }));
    function setOpen(open, animate) {
      protoRefsOpen = open;
      pg.classList.toggle("ref-open", open);
      pg.classList.toggle("ref-anim", !!(open && animate));
      infoBtn.setAttribute("aria-pressed", open ? "true" : "false");
    }
    ref.appendChild(h("div", { class: "ref-head" }, h("h2", null, t("References")),
      h("button", { type: "button", class: "icon-btn ref-close", "aria-label": t("Close"), title: t("Close"), html: ICON_X, onclick: function () { setOpen(false); } })));
    ref.appendChild(ui.externalLinks(refsNode()));
    pg.classList.add("proto-page");
    pg.appendChild(h("div", { class: "proto-shell" },
      h("div", { class: "proto-main" },
        h("div", { class: "step-head" }, h("div", { class: "step-title" }, h("h2", null, t("Recommended protocol")), infoBtn)),
        box,
        (cur.notes && cur.notes.length) ? h("div", { class: "pr-notes" }, cur.notes.map(function (n) { return h("p", null, nb(n)); })) : null),
      ref));
    setOpen(protoRefsOpen, false);
    return true;
  }

  function textPage(kind, html, withLicense) {
    document.title = t(kind === "about" ? "About" : "Help") + " · Aurora";
    var pg = page("about");
    var box = h("div", { class: "prose", html: html });
    ui.externalLinks(box);
    if (kind === "help") box.className = "prose about-page help-page";
    if (kind === "about") {
      box.className = "prose about-page";
      var pc = box.querySelector("[data-open-feedback]");      // "Propose a collaboration": the message form, on Collaboration
      if (pc) pc.addEventListener("click", function () { openFeedback(pc.getAttribute("data-open-feedback")); });
      var cb = box.querySelector("[data-copy-cite]");
      if (cb) cb.addEventListener("click", function () {
        var ct = box.querySelector(".cite-text");
        ui.copyText(ct ? ct.textContent.replace(/\s+/g, " ").trim() : "").then(function (ok) { ui.toast(ok ? t("Citation copied") : t("Copy failed")); });
      });
    }
    pg.appendChild(box);
    if (withLicense) pg.appendChild(ui.externalLinks(h("p", { class: "license", html: P.license })));
  }

  function notFound() {
    document.title = t("Page not found") + " · Aurora";
    app.innerHTML = "";
    var pg = page("narrow");
    pg.appendChild(h("div", { class: "prose" }, h("h1", null, t("Page not found")), h("p", null, h("a", { href: "#/" }, t("Go to the home page")))));
  }

  function route() {
    var p = parse();
    app.innerHTML = "";
    document.querySelectorAll(".modal[open]").forEach(function (m) { if (m.close) m.close(); });
    setNav(p[0] || "");
    document.body.classList.toggle("home-page", !p.length);
    // addresses longer than the pages that exist show "Page not found"
    var depth = { report: 2, protocol: 3, calculators: 3 };
    if (!p.length) {
      // the home page keeps a clean address: aurora-report.com instead of aurora-report.com/#/
      if (location.hash) { try { history.replaceState(null, "", location.pathname + location.search); } catch (e) { /* ignore */ } }
      home();
    }
    else if (CATS.indexOf(p[0]) >= 0 && (!p[1] || p.length <= (depth[p[1]] || 2))) category(p[0], p[1], p[2]);
    else if (p[0] === "help" && p.length === 1) textPage("help", P.help, true);
    else if (p[0] === "about" && p.length === 1) textPage("about", P.about, true);
    else notFound();
    root.scrollTo(0, 0);
    if (routed) app.focus({ preventScroll: true });   // screen readers start at the new page (not on first load)
    routed = true;
    trackPage();
  }
  var routed = false;

  /* ------------------------------------------------------------------ message button (feedback / collaboration)
     Always at the bottom right. Sends the text by email through Web3Forms when P.feedbackKey is set;
     otherwise it opens the user's email app with the text already written. */
  var ICON_MSG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20.5l1.4-4.6A8 8 0 1 1 21 12z"/><path d="M8.5 10.5h7M8.5 13.5h4.5"/></svg>';
  // Two kinds: Feedback (suggestions, bugs, technical issues, scientific inaccuracies) and Collaboration.
  function feedbackForm(startKind) {
    var kind = startKind === "Involved" ? "Involved" : "Feedback";
    function hint() { return kind === "Involved" ? t("Write your message") : t("Share your feedback or report an issue"); }
    var kinds = ui.seg({ options: [{ value: "Feedback", label: t("Feedback") }, { value: "Involved", label: t("Collaboration") }],
                         get: function () { return kind; }, cls: "fb-kind", label: t("Type of message"),
                         set: function (v) {
                           kind = v; kinds.sync(); status.textContent = "";
                           msg.placeholder = hint();
                           var need = v === "Involved";          // to get involved we need an email to reply to
                           mail.placeholder = need ? t("Email") : t("Email (optional)");
                           mail.setAttribute("aria-label", need ? t("Email") : t("Email (optional)"));
                         } });
    var msg = h("textarea", { id: "fb-msg", rows: "6", maxlength: "4000", placeholder: hint(), "aria-label": t("Message") });
    var mail = h("input", { type: "email", id: "fb-mail", autocomplete: "email", placeholder: kind === "Involved" ? t("Email") : t("Email (optional)"),
                            "aria-label": kind === "Involved" ? t("Email") : t("Email (optional)") });
    var status = h("p", { class: "fb-status", role: "status" });
    var send = h("button", { type: "submit", class: "btn primary" }, P.feedbackKey ? t("Send") : t("Write the email"));
    var form = h("form", { class: "fb-form", novalidate: true }, kinds, msg, mail,
      h("p", { class: "fb-note" }, t("Please do not include patient information.")),
      h("div", { class: "fb-actions" }, send, status));
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      var text = msg.value.trim();
      if (!text) { status.textContent = t("Write a message first."); msg.focus(); return; }
      if (kind === "Involved" && !mail.value.trim()) { status.textContent = t("Add your email so we can reply."); mail.focus(); return; }
      if (mail.value.trim() && !mail.checkValidity()) { status.textContent = kind === "Involved" ? t("Check the email address.") : t("Check the email address, or leave it empty."); mail.focus(); return; }
      var subject = "Aurora: " + (kind === "Involved" ? "get involved" : "feedback");
      var body = text + "\n\nPage: " + (location.hash || "#/");
      if (!P.feedbackKey) {             // no key yet: the user's email app opens with the message
        location.href = "mailto:" + P.contactEmail + "?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body);
        return;
      }
      send.disabled = true; status.textContent = t("Sending…");
      fetch("https://api.web3forms.com/submit", {
        method: "POST", headers: { "Content-Type": "application/json", Accept: "application/json" },
        body: JSON.stringify({ access_key: P.feedbackKey, subject: subject, from_name: "Aurora website", email: mail.value.trim() || undefined,
                               message: body, botcheck: false })
      }).then(function (r) { return r.json(); }).then(function (d) {
        if (!d || !d.success) throw new Error("not sent");
        ui.closeModal(); ui.toast(t("Thank you, your message was sent"));
      }).catch(function () {
        send.disabled = false;
        status.innerHTML = "";
        A.i18n.tn("Not sent. Check your connection, or write to {email}.", {
          email: h("a", { href: "mailto:" + P.contactEmail + "?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body) }, P.contactEmail)
        }).forEach(function (x) { status.appendChild(typeof x === "string" ? document.createTextNode(x) : x); });
      });
    });
    return form;
  }
  function openFeedback(kind) { ui.openModal(t("Send us a message"), feedbackForm(kind)); var m = document.getElementById("fb-msg"); if (m) m.focus(); }
  var fbBtn = h("button", { type: "button", class: "fb-btn", "aria-label": t("Send a message: feedback or collaboration"), title: t("Feedback"),
    onclick: function () { openFeedback(); } },
    h("span", { class: "tab-ic", html: ICON_MSG }));
  document.body.appendChild(fbBtn);

  // "Skip to content" moves the focus to the page without changing the address
  var skip = document.querySelector(".skip");
  if (skip) skip.addEventListener("click", function (e) { e.preventDefault(); app.focus(); });

  // Google Analytics: one page view per page (the address after # counts as the page)
  var gaId = P.analyticsId, gaOn = !!gaId && location.protocol === "https:";
  if (gaOn) {
    root.dataLayer = root.dataLayer || [];
    root.gtag = function () { root.dataLayer.push(arguments); };
    root.gtag("js", new Date());
    root.gtag("config", gaId, { send_page_view: false });
    var s = document.createElement("script");
    s.async = true;
    s.src = "https://www.googletagmanager.com/gtag/js?id=" + encodeURIComponent(gaId);
    document.head.appendChild(s);
  }
  function trackPage() {
    if (!gaOn) return;
    // "#/cognitive/report" is reported as the page "/cognitive/report"
    var path = location.hash.replace(/^#\/?/, "/") || "/";
    root.gtag("event", "page_view", {
      page_location: location.origin + path,
      page_path: path,
      page_title: document.title
    });
  }

  // Night mode button (light by default; the choice is remembered on this device)
  var MOON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/></svg>';
  var SUN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="4.5"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>';
  var themeBtn = document.getElementById("theme-btn");
  function applyTheme(dark) {
    if (dark) document.documentElement.setAttribute("data-theme", "dark"); else document.documentElement.removeAttribute("data-theme");
    themeBtn.innerHTML = dark ? SUN : MOON;
    themeBtn.setAttribute("aria-label", dark ? t("Day mode") : t("Night mode"));
    themeBtn.title = dark ? t("Day mode") : t("Night mode");
    themeBtn.setAttribute("aria-pressed", dark ? "true" : "false");
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute("content", dark ? "#141417" : "#ffffff");
  }
  applyTheme(ui.local.get("aurora.theme") === "dark" || document.documentElement.getAttribute("data-theme") === "dark");
  themeBtn.addEventListener("click", function () {
    var dark = document.documentElement.getAttribute("data-theme") !== "dark";
    try { localStorage.setItem("aurora.theme", dark ? "dark" : "light"); } catch (e) { /* ignore */ }
    applyTheme(dark);
  });

  // Language (top right, next to the moon). The choice is remembered on this device; changing it reloads the page.
  (function () {
    var langs = A.i18n.languages;
    if (langs.length < 2) return;
    var cur = A.i18n.meta();
    var items = langs.map(function (l) {
      return h("button", { type: "button", role: "menuitemradio", lang: A.i18n.meta(l.id).htmlLang,
                           "aria-checked": l.id === A.lang ? "true" : "false",
                           onclick: function () { close(); A.i18n.setLang(l.id); } },
        h("span", { class: "lp-name" }, l.name), h("span", { class: "lp-code", "aria-hidden": "true" }, l.code));
    });
    var menu = h("div", { class: "lang-pop", role: "menu", "aria-label": t("Language"), hidden: true }, items);
    var btn = h("button", { type: "button", class: "lang-btn", "aria-haspopup": "menu", "aria-expanded": "false",
                            "aria-label": t("Language: {name}", { name: cur.name }), title: t("Language"),
                            onclick: function () { if (menu.hidden) open(); else close(); } }, cur.code);
    var wrap = h("div", { class: "lang-menu" }, btn, menu);
    themeBtn.parentNode.insertBefore(wrap, themeBtn);
    function open() {
      menu.hidden = false; btn.setAttribute("aria-expanded", "true");
      (menu.querySelector('[aria-checked="true"]') || items[0]).focus();
    }
    function close() { menu.hidden = true; btn.setAttribute("aria-expanded", "false"); }
    document.addEventListener("click", function (e) { if (!menu.hidden && !wrap.contains(e.target)) close(); });
    wrap.addEventListener("keydown", function (e) {
      if (menu.hidden) return;
      var i = items.indexOf(document.activeElement);
      if (e.key === "Escape") { e.preventDefault(); close(); btn.focus(); }
      else if (e.key === "ArrowDown" || e.key === "ArrowUp") {
        e.preventDefault();
        items[(i + (e.key === "ArrowDown" ? 1 : items.length - 1)) % items.length].focus();
      }
      else if (e.key === "Tab") close();
    });
  })();

  root.addEventListener("hashchange", route);
  route();

  // Offline use + installable app (only on https or localhost)
  if ("serviceWorker" in navigator && (location.protocol === "https:" || location.hostname === "localhost" || location.hostname === "127.0.0.1")) {
    root.addEventListener("load", function () { navigator.serviceWorker.register("sw.js").catch(function () { /* offline mode unavailable */ }); });
  }
})(window);
