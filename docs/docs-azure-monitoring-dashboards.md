# Azure Monitoring – Dashboards Guide

Operational guide for using Azure Portal shared dashboards for system monitoring.  
Written for both newcomers and senior operators getting familiar with Azure monitoring setup.

---

## Accessing Dashboards

1. Go to **Azure Portal** → **Dashboard**
2. If you don't see the dashboards, click **"Browse all dashboards"** at the bottom of the drop-down menu
3. In the filter, search for the dashboard name
4. Click on the highlighted dashboard and then click **"Open"**

---

## Important Notes for Operators

- Graph data is updated every **5 minutes** – for accurate data always hard refresh the page (`CTRL + F5`)
- If you see a sudden extreme drop on a graph – **do not panic immediately**
- Data flow to the graph can get disrupted, causing a visual spike or drop that is not a real incident
- **What to do:** Wait up to 5 minutes and refresh. If the drop continues, monitor further based on severity
- Keep in mind that graphs follow time patterns – activity naturally drops in evening hours

---

## Azure Health vs. Ops Metrics Dashboard

A special dashboard used for checking and correlating Microsoft Azure Service Health with internal system metrics.

**Layout:**
- **Right side** – transaction metric graphs for each monitored client environment
- **Left side** – markdown panel with Azure Service Health quick links

**Quick Links available in the dashboard:**
- **Service Health Dashboard** – overall health status of the Azure subscription
- **Health History** – history of past incidents and maintenance events
- **Your Alerts** – configured alerts for system health notifications
- **Current Status** – official Microsoft Azure page showing live outages, incidents, and maintenance events

**How to use:**
1. Check the Quick Links panel for any active Azure incidents or maintenance in the relevant region
2. If Azure shows an active incident → the issue is likely on Microsoft's side
3. If Azure is healthy but metrics have dropped → the issue is internal, escalate accordingly

---

## Creating Custom Graphs (Advanced Operators Only)

### 1. Environment-Level Graph

Monitors all transaction activity within a single environment.

```kusto
union
    AppMetrics
    ,workspace("<WORKSPACE_ID>").AppMetrics
| where AppRoleName == "App Backend"
    and (
        ((Name == "Transaction Count") and (Properties.IsRealMoney == true))
        or (Name == "App Errors")
    )
    and (Properties.Platform != "Test (In Memory)")
| summarize Count = sum(ItemCount) by Name, Time = bin(TimeGenerated, 1m)
| summarize Final = avg(Count) by Name, bin(Time, 5m)
| render timechart
```

**Instructions:**
- Replace `<WORKSPACE_ID>` with the Log Analytics Workspace ID for the target environment
- The workspace ID can be found in Azure Portal by searching for the environment name
- The environment workspace must be a LAW (Log Analytics Workspace)

---

### 2. Platform-Level Graph

Monitors transaction activity across multiple environments simultaneously.

```kusto
union
    AppMetrics,
    workspace("<WORKSPACE_ID_CLIENT_A>").AppMetrics,
    workspace("<WORKSPACE_ID_CLIENT_B>").AppMetrics,
    workspace("<WORKSPACE_ID_CLIENT_C>").AppMetrics,
    workspace("<WORKSPACE_ID_CLIENT_D>").AppMetrics,
    workspace("<WORKSPACE_ID_CLIENT_E>").AppMetrics
| where AppRoleName == "App Backend"
    and (
        ((Name == "Transaction Count") and (Properties.IsRealMoney == true))
        or (Name == "App Errors")
    )
    and Properties.Platform in ("<PLATFORM_NAME>")
| summarize Count = sum(ItemCount) by Name, Time = bin(TimeGenerated, 1m)
| summarize Final = avg(Count) by Name, bin(Time, 5m)
| render timechart
```

**Instructions:**
- Add each environment workspace ID that belongs to the platform
- Replace `<PLATFORM_NAME>` with the correct platform name (case-sensitive)
- The platform name must match exactly the value used in `Properties.Platform`

---

### 3. Customer-Level Graph

Monitors transaction activity for a specific customer within an environment.

```kusto
union
    AppMetrics
    ,workspace("<WORKSPACE_ID>").AppMetrics
| where AppRoleName == "App Backend"
    and (
        ((Name == "Transaction Count")
            and tostring(Properties.Customer) in ("<CUSTOMER_ALIAS>")
            and (Properties.IsRealMoney == true))
        or (Name == "App Errors")
    )
| summarize Count = sum(ItemCount) by Name, Time = bin(TimeGenerated, 1m)
| summarize Final = avg(Count) by Name, bin(Time, 5m)
| render timechart
```

**Instructions:**
- Replace `<WORKSPACE_ID>` with the workspace ID where the customer is set up
- Replace `<CUSTOMER_ALIAS>` with the customer's alias as configured in the system settings
- **Important:** The customer alias is case-sensitive and must match exactly

---

## Final Notes

- Always verify that platform or customer names match exactly in system settings
- Workspace IDs must be updated correctly for each environment
- Case sensitivity matters for both platform names and customer aliases

---

*Domain: Azure Monitor | Log Analytics Workspace | Application Insights | Custom Metrics*
