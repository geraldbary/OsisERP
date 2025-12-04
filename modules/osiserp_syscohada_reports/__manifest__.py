# osiserp_syscohada_reports/__manifest__.py
{
    "name": "OsisERP SYSCOHADA Reports",
    "summary": "SYSCOHADA/OHADA-compliant Financial Reports for Africa",
    "description": """
OsisERP SYSCOHADA Financial Reports
====================================
Complete OHADA/SYSCOHADA compliant financial reporting suite:

Reports Included:
- Grand Livre (General Ledger) - with 2/3/4/6 column layouts
- Balance des Comptes (Trial Balance) - Opening/Movement/Closing format
- Journal Centralisateur (Journal Ledger)
- Balance Âgée Tiers (Aged Partner Balance)
- Bilan OHADA (Balance Sheet) - ACTIF/PASSIF format with REF codes
- Compte de Résultat (Income Statement) - with SYSCOHADA REF codes

Features:
- Professional OHADA-compliant formatting
- Multi-column layouts per SYSCOHADA standards
- Comparative periods (N / N-1)
- Quick filter toolbar
- PDF and Excel export
- Print-optimized styling

Compliant with:
- SYSCOHADA (Système Comptable OHADA) 2017 revision
- OHADA member states requirements
    """,
    "version": "18.0.1.0.0",
    "author": "OSIS (Open System & Innovation Solution)",
    "website": "https://globalosis.com",
    "license": "LGPL-3",
    "category": "Accounting/Reporting",
    "depends": [
        "account_financial_report",
    ],
    "data": [
        "security/ir.model.access.csv",
        "wizard/general_ledger_wizard_view.xml",
        "wizard/trial_balance_wizard_view.xml",
        "report/general_ledger_template.xml",
        "report/trial_balance_template.xml",
        "report/report_style_template.xml",
    ],
    "assets": {
        "web.report_assets_common": [
            "osiserp_syscohada_reports/static/src/scss/report_style.scss",
        ],
    },
    "installable": True,
    "application": False,
    "auto_install": False,
}
