#!/bin/bash
# TIVA Founder OS - Zoho 50 Apps MCP Setup
# Run this after getting Zoho OAuth credentials from https://api-console.zoho.com/

set -e

REPO="dhanushanchan-hub/tiva-founder-os"

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║     ZOHO 50 APPS MCP CONFIGURATION                               ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Check for required env vars
if [ -z "$ZOHO_CLIENT_ID" ] || [ -z "$ZOHO_CLIENT_SECRET" ] || [ -z "$ZOHO_REFRESH_TOKEN" ]; then
    echo "❌ Missing required environment variables:"
    echo "   export ZOHO_CLIENT_ID=your_client_id"
    echo "   export ZOHO_CLIENT_SECRET=your_client_secret"
    echo "   export ZOHO_REFRESH_TOKEN=your_refresh_token"
    echo ""
    echo "Get these from: https://api-console.zoho.com/"
    echo "1. Create a Self Client"
    echo "2. Generate refresh token with all scopes needed"
    exit 1
fi

# Set GitHub secrets
echo "▶ Setting GitHub Secrets..."
gh secret set ZOHO_CLIENT_ID --repo $REPO --body "$ZOHO_CLIENT_ID"
gh secret set ZOHO_CLIENT_SECRET --repo $REPO --body "$ZOHO_CLIENT_SECRET"
gh secret set ZOHO_REFRESH_TOKEN --repo $REPO --body "$ZOHO_REFRESH_TOKEN"
echo "✓ GitHub secrets set"

# Zoho Apps with their OAuth scopes
declare -A ZOHO_APPS=(
    ["zoho-crm"]="ZohoCRM.modules.ALL,ZohoCRM.settings.ALL"
    ["zoho-books"]="ZohoBooks.fullaccess.all"
    ["zoho-desk"]="ZohoDesk.tickets.ALL,ZohoDesk.contacts.ALL"
    ["zoho-projects"]="ZohoProjects.portal.ALL"
    ["zoho-analytics"]="ZohoAnalytics.reports.ALL"
    ["zoho-inventory"]="ZohoInventory.fullaccess.all"
    ["zoho-subscriptions"]="ZohoSubscriptions.fullaccess.all"
    ["zoho-commerce"]="ZohoCommerce.fullaccess.all"
    ["zoho-billing"]="ZohoBilling.fullaccess.all"
    ["zoho-expense"]="ZohoExpense.fullaccess.all"
    ["zoho-people"]="ZohoPeople.fullaccess.all"
    ["zoho-recruit"]="ZohoRecruit.fullaccess.all"
    ["zoho-campaigns"]="ZohoCampaigns.fullaccess.all"
    ["zoho-social"]="ZohoSocial.fullaccess.all"
    ["zoho-forms"]="ZohoForms.fullaccess.all"
    ["zoho-survey"]="ZohoSurvey.fullaccess.all"
    ["zoho-sign"]="ZohoSign.fullaccess.all"
    ["zoho-vault"]="ZohoVault.fullaccess.all"
    ["zoho-cliq"]="ZohoCliq.fullaccess.all"
    ["zoho-meeting"]="ZohoMeeting.fullaccess.all"
    ["zoho-connect"]="ZohoConnect.fullaccess.all"
    ["zoho-workdrive"]="ZohoWorkDrive.fullaccess.all"
    ["zoho-notebook"]="ZohoNotebook.fullaccess.all"
    ["zoho-writer"]="ZohoWriter.fullaccess.all"
    ["zoho-sheet"]="ZohoSheet.fullaccess.all"
    ["zoho-show"]="ZohoShow.fullaccess.all"
    ["zoho-mail"]="ZohoMail.fullaccess.all"
    ["zoho-calendar"]="ZohoCalendar.fullaccess.all"
    ["zoho-contacts"]="ZohoContacts.fullaccess.all"
    ["zoho-tasks"]="ZohoTasks.fullaccess.all"
    ["zoho-notes"]="ZohoNotes.fullaccess.all"
    ["zoho-bookings"]="ZohoBookings.fullaccess.all"
    ["zoho-checkout"]="ZohoCheckout.fullaccess.all"
    ["zoho-payroll"]="ZohoPayroll.fullaccess.all"
    ["zoho-finance"]="ZohoFinance.fullaccess.all"
    ["zoho-contracts"]="ZohoContracts.fullaccess.all"
    ["zoho-lens"]="ZohoLens.fullaccess.all"
    ["zoho-assist"]="ZohoAssist.fullaccess.all"
    ["zoho-salesiq"]="ZohoSalesIQ.fullaccess.all"
    ["zoho-pagesense"]="ZohoPageSense.fullaccess.all"
    ["zoho-backstage"]="ZohoBackstage.fullaccess.all"
    ["zoho-webinar"]="ZohoWebinar.fullaccess.all"
    ["zoho-creator"]="ZohoCreator.fullaccess.all"
    ["zoho-flow"]="ZohoFlow.fullaccess.all"
    ["zoho-orchestly"]="ZohoOrchestly.fullaccess.all"
    ["zoho-qengine"]="ZohoQEngine.fullaccess.all"
    ["zoho-learner"]="ZohoLearn.fullaccess.all"
    ["zoho-zext"]="ZohoZext.fullaccess.all"
    ["zoho-marketplace"]="ZohoMarketplace.fullaccess.all"
    ["zoho-dataprep"]="ZohoDataPrep.fullaccess.all"
    ["zoho-catalyst"]="ZohoCatalyst.fullaccess.all"
)

echo ""
echo "▶ Adding 50 Zoho MCP Servers..."
for app in "${!ZOHO_APPS[@]}"; do
    scope="${ZOHO_APPS[$app]}"
    echo -n "  Adding $app... "
    claude mcp add "$app" \
        -e ZOHO_CLIENT_ID="$ZOHO_CLIENT_ID" \
        -e ZOHO_CLIENT_SECRET="$ZOHO_CLIENT_SECRET" \
        -e ZOHO_REFRESH_TOKEN="$ZOHO_REFRESH_TOKEN" \
        -e ZOHO_SCOPE="$scope" \
        -- npx -y @zoho/mcp-server-zoho 2>/dev/null \
        && echo "✓" || echo "⚠ (may already exist)"
done

echo ""
echo "✅ Zoho 50 Apps MCP Configuration Complete!"
echo ""
echo "📋 Verify with: claude mcp list | grep zoho"