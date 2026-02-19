# Azure Monitor Alerts

Documentation of alert rules, configurations and best practices for Azure security monitoring.

---

## Alert Types

**Metric Alerts** – trigger based on a numeric threshold (e.g. CPU > 90%)  
**Log Alerts** – trigger based on a KQL query result  
**Activity Log Alerts** – trigger on specific Azure resource events  
**Smart Detection** – AI-based anomaly detection via Application Insights

---

## Alert Severity Levels

| Severity | Level | Use Case |
|----------|-------|----------|
| Sev 0 | Critical | Service down, active breach |
| Sev 1 | Error | Significant impact, needs immediate action |
| Sev 2 | Warning | Potential issue, requires investigation |
| Sev 3 | Informational | Awareness only |
| Sev 4 | Verbose | Debugging and diagnostics |

---

## Files in This Folder

| File | Description |
|------|-------------|
| `security-alerts.md` | Alert rules for security monitoring use cases |
| `application-alerts.md` | Alert rules for app health and performance |

---

*Source: Azure Monitor | Log Analytics Workspace*
