# Authentication & Identity Queries

KQL queries for identity threat detection, access monitoring and security investigations.
Data sources: SigninLogs, AuditLogs, AzureActivity, CommonSecurityLog.

---

## Sign-in & Authentication

### Failed login attempts – brute force detection
Detect accounts with high failed login counts in a short window.

```kusto
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != "0"
| summarize
    FailedAttempts = count(),
    DistinctIPs = dcount(IPAddress),
    IPList = make_set(IPAddress, 5),
    LastAttempt = max(TimeGenerated)
  by UserPrincipalName
| where FailedAttempts > 10
| order by FailedAttempts desc
```

---

### Sign-ins from multiple countries – impossible travel
Flag accounts signing in from geographically distant locations within 24h.

```kusto
SigninLogs
| where TimeGenerated > ago(24h)
| where ResultType == "0"
| summarize
    Countries = make_set(Location, 10),
    CountryCount = dcount(Location),
    IPList = make_set(IPAddress, 5)
  by UserPrincipalName
| where CountryCount > 1
| order by CountryCount desc
```

---

### Successful sign-in after multiple failures – credential stuffing
Detect potential credential stuffing – many failures followed by a success.

```kusto
let failedLogins = SigninLogs
    | where TimeGenerated > ago(1h)
    | where ResultType != "0"
    | summarize FailCount = count() by UserPrincipalName, IPAddress;
let successLogins = SigninLogs
    | where TimeGenerated > ago(1h)
    | where ResultType == "0"
    | project UserPrincipalName, IPAddress, SuccessTime = TimeGenerated;
successLogins
| join kind=inner failedLogins on UserPrincipalName
| where FailCount > 5
| project SuccessTime, UserPrincipalName, IPAddress, FailCount
| order by FailCount desc
```

---

## Privileged Access & Role Changes

### Privileged role assignments – last 7 days
Detect new Azure AD role assignments which could indicate privilege escalation.

```kusto
AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName has "Add member to role"
| extend
    TargetUser = tostring(TargetResources[0].userPrincipalName),
    RoleName = tostring(TargetResources[0].displayName),
    InitiatedBy = tostring(InitiatedBy.user.userPrincipalName)
| project TimeGenerated, InitiatedBy, TargetUser, RoleName, Result
| order by TimeGenerated desc
```

---

### Guest user invitations – last 7 days
Monitor external user access grants.

```kusto
AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName has "Invite external user"
| extend
    InvitedUser = tostring(TargetResources[0].userPrincipalName),
    InvitedBy = tostring(InitiatedBy.user.userPrincipalName)
| project TimeGenerated, InvitedBy, InvitedUser, Result
| order by TimeGenerated desc
```

---

## Azure Resource Activity

### Azure resource deletions – last 24h
Audit trail for deleted resources – detect unauthorized or accidental changes.

```kusto
AzureActivity
| where TimeGenerated > ago(24h)
| where OperationNameValue endswith "delete"
| where ActivityStatusValue == "Success"
| project
    TimeGenerated,
    Caller,
    ResourceGroup,
    Resource,
    OperationNameValue
| order by TimeGenerated desc
```

---

### Azure resource deployments – last 24h
Track all successful deployments to detect unauthorized infrastructure changes.

```kusto
AzureActivity
| where TimeGenerated > ago(24h)
| where OperationNameValue has "deployments/write"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, ResourceGroup, ResourceId, OperationNameValue
| order by TimeGenerated desc
```

---

## Network & Threat Hunting

### Anomalous outbound network traffic
Detect unusual outbound connections by volume – useful for data exfiltration detection.

```kusto
CommonSecurityLog
| where TimeGenerated > ago(24h)
| where CommunicationDirection == "Outbound"
| summarize
    BytesSent = sum(SentBytes),
    ConnectionCount = count(),
    DestinationIPs = dcount(DestinationIP)
  by SourceIP, DeviceName
| where BytesSent > 100000000 // > 100 MB
| order by BytesSent desc
```

---

*Use case: Security monitoring, threat detection, access auditing*
*Source: SigninLogs · AuditLogs · AzureActivity · CommonSecurityLog*
