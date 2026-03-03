# Container, AKS & Availability Monitoring

KQL queries for Kubernetes/AKS health monitoring and application availability tracking.
Data sources: ContainerLog, KubePodInventory, KubeNodeInventory, KubeEvents, AppAvailabilityResults.

---

## Container & AKS Monitoring

### Pod restarts - last 24h
Most common symptom of application problems in Kubernetes.
High restart count means crash loop, OOM kill or failed health checks.

```kusto
KubePodInventory
| where TimeGenerated > ago(24h)
| where RestartCount > 0
| summarize
    MaxRestarts = max(RestartCount),
    LastRestart = max(TimeGenerated)
  by Name, Namespace, ContainerName, Node
| order by MaxRestarts desc
```

---

### OOMKilled containers - last 24h
Containers killed due to memory limit exceeded.
Use to tune memory requests/limits in pod specs.

```kusto
KubeEvents
| where TimeGenerated > ago(24h)
| where Reason == "OOMKilling"
| project TimeGenerated, Name, Namespace, Message, SourceComponent
| order by TimeGenerated desc
```

---

### Failed pod deployments - last 24h
Detect deployment failures before they escalate to an incident.

```kusto
KubePodInventory
| where TimeGenerated > ago(24h)
| where PodStatus in ("Failed", "CrashLoopBackOff", "ImagePullBackOff", "Pending")
| summarize
    Count = count(),
    LastSeen = max(TimeGenerated)
  by Name, Namespace, PodStatus, ContainerName
| order by LastSeen desc
```

---

### Node resource pressure - CPU and memory
Node-level resource usage. High pressure leads to pod evictions.

```kusto
KubeNodeInventory
| where TimeGenerated > ago(1h)
| summarize
    AvgCPUCapacity = avg(Capacity_cpu_cores),
    AvgMemCapacityGB = round(avg(Capacity_memory_bytes) / 1073741824, 1)
  by Computer, Status
| order by AvgCPUCapacity desc
```

---

### Container image pull errors - last 24h
Detects registry authentication issues or missing images.

```kusto
KubeEvents
| where TimeGenerated > ago(24h)
| where Reason in ("Failed", "BackOff")
| where Message has_any ("ImagePullBackOff", "ErrImagePull", "pull access denied", "not found")
| project TimeGenerated, Name, Namespace, Reason, Message
| order by TimeGenerated desc
```

---

### Container log errors - last 1h
Application-level errors from container stdout/stderr.

```kusto
ContainerLog
| where TimeGenerated > ago(1h)
| where LogEntrySource == "stderr"
    or LogEntry has_any ("ERROR", "FATAL", "Exception", "error")
| summarize
    ErrorCount = count(),
    LastError = max(TimeGenerated),
    SampleLog = any(LogEntry)
  by ContainerID, Image
| order by ErrorCount desc
| take 20
```

---

## Availability & Synthetic Monitoring

### Availability test results - last 24h
Overall pass/fail status per availability test and location.

```kusto
AppAvailabilityResults
| where TimeGenerated > ago(24h)
| summarize
    Total = count(),
    Passed = countif(Success == true),
    Failed = countif(Success == false)
  by Name, Location
| extend AvailabilityPct = round(todouble(Passed) / todouble(Total) * 100, 2)
| order by AvailabilityPct asc
```

---

### Failed availability tests - last 6h
Drill into specific failures with error details and location.

```kusto
AppAvailabilityResults
| where TimeGenerated > ago(6h)
| where Success == false
| project
    TimeGenerated,
    TestName = Name,
    Location,
    Duration = DurationMs,
    Message
| order by TimeGenerated desc
```

---

### Availability trend - last 7 days
SLA reporting baseline - daily availability percentage per test.

```kusto
AppAvailabilityResults
| where TimeGenerated > ago(7d)
| summarize
    Total = count(),
    Passed = countif(Success == true)
  by Name, bin(TimeGenerated, 1d)
| extend AvailabilityPct = round(todouble(Passed) / todouble(Total) * 100, 2)
| render timechart
```

---

### Response time degradation - availability tests
Detect slowdowns before they become outages.
Useful for SLA monitoring and capacity planning.

```kusto
AppAvailabilityResults
| where TimeGenerated > ago(24h)
| where Success == true
| summarize
    P50 = round(percentile(DurationMs, 50), 0),
    P95 = round(percentile(DurationMs, 95), 0),
    P99 = round(percentile(DurationMs, 99), 0)
  by Name, Location
| order by P95 desc
```

---

*Use case: AKS health, container debugging, uptime monitoring, SLA reporting*
*Source: KubePodInventory - KubeNodeInventory - KubeEvents - ContainerLog - AppAvailabilityResults*

Note: AKS queries require Container Insights enabled on the cluster (Azure Monitor - Insights - Containers).
Availability queries require availability tests configured in Application Insights.
