# Full Log Investigation Queries

Queries for investigating system errors across all Application Insights data sources.
Used during outages, drops, and ad-hoc incident investigations.

Both queries use the same logic – the difference is only in the **time range**.

---

## How It Works

Each query performs a `union` across four Application Insights tables:
- `traces` – application log messages (errors and matched warnings)
- `exceptions` – unhandled exceptions
- `requests` – failed HTTP requests
- `dependencies` – failed downstream calls

Results are then normalized and grouped by error type so you can see which error is occurring most frequently.

**Output columns:**
`GroupKey` · `Hits` · `Percentage` · `FirstSeen` · `LastSeen` · `Roles` · `Tables` · `SampleTexts` · `SampleOperationIds`

---

## Version 1 – Last 24 Hours

Use for daily monitoring or post-incident review.

```kusto
let WarnMsgs = dynamic([
    "There was an error returned from the external system",
    "Failed to get response from method ProcessTransaction. Operation will be retried.",
    "Failed to get response from method ProcessPayout. Operation will be retried.",
    "Failed to get response from method EndSession. Operation will be retried.",
    "Failed to get response from method CloseSession. Operation will be retried."
]);
let ExcludeMsgs = dynamic([
    "User session does not exist",
    "Unable to obtain user session",
    "Getting currency rate from currency service failed."
]);
let Results =
union isfuzzy=true
(
    traces
    | where timestamp > ago(24h)
    | extend levelText = tolower(
            coalesce(
                tostring(customDimensions["level"]),
                tostring(customDimensions["Level"]),
                tostring(customDimensions["loglevel"]),
                tostring(customDimensions["LogLevel"])
            )
        )
    | extend IsError = (severityLevel == 3) or (levelText == "error")
    | extend IsWarnMatch = (severityLevel == 2) and (tostring(message) has_any (WarnMsgs))
    | extend Text = tostring(message), 
             Table = "traces", 
             Role = cloud_RoleName,
             AppRoleInstance = cloud_RoleInstance,
             OperationId = operation_Id
    | project timestamp, Table, Role, AppRoleInstance, severityLevel, Text, OperationId, _ResourceId, IsError, IsWarnMatch
),
(
    exceptions
    | where timestamp > ago(24h)
    | extend Text = tostring(coalesce(outerMessage, innermostMessage, type, problemId, ""))
    | extend Table = "exceptions", 
             Role = cloud_RoleName,
             AppRoleInstance = cloud_RoleInstance,
             severityLevel = 3,
             IsError = true, 
             IsWarnMatch = false,
             OperationId = operation_Id
    | project timestamp, Table, Role, AppRoleInstance, severityLevel, Text, OperationId, _ResourceId, IsError, IsWarnMatch
),
(
    requests
    | where timestamp > ago(24h)
    | where success == false
    | extend Text = strcat("Request failed: ", name, " (", resultCode, ")")
    | extend Table = "requests", 
             Role = cloud_RoleName,
             AppRoleInstance = cloud_RoleInstance,
             severityLevel = 3,
             IsError = true, 
             IsWarnMatch = false,
             OperationId = operation_Id
    | project timestamp, Table, Role, AppRoleInstance, severityLevel, Text, OperationId, _ResourceId, IsError, IsWarnMatch
),
(
    dependencies
    | where timestamp > ago(24h)
    | where success == false
    | extend Text = strcat("Dependency failed: ", name, " (", resultCode, ") - ", type, " to ", target)
    | extend Table = "dependencies", 
             Role = cloud_RoleName,
             AppRoleInstance = cloud_RoleInstance,
             severityLevel = 3,
             IsError = true, 
             IsWarnMatch = false,
             OperationId = operation_Id
    | project timestamp, Table, Role, AppRoleInstance, severityLevel, Text, OperationId, _ResourceId, IsError, IsWarnMatch
)
| where IsError or IsWarnMatch
| where not(Text has_any (ExcludeMsgs))
| extend ResourceGroup = extract(@"resourceGroups/([^/]+)/", 1, _ResourceId),
         AiComponent   = extract(@"components/([^/]+)$", 1, _ResourceId)
| extend NormalizedText = replace_regex(Text, @"'\d+->\d+'", "'N->N'")
| extend NormalizedText = replace_regex(NormalizedText, @"\b\d+\b", "N")
| extend NormalizedText = replace_regex(NormalizedText, @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}", "GUID")
| extend GroupKey = case(
    Text startswith "Request failed: ", "Request failed",
    Text startswith "Dependency failed: ", "Dependency failed",
    Text startswith "Failed to send critical files for client ", "Failed to send critical files for client",
    Text startswith "SyncService: Failed to fetch currency rate for ", "SyncService: Failed to fetch currency rate",
    Text startswith "FeatureX functionality is disabled for client ", "FeatureX functionality is disabled for client",
    Text startswith "Response did not arrive on time in ", "Response did not arrive on time in",
    NormalizedText
);
let TotalHits = toscalar(Results | count);
Results
| summarize Hits=count(), 
            FirstSeen=min(timestamp), 
            LastSeen=max(timestamp),
            Roles=make_set(Role, 10), 
            Tables=make_set(Table, 4), 
            RGs=make_set(ResourceGroup, 5), 
            AIs=make_set(AiComponent, 5),
            SampleTexts=make_set(Text, 5),
            SampleOperationIds=make_set(OperationId, 3)
  by GroupKey
| extend Percentage = round(todouble(Hits) * 100.0 / todouble(TotalHits), 2)
| order by Hits desc, LastSeen desc
```

---

## Version 2 – Fixed Time Window (1 Hour)

Use when investigating a specific incident with a known time window.
Replace the datetime values with the actual start and end of the incident.

```kusto
// Set your investigation window here
// Example: datetime(2025-01-01 10:00:00) and timestamp <= datetime(2025-01-01 11:00:00)

let WarnMsgs = dynamic([
    "There was an error returned from the external system",
    "Failed to get response from method ProcessTransaction. Operation will be retried.",
    "Failed to get response from method ProcessPayout. Operation will be retried.",
    "Failed to get response from method EndSession. Operation will be retried.",
    "Failed to get response from method CloseSession. Operation will be retried."
]);
let ExcludeMsgs = dynamic([
    "User session does not exist",
    "Unable to obtain user session",
    "Getting currency rate from currency service failed."
]);
let Results =
union isfuzzy=true
(
    traces
    | where timestamp >= datetime(2025-01-01 10:00:00) and timestamp <= datetime(2025-01-01 11:00:00)
    | extend levelText = tolower(
            coalesce(
                tostring(customDimensions["level"]),
                tostring(customDimensions["Level"]),
                tostring(customDimensions["loglevel"]),
                tostring(customDimensions["LogLevel"])
            )
        )
    | extend IsError = (severityLevel == 3) or (levelText == "error")
    | extend IsWarnMatch = (severityLevel == 2) and (tostring(message) has_any (WarnMsgs))
    | extend Text = tostring(message), 
             Table = "traces", 
             Role = cloud_RoleName,
             AppRoleInstance = cloud_RoleInstance,
             OperationId = operation_Id
    | project timestamp, Table, Role, AppRoleInstance, severityLevel, Text, OperationId, _ResourceId, IsError, IsWarnMatch
),
(
    exceptions
    | where timestamp >= datetime(2025-01-01 10:00:00) and timestamp <= datetime(2025-01-01 11:00:00)
    | extend Text = tostring(coalesce(outerMessage, innermostMessage, type, problemId, ""))
    | extend Table = "exceptions", 
             Role = cloud_RoleName,
             AppRoleInstance = cloud_RoleInstance,
             severityLevel = 3,
             IsError = true, 
             IsWarnMatch = false,
             OperationId = operation_Id
    | project timestamp, Table, Role, AppRoleInstance, severityLevel, Text, OperationId, _ResourceId, IsError, IsWarnMatch
),
(
    requests
    | where timestamp >= datetime(2025-01-01 10:00:00) and timestamp <= datetime(2025-01-01 11:00:00)
    | where success == false
    | extend Text = strcat("Request failed: ", name, " (", resultCode, ")")
    | extend Table = "requests", 
             Role = cloud_RoleName,
             AppRoleInstance = cloud_RoleInstance,
             severityLevel = 3,
             IsError = true, 
             IsWarnMatch = false,
             OperationId = operation_Id
    | project timestamp, Table, Role, AppRoleInstance, severityLevel, Text, OperationId, _ResourceId, IsError, IsWarnMatch
),
(
    dependencies
    | where timestamp >= datetime(2025-01-01 10:00:00) and timestamp <= datetime(2025-01-01 11:00:00)
    | where success == false
    | extend Text = strcat("Dependency failed: ", name, " (", resultCode, ") - ", type, " to ", target)
    | extend Table = "dependencies", 
             Role = cloud_RoleName,
             AppRoleInstance = cloud_RoleInstance,
             severityLevel = 3,
             IsError = true, 
             IsWarnMatch = false,
             OperationId = operation_Id
    | project timestamp, Table, Role, AppRoleInstance, severityLevel, Text, OperationId, _ResourceId, IsError, IsWarnMatch
)
| where IsError or IsWarnMatch
| where not(Text has_any (ExcludeMsgs))
| extend ResourceGroup = extract(@"resourceGroups/([^/]+)/", 1, _ResourceId),
         AiComponent   = extract(@"components/([^/]+)$", 1, _ResourceId)
| extend NormalizedText = replace_regex(Text, @"'\d+->\d+'", "'N->N'")
| extend NormalizedText = replace_regex(NormalizedText, @"\b\d+\b", "N")
| extend NormalizedText = replace_regex(NormalizedText, @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}", "GUID")
| extend GroupKey = case(
    Text startswith "Request failed: ", "Request failed",
    Text startswith "Dependency failed: ", "Dependency failed",
    Text startswith "Failed to send critical files for client ", "Failed to send critical files for client",
    Text startswith "SyncService: Failed to fetch currency rate for ", "SyncService: Failed to fetch currency rate",
    Text startswith "FeatureX functionality is disabled for client ", "FeatureX functionality is disabled for client",
    Text startswith "Response did not arrive on time in ", "Response did not arrive on time in",
    NormalizedText
);
let TotalHits = toscalar(Results | summarize count());
Results
| summarize Hits=count(), 
            FirstSeen=min(timestamp), 
            LastSeen=max(timestamp),
            Roles=make_set(Role, 10), 
            Tables=make_set(Table, 4), 
            RGs=make_set(ResourceGroup, 5), 
            AIs=make_set(AiComponent, 5),
            SampleTexts=make_set(Text, 5),
            SampleOperationIds=make_set(OperationId, 3)
  by GroupKey
| extend Percentage = round(todouble(Hits) * 100.0 / todouble(TotalHits), 2)
| order by Hits desc, LastSeen desc
```

---

*Use case: Incident investigation, outage root cause analysis | Source: Application Insights – traces, exceptions, requests, dependencies*
