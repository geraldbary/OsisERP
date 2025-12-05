# -*- coding: utf-8 -*-
from odoo import models, fields


class Website(models.Model):
    _inherit = 'website'

    bsc_phone = fields.Char(string='BSC Phone', default='+971 50 425 6870')
    bsc_email = fields.Char(string='BSC Email', default='info@groupe-bsc-international.com')
    bsc_address = fields.Text(string='BSC Address', default='Hyatt Regency, The Galleria Residence, Office 259')
    bsc_whatsapp = fields.Char(string='WhatsApp Link', default='https://wa.me/message/EQSY5OFPJXORM1')
