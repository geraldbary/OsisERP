# os_web_theme/__manifest__.py
{
    "name": "OsisERP Web Theme",
    "summary": "OsisERP visual theme and branding for Odoo Community 18/19",
    "description": """
OsisERP Web Theme
=================
Complete rebranding of Odoo Community into OsisERP:

- Custom color scheme (Osis Blue, Gold, Emerald)
- Dark navbar with OsisERP branding
- Modern Home Menu with animated app tiles
- Modern login page with gradient background
- Styled buttons, forms, kanban cards
- Google Fonts (Poppins, Roboto)
- Theme settings in Settings → OsisERP Theme
- Portal UI customization
- Responsive grid layout
- Dark mode support (future-proof)
- Easily extendable architecture
    """,
    "version": "18.0.1.1.0",
    "author": "OSIS (Open System & Innovation Solution)",
    "website": "https://globalosis.com",
    "license": "LGPL-3",
    "category": "Themes/Backend",
    "depends": [
        "web",
        "base_setup",
    ],
    "data": [
        "security/ir.model.access.csv",
        "views/theme_settings.xml",
        "views/login_templates.xml",
        "views/webclient_templates.xml",
    ],
    "assets": {
        # Backend assets (main Odoo interface)
        "web.assets_backend": [
            # SCSS Styles
            "os_web_theme/static/src/scss/theme.scss",
            "os_web_theme/static/src/scss/home_menu.scss",
            # JS Components
            "os_web_theme/static/src/js/theme_service.js",
            "os_web_theme/static/src/js/home_button.js",
            # XML Templates
            "os_web_theme/static/src/xml/app_launcher.xml",
        ],
        # Frontend assets (portal, website)
        "web.assets_frontend": [
            "os_web_theme/static/src/scss/theme.scss",
        ],
    },
    "installable": True,
    "application": False,
    "auto_install": False,
}
