# Azure Alerts – Introduction & Response Guide

Operational guide for responding to Azure Monitor alerts.  
Covers alert types, initial triage workflow, and escalation process.

---

## Alert Types

### A – Service Outage Alert (Sev 0 / Sev 1)
Fires when transaction or activity count drops to zero within a defined time window.  
Indicates a full service outage for the monitored system.

**Trigger condition:** Transaction count `<= 0` in last 5 minutes  
**Expected response time:** Immediate

---

### B – Activity Decrease Alert (Sev 2)
Fires when activity drops by approximately 50% compared to the baseline.  
May indicate a partial outage, degraded performance, or upstream issue.

**Trigger condition:** Activity count drops >= 50% vs. rolling average  
**Expected response time:** Within 15 minutes

---

## Response Workflow

### Step 1 – Set Up Alert Notifications
Configure your email client to receive and organize Azure alert emails.

- Create a dedicated folder for Microsoft Azure alerts
- Set up an inbox rule: sender contains `microsoft.com` or subject contains `Azure Monitor` → move to folder
- This ensures alerts are never missed during high-volume periods

---

### Step 2 – Triage the Alert
When an alert email arrives, open it and click **"View the Alert in Azure Monitor"** or **"See in Azure Portal"**.

Check the following immediately:
- Which system or component is affected
- Alert severity (Sev 0 = critical outage, Sev 2 = warning)
- Whether it is a **false positive** – verify against live monitors before escalating

---

### Step 3 – Verify on Monitors
Open the relevant dashboards to estimate the exact start time and scope of the issue.

- Check transaction or activity volume charts for the affected system
- Identify when the drop started and whether it is recovering
- Take screenshots with timestamps – these will be needed for the incident report

---

### Step 4 – Communicate to the Team
Post to the operations channel with:
- Screenshots from Azure Monitor showing the drop
- Affected system name and alert type
- Estimated start time of the issue
- Your initial assessment (outage / degraded / recovering)

Use a clear format so the team can act immediately without asking follow-up questions.

---

### Step 5 – Escalate if Needed
- If the outage is confirmed and not recovering → contact your manager or team lead immediately
- If it is outside business hours or a weekend duty → follow the on-call escalation process

---

## Quick Reference

| Alert Type | Severity | Action |
|------------|----------|--------|
| Service Outage | Sev 0–1 | Immediate triage + escalate |
| Activity Decrease 50% | Sev 2 | Verify on monitors, inform team |
| False Positive | – | Document and dismiss |

---

*Domain: Azure Monitor Alerts | Operational Monitoring | Incident Response*
