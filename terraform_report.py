#!/usr/bin/env python3

import os
import re
import sys
import json
from collections import defaultdict

try:
    import hcl2
except ImportError:
    print("Install dependency:")
    print("pip install python-hcl2")
    sys.exit(1)

REFERENCE_PATTERN = re.compile(
    r'((?:aws|azurerm|google|kubernetes|helm|random|tls|local|null)_[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+)'
)

class TerraformAnalyzer:

    def __init__(self):
        self.providers = []
        self.resources = []
        self.variables = []
        self.outputs = []
        self.modules = []
        self.datasources = []
        self.files = []
        self.dependencies = defaultdict(set)

    def scan(self, root_dir):

        for root, _, files in os.walk(root_dir):

            for file in files:

                if not file.endswith((".tf", ".tfvars", ".hcl")):
                    continue

                path = os.path.join(root, file)
                self.files.append(path)

                try:
                    with open(path, "r", encoding="utf-8") as f:
                        data = hcl2.load(f)

                    self.process_file(path, data)

                except Exception as e:
                    print(f"Failed parsing {path}: {e}")

    def process_file(self, path, data):

        if "provider" in data:
            for provider in data["provider"]:
                self.providers.append({
                    "file": path,
                    "config": provider
                })

        if "resource" in data:
            for resource in data["resource"]:
                for resource_type, instances in resource.items():

                    for resource_name, config in instances.items():

                        full_name = f"{resource_type}.{resource_name}"

                        self.resources.append({
                            "file": path,
                            "type": resource_type,
                            "name": resource_name,
                            "config": config
                        })

                        self.extract_dependencies(
                            full_name,
                            json.dumps(config)
                        )

        if "variable" in data:
            for variable in data["variable"]:
                self.variables.append(variable)

        if "output" in data:
            for output in data["output"]:
                self.outputs.append(output)

        if "module" in data:
            for module in data["module"]:
                self.modules.append(module)

        if "data" in data:
            for datasource in data["data"]:
                self.datasources.append(datasource)

    def extract_dependencies(self, resource_name, text):

        matches = REFERENCE_PATTERN.findall(text)

        for match in matches:
            self.dependencies[resource_name].add(match)

    def generate_report(self):

        report = []

        report.append("# Terraform Infrastructure Analysis")
        report.append("")

        report.append("## Overview")
        report.append("")
        report.append(f"Files scanned: {len(self.files)}")
        report.append(f"Providers: {len(self.providers)}")
        report.append(f"Resources: {len(self.resources)}")
        report.append(f"Variables: {len(self.variables)}")
        report.append(f"Outputs: {len(self.outputs)}")
        report.append(f"Modules: {len(self.modules)}")
        report.append(f"Data Sources: {len(self.datasources)}")
        report.append("")

        report.append("## Files")
        report.append("")

        for f in sorted(self.files):
            report.append(f"- {f}")

        report.append("")
        report.append("## Providers")
        report.append("")

        if self.providers:
            for provider in self.providers:
                report.append(f"### {provider['file']}")
                report.append("```json")
                report.append(json.dumps(provider["config"], indent=2))
                report.append("```")
        else:
            report.append("No providers found.")

        report.append("")
        report.append("## Modules")
        report.append("")

        if self.modules:
            for module in self.modules:
                for name, config in module.items():

                    report.append(f"### {name}")
                    report.append("")

                    source = config.get("source", "unknown")
                    report.append(f"Source: `{source}`")
                    report.append("")

                    report.append("Configuration:")
                    report.append("```json")
                    report.append(json.dumps(config, indent=2))
                    report.append("```")
        else:
            report.append("No modules found.")

        report.append("")
        report.append("## Variables")
        report.append("")

        if self.variables:
            for variable in self.variables:

                for name, config in variable.items():

                    report.append(f"### {name}")

                    if isinstance(config, dict):
                        report.append(
                            f"- Type: {config.get('type', 'unknown')}"
                        )
                        report.append(
                            f"- Description: {config.get('description', 'none')}"
                        )

                        if "default" in config:
                            report.append(
                                f"- Default: `{config['default']}`"
                            )

                    report.append("")
        else:
            report.append("No variables found.")

        report.append("")
        report.append("## Resources")
        report.append("")

        resources_by_type = defaultdict(list)

        for resource in self.resources:
            resources_by_type[resource["type"]].append(resource)

        for resource_type in sorted(resources_by_type.keys()):

            report.append(f"### {resource_type}")
            report.append("")

            for resource in resources_by_type[resource_type]:

                full_name = (
                    f"{resource['type']}.{resource['name']}"
                )

                report.append(f"- `{full_name}`")
                report.append(
                    f"  - Defined in: {resource['file']}"
                )

                deps = self.dependencies.get(full_name)

                if deps:
                    report.append(
                        f"  - References: {', '.join(sorted(deps))}"
                    )

            report.append("")

        report.append("")
        report.append("## Outputs")
        report.append("")

        if self.outputs:
            for output in self.outputs:

                for name, config in output.items():

                    report.append(f"### {name}")

                    if isinstance(config, dict):

                        report.append(
                            f"- Description: {config.get('description', 'none')}"
                        )

                        if "value" in config:
                            report.append(
                                f"- Value: `{config['value']}`"
                            )

                    report.append("")
        else:
            report.append("No outputs found.")

        report.append("")
        report.append("## Dependency Graph")
        report.append("")

        if self.dependencies:

            for resource, deps in sorted(
                self.dependencies.items()
            ):
                report.append(f"### {resource}")

                for dep in sorted(deps):
                    report.append(f"- depends on `{dep}`")

                report.append("")
        else:
            report.append("No dependencies detected.")

        report.append("")
        report.append("## Architecture Summary")
        report.append("")

        report.append(
            "This section provides a high-level inventory of "
            "Terraform resources, modules, variables, outputs, "
            "providers, and detected dependencies."
        )

        return "\n".join(report)


def main():

    directory = "."

    if len(sys.argv) > 1:
        directory = sys.argv[1]

    analyzer = TerraformAnalyzer()

    print(f"Scanning: {directory}")
    analyzer.scan(directory)

    report = analyzer.generate_report()

    output_file = "terraform_analysis_report.md"

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(report)

    print(f"\nReport written to: {output_file}")


if __name__ == "__main__":
    main()
