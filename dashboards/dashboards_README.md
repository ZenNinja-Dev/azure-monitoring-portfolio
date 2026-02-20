# Azure Dashboards

Azure Portal shared dashboard templates for operational monitoring.

---

## Dashboards in This Folder

| File | Description |
|------|-------------|
| `error-logs-dashboard.json` | Multi-client error log monitoring dashboard |

---

## error-logs-dashboard.json

### Overview
A shared Azure Portal dashboard designed for real-time error log monitoring across multiple client environments simultaneously.

Built for operations teams who need a single-pane-of-glass view of system health without switching between Application Insights instances.

### Dashboard Tiles
- **Donut chart per client** – visual breakdown of error types by frequency for each monitored environment
- **Error group summary** – aggregated view showing `GroupKey`, `Hits`, `Percentage`, `FirstSeen`, `LastSeen`
- **Multi-source coverage** – each tile queries across `traces`, `exceptions`, `requests` and `dependencies`

### Key Features
- Covers multiple client environments in a single dashboard (ClientA through ClientF)
- Errors are normalized and grouped – dynamic values like IDs and GUIDs are replaced with placeholders for consistent grouping
- Separates actionable errors from known noise via `WarnMsgs` and `ExcludeMsgs` filters
- Time range is configurable per tile

### How to Deploy
1. Go to Azure Portal → Dashboard → **Upload**
2. Select `error-logs-dashboard.json`
3. After upload, edit each tile and update the `Scope` → `resourceIds` to point to your own Application Insights resources
4. Save and share with your team

---

*Domain: Azure Monitor | Application Insights | Shared Dashboards | Multi-client Monitoring*
