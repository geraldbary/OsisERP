/** @odoo-module **/
// os_web_theme/static/src/js/home_menu.js
// OsisERP Home Menu - Enterprise-style for Community

import { Component, useState, xml, onMounted } from "@odoo/owl";
import { registry } from "@web/core/registry";
import { useService } from "@web/core/utils/hooks";

// Session storage key
const LAST_APP_KEY = "osis_last_app_id";

/**
 * OsisERP Home Menu Component
 * Full-screen app dashboard like Odoo Enterprise
 */
export class OsisHomeMenu extends Component {
    static template = xml`
        <div class="o_home_menu osiserp_home_menu">
            <div class="o_home_menu_scrollable">
                <!-- Search Bar -->
                <div class="o_home_menu_search">
                    <input type="text" 
                           t-att-value="state.searchQuery"
                           t-on-input="onSearchInput"
                           t-on-keydown="onSearchKeydown"
                           placeholder="Search apps..."
                           class="o_home_menu_search_input"/>
                </div>
                
                <!-- Apps Grid -->
                <div class="o_apps">
                    <t t-foreach="filteredApps" t-as="app" t-key="app.id">
                        <a class="o_app" 
                           t-on-click="() => this.openApp(app)"
                           t-att-data-menu-xmlid="app.xmlid"
                           tabindex="0">
                            <div class="o_app_icon">
                                <img t-if="app.webIconData" 
                                     t-att-src="'data:image/png;base64,' + app.webIconData"
                                     t-att-alt="app.name"/>
                                <img t-elif="app.webIcon" 
                                     t-att-src="app.webIcon"
                                     t-att-alt="app.name"/>
                                <i t-else="" class="fa fa-cube"></i>
                            </div>
                            <div class="o_app_name" t-esc="app.name"/>
                        </a>
                    </t>
                </div>
                
                <!-- Empty State -->
                <div t-if="filteredApps.length === 0" class="o_home_menu_empty">
                    <i class="fa fa-search"></i>
                    <p>No apps found</p>
                </div>
            </div>
        </div>
    `;

    setup() {
        this.menuService = useService("menu");
        
        this.state = useState({
            searchQuery: "",
            isVisible: true,
        });

        onMounted(() => {
            // Add class to body
            document.body.classList.add("osis-home-menu-open");
        });
    }

    get filteredApps() {
        let apps = this.menuService.getApps() || [];
        
        if (this.state.searchQuery) {
            const query = this.state.searchQuery.toLowerCase();
            apps = apps.filter(app => 
                app.name.toLowerCase().includes(query)
            );
        }
        
        return apps;
    }

    onSearchInput(ev) {
        this.state.searchQuery = ev.target.value;
    }

    onSearchKeydown(ev) {
        if (ev.key === "Escape") {
            this.state.searchQuery = "";
        } else if (ev.key === "Enter") {
            const apps = this.filteredApps;
            if (apps.length > 0) {
                this.openApp(apps[0]);
            }
        }
    }

    openApp(app) {
        // Save this app as last opened
        sessionStorage.setItem(LAST_APP_KEY, window.location.href);
        // Remove home menu class
        document.body.classList.remove("osis-home-menu-open");
        // Open the app
        this.menuService.selectMenu(app);
    }

    close() {
        this.state.isVisible = false;
        document.body.classList.remove("osis-home-menu-open");
    }
}

// Register as a main component
registry.category("main_components").add("OsisHomeMenu", {
    Component: OsisHomeMenu,
});
