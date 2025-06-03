// Habilitar CSS personalizado (userChrome.css)
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Forzar modo oscuro en sitios web que lo soporten
user_pref("layout.css.prefers-color-scheme.content-override", 0);
// Desactivar animaciones innecesarias (mejora rendimiento)
user_pref("toolkit.cosmeticAnimations.enabled", false);
// Mostrar marcadores en nueva pestaña
user_pref("browser.newtabpage.activity-stream.showTopSites", false);
// Desactivar página de inicio de Firefox
user_pref("browser.startup.homepage_override.mstone", "ignore");
// Nueva pestaña en blanco
user_pref("browser.newtabpage.enabled", false);
// Desactivar pocket
user_pref("extensions.pocket.enabled", false);
// Activar Do Not Track
user_pref("privacy.donottrackheader.enabled", true);
// Bloquear rastreadores
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
// Configuración de cookies estricta
user_pref("network.cookie.cookieBehavior", 4);
// Desactivar telemetría
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.server", "");
// Desactivar estudios de Firefox
user_pref("app.shield.optoutstudies.enabled", false);
// Desactivar informes de fallos
user_pref("breakpad.reportURL", "");
// Desactivar autocompletado de URLs
user_pref("browser.urlbar.autoFill", false);
// No guardar contraseñas automáticamente
user_pref("signon.rememberSignons", false);
// Desactivar geolocalización por defecto
user_pref("geo.enabled", false);
// Desactivar notificaciones web
user_pref("dom.webnotifications.enabled", false);
// Desactivar autoplay de medios
user_pref("media.autoplay.default", 5);
// Desactivar actualizaciones automáticas (Kali maneja esto)
user_pref("app.update.enabled", false);
user_pref("app.update.auto", false);
// Desactivar add-ons automáticos
user_pref("extensions.update.enabled", false);
// Habilitar herramientas de desarrollador avanzadas
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.debugger.remote-enabled", true);
// Mostrar reglas de usuario en inspector CSS
user_pref("devtools.inspector.showUserAgentStyles", true);
