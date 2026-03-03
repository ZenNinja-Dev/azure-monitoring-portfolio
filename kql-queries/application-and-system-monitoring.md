# Application & System Monitoring Queries

KQL queries for application health monitoring, performance analysis and incident response.
Data sources: AppRequests, AppExceptions, AppDependencies, AppTraces, AppMetrics.

---

## Error Detection & Incident Response

### Error spike detection – current 24h vs previous 24h
Compare current error volume against previous day to detect anomalies.

```kusto
let current = AppExceptions
    | where TimeGenerated > ago(24h)
    | summarize Current = count();
let previous = AppExceptions
    | where TimeGenerated between (ago(48h) .. ago(24h))
    | summarize Previous = count();
current
| join kind=fullouter previous on $left.$table == $right.$table
| extend ChangePercent = round((todouble(Current) - todouble(Previous)) / todouble(Previous) * 100, 1)
| project Current, Previous, ChangePercent
```

---

### Top errors by frequency – rolling 24h
Find the most impactful errors with text normalization for consistent grouping.

```kusto
AppExceptions
| where TimeGenerated > ago(24h)
| extend ErrorType = coalesce(OuterMessage, InnermostMessage, Type, ProblemId, "Unknown")
| extend ErrorType = replace_regex(ErrorType, @"\b\d+\b", "N")
| extend ErrorType = replace_regex(ErrorType, @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}", "GUID")
| summarize
    Hits = count(),
    FirstSeen = min(TimeGenerated),
    LastSeen = max(TimeGenerated),
    AffectedRoles = make_set(AppRoleName, 5)
  by ErrorType
| extend PctOfTotal = round(todouble(Hits) * 100.0 / toscalar(AppExceptions | where TimeGenerated > ago(24h) | count), 2)
| order by Hits desc
| take 20
```

---

### Timeout pattern detection – all sources
Identify timeout errors across traces and exceptions – useful for pinpointing slow dependencies.

```kusto
union AppTraces, AppExceptions
| where TimeGenerated > ago(24h)
| where Message has_any ("timeout", "Timeout", "timed out", "request was canceled")
    or ExceptionType has "TimeoutException"
| extend Source = iif(Type == "AppTraces", "trace", "exception")
| summarize
    Count = count(),
    FirstSeen = min(TimeGenerated),
    LastSeen = max(TimeGenerated)
  by Source, AppRoleName
| order by Count desc
```

---

## Request Performance

### Failed requests with latency – last 1h
Identify failing endpoints and their response times.

```kusto
AppRequests
| where TimeGenerated > ago(1h)
| where Success == false
| summarize
    FailCount = count(),
    AvgDuration = round(avg(DurationMs), 0),
    P95Duration = round(percentile(DurationMs, 95), 0),
    ResultCodes = make_set(ResultCode, 5)
  by Name, AppRoleName
| order by FailCount desc
```

---

### Request latency percentiles – P50 / P95 / P99
Performance baseline per endpoint – essential for SLA monitoring.

```kusto
AppRequests
| where TimeGenerated > ago(24h)
| where Success == true
| summarize
    P50 = round(percentile(DurationMs, 50), 0),
    P95 = round(percentile(DurationMs, 95), 0),
    P99 = round(percentile(DurationMs, 99), 0),
    RequestCount = count()
  by Name
| order by P95 desc
| take 20
```

---

### Success rate per endpoint – last 6h
Identify endpoints with degraded success rates.

```kusto
AppRequests
| where TimeGenerated > ago(6h)
| summarize
    Total = count(),
    Failed = countif(Success == false)
  by Name, AppRoleName
| extend SuccessRate = round((1.0 - todouble(Failed) / todouble(Total)) * 100, 2)
| where Total > 10
| order by SuccessRate asc
```

---

## Dependency Monitoring

### Dependency failures – downstream services
Detect which downstream services are causing failures.

```kusto
AppDependencies
| where TimeGenerated > ago(6h)
| where Success == false
| summarize
    Failures = count(),
    AvgDuration = round(avg(DurationMs), 0),
    LastFailure = max(TimeGenerated)
  by Target, Type, AppRoleName
| order by Failures desc
```

---

### Slow dependency calls – P95 latency by target
Find which external dependencies are the slowest.

```kusto
AppDependencies
| where TimeGenerated > ago(6h)
| where Success == true
| summarize
    CallCount = count(),
    P95Duration = round(percentile(DurationMs, 95), 0),
    AvgDuration = round(avg(DurationMs), 0)
  by Target, Type
| where CallCount > 50
| order by P95Duration desc
| take 15
```

---

## Custom Metrics

### Custom metrics per node over time
Track any custom application metric per node – replace metric name as needed.

```kusto
AppMetrics
| where TimeGenerated > ago(6h)
| where Name == "YourMetricName" // replace with your metric
| summarize
    AvgValue = round(avg(Sum), 2),
    MaxValue = round(max(Max), 2)
  by AppRoleInstance, bin(TimeGenerated, 5m)
| render timechart
```

---

*Use case: Application health, SLA monitoring, incident response, performance analysis*
*Source: AppRequests · AppExceptions · AppDependencies · AppTraces · AppMetrics*
