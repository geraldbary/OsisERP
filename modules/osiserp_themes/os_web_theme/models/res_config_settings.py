# os_web_theme/models/res_config_settings.py
# OsisERP Theme - Configuration Settings Extension

from odoo import fields, models, api


class ResConfigSettings(models.TransientModel):
    _inherit = 'res.config.settings'

    # ==========================================================================
    # NAVBAR SETTINGS
    # ==========================================================================
    osis_navbar_bg_color = fields.Char(
        string="Navbar Background",
        config_parameter='os_web_theme.navbar_bg_color',
        default='#714B67',
        help="Background color for the main navbar"
    )
    osis_navbar_text_color = fields.Char(
        string="Navbar Text Color",
        config_parameter='os_web_theme.navbar_text_color',
        default='#FFFFFF',
        help="Text and icon color in navbar"
    )
    osis_navbar_hover_color = fields.Char(
        string="Navbar Hover Color",
        config_parameter='os_web_theme.navbar_hover_color',
        default='rgba(255,255,255,0.1)',
        help="Hover background color for navbar items"
    )

    # ==========================================================================
    # THEME COLORS
    # ==========================================================================
    osis_primary_color = fields.Char(
        string="Primary Color",
        config_parameter='os_web_theme.primary_color',
        default='#714B67',
        help="Main brand color (buttons, links, highlights)"
    )
    osis_secondary_color = fields.Char(
        string="Secondary Color",
        config_parameter='os_web_theme.secondary_color',
        default='#017E84',
        help="Accent color (teal highlights)"
    )
    osis_accent_color = fields.Char(
        string="Accent Color",
        config_parameter='os_web_theme.accent_color',
        default='#34C759',
        help="Success states and positive actions"
    )
    osis_danger_color = fields.Char(
        string="Danger Color",
        config_parameter='os_web_theme.danger_color',
        default='#DC3545',
        help="Error states and destructive actions"
    )

    # ==========================================================================
    # HOME MENU SETTINGS
    # ==========================================================================
    osis_home_bg_type = fields.Selection(
        string="Background Type",
        selection=[
            ('gradient', 'Gradient'),
            ('solid', 'Solid Color'),
            ('image', 'Custom Image'),
        ],
        config_parameter='os_web_theme.home_bg_type',
        default='gradient',
        help="Type of background for home menu"
    )

    osis_home_bg_color = fields.Char(
        string="Background Color",
        config_parameter='os_web_theme.home_bg_color',
        default='#f8f6ff',
        help="Solid background color for home menu"
    )

    osis_home_gradient_start = fields.Char(
        string="Gradient Start Color",
        config_parameter='os_web_theme.home_gradient_start',
        default='#f8f6ff',
        help="Starting color for gradient background"
    )

    osis_home_gradient_end = fields.Char(
        string="Gradient End Color",
        config_parameter='os_web_theme.home_gradient_end',
        default='#e8eaef',
        help="Ending color for gradient background"
    )

    osis_home_bg_image = fields.Binary(
        string="Background Image",
        related='company_id.osis_home_bg_image',
        readonly=False,
        help="Custom background image for home menu (recommended: 1920x1080)"
    )

    osis_home_bg_overlay = fields.Boolean(
        string="Dark Overlay",
        config_parameter='os_web_theme.home_bg_overlay',
        default=False,
        help="Add dark overlay on background for better readability"
    )

    # ==========================================================================
    # SEARCH BAR SETTINGS
    # ==========================================================================
    osis_search_bg_color = fields.Char(
        string="Search Background",
        config_parameter='os_web_theme.search_bg_color',
        default='#FFFFFF',
        help="Background color for search bar"
    )
    osis_search_border_color = fields.Char(
        string="Search Border Color",
        config_parameter='os_web_theme.search_border_color',
        default='#e0e0e0',
        help="Border color for search bar"
    )
    osis_search_border_radius = fields.Integer(
        string="Search Border Radius",
        config_parameter='os_web_theme.search_border_radius',
        default=12,
        help="Border radius in pixels for search bar"
    )

    # ==========================================================================
    # APP TILES SETTINGS
    # ==========================================================================
    osis_app_tile_bg = fields.Char(
        string="App Tile Background",
        config_parameter='os_web_theme.app_tile_bg',
        default='#f0f0f3',
        help="Background color for app icon tiles"
    )
    osis_app_tile_radius = fields.Integer(
        string="App Tile Radius",
        config_parameter='os_web_theme.app_tile_radius',
        default=16,
        help="Border radius in pixels for app tiles"
    )
    osis_app_tile_size = fields.Integer(
        string="App Tile Size",
        config_parameter='os_web_theme.app_tile_size',
        default=64,
        help="Size in pixels for app icon tiles"
    )
    osis_app_name_color = fields.Char(
        string="App Name Color",
        config_parameter='os_web_theme.app_name_color',
        default='#495057',
        help="Text color for app names"
    )
    osis_app_name_size = fields.Integer(
        string="App Name Font Size",
        config_parameter='os_web_theme.app_name_size',
        default=12,
        help="Font size in pixels for app names"
    )

    # ==========================================================================
    # BUTTON SETTINGS
    # ==========================================================================
    osis_btn_border_radius = fields.Integer(
        string="Button Border Radius",
        config_parameter='os_web_theme.btn_border_radius',
        default=4,
        help="Border radius in pixels for buttons"
    )

    # ==========================================================================
    # SIDEBAR SETTINGS
    # ==========================================================================
    osis_sidebar_bg_color = fields.Char(
        string="Sidebar Background",
        config_parameter='os_web_theme.sidebar_bg_color',
        default='#f8f9fa',
        help="Background color for settings sidebar"
    )
    osis_sidebar_text_color = fields.Char(
        string="Sidebar Text Color",
        config_parameter='os_web_theme.sidebar_text_color',
        default='#333333',
        help="Text color for sidebar items"
    )
