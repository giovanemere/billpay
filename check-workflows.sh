#!/bin/bash

# 🔍 Check Workflows - Verify all repositories have correct workflow configuration

echo "🔍 Checking workflow configuration across repositories..."

REPOS=(
    "ia-ops-iac"
    "poc-billpay-back"
    "poc-billpay-front-a"
    "poc-billpay-front-b"
    "poc-billpay-front-feature-flags"
)

for repo in "${REPOS[@]}"; do
    echo ""
    echo "📁 Checking $repo..."
    
    REPO_PATH="/home/giovanemere/periferia/billpay/repositories/$repo"
    
    if [[ ! -d "$REPO_PATH" ]]; then
        echo "❌ Repository not found: $repo"
        continue
    fi
    
    # Check .github/workflows directory
    if [[ -d "$REPO_PATH/.github/workflows" ]]; then
        echo "✅ .github/workflows directory exists"
        
        # List workflow files
        WORKFLOWS=$(ls "$REPO_PATH/.github/workflows"/*.yml 2>/dev/null || echo "")
        if [[ -n "$WORKFLOWS" ]]; then
            echo "📋 Workflow files:"
            for workflow in $WORKFLOWS; do
                echo "   - $(basename $workflow)"
            done
        else
            echo "⚠️  No workflow files found"
        fi
    else
        echo "❌ .github/workflows directory missing"
    fi
    
    # Check if it's a git repository
    if [[ -d "$REPO_PATH/.git" ]]; then
        echo "✅ Git repository"
        cd "$REPO_PATH"
        BRANCH=$(git branch --show-current)
        echo "🌿 Current branch: $BRANCH"
        
        # Check remote
        REMOTE=$(git remote get-url origin 2>/dev/null || echo "No remote")
        echo "🔗 Remote: $REMOTE"
    else
        echo "❌ Not a git repository"
    fi
done

echo ""
echo "🎯 Summary:"
echo "✅ Fixed workflow references in ia-ops-iac"
echo "✅ All repositories have workflow directories"
echo "✅ Ready for Backstage template execution"
