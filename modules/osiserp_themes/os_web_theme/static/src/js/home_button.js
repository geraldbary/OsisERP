/** @odoo-module **/
// os_web_theme/static/src/js/home_button.js
// Enterprise-style Home Menu Toggle: App View ↔ Home Menu

import { patch } from "@web/core/utils/patch";
import { useState } from "@odoo/owl";
import { NavBar } from "@web/webclient/navbar/navbar";

// Session storage key
const LAST_APP_KEY = "osis_last_app_id";

// Gradient definitions
const GRADIENTS = {
    'default': 'linear-gradient(135deg, #004AAD 0%, #1A1F25 100%)',
    'ocean': 'linear-gradient(135deg, #0077B6 0%, #023E8A 50%, #03045E 100%)',
    'sunset': 'linear-gradient(135deg, #F2A900 0%, #E85D04 50%, #9D0208 100%)',
    'forest': 'linear-gradient(135deg, #0DBF6F 0%, #2D6A4F 50%, #1B4332 100%)',
    'midnight': 'linear-gradient(135deg, #1A1F25 0%, #0D1117 100%)',
    'aurora': 'linear-gradient(135deg, #004AAD 0%, #7B2CBF 50%, #E040FB 100%)',
    'corporate': 'linear-gradient(135deg, #1e3a5f 0%, #0d1b2a 100%)',
};

/**
 * Patch NavBar to add Enterprise-style home menu toggle
 */
patch(NavBar.prototype, {
    setup() {
        super.setup(...arguments);
        
        // State for home menu visibility
        this.osisHomeState = useState({
            showHomeMenu: false,
            bgStyle: 'default',
        });
        
        // Initialize search query
        this._osisSearchQuery = "";
    },
    
    /**
     * Get background style for home menu
     */
    get osisHomeBackground() {
        const style = this.osisHomeState.bgStyle || 'default';
        return GRADIENTS[style] || GRADIENTS['default'];
    },

    /**
     * Check if home menu is currently shown
     */
    get isOnHomeMenu() {
        return this.osisHomeState.showHomeMenu || !this.menuService.getCurrentApp();
    },

    /**
     * Toggle between Home Menu and Last App (Enterprise-style)
     */
    onOsisHomeToggle(ev) {
        if (ev) {
            ev.preventDefault();
            ev.stopPropagation();
        }
        
        const currentApp = this.menuService.getCurrentApp();
        
        if (currentApp && !this.osisHomeState.showHomeMenu) {
            // Currently in an app → Show Home Menu
            sessionStorage.setItem(LAST_APP_KEY, JSON.stringify({
                id: currentApp.id,
                actionId: currentApp.actionID,
            }));
            this.osisHomeState.showHomeMenu = true;
            document.body.classList.add("osis-home-menu-open");
        } else {
            // Currently on Home Menu → Go back to last app
            this.osisHomeState.showHomeMenu = false;
            document.body.classList.remove("osis-home-menu-open");
            
            const lastAppData = sessionStorage.getItem(LAST_APP_KEY);
            if (lastAppData) {
                try {
                    const { id } = JSON.parse(lastAppData);
                    const apps = this.menuService.getApps();
                    const lastApp = apps.find(app => app.id === id);
                    if (lastApp) {
                        this.menuService.selectMenu(lastApp);
                        return;
                    }
                } catch (e) {
                    console.warn("Could not restore last app:", e);
                }
            }
            
            // No last app - go to first available app
            const apps = this.menuService.getApps();
            if (apps.length > 0) {
                this.menuService.selectMenu(apps[0]);
            }
        }
    },

    /**
     * Get tooltip text based on current state
     */
    get osisHomeTitle() {
        return this.isOnHomeMenu ? "Back to App" : "Home Menu";
    },

    /**
     * Get filtered apps for home menu
     */
    get osisFilteredApps() {
        let apps = this.menuService.getApps() || [];
        
        if (this._osisSearchQuery) {
            const query = this._osisSearchQuery.toLowerCase();
            apps = apps.filter(app => 
                app.name.toLowerCase().includes(query)
            );
        }
        
        return apps;
    },

    /**
     * Handle search input in home menu
     */
    onOsisSearchInput(ev) {
        this._osisSearchQuery = ev.target.value;
        // Toggle search-active class based on input
        const homeMenu = document.querySelector('.osiserp_home_menu');
        if (homeMenu) {
            if (this._osisSearchQuery) {
                homeMenu.classList.add('search-active');
            } else {
                homeMenu.classList.remove('search-active');
            }
        }
        // Force re-render
        this.osisHomeState.showHomeMenu = true;
    },

    /**
     * Handle search keydown
     */
    onOsisSearchKeydown(ev) {
        if (ev.key === "Escape") {
            this._osisSearchQuery = "";
            const homeMenu = document.querySelector('.osiserp_home_menu');
            if (homeMenu) {
                homeMenu.classList.remove('search-active');
            }
            // If search was active, just clear it. Otherwise close home menu
            if (!ev.target.value) {
                this.osisHomeState.showHomeMenu = false;
                document.body.classList.remove("osis-home-menu-open");
            }
            ev.target.value = "";
        } else if (ev.key === "Enter") {
            const apps = this.osisFilteredApps;
            if (apps.length > 0) {
                this.onOsisAppClick(apps[0]);
            }
        }
    },
    
    /**
     * Handle keydown on home menu for search
     */
    onOsisHomeKeydown(ev) {
        // If typing a letter/number and search not focused, focus search
        if (this.osisHomeState.showHomeMenu && ev.key.length === 1 && !ev.ctrlKey && !ev.metaKey) {
            const searchInput = document.querySelector('.osiserp_home_menu .o_home_menu_search_input');
            if (searchInput && document.activeElement !== searchInput) {
                searchInput.focus();
                searchInput.value = ev.key;
                this._osisSearchQuery = ev.key;
                const homeMenu = document.querySelector('.osiserp_home_menu');
                if (homeMenu) {
                    homeMenu.classList.add('search-active');
                }
                this.osisHomeState.showHomeMenu = true;
            }
        }
    },

    /**
     * Handle app click in home menu
     */
    onOsisAppClick(app) {
        this.osisHomeState.showHomeMenu = false;
        document.body.classList.remove("osis-home-menu-open");
        this._osisSearchQuery = "";
        this.menuService.selectMenu(app);
    },
});
