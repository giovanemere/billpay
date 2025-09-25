#!/usr/bin/env python3
"""
MCP Server for BillPay Template Management
Standardizes creation and management of Backstage templates
"""

import json
import os
import yaml
from pathlib import Path
from typing import Dict, List, Any, Optional
from mcp.server import Server
from mcp.types import Tool, TextContent

# Template base path
TEMPLATES_BASE = "/home/giovanemere/periferia/billpay/repositories/templates_backstage"

# Template standards and configurations
TEMPLATE_STANDARDS = {
    "naming_convention": "billpay-{purpose}",
    "required_files": [
        "template.yaml",
        "skeleton/catalog-info.yaml", 
        "skeleton/README.md",
        "skeleton/.github/workflows/deploy.yml"
    ],
    "standard_parameters": ["name", "deployment_type", "environment"],
    "standard_steps": ["fetch", "publish", "register", "trigger-deployment"],
    "branch_config": {
        "ia_ops_iac": "trunk",
        "new_projects": "main",
        "workflow_triggers": ["main", "trunk"]
    }
}

# Template types and their configurations
TEMPLATE_TYPES = {
    "repository-creation": {
        "purpose": "Create new repository with basic deployment",
        "steps": ["fetch", "publish", "register", "trigger-deployment"],
        "creates_repo": True,
        "deployment_target": "deploy-demo.yml"
    },
    "simple-deployment": {
        "purpose": "Simple deployment without EKS (S3, Lambda, etc)",
        "steps": ["fetch", "publish", "register", "trigger-deployment"],
        "creates_repo": True,
        "deployment_target": "deploy-simple.yml"
    },
    "complete-stack": {
        "purpose": "Full multi-cloud deployment with EKS/GKE/AKS",
        "steps": ["trigger-deployment", "register"],
        "creates_repo": False,
        "deployment_target": "deploy-complete.yml"
    }
}

app = Server("billpay-template-manager")

@app.list_tools()
async def list_tools() -> List[Tool]:
    return [
        Tool(
            name="create_template",
            description="Create a new Backstage template following BillPay standards",
            inputSchema={
                "type": "object",
                "properties": {
                    "template_name": {"type": "string", "description": "Template name (without billpay- prefix)"},
                    "template_type": {"type": "string", "enum": list(TEMPLATE_TYPES.keys())},
                    "description": {"type": "string", "description": "Template description"},
                    "cloud_providers": {"type": "array", "items": {"type": "string"}, "default": ["aws"]},
                    "deployment_types": {"type": "array", "items": {"type": "string"}, "default": ["simulation", "real-aws-oidc"]}
                },
                "required": ["template_name", "template_type", "description"]
            }
        ),
        Tool(
            name="validate_template",
            description="Validate existing template against BillPay standards",
            inputSchema={
                "type": "object",
                "properties": {
                    "template_name": {"type": "string", "description": "Template name to validate"}
                },
                "required": ["template_name"]
            }
        ),
        Tool(
            name="fix_template_branches",
            description="Fix branch inconsistencies in template",
            inputSchema={
                "type": "object",
                "properties": {
                    "template_name": {"type": "string", "description": "Template name to fix"}
                },
                "required": ["template_name"]
            }
        ),
        Tool(
            name="rename_template",
            description="Rename template following naming conventions",
            inputSchema={
                "type": "object",
                "properties": {
                    "old_name": {"type": "string", "description": "Current template name"},
                    "new_purpose": {"type": "string", "description": "New purpose for naming"}
                },
                "required": ["old_name", "new_purpose"]
            }
        ),
        Tool(
            name="list_templates",
            description="List all templates with their status and configuration",
            inputSchema={"type": "object", "properties": {}}
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    if name == "create_template":
        return await create_template(arguments)
    elif name == "validate_template":
        return await validate_template(arguments)
    elif name == "fix_template_branches":
        return await fix_template_branches(arguments)
    elif name == "rename_template":
        return await rename_template(arguments)
    elif name == "list_templates":
        return await list_templates(arguments)
    else:
        return [TextContent(type="text", text=f"Unknown tool: {name}")]

async def create_template(args: Dict[str, Any]) -> List[TextContent]:
    """Create a new template following BillPay standards"""
    template_name = f"billpay-{args['template_name']}"
    template_type = args['template_type']
    description = args['description']
    
    if template_type not in TEMPLATE_TYPES:
        return [TextContent(type="text", text=f"❌ Invalid template type. Use: {list(TEMPLATE_TYPES.keys())}")]
    
    template_config = TEMPLATE_TYPES[template_type]
    template_path = Path(TEMPLATES_BASE) / template_name
    
    # Create directory structure
    template_path.mkdir(exist_ok=True)
    (template_path / "skeleton" / ".github" / "workflows").mkdir(parents=True, exist_ok=True)
    
    # Generate template.yaml
    template_yaml = generate_template_yaml(template_name, template_type, description, args)
    with open(template_path / "template.yaml", "w") as f:
        yaml.dump(template_yaml, f, default_flow_style=False, sort_keys=False)
    
    # Generate skeleton files
    generate_skeleton_files(template_path / "skeleton", template_name, template_config, args)
    
    return [TextContent(
        type="text", 
        text=f"✅ Template '{template_name}' created successfully\n"
             f"📁 Path: {template_path}\n"
             f"🎯 Type: {template_type}\n"
             f"📝 Description: {description}\n"
             f"🔧 Steps: {template_config['steps']}"
    )]

async def validate_template(args: Dict[str, Any]) -> List[TextContent]:
    """Validate template against standards"""
    template_name = args['template_name']
    template_path = Path(TEMPLATES_BASE) / template_name
    
    if not template_path.exists():
        return [TextContent(type="text", text=f"❌ Template '{template_name}' not found")]
    
    issues = []
    
    # Check required files
    for required_file in TEMPLATE_STANDARDS["required_files"]:
        file_path = template_path / required_file
        if not file_path.exists():
            issues.append(f"❌ Missing required file: {required_file}")
    
    # Check template.yaml structure
    template_yaml_path = template_path / "template.yaml"
    if template_yaml_path.exists():
        with open(template_yaml_path) as f:
            template_data = yaml.safe_load(f)
            
        # Check naming convention
        if not template_data.get('metadata', {}).get('name', '').startswith('billpay-'):
            issues.append("❌ Template name doesn't follow 'billpay-{purpose}' convention")
            
        # Check branch consistency
        steps = template_data.get('spec', {}).get('steps', [])
        for step in steps:
            if step.get('action') == 'github:actions:dispatch':
                branch = step.get('input', {}).get('branchOrTagName')
                if branch != 'trunk':
                    issues.append(f"❌ Step '{step.get('id')}' uses branch '{branch}', should use 'trunk'")
    
    if not issues:
        return [TextContent(type="text", text=f"✅ Template '{template_name}' is valid")]
    else:
        return [TextContent(type="text", text=f"⚠️ Template '{template_name}' has issues:\n" + "\n".join(issues))]

async def fix_template_branches(args: Dict[str, Any]) -> List[TextContent]:
    """Fix branch inconsistencies"""
    template_name = args['template_name']
    template_path = Path(TEMPLATES_BASE) / template_name
    
    if not template_path.exists():
        return [TextContent(type="text", text=f"❌ Template '{template_name}' not found")]
    
    fixes_applied = []
    
    # Fix template.yaml
    template_yaml_path = template_path / "template.yaml"
    if template_yaml_path.exists():
        with open(template_yaml_path) as f:
            template_data = yaml.safe_load(f)
            
        steps = template_data.get('spec', {}).get('steps', [])
        for step in steps:
            if step.get('action') == 'github:actions:dispatch':
                old_branch = step.get('input', {}).get('branchOrTagName')
                if old_branch != 'trunk':
                    step['input']['branchOrTagName'] = 'trunk'
                    fixes_applied.append(f"Fixed step '{step.get('id')}': {old_branch} → trunk")
        
        with open(template_yaml_path, "w") as f:
            yaml.dump(template_data, f, default_flow_style=False, sort_keys=False)
    
    # Fix workflow files
    workflow_path = template_path / "skeleton" / ".github" / "workflows" / "deploy.yml"
    if workflow_path.exists():
        with open(workflow_path) as f:
            content = f.read()
        
        if "branches: [main]" in content:
            content = content.replace("branches: [main]", "branches: [main, trunk]")
            fixes_applied.append("Fixed workflow: Added trunk to trigger branches")
            
            with open(workflow_path, "w") as f:
                f.write(content)
    
    if fixes_applied:
        return [TextContent(type="text", text=f"✅ Fixed branches in '{template_name}':\n" + "\n".join(fixes_applied))]
    else:
        return [TextContent(type="text", text=f"✅ No branch fixes needed for '{template_name}'")]

async def rename_template(args: Dict[str, Any]) -> List[TextContent]:
    """Rename template following conventions"""
    old_name = args['old_name']
    new_purpose = args['new_purpose']
    new_name = f"billpay-{new_purpose}"
    
    old_path = Path(TEMPLATES_BASE) / old_name
    new_path = Path(TEMPLATES_BASE) / new_name
    
    if not old_path.exists():
        return [TextContent(type="text", text=f"❌ Template '{old_name}' not found")]
    
    if new_path.exists():
        return [TextContent(type="text", text=f"❌ Template '{new_name}' already exists")]
    
    # Rename directory
    old_path.rename(new_path)
    
    # Update template.yaml metadata
    template_yaml_path = new_path / "template.yaml"
    if template_yaml_path.exists():
        with open(template_yaml_path) as f:
            template_data = yaml.safe_load(f)
        
        template_data['metadata']['name'] = new_name
        template_data['metadata']['title'] = f"BillPay {new_purpose.replace('-', ' ').title()}"
        
        with open(template_yaml_path, "w") as f:
            yaml.dump(template_data, f, default_flow_style=False, sort_keys=False)
    
    return [TextContent(type="text", text=f"✅ Template renamed: '{old_name}' → '{new_name}'")]

async def list_templates(args: Dict[str, Any]) -> List[TextContent]:
    """List all templates with status"""
    templates_path = Path(TEMPLATES_BASE)
    templates = []
    
    for template_dir in templates_path.iterdir():
        if template_dir.is_dir() and template_dir.name.startswith('billpay-'):
            template_yaml_path = template_dir / "template.yaml"
            if template_yaml_path.exists():
                with open(template_yaml_path) as f:
                    template_data = yaml.safe_load(f)
                
                templates.append({
                    "name": template_data.get('metadata', {}).get('name', template_dir.name),
                    "title": template_data.get('metadata', {}).get('title', 'No title'),
                    "description": template_data.get('metadata', {}).get('description', 'No description'),
                    "path": str(template_dir),
                    "steps": len(template_data.get('spec', {}).get('steps', []))
                })
    
    if not templates:
        return [TextContent(type="text", text="No BillPay templates found")]
    
    result = "📋 BillPay Templates:\n\n"
    for template in templates:
        result += f"🎭 **{template['name']}**\n"
        result += f"   📝 {template['description']}\n"
        result += f"   🔧 {template['steps']} steps\n"
        result += f"   📁 {template['path']}\n\n"
    
    return [TextContent(type="text", text=result)]

def generate_template_yaml(name: str, template_type: str, description: str, args: Dict[str, Any]) -> Dict[str, Any]:
    """Generate template.yaml structure"""
    config = TEMPLATE_TYPES[template_type]
    
    template = {
        "apiVersion": "scaffolder.backstage.io/v1beta3",
        "kind": "Template",
        "metadata": {
            "name": name,
            "title": f"BillPay {name.replace('billpay-', '').replace('-', ' ').title()}",
            "description": description,
            "tags": ["billpay"] + args.get('cloud_providers', ['aws'])
        },
        "spec": {
            "owner": "platform-team",
            "type": "service",
            "parameters": [
                {
                    "title": "Project Information",
                    "required": ["name", "deployment_type"],
                    "properties": {
                        "name": {
                            "title": "Project Name",
                            "type": "string",
                            "pattern": "^[a-zA-Z0-9-_]+$"
                        },
                        "deployment_type": {
                            "title": "Deployment Type",
                            "type": "string",
                            "default": "simulation",
                            "enum": args.get('deployment_types', ['simulation', 'real-aws-oidc']),
                            "enumNames": ["Simulation (Demo)", "Real AWS Deployment"]
                        }
                    }
                }
            ],
            "steps": generate_steps(config),
            "output": generate_output(config)
        }
    }
    
    return template

def generate_steps(config: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Generate standard steps based on template type"""
    steps = []
    
    if "fetch" in config["steps"]:
        steps.append({
            "id": "fetch",
            "name": "Fetch Template",
            "action": "fetch:template",
            "input": {
                "url": "./skeleton",
                "values": {
                    "name": "${{ parameters.name }}",
                    "deployment_type": "${{ parameters.deployment_type }}"
                }
            }
        })
    
    if "publish" in config["steps"]:
        steps.append({
            "id": "publish",
            "name": "Create GitHub Repository",
            "action": "publish:github",
            "input": {
                "description": "BillPay Project - ${{ parameters.name }}",
                "repoUrl": "github.com?repo=${{ parameters.name }}&owner=giovanemere",
                "defaultBranch": "main"
            }
        })
    
    if "register" in config["steps"]:
        steps.append({
            "id": "register",
            "name": "Register in Catalog",
            "action": "catalog:register",
            "input": {
                "repoContentsUrl": "${{ steps.publish.output.repoContentsUrl }}",
                "catalogInfoPath": "/catalog-info.yaml"
            }
        })
    
    if "trigger-deployment" in config["steps"]:
        steps.append({
            "id": "trigger-deployment",
            "name": "🚀 Deploy to AWS",
            "if": "${{ parameters.deployment_type !== 'simulation' }}",
            "action": "github:actions:dispatch",
            "input": {
                "repoUrl": "github.com?owner=giovanemere&repo=ia-ops-iac",
                "branchOrTagName": "trunk",
                "workflowId": config["deployment_target"],
                "workflowInputs": {
                    "project_name": "${{ parameters.name }}",
                    "environment": "demo",
                    "deployment_type": "${{ parameters.deployment_type }}"
                }
            }
        })
    
    return steps

def generate_output(config: Dict[str, Any]) -> Dict[str, Any]:
    """Generate standard output links"""
    links = []
    
    if config["creates_repo"]:
        links.extend([
            {
                "title": "Repository",
                "url": "${{ steps.publish.output.remoteUrl }}",
                "icon": "github"
            },
            {
                "title": "Open in catalog",
                "icon": "catalog",
                "entityRef": "${{ steps.register.output.entityRef }}"
            },
            {
                "title": "GitHub Actions",
                "url": "${{ steps.publish.output.remoteUrl }}/actions",
                "icon": "deployment"
            }
        ])
    
    links.append({
        "title": "AWS Deployment Monitor",
        "url": "https://github.com/giovanemere/ia-ops-iac/actions",
        "icon": "cloud"
    })
    
    return {"links": links}

def generate_skeleton_files(skeleton_path: Path, template_name: str, config: Dict[str, Any], args: Dict[str, Any]):
    """Generate skeleton files"""
    # catalog-info.yaml
    catalog_info = {
        "apiVersion": "backstage.io/v1alpha1",
        "kind": "Component",
        "metadata": {
            "name": "${{ values.name }}",
            "description": f"BillPay Project - ${{ values.name }}",
            "annotations": {
                "github.com/project-slug": "giovanemere/${{ values.name }}",
                "backstage.io/techdocs-ref": "dir:."
            }
        },
        "spec": {
            "type": "service",
            "lifecycle": "production",
            "owner": "platform-team",
            "system": "billpay-platform"
        }
    }
    
    with open(skeleton_path / "catalog-info.yaml", "w") as f:
        yaml.dump(catalog_info, f, default_flow_style=False)
    
    # README.md
    readme_content = f"""# ${{{{ values.name }}}}

BillPay Project: **${{{{ values.name }}}}**

## 🚀 Deployment Type: ${{{{ values.deployment_type }}}}

## 📊 Monitoring

- **🔄 GitHub Actions**: [View Workflows](https://github.com/giovanemere/${{{{ values.name }}}}/actions)
- **☁️ AWS Deployment**: [Monitor Infrastructure](https://github.com/giovanemere/ia-ops-iac/actions)

## 🏗️ Architecture

This project follows BillPay's enterprise architecture with {config['purpose']}.
"""
    
    with open(skeleton_path / "README.md", "w") as f:
        f.write(readme_content)
    
    # deploy.yml workflow
    workflow_content = f"""name: Deploy
on:
  push:
    branches: [main, trunk]
  workflow_dispatch:
    inputs:
      deployment_type:
        description: 'Deployment Type'
        required: true
        default: '${{{{ values.deployment_type }}}}'
        type: choice
        options:
          - simulation
          - real-aws-oidc

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: 🎭 Simulation Deploy
        if: github.event.inputs.deployment_type == 'simulation' || '${{{{ values.deployment_type }}}}' == 'simulation'
        run: |
          echo "🎭 BillPay Simulation Deployment"
          echo "📦 Project: ${{{{ values.name }}}}"
          echo "✅ Deployment completed successfully!"
          
      - name: 🚀 Real AWS Deployment
        if: github.event.inputs.deployment_type == 'real-aws-oidc' || '${{{{ values.deployment_type }}}}' == 'real-aws-oidc'
        run: |
          echo "🚀 Starting real AWS deployment"
          echo "📦 Project: ${{{{ values.name }}}}"
          echo "🔗 Monitor at: https://github.com/giovanemere/ia-ops-iac/actions"
"""
    
    with open(skeleton_path / ".github" / "workflows" / "deploy.yml", "w") as f:
        f.write(workflow_content)

if __name__ == "__main__":
    import asyncio
    from mcp.server.stdio import stdio_server
    
    async def main():
        async with stdio_server() as (read_stream, write_stream):
            await app.run(read_stream, write_stream, app.create_initialization_options())
    
    asyncio.run(main())
