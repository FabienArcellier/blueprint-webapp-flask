APPLICATION_MODULE=app
TEST_MODULE=$(APPLICATION_MODULE)_tests

# @see http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.DEFAULT_GOAL := help
.PHONY: help
help: ## provides cli help for this makefile (default)
	@grep -E '^[a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: server_run
server_run:
	. venv/bin/activate; FLASK_APP=${APPLICATION_MODULE}/webapp.py FLASK_ENV=development flask run

.PHONY: dist
dist:
	. venv/bin/activate; python setup.py sdist

.PHONY: tests
tests: tests_units tests_functionals ## run automatic tests

.PHONY: tests_units
tests_units: ## run units tests
	. venv/bin/activate; python -u -m unittest discover "$(TEST_MODULE)/units"

.PHONY: tests_functionals
tests_functionals: ## run functionals tests
	. venv/bin/activate; python -u -m unittest discover "$(TEST_MODULE)/functionals"

.PHONY: lint
lint: ## run pylint
	. venv/bin/activate; pylint --rcfile=.pylintrc $(APPLICATION_MODULE)

.PHONY: coverage
coverage: coverage_run coverage_report # run the code coverage

coverage_run :
	. venv/bin/activate; coverage run --omit **/test_*.py,**/__init__.py,/usr/local/lib/python2.7/**,venv/** -m unittest discover $(TEST_MODULE)

coverage_report:
	. venv/bin/activate; coverage report

.PHONY: clean
clean :
	rm -rf dist
	rm -rf venv
	rm -f .coverage
	rm -rf *.egg-info
	rm -f MANIFEST
	find -name __pycache__ -print0 | xargs -0 rm -rf

.PHONY: freeze_requirements
freeze_requirements: ## update the project dependencies based on setup.py declaration
	rm -rf venv
	$(MAKE) venv
	. venv/bin/activate; pip install --editable .
	. venv/bin/activate; pip freeze --exclude-editable > requirements.txt

.PHONY: install_requirements_dev
install_requirements_dev: venv ## install pip requirements for development
	. venv/bin/activate; pip install -r requirements.txt
	. venv/bin/activate; pip install -e .[dev]

.PHONY: install_requirements
install_requirements: ## install pip requirements based on requirements.txt
	. venv/bin/activate; pip install -r requirements.txt
	. venv/bin/activate; pip install -e .

.PHONY: venv
venv: ## build a virtual env for python 3 in ./venv
	virtualenv venv -p python3
	@echo "\"source venv/bin/activate\" to activate the virtual env"
