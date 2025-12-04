# os_web_theme/controllers/theme_controller.py
from odoo import http
from odoo.http import request


class OsisThemeController(http.Controller):
    
    @http.route('/os_web_theme/css', type='http', auth='public', website=False)
    def get_dynamic_css(self):
        """Return dynamic CSS based on theme settings"""
        ICP = request.env['ir.config_parameter'].sudo()
        
        # Navbar
        navbar_bg = ICP.get_param('os_web_theme.navbar_bg_color', '#714B67')
        navbar_text = ICP.get_param('os_web_theme.navbar_text_color', '#FFFFFF')
        
        # Brand colors
        primary = ICP.get_param('os_web_theme.primary_color', '#714B67')
        secondary = ICP.get_param('os_web_theme.secondary_color', '#017E84')
        
        # Home menu
        home_bg_type = ICP.get_param('os_web_theme.home_bg_type', 'gradient')
        home_bg_color = ICP.get_param('os_web_theme.home_bg_color', '#f8f6ff')
        home_gradient_start = ICP.get_param('os_web_theme.home_gradient_start', '#f8f6ff')
        home_gradient_end = ICP.get_param('os_web_theme.home_gradient_end', '#e8eaef')
        
        # App tiles
        app_tile_bg = ICP.get_param('os_web_theme.app_tile_bg', '#f0f0f3')
        app_name_color = ICP.get_param('os_web_theme.app_name_color', '#495057')
        
        # Determine home background
        if home_bg_type == 'solid':
            home_bg = home_bg_color
        else:
            home_bg = f'linear-gradient(180deg, {home_gradient_start} 0%, {home_gradient_end} 100%)'
        
        css = f"""
/* OsisERP Dynamic Theme CSS */
:root {{
    --osis-navbar-bg: {navbar_bg};
    --osis-navbar-text: {navbar_text};
    --osis-primary: {primary};
    --osis-secondary: {secondary};
    --osis-home-bg: {home_bg};
    --osis-app-tile-bg: {app_tile_bg};
    --osis-app-name-color: {app_name_color};
}}
"""
        return request.make_response(
            css,
            headers=[
                ('Content-Type', 'text/css'),
                ('Cache-Control', 'no-cache'),
            ]
        )
