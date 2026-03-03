# Cost, Workspace Health & Alert Investigation

KQL queries for cost monitoring, Log Analytics workspace health and alert history analysis.
Data sources: Usage, AzureActivity, AlertsManagementResources.

---

## Cost & Resource Management

### Log Analytics ingestion cost by table - last 7 days
Identify which tables are driving workspace ingestion costs.

```kusto
Usage
| where TimeGenerated > ago(7d)
| where IsBillable == true
| summarize
    TotalGB = round(sum(Quantity) / 1024, 3),
    DailyAvgGB = round(sum(Quantity) / 1024 / 7, 3)
  by DataType
| order by TotalGB desc
```

---

### Ingestion volume trend - last 30 days
Detect cost spikes before they appear on your Azure bill.

```kusto
Usage
| where TimeGenerated > ago(30d)
| where IsBillable == true
| summarize DailyGB = round(sum(Quantity) / 1024, 2) by bin(TimeGenerated, 1d)
| order by TimeGenerated asc
| render timechart
```

---

### Top 20 resource operations - last 30 days
Starting point for cost investigation - which resources are most active.

```kusto
AzureActivity
| where TimeGenerated > ago(30d)
| where ActivityStatusValue == "Success"
| summarize
    Operations = count(),
    LastActivity = max(TimeGenerated)
  by ResourceGroup, OperationNameValue
| order by Operations desc
| take 20
```

---

## Log Analytics Workspace Health

### Ingestion latency per table - last 24h
If logs arrive late, alerting and dashboards show stale data.
Latency above 10 minutes usually means agent or network issues.

```kusto
union withsource=TableName *
| where TimeGenerated > ago(24h)
| extend IngestionLatencyMin = datetime_diff("minute", ingestion_time(), TimeGenerated)
| summarize
    AvgLatencyMin = round(avg(IngestionLatencyMin), 1),
    MaxLatencyMin = round(max(IngestionLatencyMin), 1),
    RowCount = count()
  by TableName
| where AvgLatencyMin > 5
| order by AvgLatencyMin desc
```

---

### Tables with zero ingestion - last 24h
Detects broken agents, disconnected sources or misconfigured diagnostic settings.

```kusto
let expectedTables = dynamic(["Heartbeat", "Perf", "AppExceptions", "AppRequests", "AzureActivity"]);
union withsource=TableName *
| where TimeGenerated > ago(24h)
| summarize LastSeen = max(TimeGenerated) by TableName
| where TableName in (expectedTables)
| join kind=rightouter (
    print TableName = expectedTables
    | mv-expand TableName to typeof(string)
) on TableName
| extend Status = iif(isnotempty(LastSeen), "OK", "NO DATA")
| project TableName, Status, LastSeen
| order by Status desc
```

---

### Daily ingestion volume by table - last 7 days
Capacity planning baseline - know your normal before anomalies appear.

```kusto
Usage
| where TimeGenerated > ago(7d)
| summarize
    TotalMB = round(sum(Quantity), 1),
    Days = dcount(bin(TimeGenerated, 1d))
  by DataType
| extend DailyAvgMB = round(TotalMB / Days, 1)
| order by TotalMB desc
| take 15
```

---

### Workspace ingestion anomaly - today vs 7-day average
Early warning for unexpected ingestion spikes.

```kusto
let avg7d = Usage
    | where TimeGenerated between (ago(8d) .. ago(1d))
    | where IsBillable == true
    | summarize AvgDailyGB = sum(Quantity) / 1024 / 7;
let today = Usage
    | where TimeGenerated > ago(1d)
    | where IsBillable == true
    | summarize TodayGB = sum(Quantity) / 1024;
today
| join kind=inner avg7d on $left.$table == $right.$table
| extend ChangePercent = round((TodayGB - AvgDailyGB) / AvgDailyGB * 100, 1)
| project TodayGB = round(TodayGB, 2), AvgDailyGB = round(AvgDailyGB, 2), ChangePercent
```

---

## Alert Investigation

### Most fired alerts - last 7 days
Identifies noisy alerts that fire constantly but nobody resolves.

```kusto
AlertsManagementResources
| where type == "microsoft.alertsmanagement/alerts"
| where todatetime(properties.startDateTime) > ago(7d)
| extend
    AlertName = tostring(properties.essentials.alertRule),
    Severity  = tostring(properties.essentials.severity),
    State     = tostring(properties.essentials.alertState)
| summarize
    FiredCount = count(),
    LastFired  = max(todatetime(properties.essentials.startDateTime))
  by AlertName, Severity, State
| order by FiredCount desc
| take 20
```

Note: Run in Azure Resource Graph Explorer, not Log Analytics.

---

### Unresolved alerts older than 1 hour
SLA tracking - alerts that should have been acknowledged or resolved.

```kusto
AlertsManagementResources
| where type == "microsoft.alertsmanagement/alerts"
| extend
    AlertName = tostring(properties.essentials.alertRule),
    Severity  = tostring(properties.essentials.severity),
    State     = tostring(properties.essentials.alertState),
    StartTime = todatetime(properties.essentials.startDateTime)
| where State == "New"
| where StartTime < ago(1h)
| extend OpenMinutes = datetime_diff("minute", now(), StartTime)
| project AlertName, Severity, StartTime, OpenMinutes
| order by OpenMinutes desc
```

Note: Run in Azure Resource Graph Explorer, not Log Analytics.

---

### Alert timeline - last 24h
Correlate alert spikes with deployments or infrastructure changes.

```kusto
AzureActivity
| where TimeGenerated > ago(24h)
| where CategoryValue == "Alert"
| summarize AlertCount = count() by bin(TimeGenerated, 15m)
| render timechart
```

---

*Use case: Cost optimization, workspace reliability, alert noise reduction, SLA tracking*
*Source: Usage - AzureActivity - AlertsManagementResources*
