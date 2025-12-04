# osiserp_syscohada_reports/wizard/general_ledger_wizard.py
from odoo import api, fields, models


class GeneralLedgerReportWizard(models.TransientModel):
    """Extend General Ledger wizard with SYSCOHADA options."""

    _inherit = "general.ledger.report.wizard"

    # SYSCOHADA Column Layout
    column_layout = fields.Selection(
        selection=[
            ("2", "2 Colonnes (Débit/Crédit)"),
            ("3", "3 Colonnes (Débit/Crédit/Solde)"),
            ("4", "4 Colonnes (Débit/Crédit/Solde Débit/Solde Crédit)"),
            ("6", "6 Colonnes (Complet SYSCOHADA)"),
        ],
        string="Format Colonnes",
        default="3",
        required=True,
        help="Choisir le format de colonnes selon SYSCOHADA",
    )

    # Quick filters
    show_opening_balance = fields.Boolean(
        string="Afficher Solde d'Ouverture",
        default=True,
    )
    
    show_period_movements = fields.Boolean(
        string="Afficher Mouvements Période",
        default=True,
    )
    
    show_cumulative_balance = fields.Boolean(
        string="Afficher Solde Cumulé",
        default=True,
    )

    def _prepare_report_general_ledger(self):
        """Add SYSCOHADA options to report data."""
        res = super()._prepare_report_general_ledger()
        res.update({
            "column_layout": self.column_layout,
            "show_opening_balance": self.show_opening_balance,
            "show_period_movements": self.show_period_movements,
            "show_cumulative_balance": self.show_cumulative_balance,
        })
        return res
