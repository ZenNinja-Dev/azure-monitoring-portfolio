# Azure Service Health Alerts – Setup & Response Guide

Guide for configuring email notifications for Azure Service Health alerts and Tier 1 outage alerts.  
Covers Outlook rule setup, alert types, and investigation workflow.

---

## Part 1 – Azure Service Health Alerts

### Email Rule Setup

**Step 1** – Create a dedicated folder in Outlook: `"Service Health"` inside your Azure alerts folder

**Step 2** – Create an Outlook inbox rule:
- Condition: **specific words in the body** → insert: `Azure-ServiceHealth`
- Action: move to folder `"Service Health"`
- Click OK → Next → allow the rule to run on previous emails → Finish

When an Azure Service Health alert fires, you will receive an email notification with details about the affected service, region, and estimated resolution time.

---

## Part 2 – Tier 1 Transaction Outage Alerts

These alerts fire when transaction count drops to zero for a monitored client environment.

### Email Rule Setup

**Step 1** – Create a dedicated folder in Outlook: `"Tier1-Transactions-Zero"` inside your Azure alerts folder

**Step 2** – Create an Outlook inbox rule:
- Condition: **subject contains** → `Alert 'Tier1-Transactions-Zero-Alert-`
- Action: move to folder `"Tier1-Transactions-Zero"`
- Click OK → Next → allow the rule to run on previous emails → Finish

---

## Alert Investigation Workflow

When a Tier 1 outage alert fires:

**Step 1** – Open the **Tier 1 Metrics dashboard** in Azure Portal  
*(URL configured in your team's shared bookmarks or dashboard list)*

**Step 2** – Identify the affected client from the alert email subject line and open their graph

**Step 3** – Estimate the outage window:
- When did the drop start?
- Is it recovering or still at zero?
- Is it isolated to one client or affecting multiple?

**Step 4** – Share your investigation findings with the operations team channel including:
- Screenshots with timestamps
- Affected client name
- Drop start time and current status
- Your initial assessment

**Step 5** – Escalate if needed:
- Contact your manager or team lead
- If outside business hours → follow the on-call escalation process

---

## Quick Reference – Alert Types

| Alert Type | Folder | Trigger |
|------------|--------|---------|
| Azure Service Health | `Service Health` | Microsoft Azure infrastructure issues |
| Tier 1 Transaction Outage | `Tier1-Transactions-Zero` | Client transaction count = 0 for 5 min |

---

*Domain: Azure Monitor Alerts | Azure Service Health | Incident Response | Outlook Rules*
