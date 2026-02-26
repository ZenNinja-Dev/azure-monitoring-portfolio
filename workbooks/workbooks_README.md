# Azure Workbooks

Azure Monitor Workbook templates for operational monitoring, error investigation and per-node infrastructure visibility.

---

## Workbooks in This Folder

| File | Description |
|------|-------------|
| `drill-down-logs-workbook.json` | Multi-source error investigation with drill-down – for outage and incident response |
| `single-system-pernode-workbook.json` | Per-node infrastructure and application monitoring for a single environment |
| `all-systems-pernode-workbook.json` | Per-node transaction and error monitoring across all environments in one view |

---

## drill-down-logs-workbook.json

### Overview
Operational monitoring workbook for investigating system errors and outages using Application Insights data. Built for both technical and non-technical operators – provides a consistent investigation workflow without requiring KQL knowledge.

### Features
- **Time range selector** – filter by last 1h, 6h, 24h, 7 days
- **Error Summary table** – all errors aggregated by frequency with percentage of total hits
- **Drill-down detail view** – click any error group to see individual log entries with full context
- **Multi-source union** – combines `traces`, `exceptions`, `requests` and `dependencies` in a single query
- **Error classification** – auto-categorizes into `IntegrationTimeout`, `IntegrationError`, `SessionError`, `DatabaseError`, `ValidationError`, `ApiError` and more
- **Text normalization** – replaces dynamic values (numbers, GUIDs) with placeholders for consistent grouping

### Data Sources
Application Insights – traces, exceptions, requests, dependencies

### Columns in Drill-down View
`timestamp` · `Text` · `Table` · `ErrorType` · `ErrorCode` · `ErrorId` · `UserId` · `OperationId` · `Logger` · `HostName` · `SystemName` · `Environment`

### How to Deploy
1. Azure Portal → Application Insights → Workbooks → **+ New** → **Advanced Editor**
2. Paste contents of `drill-down-logs-workbook.json`
3. Click **Apply** → **Done Editing** → Save

---

## single-system-pernode-workbook.json

### Overview
Comprehensive per-node monitoring workbook for a single environment. Inspired by SCOM-style node visibility – if a node goes down, its line disappears from the chart immediately. Combines infrastructure metrics from Log Analytics with application metrics from Application Insights in one workbook.

### Features
- **Heartbeat – Node Status** – current up/down state per node as a table
- **Heartbeat time series** – SCOM-like lines per node showing availability over time
- **Disk Bytes/sec** – disk throughput per node
- **Avg. Disk Queue Length** – disk bottleneck indicator (threshold >1)
- **Network Bytes Total/sec** – network throughput per node
- **Transaction Count/sec per node** – application throughput from App Insights custom metrics
- **App Errors/sec per node** – error rate per node for quick fault isolation
- **Summary table** – latest values per node in a single table

### Data Sources
- Log Analytics Workspace – `Heartbeat`, `Perf`
- Application Insights – `customMetrics`

### How to Deploy
1. Azure Portal → Application Insights → Workbooks → **+ New** → **Advanced Editor**
2. Paste contents of `single-system-pernode-workbook.json`
3. Update `crossComponentResources` with your Application Insights resource ID
4. Click **Apply** → **Done Editing** → Save

---

## all-systems-pernode-workbook.json

### Overview
Multi-environment overview workbook showing per-node transaction and error metrics across all monitored environments on a single screen. Each line in the chart represents one node – making it immediately visible if a single node or an entire environment drops off.

### Features
- **Per-environment sections** – each environment has its own Transaction Count/sec and App Errors/sec charts
- **Line per node** – SCOM-like visibility where each node is a separate line
- **Time range selector** – shared across all sections
- **Cross-component queries** – each section queries its own Application Insights resource

### Data Sources
Application Insights – `customMetrics` (Transaction Count, App Errors)

### How to Deploy
1. Azure Portal → Monitor → Workbooks → **+ New** → **Advanced Editor**
2. Paste contents of `all-systems-pernode-workbook.json`
3. Update all `crossComponentResources` entries with your Application Insights resource IDs
4. Click **Apply** → **Done Editing** → Save

---

*Source: Application Insights · Log Analytics · Azure Monitor Workbooks*
