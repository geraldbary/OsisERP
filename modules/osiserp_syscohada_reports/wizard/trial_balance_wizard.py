# osiserp_syscohada_reports/wizard/trial_balance_wizard.py
from odoo import api, fields, models


class TrialBalanceReportWizard(models.TransientModel):
    """Extend Trial Balance wizard with SYSCOHADA options."""

    _inherit = "trial.balance.report.wizard"

    # SYSCOHADA Column Layout for Balance des Comptes
    balance_layout = fields.Selection(
        selection=[
            ("4", "4 Colonnes (Débit/Crédit Ouverture + Clôture)"),
            ("6", "6 Colonnes (Ouverture + Mouvement + Clôture)"),
            ("8", "8 Colonnes (Complet avec Débiteur/Créditeur)"),
        ],
        string="Format Balance",
        default="6",
        required=True,
        help="Format des colonnes selon SYSCOHADA",
    )

    show_account_ref = fields.Boolean(
        string="Afficher Réf. Compte",
        default=True,
        help="Afficher le code de référence SYSCOHADA",
    )

    compare_previous_year = fields.Boolean(
        string="Comparer Exercice N-1",
        default=False,
        help="Afficher les soldes de l'exercice précédent",
    )

    def _prepare_report_trial_balance(self):
        """Add SYSCOHADA options to report data."""
        res = super()._prepare_report_trial_balance()
        res.update({
            "balance_layout": self.balance_layout,
            "show_account_ref": self.show_account_ref,
            "compare_previous_year": self.compare_previous_year,
        })
        return res
