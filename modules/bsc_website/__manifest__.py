# -*- coding: utf-8 -*-
{
    'name': 'BSC International Website',
    'version': '18.0.1.0.0',
    'category': 'Website',
    'summary': 'Groupe BSC International Corporate Website',
    'description': """
        Corporate website for Groupe BSC International
        - Modern responsive design
        - Services showcase
        - Team section
        - Contact forms
        - Blog integration
    """,
    'author': 'OSIS - Open System & Innovation Solution',
    'website': 'https://globalosis.com',
    'license': 'LGPL-3',
    'depends': [
        'website',
        'website_blog',
        'website_form',
        'website_crm',
        'website_slides',
        'contacts',
    ],
    'data': [
        'security/ir.model.access.csv',
        'data/website_data.xml',
        'data/menu_data.xml',
        'views/templates/layout.xml',
        'views/templates/homepage.xml',
        'views/templates/services.xml',
        'views/templates/about.xml',
        'views/templates/team.xml',
        'views/templates/contact.xml',
        'views/snippets/snippets.xml',
    ],
    'assets': {
        'web.assets_frontend': [
            'bsc_website/static/src/scss/theme.scss',
            'bsc_website/static/src/scss/homepage.scss',
            'bsc_website/static/src/scss/components.scss',
            'bsc_website/static/src/js/main.js',
        ],
    },
    'images': ['static/description/banner.png'],
    'installable': True,
    'application': True,
    'auto_install': False,
}
