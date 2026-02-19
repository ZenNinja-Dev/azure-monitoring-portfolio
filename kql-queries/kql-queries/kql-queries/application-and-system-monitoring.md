# Application & System Monitoring Queries

## 1. Error Logs – Last 24 Hours
Retrieves all error-level logs ordered by most recent.
```kusto
AppTraces
| where TimeGenerated > ago(24h)
| where SeverityLevel == 3
| project TimeGenerated, Message, AppRoleName, OperationName
| order by TimeGenerated desc
```

---

## 2. Exception Tracking – Top Errors by Count
Identifies the most frequently occurring exceptions – useful for bug prioritization.
```kusto
AppExceptions
| where TimeGenerated > ago(7d)
| summarize ExceptionCount = count() by ExceptionType, OuterMessage, AppRoleName
| order by ExceptionCount desc
| take 20
```

---

## 3. Failed HTTP Requests – 4xx and 5xx
Monitors failed requests and separates client errors (4xx) from server errors (5xx).
```kusto
AppRequests
| where TimeGenerated > ago(24h)
| where ResultCode >= 400
| summarize Count = count() by ResultCode, Name, AppRoleName
| order by Count desc
```

---

## 4. Slow Requests – Performance Monitoring
Detects requests taking longer than 3 seconds – useful for performance baseline monitoring.
```kusto
AppRequests
| where TimeGenerated > ago(24h)
| where DurationMs > 3000
| project TimeGenerated, Name, DurationMs, ResultCode, AppRoleName
| order by DurationMs desc
```

---

## 5. Request Volume Over Time
Visualizes request count over time – useful for detecting traffic spikes or outages.
```kusto
AppRequests
| where TimeGenerated > ago(24h)
| summarize RequestCount = count() by bin(TimeGenerated, 5m)
| render timechart
```

---

## 6. Exceptions Correlated with Failed Requests
Joins exceptions with failed requests by OperationId – supports root cause analysis.
```kusto
AppRequests
| where TimeGenerated > ago(24h)
| where Success == false
| join kind=leftouter (
    AppExceptions
    | where TimeGenerated > ago(24h)
) on OperationId
| project TimeGenerated, Name, ResultCode, ExceptionType, OuterMessage
| order by TimeGenerated desc
```

---

*Use case: Application health & performance monitoring | Source: Application Insights / Log Analytics*
