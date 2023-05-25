#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
NAME=terranetes-workflows
PWD=$(shell pwd)
UID=$(shell id -u)

.PHONY: test clean docs verify-docs verify-security verify-terraform verify-format

test: act
	@echo "--> Testing the module"
	@$(MAKE) verify-linting
	@$(MAKE) verify-module
	@$(MAKE) verify-format
	@$(MAKE) verify-security

docs:
	@echo "--> Generating the documentation"
	@docker run --rm -t \
		-u ${UID} \
		-v ${PWD}:/workspace \
		-w /workspace \
		quay.io/terraform-docs/terraform-docs:0.16.0 \
		markdown table --output-file README.md --output-mode inject .

format:
	@echo "--> Formatting terraform module"
	@terraform fmt

verify-linting:
	@echo "--> Verifying code linting"
	@act -j code-linting

verify-security:
	@echo "--> Verifying against security policies"
	@act -s GITHUB_TOKEN=${GITHUB_TOKEN} -j code-security

verify-docs:
	@echo "--> Generating documentation"
	@act -j code-docs pull_request

verify-module:
	@echo "--> Validating terraform module"
	@act -j code-validate

verify-format:
	@echo "--> Formatting terraform module"
	@act -j code-format

act:
	@act --version >/dev/null 2>&1 || (echo "ERROR: act is required. (https://github.com/nektos/act)"; exit 1)
	@act -g

controller-kind:
	@echo "--> Creating Kubernetes Cluster"
	@kind --version >/dev/null 2>&1 || (echo "ERROR: kind is required."; exit 1)
	@helm version >/dev/null 2>&1 || (echo "ERROR: helm is required."; exit 1)
	@kubectl version --client >/dev/null 2>&1 || (echo "ERROR: kubectl is required."; exit 1)
	@kind create cluster || true
	@echo "--> Adding Terranetes Helm Repository"
	@helm repo add appvia https://terranetes-controller.appvia.io
	@echo "--> Deploying Terranetes Controller"
	@helm upgrade -n terraform-system terranetes-controller appvia/terranetes-controller --install --create-namespace
	@echo "--> Terranetes Controller is available, please configure credentials"
	@echo "--> Documentation: https://terranetes.appvia.io/terranetes-controller/category/administration/"
	@kubectl -n terraform-system get deployment
