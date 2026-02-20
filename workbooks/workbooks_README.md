# Azure Workbooks

Azure Monitor Workbook templates for operational monitoring and security investigation.

---

## Workbooks in This Folder

| File | Description |
|------|-------------|
| `drill-down-logs-workbook.json` | Drill-down log investigation workbook for outage and error analysis |

---

## drill-down-logs-workbook.json

### Overview
An operational monitoring workbook designed for investigating system errors and outages using Application Insights data.

Built for both technical and non-technical operators – provides a consistent investigation workflow without requiring KQL knowledge.

### Features
- **Time range selector** – filter logs by last 1h, 6h, 24h, 7 days
- **Error Summary table** – aggregated view of all errors ordered by frequency, with percentage of total hits
- **Drill-down detail view** – click any error group to see all individual log entries with full context
- **Multi-source union** – combines data from `traces`, `exceptions`, `requests` and `dependencies` in a single view
- **Error classification** – automatically categorizes errors into types: `IntegrationTimeout`, `IntegrationError`, `SessionError`, `DatabaseError`, `ValidationError`, `ApiError` and more
- **Text normalization** – replaces dynamic values (numbers, GUIDs) with placeholders for consistent grouping

### Data Sources
- Application Insights (traces, exceptions, requests, dependencies)
- Log Analytics Workspace

### Columns in Drill-down View
`timestamp` · `Text` · `Table` · `ErrorType` · `ErrorCode` · `ErrorId` · `UserId` · `SessionId` · `OperationId` · `Logger` · `HostName` · `SystemName` · `Environment`

### How to Deploy
1. Go to Azure Portal → Monitor → Workbooks
2. Click **"+ New"** → **Advanced Editor**
3. Paste the contents of `drill-down-logs-workbook.json`
4. Update `workbookSourceId` to point to your Application Insights resource
5. Save

---

*Source: Application Insights | Azure Monitor Workbooks*
