ISORT_MODULES = setup.py src tests

.PHONY: lint
lint:
	pylint setup.py
	pylint src/into_dbus_python
	pylint tests
	bandit setup.py
	# Ignore B101 errors. We do not distribute optimized code, i.e., .pyo
	# files in Fedora, so we do not need to have concerns that assertions
	# are removed by optimization.
	bandit --recursive ./src --skip B101
	bandit --recursive ./tests
	pyright

.PHONY: test
test:
	python3 -m unittest discover --verbose tests

.PHONY: coverage
coverage:
	coverage --version
	coverage run --timid --branch -m unittest discover tests
	coverage report -m --fail-under=100 --show-missing --include="./src/*"

.PHONY: fmt
fmt:
	isort ${ISORT_MODULES}
	black .

.PHONY: fmt-travis
fmt-travis:
	isort --diff --check-only ${ISORT_MODULES}
	black . --check

.PHONY: upload-release
upload-release:
	python setup.py register sdist upload

.PHONY: yamllint
yamllint:
	yamllint --strict .github/workflows/main.yml

.PHONY: package
package:
	(umask 0022; python -m build; python -m twine check --strict ./dist/*)
