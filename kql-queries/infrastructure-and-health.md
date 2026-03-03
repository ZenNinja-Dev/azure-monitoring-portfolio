test

# Infrastructure & Health Queries

KQL queries for infrastructure monitoring, node health and Azure Service Health correlation.
Inspired by SCOM-style node monitoring.
Data sources: Heartbeat, Perf, ServiceHealthResources, AppExceptions.

---

## Node Health

### Node heartbeat - current status
```kusto
Heartbeat
| summarize LastHeartbeat = max(TimeGenerated) by Computer, OSType, ComputerIP
| extend Status = case(
    LastHeartbeat > ago(5m),  "Online",
    LastHeartbeat > ago(15m), "Warning",
    "Offline"
)
| project Computer, Status, LastHeartbeat, OSType, ComputerIP
| order by Status asc, Computer asc
```

---

### Heartbeat time series - SCOM-like per node lines

```kusto
Heartbeat
| where TimeGenerated > ago(24h)
| summarize Heartbeats = count() by Computer, bin(TimeGenerated, 5m)
| render timechart
```

---

### Nodes offline for more than 15 minutes

```kusto
Heartbeat
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(15m)
| extend MinutesSilent = datetime_diff("minute", now(), LastHeartbeat)
| order by MinutesSilent desc
```

---

## Disk & Storage

### Disk queue length - bottleneck detection (threshold > 1)

```kusto
Perf
| where TimeGenerated > ago(1h)
| where ObjectName == "LogicalDisk"
    and CounterName == "Avg. Disk Queue Length"
    and InstanceName != "_Total"
| summarize AvgQueue = round(avg(CounterValue), 2) by Computer, InstanceName
| where AvgQueue > 1
| order by AvgQueue desc
```

---

### Disk bytes/sec - throughput per node

```kusto
Perf
| where TimeGenerated > ago(1h)
| where ObjectName == "LogicalDisk"
    and CounterName == "Disk Bytes/sec"
    and InstanceName != "_Total"
| summarize AvgBytesPerSec = round(avg(CounterValue), 0) by Computer, InstanceName
| order by AvgBytesPerSec desc
```

---

## CPU & Memory

### Nodes over 80% CPU or memory - last 30 minutes

```kusto
Perf
| where TimeGenerated > ago(30m)
| where (ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total")
    or (ObjectName == "Memory" and CounterName == "% Committed Bytes In Use")
| summarize AvgValue = round(avg(CounterValue), 1) by Computer, CounterName
| where AvgValue > 80
| order by AvgValue desc
```

---

### Network bytes total/sec - per node

```kusto
Perf
| where TimeGenerated > ago(1h)
| where ObjectName == "Network Adapter"
    and CounterName == "Bytes Total/sec"
| summarize AvgBytesPerSec = round(avg(CounterValue), 0) by Computer, InstanceName
| order by AvgBytesPerSec desc
```

---

## Azure Service Health

### Active Azure platform incidents

```kusto
ServiceHealthResources
| where type == "microsoft.resourcehealth/events"
| extend
    EventType = tostring(properties.EventType),
    Status    = tostring(properties.Status),
    Title     = tostring(properties.Title),
    Impact    = tostring(properties.Impact)
| where Status == "Active"
| project
    IncidentStart = todatetime(properties.ImpactStartTime),
    EventType, Status, Title, Impact
| order by IncidentStart desc
```

---

### Azure Service Health vs. internal errors - correlation
Use to answer immediately: is this our problem or Microsoft's?

```kusto
let azureIncidents = ServiceHealthResources
    | where type == "microsoft.resourcehealth/events"
    | where tostring(properties.Status) == "Active"
    | extend IncidentStart = todatetime(properties.ImpactStartTime)
    | project IncidentStart, Title = tostring(properties.Title);
let appErrors = AppExceptions
    | where TimeGenerated > ago(24h)
    | summarize ErrorCount = count() by bin(TimeGenerated, 5m);
azureIncidents
| join kind=leftouter appErrors on $left.IncidentStart == $right.TimeGenerated
| project IncidentStart, Title, ErrorCount = coalesce(ErrorCount, 0)
| order by IncidentStart desc
```

---

*Use case: Node monitoring, infrastructure health, incident triage, Azure platform correlation*
*Source: Heartbeat - Perf - ServiceHealthResources - AppExceptions*
