# Application Alert Rules

Alert rules for application health, performance and error monitoring.

---

## 1. High Error Rate Alert
**Trigger:** More than 10 exceptions in 5 minutes  
**Severity:** Sev 1 – Error  
**Action:** Notify on-call engineer
```kusto
AppExceptions
| where TimeGenerated > ago(5m)
| summarize ExceptionCount = count() by AppRoleName
| where ExceptionCount > 10
```

**Alert configuration:**
- Frequency: Every 5 minutes
- Lookback window: 5 minutes
- Threshold: Results > 0

---

## 2. Elevated HTTP 5xx Error Rate
**Trigger:** More than 20 server-side errors in 10 minutes  
**Severity:** Sev 1 – Error  
**Action:** Notify development team
```kusto
AppRequests
| where TimeGenerated > ago(10m)
| where ResultCode >= 500
| summarize ServerErrors = count() by AppRoleName
| where ServerErrors > 20
```

**Alert configuration:**
- Frequency: Every 5 minutes
- Lookback window: 10 minutes
- Threshold: Results > 0

---

## 3. Slow Response Time Alert
**Trigger:** Average request duration exceeds 3 seconds  
**Severity:** Sev 2 – Warning  
**Action:** Notify development team
```kusto
AppRequests
| where TimeGenerated > ago(15m)
| summarize AvgDuration = avg(DurationMs) by AppRoleName
| where AvgDuration > 3000
```

**Alert configuration:**
- Frequency: Every 10 minutes
- Lookback window: 15 minutes
- Threshold: Results > 0

---

## 4. Zero Requests Received – Availability Alert
**Trigger:** No requests received in 10 minutes – possible outage  
**Severity:** Sev 0 – Critical  
**Action:** Page on-call engineer immediately
```kusto
AppRequests
| where TimeGenerated > ago(10m)
| summarize RequestCount = count() by AppRoleName
| where RequestCount == 0
```

**Alert configuration:**
- Frequency: Every 5 minutes
- Lookback window: 10 minutes
- Threshold: Results > 0

---

*Source: Application Insights | Azure Monitor Alerts*
