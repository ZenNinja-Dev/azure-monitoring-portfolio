# Azure Specific Monitoring – Customer & Environment Metrics

Guide for checking specific metrics for customers and environments in Azure Monitor.  
Written for operators who need to investigate activity for individual clients.

---

## Prerequisites

Before monitoring a specific customer, the **Customer Alias** must be configured in the system's BackOffice settings under **"Customer's alias in metrics"**.

If this alias is not set, the customer will not appear in Azure metric filters.

---

## Step-by-Step: Check Customer Activity

### Step 1 – Find the Customer's Environment

Use the Azure Portal search bar to find the correct environment for the customer.

Each environment has an Application Insights component – always look for the **"-ain"** suffix (e.g. `ClientA-ain`).

---

### Step 2 – Open the Metrics Section

Inside the Application Insights resource, navigate to the **Metrics** section in the left panel.

---

### Step 3 – Set the Metric

Select the metric you want to monitor.  
For transaction monitoring, use **Transaction Count** and always set **Aggregation** to **"Sum"**.

---

### Step 4 – Add a Customer Filter

To narrow results to a specific customer:

1. Click **"Add filter"**
2. Set **Property** = `Customer`
3. Select the desired customer from the values list

> **Note:** If the customer does not appear in the values list, the alias in BackOffice settings has not been configured yet.

---

## Common Use Cases

| Scenario | What to check |
|----------|---------------|
| Customer reports issues | Filter by customer alias, check Transaction Count drop |
| Investigating outage window | Set custom time range, look for drop start time |
| Comparing environments | Open multiple browser tabs, one per environment |
| Checking if issue is customer-specific | Compare affected customer vs. others on same environment |

---

*Domain: Azure Monitor | Application Insights | Custom Metrics | Customer Monitoring*
