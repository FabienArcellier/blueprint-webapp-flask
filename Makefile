APPLICATION_MODULE=app
TEST_MODULE=$(APPLICATION_MODULE)_tests

.PHONY: activate
activate: _init_venv ## activate the virtualenv associate with this project
	pipenv shell

# @see http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.DEFAULT_GOAL := help
.PHONY: help
help: ## provides cli help for this makefile (default)
	@grep -E '^[a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: ci
ci : lint tests ## run continuous integration process

.PHONY: coverage
coverage: coverage_run coverage_html ## output the code coverage in htmlcov/index.html

coverage_run: _init_venv
	pipenv run coverage run -m unittest discover $(TEST_MODULE)

coverage_html: _init_venv
	pipenv run coverage html
	@echo "$ browse htmlcov/index.html"

.PHONY: dist
dist: _init_venv
	pipenv run python setup.py sdist

.PHONY: freeze_requirements
freeze_requirements: _init_venv ## update the project dependencies based on setup.py declaration
	pipenv update

.PHONY: install_requirements_dev
install_requirements_dev: _init_venv ## install pip requirements for development
	pipenv install --dev

.PHONY: install_requirements
install_requirements: _init_venv ## install pip requirements based on requirements.txt
	pipenv install

.PHONY: lint
lint: _init_venv ## run pylint
	pipenv run pylint --rcfile=.pylintrc $(APPLICATION_MODULE)

.PHONY: start
start: ## run the webserver for development
	pipenv run start

.PHONY: prod
prod: ## run the webserver for production
	pipenv run prod

.PHONY: tests
tests: _init_venv tests_units tests_acceptances ## run automatic tests

.PHONY: tests_units
tests_units: ## run only unit tests
	pipenv run python -u -m unittest discover "$(TEST_MODULE)/units"

.PHONY: tests_acceptances
tests_acceptances: ## run only acceptance tests
	pipenv run python -u -m unittest discover "$(TEST_MODULE)/acceptances"

# If a directory .venv is present in the project folder,
# pipenv will use this directory to instanciate a virtualenv
# instead of doing it in your localdata.
#
# Doing it make easier the sharing of debug configuration between
# IDE like vscode or pycharm.
#
# The issue is pipenv --rm will remove all the .venv directory and .gitkeep file.
# this instruction ensure the directory is present even if the virtual environment
# has been remove.
.PHONY: _init_venv
_init_venv:
	mkdir -p .venv && touch .venv/.gitkeep
