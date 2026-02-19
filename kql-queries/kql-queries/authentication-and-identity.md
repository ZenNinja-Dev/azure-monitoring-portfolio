# Authentication & Identity Queries

## 1. Failed Sign-in Attempts (Last 24 Hours)
Detects multiple failed logins – useful for brute force detection.
```kusto
SigninLogs
| where TimeGenerated > ago(24h)
| where ResultType != "0"
| summarize FailedAttempts = count() by UserPrincipalName, IPAddress, Location
| where FailedAttempts > 5
| order by FailedAttempts desc
```

---

## 2. Sign-ins from Multiple Countries (Same User)
Flags accounts logging in from different countries in short time window – impossible travel detection.
```kusto
SigninLogs
| where TimeGenerated > ago(1h)
| summarize Countries = dcount(Location), LocationList = make_set(Location) by UserPrincipalName
| where Countries > 1
```

---

## 3. Privileged Role Assignments
Detects when someone is assigned a privileged Azure AD role – critical for privilege escalation monitoring.
```kusto
AuditLogs
| where OperationName == "Add member to role"
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend Role = tostring(TargetResources[0].displayName)
| project TimeGenerated, InitiatedBy, TargetUser, Role
| order by TimeGenerated desc
```

---

## 4. Service Principal Logins Outside Business Hours
Useful for detecting suspicious automation or compromised service accounts.
```kusto
SigninLogs
| where TimeGenerated > ago(7d)
| where AppDisplayName != ""
| extend Hour = datetime_part("Hour", TimeGenerated)
| where Hour < 6 or Hour > 20
| project TimeGenerated, AppDisplayName, IPAddress, Location, ResultType
```

---

*Use case: Identity threat detection | Tested in: Log Analytics Workspace*
