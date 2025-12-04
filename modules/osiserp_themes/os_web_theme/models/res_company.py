# os_web_theme/models/res_company.py
# OsisERP Theme - Company Settings Extension

from odoo import fields, models


class ResCompany(models.Model):
    _inherit = 'res.company'

    # Background image for home menu / app dashboard
    osis_home_bg_image = fields.Binary(
        string='Home Menu Background Image',
        attachment=True,
        help="Custom background image for the app dashboard (recommended: 1920x1080)"
    )
