//I read the wiki
//https://github.com/arkenfox/user.js/wiki/3.2-Overrides-%5BCommon%5D

user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");
user_pref("network.trr.mode", 2);

//Disable Safe Browsing, this phones home to Google.
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);

// Disk caching, which might improve performance if enabled.
user_pref("browser.cache.disk.enable", false);
//Enable favicons, the icons in bookmarks
user_pref("browser.shell.shortcutFavicons", true);

// Strict third party requests, may cause images/video to break.
user_pref("network.http.referer.XOriginPolicy", 2);

// 0801
user_pref("keyword.enabled", true);

//Clear data on shutdown
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown.cache", true);     // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.downloads", true); // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.formdata", true);  // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.history", false);   // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.sessions", true);  // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.offlineApps", false); // [DEFAULT: false]
user_pref("privacy.clearOnShutdown.cookies", false);
   // user_pref("privacy.clearOnShutdown.siteSettings", false); // [DEFAULT: false]
// Manual wiping, such as the forget-me-not button
user_pref("privacy.cpd.cache", true);    // [DEFAULT: true]
user_pref("privacy.cpd.formdata", true); // [DEFAULT: true]
user_pref("privacy.cpd.history", true);  // [DEFAULT: true]
user_pref("privacy.cpd.sessions", true); // [DEFAULT: true]
user_pref("privacy.cpd.offlineApps", false); // [DEFAULT: false]
user_pref("privacy.cpd.cookies", false);
   // user_pref("privacy.cpd.downloads", true); // not used, see note above
   // user_pref("privacy.cpd.passwords", false); // [DEFAULT: false] not listed
   // user_pref("privacy.cpd.siteSettings", false); // [DEFAULT: false]
// Delete everything ever.
user_pref("privacy.sanitize.timeSpan", 0);
//Delete history, although might be security theater.
//Helps against forensic tools.
user_pref("places.history.enabled", true);

//WebGL is a security risk, but sometimes breaks things like 23andMe
//or Google Maps (not always).
/* override recipe: RFP is not for me ***/
user_pref("privacy.resistFingerprinting", false); // 4501
user_pref("privacy.resistFingerprinting.letterboxing", false); // 4504 [pointless if not using RFP]
user_pref("webgl.disabled", true); // 4520 [mostly pointless if not using RFP]

//Firefox stores passwords in plain text and obsolete if you use a password manager.
//Mozilla also told people to stop using their password manager.
user_pref("signon.rememberSignons", false);
//Disable Pocket, it's proprietary trash
user_pref("extensions.pocket.enabled", false);
// Disable Mozilla account
user_pref("identity.fxaccounts.enabled", false);

// 7002: set default permissions
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.xr", 2); // Virtual Reality
