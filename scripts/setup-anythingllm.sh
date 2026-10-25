#!/bin/bash
# TIVA Founder OS - AnythingLLM Setup & MCP Integration

set -e

REPO="dhanushanchan-hub/tiva-founder-os"
ANYTHINGLLM_URL="${ANYTHINGLLM_URL:-http://localhost:3001}"

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║     ANYTHINGLLM SETUP & MCP INTEGRATION                          ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Check if AnythingLLM is running
echo "▶ Checking AnythingLLM at $ANYTHINGLLM_URL..."
if curl -s -f "$ANYTHINGLLM_URL/api/ping" > /dev/null 2>&1; then
    echo "✅ AnythingLLM is running"
else
    echo "⚠ AnythingLLM not detected at $ANYTHINGLLM_URL"
    echo ""
    echo "📋 To start AnythingLLM:"
    echo "   docker-compose -f docker-compose.anythingllm.yml up -d"
    echo ""
    echo "   Or with PostgreSQL:"
    echo "   docker-compose -f docker-compose.anythingllm.yml --profile postgres up -d"
    echo ""
    echo "   First run will create admin user. Check logs:"
    echo "   docker logs tiva-anythingllm"
    exit 1
fi

# Get API key if not provided
if [ -z "$ANYTHINGLLM_API_KEY" ]; then
    echo ""
    echo "▶ Getting AnythingLLM API Key..."
    echo "   Go to: $ANYTHINGLLM_URL/settings/api-keys"
    echo "   Create a new API key and export it:"
    echo "   export ANYTHINGLLM_API_KEY=your_api_key_here"
    echo ""
    read -p "Enter AnythingLLM API Key: " ANYTHINGLLM_API_KEY
fi

# Set GitHub secret
echo "▶ Setting GitHub Secret..."
gh secret set ANYTHINGLLM_API_KEY --repo $REPO --body "$ANYTHINGLLM_API_KEY"
gh secret set ANYTHINGLLM_URL --repo $REPO --body "$ANYTHINGLLM_URL"
echo "✓ GitHub secrets set"

# Add AnythingLLM MCP Server
echo "▶ Adding AnythingLLM MCP Server..."
claude mcp add anythingllm \
    -e ANYTHINGLLM_API_KEY="$ANYTHINGLLM_API_KEY" \
    -e ANYTHINGLLM_URL="$ANYTHINGLLM_URL" \
    -- npx -y @anything-llm/mcp-server 2>/dev/null \
    && echo "✓ MCP server added (NPX)" \
    || {
        echo "⚠ NPX package not available, trying HTTP transport..."
        claude mcp add anythingllm --transport http "$ANYTHINGLLM_URL/api/mcp" 2>/dev/null \
        && echo "✓ MCP server added (HTTP)" \
        || echo "✗ Failed to add MCP server"
    }

# Create workspace for TIVA
echo "▶ Creating TIVA Workspace in AnythingLLM..."
curl -s -X POST "$ANYTHINGLLM_URL/api/workspace" \
    -H "Authorization: Bearer $ANYTHINGLLM_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "TIVA Founder OS",
        "slug": "tiva-founder-os",
        "description": "Multi-agent AI orchestration platform knowledge base"
    }' | jq . 2>/dev/null || echo "Workspace may already exist"

# Upload key documents
echo "▶ Uploading TIVA documents to AnythingLLM..."
for file in README.md package.json tsconfig.json .codex/config.toml; do
    if [ -f "$file" ]; then
        echo "  Uploading $file..."
        curl -s -X POST "$ANYTHINGLLM_URL/api/document" \
            -H "Authorization: Bearer $ANYTHINGLLM_API_KEY" \
            -F "file=@$file" \
            -F "workspaceSlug=tiva-founder-os" | jq . 2>/dev/null || echo "  Uploaded"
    fi
done

# Upload all markdown files
echo "▶ Uploading all documentation..."
find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" | while read file; do
    echo "  Uploading $file..."
    curl -s -X POST "$ANYTHINGLLM_URL/api/document" \
        -H "Authorization: Bearer $ANYTHINGLLM_API_KEY" \
        -F "file=@$file" \
        -F "workspaceSlug=tiva-founder-os" > /dev/null 2>&1 && echo "  ✓ $file"
done

echo ""
echo "✅ AnythingLLM Setup Complete!"
echo ""
echo "📋 Access AnythingLLM at: $ANYTHINGLLM_URL"
echo "📋 Workspace: TIVA Founder OS"
echo "📋 MCP Server: anythingllm (available in Claude Code)"
echo ""
echo "🔗 Test with: @ai search AnythingLLM for TIVA architecture"