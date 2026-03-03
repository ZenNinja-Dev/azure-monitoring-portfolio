# KQL Query Library

Practical KQL queries for daily cloud operations, security investigations and infrastructure monitoring.
Built from real operational experience - used for incident response, threat detection, cost monitoring and system health.

---

## Files in This Folder

| File | Focus | Queries | Data Sources |
|------|-------|---------|-------------|
| authentication-and-identity.md | Sign-in threats, privilege escalation, resource auditing | 8 | SigninLogs, AuditLogs, AzureActivity, CommonSecurityLog |
| application-and-system-monitoring.md | Error detection, request performance, dependency health | 9 | AppRequests, AppExceptions, AppDependencies, AppMetrics |
| infrastructure-and-health.md | Node heartbeat, disk/CPU/network, Service Health correlation | 9 | Heartbeat, Perf, ServiceHealthResources |
| cost-and-workspace-health.md | Ingestion cost, workspace anomalies, alert investigation | 12 | Usage, AzureActivity, AlertsManagementResources |
| containers-and-availability.md | AKS pod health, container errors, uptime and SLA monitoring | 9 | KubePodInventory, KubeEvents, AppAvailabilityResults |
| full-log-investigation.md | Deep incident investigation across all App Insights sources | 2 | AppTraces, AppExceptions, AppRequests, AppDependencies |

---

## Query Index

### Authentication and Identity
- Failed login attempts - brute force detection
- Sign-ins from multiple countries - impossible travel
- Successful sign-in after multiple failures - credential stuffing
- Privileged role assignments
- Guest user invitations
- Azure resource deletions
- Azure resource deployments
- Anomalous outbound network traffic

### Application and System Monitoring
- Error spike detection - 24h vs previous 24h
- Top errors by frequency with text normalization
- Timeout pattern detection across all sources
- Failed requests with latency percentiles
- Request latency - P50 / P95 / P99
- Success rate per endpoint
- Dependency failures by downstream service
- Slow dependency calls - P95 latency
- Custom metrics per node over time

### Infrastructure and Health
- Node heartbeat - current status table
- Heartbeat time series - SCOM-like per node lines
- Nodes offline for more than 15 minutes
- Disk queue length - bottleneck detection
- Disk bytes/sec - throughput per node
- Nodes over 80% CPU or memory
- Network bytes/sec per node
- Active Azure platform incidents
- Azure Service Health vs internal errors - correlation

### Cost, Workspace Health and Alert Investigation
- Log Analytics ingestion cost by table
- Ingestion volume trend - last 30 days
- Top resource operations - last 30 days
- Ingestion latency per table
- Tables with zero ingestion
- Daily ingestion volume baseline
- Workspace ingestion anomaly - today vs 7-day average
- Most fired alerts - last 7 days
- Unresolved alerts older than 1 hour
- Alert timeline - last 24h

### Containers and Availability
- Pod restarts - last 24h
- OOMKilled containers
- Failed pod deployments
- Node resource pressure
- Container image pull errors
- Container log errors
- Availability test results - pass/fail by location
- Failed availability tests with error details
- Availability trend - last 7 days
- Response time degradation - P50/P95/P99

### Full Log Investigation
- Union query - last 24h rolling window
- Union query - fixed time window for known incident

---

## How to Use

All queries run in Azure Portal - Log Analytics Workspace - Logs.

- AppRequests, AppExceptions - requires Application Insights connected to workspace
- Heartbeat, Perf - requires Azure Monitor Agent deployed on nodes
- SigninLogs, AuditLogs - requires Entra ID diagnostic settings connected to workspace
- AlertsManagementResources - run in Azure Resource Graph Explorer, not Log Analytics
- KubePodInventory, KubeEvents - requires Container Insights enabled on AKS cluster
- AppAvailabilityResults - requires availability tests configured in Application Insights

---

Updated: 2026 | Azure Monitor - Log Analytics - Application Insights - Microsoft Sentinel - AKS
