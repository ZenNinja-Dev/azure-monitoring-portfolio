# Security Alert Rules

KQL-based alert rules for security monitoring in Azure Monitor / Log Analytics.

---

## 1. Brute Force Detection – Multiple Failed Sign-ins
**Trigger:** More than 5 failed login attempts from the same IP within 10 minutes  
**Severity:** Sev 1 – Error  
**Action:** Notify SOC team via Action Group
```kusto
SigninLogs
| where TimeGenerated > ago(10m)
| where ResultType != "0"
| summarize FailedAttempts = count() by IPAddress, UserPrincipalName
| where FailedAttempts > 5
```

**Alert configuration:**
- Frequency: Every 5 minutes
- Lookback window: 10 minutes
- Threshold: Results > 0

---

## 2. Privileged Role Assignment Alert
**Trigger:** Any assignment of a privileged Azure AD role  
**Severity:** Sev 1 – Error  
**Action:** Notify security team immediately
```kusto
AuditLogs
| where OperationName == "Add member to role"
| extend Role = tostring(TargetResources[0].displayName)
| where Role in ("Global Administrator", "Security Administrator", "Privileged Role Administrator")
```

**Alert configuration:**
- Frequency: Every 5 minutes
- Lookback window: 5 minutes
- Threshold: Results > 0

---

## 3. Impossible Travel Detection
**Trigger:** Same user signs in from 2+ countries within 1 hour  
**Severity:** Sev 0 – Critical  
**Action:** Block account + notify SOC
```kusto
SigninLogs
| where TimeGenerated > ago(1h)
| summarize Countries = dcount(Location), LocationList = make_set(Location) by UserPrincipalName
| where Countries > 1
```

**Alert configuration:**
- Frequency: Every 15 minutes
- Lookback window: 1 hour
- Threshold: Results > 0

---

*Source: Azure Monitor Alerts | Log Analytics Workspace | Microsoft Defender for Cloud*
