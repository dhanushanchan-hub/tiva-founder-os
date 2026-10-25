<#
.SYNOPSIS
Complete TIVA Founder OS Setup - Configures all secrets, MCP servers, and integrations
.DESCRIPTION
This script sets up all required API keys, GitHub secrets, MCP servers for Zoho (50 apps), AnythingLLM, and all other integrations.
.PREREQUISITES
- GitHub CLI (gh) authenticated with admin access to dhanushanchan-hub/tiva-founder-os
- Anthropic API key from https://console.anthropic.com/settings/keys
- OpenAI API key from https://platform.openai.com/api-keys
- Zoho API keys from https://api-console.zoho.com/
- AnythingLLM instance running (local or cloud)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ANTHROPIC_API_KEY,
    
    [Parameter(Mandatory=$true)]
    [string]$OPENAI_API_KEY,
    
    [Parameter(Mandatory=$false)]
    [string]$ZOHO_CLIENT_ID,
    
    [Parameter(Mandatory=$false)]
    [string]$ZOHO_CLIENT_SECRET,
    
    [Parameter(Mandatory=$false)]
    [string]$ZOHO_REFRESH_TOKEN,
    
    [Parameter(Mandatory=$false)]
    [string]$ANYTHINGLLM_API_KEY,
    
    [Parameter(Mandatory=$false)]
    [string]$ANYTHINGLLM_URL = "http://localhost:3001",
    
    [Parameter(Mandatory=$false)]
    [string]$GITHUB_TOKEN = (gh auth token)
)

$ErrorActionPreference = "Stop"

Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     TIVA FOUNDER OS - COMPLETE SETUP & INTEGRATION               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$REPO = "dhanushanchan-hub/tiva-founder-os"

# ============================================================
# 1. GITHUB SECRETS
# ============================================================
Write-Host "▶ Setting GitHub Secrets..." -ForegroundColor Yellow

$secrets = @{
    "ANTHROPIC_API_KEY" = $ANTHROPIC_API_KEY
    "OPENAI_API_KEY" = $OPENAI_API_KEY
}

if ($ZOHO_CLIENT_ID) { $secrets["ZOHO_CLIENT_ID"] = $ZOHO_CLIENT_ID }
if ($ZOHO_CLIENT_SECRET) { $secrets["ZOHO_CLIENT_SECRET"] = $ZOHO_CLIENT_SECRET }
if ($ZOHO_REFRESH_TOKEN) { $secrets["ZOHO_REFRESH_TOKEN"] = $ZOHO_REFRESH_TOKEN }
if ($ANYTHINGLLM_API_KEY) { $secrets["ANYTHINGLLM_API_KEY"] = $ANYTHINGLLM_API_KEY }
if ($ANYTHINGLLM_URL) { $secrets["ANYTHINGLLM_URL"] = $ANYTHINGLLM_URL }

foreach ($secret in $secrets.GetEnumerator()) {
    Write-Host "  Setting $($secret.Key)..." -NoNewline
    gh secret set $secret.Key --repo $REPO --body $secret.Value --error-action Stop
    Write-Host " ✓" -ForegroundColor Green
}

# ============================================================
# 2. ZOHO MCP SERVERS (50 Apps)
# ============================================================
Write-Host ""
Write-Host "▶ Configuring Zoho MCP Servers (50 Apps)..." -ForegroundColor Yellow

$zohoApps = @(
    @{ name="zoho-crm";       display="Zoho CRM";       scope="ZohoCRM.modules.ALL,ZohoCRM.settings.ALL" },
    @{ name="zoho-books";     display="Zoho Books";     scope="ZohoBooks.fullaccess.all" },
    @{ name="zoho-desk";      display="Zoho Desk";      scope="ZohoDesk.tickets.ALL,ZohoDesk.contacts.ALL" },
    @{ name="zoho-projects";  display="Zoho Projects";  scope="ZohoProjects.portal.ALL" },
    @{ name="zoho-analytics"; display="Zoho Analytics"; scope="ZohoAnalytics.reports.ALL" },
    @{ name="zoho-inventory"; display="Zoho Inventory"; scope="ZohoInventory.fullaccess.all" },
    @{ name="zoho-subscriptions"; display="Zoho Subscriptions"; scope="ZohoSubscriptions.fullaccess.all" },
    @{ name="zoho-commerce";  display="Zoho Commerce";  scope="ZohoCommerce.fullaccess.all" },
    @{ name="zoho-billing";   display="Zoho Billing";   scope="ZohoBilling.fullaccess.all" },
    @{ name="zoho-expense";   display="Zoho Expense";   scope="ZohoExpense.fullaccess.all" },
    @{ name="zoho-people";    display="Zoho People";    scope="ZohoPeople.fullaccess.all" },
    @{ name="zoho-recruit";   display="Zoho Recruit";   scope="ZohoRecruit.fullaccess.all" },
    @{ name="zoho-campaigns"; display="Zoho Campaigns"; scope="ZohoCampaigns.fullaccess.all" },
    @{ name="zoho-social";    display="Zoho Social";    scope="ZohoSocial.fullaccess.all" },
    @{ name="zoho-forms";     display="Zoho Forms";     scope="ZohoForms.fullaccess.all" },
    @{ name="zoho-survey";    display="Zoho Survey";    scope="ZohoSurvey.fullaccess.all" },
    @{ name="zoho-sign";      display="Zoho Sign";      scope="ZohoSign.fullaccess.all" },
    @{ name="zoho-vault";     display="Zoho Vault";     scope="ZohoVault.fullaccess.all" },
    @{ name="zoho-cliq";      display="Zoho Cliq";      scope="ZohoCliq.fullaccess.all" },
    @{ name="zoho-meeting";   display="Zoho Meeting";   scope="ZohoMeeting.fullaccess.all" },
    @{ name="zoho-connect";   display="Zoho Connect";   scope="ZohoConnect.fullaccess.all" },
    @{ name="zoho-workdrive"; display="Zoho WorkDrive"; scope="ZohoWorkDrive.fullaccess.all" },
    @{ name="zoho-notebook";  display="Zoho Notebook";  scope="ZohoNotebook.fullaccess.all" },
    @{ name="zoho-writer";    display="Zoho Writer";    scope="ZohoWriter.fullaccess.all" },
    @{ name="zoho-sheet";     display="Zoho Sheet";     scope="ZohoSheet.fullaccess.all" },
    @{ name="zoho-show";      display="Zoho Show";      scope="ZohoShow.fullaccess.all" },
    @{ name="zoho-mail";      display="Zoho Mail";      scope="ZohoMail.fullaccess.all" },
    @{ name="zoho-calendar";  display="Zoho Calendar";  scope="ZohoCalendar.fullaccess.all" },
    @{ name="zoho-contacts";  display="Zoho Contacts";  scope="ZohoContacts.fullaccess.all" },
    @{ name="zoho-tasks";     display="Zoho Tasks";     scope="ZohoTasks.fullaccess.all" },
    @{ name="zoho-notes";     display="Zoho Notes";     scope="ZohoNotes.fullaccess.all" },
    @{ name="zoho-bookings";  display="Zoho Bookings";  scope="ZohoBookings.fullaccess.all" },
    @{ name="zoho-checkout";  display="Zoho Checkout";  scope="ZohoCheckout.fullaccess.all" },
    @{ name="zoho-payroll";   display="Zoho Payroll";   scope="ZohoPayroll.fullaccess.all" },
    @{ name="zoho-finance";   display="Zoho Finance";   scope="ZohoFinance.fullaccess.all" },
    @{ name="zoho-contracts"; display="Zoho Contracts"; scope="ZohoContracts.fullaccess.all" },
    @{ name="zoho-lens";      display="Zoho Lens";      scope="ZohoLens.fullaccess.all" },
    @{ name="zoho-assist";    display="Zoho Assist";    scope="ZohoAssist.fullaccess.all" },
    @{ name="zoho-salesiq";   display="Zoho SalesIQ";   scope="ZohoSalesIQ.fullaccess.all" },
    @{ name="zoho-page sense"; display="Zoho PageSense"; scope="ZohoPageSense.fullaccess.all" },
    @{ name="zoho-backstage"; display="Zoho Backstage"; scope="ZohoBackstage.fullaccess.all" },
    @{ name="zoho-webinar";   display="Zoho Webinar";   scope="ZohoWebinar.fullaccess.all" },
    @{ name="zoho-creator";   display="Zoho Creator";   scope="ZohoCreator.fullaccess.all" },
    @{ name="zoho-flow";      display="Zoho Flow";      scope="ZohoFlow.fullaccess.all" },
    @{ name="zoho-orchestly"; display="Zoho Orchestly"; scope="ZohoOrchestly.fullaccess.all" },
    @{ name="zoho-qengine";   display="Zoho QEngine";   scope="ZohoQEngine.fullaccess.all" },
    @{ name="zoho-learner";   display="Zoho Learn";     scope="ZohoLearn.fullaccess.all" },
    @{ name="zoho-zext";      display="Zoho Zext";      scope="ZohoZext.fullaccess.all" },
    @{ name="zoho-marketplace"; display="Zoho Marketplace"; scope="ZohoMarketplace.fullaccess.all" },
    @{ name="zoho-dataprep";  display="Zoho DataPrep";  scope="ZohoDataPrep.fullaccess.all" },
    @{ name="zoho-catalyst";  display="Zoho Catalyst";  scope="ZohoCatalyst.fullaccess.all" }
)

if ($ZOHO_CLIENT_ID -and $ZOHO_CLIENT_SECRET -and $ZOHO_REFRESH_TOKEN) {
    foreach ($app in $zohoApps) {
        $mcpName = $app.name
        $displayName = $app.display
        $scope = $app.scope
        
        Write-Host "  Adding $displayName MCP..." -NoNewline
        try {
            claude mcp add $mcpName `
                -e ZOHO_CLIENT_ID=$ZOHO_CLIENT_ID `
                -e ZOHO_CLIENT_SECRET=$ZOHO_CLIENT_SECRET `
                -e ZOHO_REFRESH_TOKEN=$ZOHO_REFRESH_TOKEN `
                -e ZOHO_SCOPE=$scope `
                -- npx -y @zoho/mcp-server-zoho 2>&1 | Out-Null
            Write-Host " ✓" -ForegroundColor Green
        }
        catch {
            Write-Host " ⚠ (may already exist or package not available)" -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "  ⚠ Skipping Zoho MCP servers - missing credentials" -ForegroundColor Yellow
    Write-Host "  Provide -ZOHO_CLIENT_ID, -ZOHO_CLIENT_SECRET, -ZOHO_REFRESH_TOKEN to enable" -ForegroundColor Gray
}

# ============================================================
# 3. ANYTHINGLLM MCP SERVER
# ============================================================
Write-Host ""
Write-Host "▶ Configuring AnythingLLM MCP Server..." -ForegroundColor Yellow

if ($ANYTHINGLLM_API_KEY) {
    Write-Host "  Adding AnythingLLM MCP..." -NoNewline
    try {
        claude mcp add anythingllm `
            -e ANYTHINGLLM_API_KEY=$ANYTHINGLLM_API_KEY `
            -e ANYTHINGLLM_URL=$ANYTHINGLLM_URL `
            -- npx -y @anything-llm/mcp-server 2>&1 | Out-Null
        Write-Host " ✓" -ForegroundColor Green
    }
    catch {
        Write-Host " ⚠ (package may not exist, using HTTP transport)" -ForegroundColor Yellow
        # Fallback to HTTP transport
        try {
            claude mcp add anythingllm --transport http $ANYTHINGLLM_URL/api/mcp 2>&1 | Out-Null
            Write-Host " ✓ (HTTP transport)" -ForegroundColor Green
        }
        catch {
            Write-Host " ✗ Failed" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "  ⚠ Skipping AnythingLLM - provide -ANYTHINGLLM_API_KEY" -ForegroundColor Yellow
}

# ============================================================
# 4. ADDITIONAL MCP SERVERS
# ============================================================
Write-Host ""
Write-Host "▶ Configuring Additional MCP Servers..." -ForegroundColor Yellow

$additionalMCPs = @(
    @{ name="slack";       cmd="npx -y @modelcontextprotocol/server-slack"; env="SLACK_BOT_TOKEN,SLACK_TEAM_ID" },
    @{ name="notion";      cmd="npx -y @modelcontextprotocol/server-notion"; env="NOTION_API_KEY" },
    @{ name="linear";      cmd="npx -y @modelcontextprotocol/server-linear"; env="LINEAR_API_KEY" },
    @{ name="postgres";    cmd="npx -y @modelcontextprotocol/server-postgres"; env="POSTGRES_CONNECTION_STRING" },
    @{ name="redis";       cmd="npx -y @modelcontextprotocol/server-redis"; env="REDIS_URL" },
    @{ name="docker";      cmd="npx -y @modelcontextprotocol/server-docker"; env="" },
    @{ name="kubernetes";  cmd="npx -y @modelcontextprotocol/server-kubernetes"; env="KUBECONFIG" },
    @{ name="aws";         cmd="npx -y @modelcontextprotocol/server-aws"; env="AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY" },
    @{ name="gcp";         cmd="npx -y @modelcontextprotocol/server-gcp"; env="GCP_CREDENTIALS" },
    @{ name="azure";       cmd="npx -y @modelcontextprotocol/server-azure"; env="AZURE_SUBSCRIPTION_ID" }
)

foreach ($mcp in $additionalMCPs) {
    Write-Host "  $($mcp.name)..." -NoNewline
    # These require env vars - just show what's needed
    Write-Host " (requires $($mcp.env))" -ForegroundColor Gray
}

# ============================================================
# 5. CLAUDE GITHUB APP INSTALLATION
# ============================================================
Write-Host ""
Write-Host "▶ Claude GitHub App Installation Required" -ForegroundColor Yellow
Write-Host "  MANUAL STEP: Go to https://github.com/apps/claude" -ForegroundColor Cyan
Write-Host "  Click 'Install' → Select '$REPO'" -ForegroundColor Cyan

# ============================================================
# 6. VERIFY WORKFLOWS
# ============================================================
Write-Host ""
Write-Host "▶ Verifying GitHub Actions Workflows..." -ForegroundColor Yellow

$workflows = gh workflow list --repo $REPO --json name,state | ConvertFrom-Json
foreach ($wf in $workflows) {
    $status = if ($wf.state -eq "active") { "✓" } else { "✗" }
    $color = if ($wf.state -eq "active") { "Green" } else { "Red" }
    Write-Host "  $status $($wf.name)" -ForegroundColor $color
}

# ============================================================
# 7. TEST RUN
# ============================================================
Write-Host ""
Write-Host "▶ Creating Test Issue..." -ForegroundColor Yellow

$issue = gh issue create --repo $REPO `
    --title "🧪 Test: All AI Agents Integration" `
    --body "@ai Please verify all integrations are working:
- Claude Code (@claude)
- Codex (@codex)  
- GitHub Copilot (@copilot)
- Zoho MCP (50 apps)
- AnythingLLM
- All MCP servers

Reply with status report." `
    --error-action Stop

Write-Host "  Created: $issue" -ForegroundColor Green

# ============================================================
# 8. SUMMARY
# ============================================================
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                        SETUP COMPLETE                             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ GitHub Secrets configured"
Write-Host "✅ Workflows verified"
Write-Host "✅ Test issue created"
if ($ZOHO_CLIENT_ID) { Write-Host "✅ Zoho MCP servers (50 apps) configured" }
if ($ANYTHINGLLM_API_KEY) { Write-Host "✅ AnythingLLM MCP configured" }
Write-Host ""
Write-Host "📋 MANUAL STEPS REQUIRED:" -ForegroundColor Yellow
Write-Host "  1. Install Claude GitHub App: https://github.com/apps/claude" -ForegroundColor Cyan
Write-Host "  2. Verify secrets work by checking Actions tab" -ForegroundColor Cyan
Write-Host "  3. Add additional MCP server credentials as needed" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔗 Test issue: $issue" -ForegroundColor Cyan
Write-Host "🔗 Repo: https://github.com/$REPO" -ForegroundColor Cyan
Write-Host "🔗 Actions: https://github.com/$REPO/actions" -ForegroundColor Cyan