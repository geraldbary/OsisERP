/** @odoo-module **/
// os_web_theme/static/src/js/app_launcher.js
// OsisERP App Launcher - Shows current app icon, hover for home button

import { patch } from "@web/core/utils/patch";
import { NavBar } from "@web/webclient/navbar/navbar";
import { useService } from "@web/core/utils/hooks";
import { useState, onMounted, onWillUpdateProps } from "@odoo/owl";

// =============================================================================
// PATCH NAVBAR TO ENHANCE APP LAUNCHER
// =============================================================================
patch(NavBar.prototype, {
    setup() {
        super.setup(...arguments);
        
        this.actionService = useService("action");
        this.menuService = useService("menu");
        
        // OsisERP state for app launcher
        this.osisAppState = useState({
            currentApp: null,
            currentAppIcon: null,
            isHovering: false,
            showHomeMenu: false,
        });

        onMounted(() => {
            this._updateCurrentApp();
            // Add class to navbar for styling
            const navbar = document.querySelector('.o_main_navbar');
            if (navbar) {
                navbar.classList.add('osiserp_navbar');
            }
        });

        onWillUpdateProps(() => {
            this._updateCurrentApp();
        });
    },

    /**
     * Update current app info based on menu service
     */
    _updateCurrentApp() {
        try {
            const currentApp = this.menuService.getCurrentApp();
            if (currentApp) {
                this.osisAppState.currentApp = currentApp;
                this.osisAppState.currentAppIcon = currentApp.webIconData 
                    ? `data:image/png;base64,${currentApp.webIconData}`
                    : currentApp.webIcon || null;
            } else {
                this.osisAppState.currentApp = null;
                this.osisAppState.currentAppIcon = null;
            }
        } catch (e) {
            // Menu service might not be ready
            this.osisAppState.currentApp = null;
            this.osisAppState.currentAppIcon = null;
        }
    },

    /**
     * Handle mouse enter on app launcher
     */
    onOsisLauncherEnter() {
        this.osisAppState.isHovering = true;
    },

    /**
     * Handle mouse leave on app launcher
     */
    onOsisLauncherLeave() {
        this.osisAppState.isHovering = false;
    },

    /**
     * Navigate to home menu
     */
    onOsisGoHome() {
        // Toggle home menu
        this.menuService.setCurrentMenu(false);
    },
});

export default {};
