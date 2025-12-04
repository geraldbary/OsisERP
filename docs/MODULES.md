# OsisERP Module Reference

## Module Packages

The deployment script organizes OCA modules into logical packages for easy selection.

---

## CORE Package (Always Installed)

Essential modules for server stability, security, and user experience.

### Server Tools (`server-tools`)
| Module | Description |
|--------|-------------|
| `auto_backup` | Automatic database backups |
| `auditlog` | Audit trail logging |
| `database_cleanup` | Database maintenance utilities |
| `base_name_search_improved` | Enhanced search functionality |
| `base_technical_user` | Technical user management |
| `base_jsonify` | JSON serialization |
| `base_sparse_field_list_support` | Sparse field support |

### Server UX (`server-ux`)
| Module | Description |
|--------|-------------|
| `base_technical_features` | Technical features menu |
| `base_tier_validation` | Approval workflows |
| `base_user_role` | User role management |
| `mail_debrand` | Remove Odoo branding from emails |
| `base_export_manager` | Export management |

### Web Enhancements (`web`)
| Module | Description |
|--------|-------------|
| `web_responsive` | Mobile-friendly interface |
| `web_dialog_size` | Resizable dialogs |
| `web_search_with_and` | AND operator in search |
| `web_tree_many2one_clickable` | Clickable links in tree views |
| `web_notify` | Browser notifications |
| `web_refresher` | Auto-refresh views |
| `web_environment_ribbon` | Environment indicator |
| `web_m2x_options` | Many2X field options |

### Reporting Engine (`reporting-engine`)
| Module | Description |
|--------|-------------|
| `report_xlsx` | Excel report generation |
| `report_xlsx_helper` | Excel report helpers |
| `report_qweb_pdf_watermark` | PDF watermarks |
| `bi_sql_editor` | SQL-based BI reports |

---

## ACCOUNTING Package

Financial management and reporting modules.

### Account Financial Tools (`account-financial-tools`)
| Module | Description |
|--------|-------------|
| `account_fiscal_year` | Fiscal year management |
| `account_lock_date_update` | Period locking |
| `account_move_template` | Journal entry templates |
| `account_asset_management` | Fixed asset management |
| `account_chart_update` | Chart of accounts updates |
| `account_netting` | Account netting |
| `account_due_list` | Due list management |

### Account Financial Reporting (`account-financial-reporting`)
| Module | Description |
|--------|-------------|
| `account_financial_report` | Financial reports (GL, TB, etc.) |
| `account_tax_balance` | Tax balance reports |

### Account Payment (`account-payment`)
| Module | Description |
|--------|-------------|
| `account_payment_term_extension` | Payment term extensions |
| `account_payment_mode` | Payment modes |
| `account_payment_partner` | Partner payment info |

### MIS Builder (`mis-builder`)
| Module | Description |
|--------|-------------|
| `mis_builder` | Management Information System |
| `mis_builder_budget` | Budget management |
| `mis_builder_cash_flow` | Cash flow reports |

---

## HR & PAYROLL Package

Human resources and payroll management.

### HR (`hr`)
| Module | Description |
|--------|-------------|
| `hr_employee_firstname` | First/last name separation |
| `hr_employee_calendar_planning` | Calendar planning |
| `hr_contract_reference` | Contract references |
| `hr_employee_id` | Employee ID numbers |
| `hr_employee_age` | Age calculation |
| `hr_employee_relative` | Employee relatives |
| `hr_department_code` | Department codes |

### Payroll (`payroll`)
| Module | Description |
|--------|-------------|
| `payroll` | Base payroll module |
| `payroll_account` | Payroll accounting |

### HR Attendance (`hr-attendance`)
| Module | Description |
|--------|-------------|
| `hr_attendance_reason` | Attendance reasons |
| `hr_attendance_report_theoretical_time` | Theoretical time reports |

---

## MANUFACTURING Package

Production and MRP modules.

### Manufacture (`manufacture`)
| Module | Description |
|--------|-------------|
| `mrp_bom_hierarchy` | BOM tree view |
| `mrp_bom_location` | BOM by location |
| `mrp_bom_line_formula_quantity` | Formula-based quantities |
| `mrp_multi_level` | Multi-level MRP |
| `mrp_production_note` | Production notes |
| `mrp_lot_propagation` | Lot propagation |

### Manufacture Reporting (`manufacture-reporting`)
| Module | Description |
|--------|-------------|
| `mrp_bom_structure_report` | BOM structure reports |

---

## INVENTORY Package

Warehouse and logistics management.

### Stock Logistics Warehouse (`stock-logistics-warehouse`)
| Module | Description |
|--------|-------------|
| `stock_inventory` | Inventory adjustments |
| `stock_move_location` | Stock move by location |
| `stock_picking_show_linked` | Show linked pickings |
| `stock_request` | Stock requests |
| `stock_user_default_warehouse` | Default warehouse per user |

### Stock Logistics Workflow (`stock-logistics-workflow`)
| Module | Description |
|--------|-------------|
| `stock_picking_batch` | Batch picking |
| `stock_picking_auto_assign` | Auto-assign pickings |

### Stock Logistics Barcode (`stock-logistics-barcode`)
| Module | Description |
|--------|-------------|
| `stock_barcodes` | Barcode scanning |

---

## SALES & CRM Package

Sales and customer relationship management.

### Sale Workflow (`sale-workflow`)
| Module | Description |
|--------|-------------|
| `sale_order_type` | Sale order types |
| `sale_order_line_sequence` | Line sequencing |
| `sale_discount_display_amount` | Discount display |

### CRM (`crm`)
| Module | Description |
|--------|-------------|
| `crm_lead_code` | Lead codes |
| `crm_stage_probability` | Stage probability |

### Partner Contact (`partner-contact`)
| Module | Description |
|--------|-------------|
| `partner_firstname` | First/last name |
| `partner_contact_gender` | Gender field |
| `partner_contact_birthdate` | Birthdate field |
| `partner_contact_nationality` | Nationality field |

---

## PURCHASE Package

Procurement management.

### Purchase Workflow (`purchase-workflow`)
| Module | Description |
|--------|-------------|
| `purchase_order_type` | Purchase order types |
| `purchase_order_line_sequence` | Line sequencing |
| `purchase_discount` | Purchase discounts |

---

## PROJECT Package

Project and timesheet management.

### Project (`project`)
| Module | Description |
|--------|-------------|
| `project_task_code` | Task codes |
| `project_status` | Project status |
| `project_template` | Project templates |

### Timesheet (`timesheet`)
| Module | Description |
|--------|-------------|
| `hr_timesheet_sheet` | Timesheet sheets |
| `hr_timesheet_task_required` | Required task on timesheet |

---

## SYSCOHADA Package

OHADA accounting compliance for African countries.

### OsisERP SYSCOHADA Reports (`osiserp_syscohada_reports`)
| Report | Description |
|--------|-------------|
| Grand Livre | General Ledger (2/3/4/6 columns) |
| Balance des Comptes | Trial Balance (Opening/Movement/Closing) |
| Journal Centralisateur | Journal Ledger |
| Balance Âgée Tiers | Aged Partner Balance |
| Bilan OHADA | Balance Sheet (ACTIF/PASSIF) |
| Compte de Résultat | Income Statement |

**Features:**
- SYSCOHADA 2017 revision compliant
- Multi-column layouts
- Comparative periods (N / N-1)
- Professional OHADA formatting
- PDF and Excel export

---

## Custom OsisERP Modules

### OsisERP Web Theme (`os_web_theme`)
Enterprise-style theme with:
- Custom color scheme
- Dark navbar
- Animated home menu
- App icon hover effects
- Responsive design
- Dynamic CSS theming

---

## Installing Modules

### Via Web Interface
1. Go to **Apps** menu
2. Click **Update Apps List**
3. Search for module name
4. Click **Install**

### Via Command Line
```bash
# Install a module
osiserp install-module module_name

# Update a module
osiserp update-module module_name

# Update all modules
docker exec osiserp-odoo odoo -u all -d osiserp --stop-after-init
```

---

## Module Dependencies

Some modules have dependencies. The installer handles most automatically, but be aware:

- `payroll_account` requires `payroll` and `account`
- `mis_builder_budget` requires `mis_builder`
- `stock_request` requires `stock`
- Financial reports require `account`

---

## Adding Custom Modules

1. Place module in `/opt/osiserp/custom/addons/`
2. Restart Odoo: `osiserp restart`
3. Update Apps List in web interface
4. Install the module

---

## Support

For module-specific issues:
- Check OCA GitHub repositories
- Review module README files
- Open issue on OsisERP GitHub
