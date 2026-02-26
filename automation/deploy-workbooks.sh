#!/bin/bash
# =============================================================================
#  deploy-workbooks.sh
#  Deploys Logs Drill Down workbook for all systems defined in systems.csv
#
#  Použitie:
#    chmod +x deploy-workbooks.sh
#    ./deploy-workbooks.sh
#
#  Prerekvizity:
#    - Azure CLI nainštalované a prihlásené: az login
#    - Súbory workbook-template.json a systems.csv v rovnakom adresári
# =============================================================================

set -euo pipefail

TEMPLATE_FILE="workbook-template.json"
SYSTEMS_FILE="systems.csv"
LOG_FILE="deploy-workbooks.log"
SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"

# Output colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo " Azure Workbook Deployment"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="
echo ""

# Check prerequisites
if ! command -v az &> /dev/null; then
    echo -e "${RED}ERROR: Azure CLI is not installed.${NC}"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}ERROR: $TEMPLATE_FILE does not exist.${NC}"
    exit 1
fi

if [ ! -f "$SYSTEMS_FILE" ]; then
    echo -e "${RED}ERROR: $SYSTEMS_FILE does not exist.${NC}"
    exit 1
fi

# Set subscription
echo "Setting subscription: $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"
echo ""

# Initialize log
echo "Deployment started: $(date)" > "$LOG_FILE"

SUCCESS=0
FAILED=0
SKIPPED=0

# Skip CSV header row
tail -n +2 "$SYSTEMS_FILE" | while IFS=',' read -r systemName resourceGroup appInsightsId; do

    # Skip empty rows
    if [ -z "$systemName" ] || [ -z "$appInsightsId" ]; then
        continue
    fi

    DISPLAY_NAME="${systemName} - LOGS Drill Down"

    echo -e "${YELLOW}[${systemName}]${NC} Deploying workbook..."
    echo "  Resource Group : $resourceGroup"
    echo "  App Insights   : $appInsightsId"
    echo "  Display Name   : $DISPLAY_NAME"

    # Run deployment
    RESULT=$(az deployment group create \
        --resource-group "$resourceGroup" \
        --template-file "$TEMPLATE_FILE" \
        --parameters \
            workbookDisplayName="$DISPLAY_NAME" \
            workbookSourceId="$appInsightsId" \
        --query "properties.provisioningState" \
        --output tsv 2>&1)

    if echo "$RESULT" | grep -q "Succeeded"; then
        echo -e "  ${GREEN}✓ OK${NC}"
        echo "OK: $systemName" >> "$LOG_FILE"
        ((SUCCESS++)) || true
    else
        echo -e "  ${RED}✗ CHYBA${NC}"
        echo "  Detail: $RESULT"
        echo "FAILED: $systemName | $RESULT" >> "$LOG_FILE"
        ((FAILED++)) || true
    fi

    echo ""

done

echo "=============================================="
echo " Deployment completed: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Succeeded : $SUCCESS"
echo " Failed  : $FAILED"
echo " Log      : $LOG_FILE"
echo "=============================================="

if [ "$FAILED" -gt 0 ]; then
    echo ""
    echo -e "${RED}Some systems failed. Check $LOG_FILE for details.${NC}"
    exit 1
fi
