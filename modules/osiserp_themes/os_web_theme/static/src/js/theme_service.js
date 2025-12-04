/** @odoo-module **/
// os_web_theme/static/src/js/theme_service.js
// Dynamic theme CSS loader

import { registry } from "@web/core/registry";

// Load dynamic CSS on module init
const cssLink = document.createElement('link');
cssLink.id = 'osis-theme-dynamic';
cssLink.rel = 'stylesheet';
cssLink.href = '/os_web_theme/css?t=' + Date.now();
document.head.appendChild(cssLink);

// Service for theme management
const themeService = {
    dependencies: [],
    start() {
        return {
            refresh() {
                const link = document.getElementById('osis-theme-dynamic');
                if (link) {
                    link.href = '/os_web_theme/css?t=' + Date.now();
                }
            }
        };
    }
};

registry.category("services").add("osisTheme", themeService);
