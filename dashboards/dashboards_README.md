# Azure Dashboards

Azure Portal shared dashboard templates for operational monitoring and incident investigation.

---

## Dashboards in This Folder

| File | Description | Primary Use |
|------|-------------|-------------|
| `error-logs-dashboard.json` | Multi-client error log monitoring dashboard | Daily monitoring |
| `metrics-investigation-dashboard.json` | Multi-client transaction metrics dashboard | Outage & drop investigation |

---

## error-logs-dashboard.json

### Overview
A shared Azure Portal dashboard for real-time error log monitoring across multiple client environments simultaneously.

Built for operations teams who need a single-pane-of-glass view of system health without switching between Application Insights instances.

### Features
- Donut chart per client – visual breakdown of error types by frequency
- Aggregated error group summary with `GroupKey`, `Hits`, `Percentage`, `FirstSeen`, `LastSeen`
- Multi-source coverage – queries across `traces`, `exceptions`, `requests` and `dependencies`
- Errors normalized and grouped – dynamic values like IDs and GUIDs replaced with placeholders
- Separates actionable errors from known noise via include/exclude message filters
- Covers multiple client environments (ClientA through ClientG)

### How to Deploy
1. Go to Azure Portal → Dashboard → **Upload**
2. Select `error-logs-dashboard.json`
3. After upload, edit each tile and update `Scope` → `resourceIds` to point to your own Application Insights resources
4. Save and share with your team

---

## metrics-investigation-dashboard.json

### Overview
A shared Azure Portal dashboard designed for investigating outages and transaction drops across multiple client environments.

Operators use this dashboard to identify the exact time window of a drop, compare behavior across clients, and determine scope of an incident.

### Features
- Transaction count metric charts per client – visual timeline of activity
- Shared time range control – change the time window once, all tiles update simultaneously
- Multi-client view – compare all environments side by side to isolate affected clients
- Configurable time range – supports custom windows for pinpointing incident start and recovery
- Covers multiple client environments (ClientA through ClientH)

### Typical Investigation Workflow
1. Open the dashboard when an alert fires
2. Use the shared time range selector to zoom into the incident window
3. Identify which clients are affected vs. healthy
4. Use the drop start time for deeper log investigation in Log Analytics

### How to Deploy
1. Go to Azure Portal → Dashboard → **Upload**
2. Select `metrics-investigation-dashboard.json`
3. After upload, edit each tile and update the metric scope to point to your own Application Insights resources
4. Save and share with your team

---

*Domain: Azure Monitor | Application Insights | Shared Dashboards | Multi-client Monitoring | Incident Investigation*
