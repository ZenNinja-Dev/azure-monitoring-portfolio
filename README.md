# Azure Monitoring Portfolio

> Personal learning portfolio focused on Azure Monitor, Log Analytics, KQL and Security Dashboarding.  
> Built as part of my journey toward Cloud Security Engineering.

---

## About This Repository

This repository documents my hands-on experience and learning in Azure monitoring and security observability.  
All content is based on personal lab work and anonymized knowledge from real-world experience.

**Focus areas:**
- Azure Monitor & Log Analytics Workspace
- KQL (Kusto Query Language) for security and operational investigations
- Custom Dashboards & Workbooks for incident response
- Alert rules and automated responses
- Operational documentation and team knowledge sharing

---

## Repository Structure

```
azure-monitoring-portfolio/
├── kql-queries/
│   ├── authentication-and-identity.md     # Identity threat detection queries
│   ├── application-and-system-monitoring.md  # App health and error monitoring
│   └── full-log-investigation.md          # Incident investigation queries (24h and fixed window)
│
├── workbooks/
│   ├── drill-down-logs-workbook.json      # Drill-down error investigation workbook (ARM template)
│   └── workbooks_README.md
│
├── alerts/
│   ├── security-alerts.md                 # KQL-based security alert rules
│   ├── application-alerts.md              # Application health alert rules
│   └── alert-zero-transactions.json       # Zero transaction outage alert (ARM template)
│
├── dashboards/
│   ├── error-logs-dashboard.json          # Multi-client error log monitoring dashboard
│   ├── metrics-investigation-dashboard.json  # Outage and drop investigation dashboard
│   └── azure-health-vs-metrics-dashboard.json  # Azure Service Health vs. internal metrics
│
└── docs/
    ├── alert-response-guide.md            # Alert triage and response workflow
    ├── docs-azure-monitoring-dashboards.md  # Dashboard usage guide with KQL examples
    └── docs-azure-specific-monitoring.md  # Customer and environment metrics guide
```

---

## Skills Demonstrated

| Area | Tools & Skills |
|------|---------------|
| Log querying | KQL, Log Analytics Workspace, Application Insights |
| Incident investigation | Multi-source union queries, drill-down workbooks |
| Visualization | Azure Workbooks, Custom Dashboards, Application Insights |
| Alerting | Scheduled Query Rules, Metric Alerts, ARM templates |
| Service monitoring | Azure Service Health, multi-client monitoring |
| Documentation | Operational guides, team knowledge sharing, wiki documentation |

---

## Highlights

**Drill-down Workbook** – investigates errors across `traces`, `exceptions`, `requests` and `dependencies` in a single view with clickable drill-down to individual log entries. Built for operator use during outages.

**Azure Health vs. Metrics Dashboard** – correlates Azure Service Health status with internal transaction metrics. Created to answer the key incident question: *is this our problem or Microsoft's?*

**Full Log Investigation Queries** – union queries covering all Application Insights data sources, with error normalization and grouping. Available in 24h and fixed time window variants for post-incident analysis.

---

## Status

🔨 Active learning – content added continuously

---

*ZenNinja-Dev | Aspiring Cloud Security Engineer*
