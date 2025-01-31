# simple makefile to simplify repetetive build env management tasks under posix
# Ideas borrowed from scikit-learn's and PyMVPA Makefiles  -- thanks!

PYTHON ?= python

MODULE ?= datalad

all: clean test

clean:
	$(PYTHON) setup.py clean
	rm -rf dist build bin docs/build docs/source/generated
	-find . -name '*.pyc' -delete
	-find . -name '__pycache__' -type d -delete

bin:
	mkdir -p $@
	PYTHONPATH=bin:$(PYTHONPATH) python setup.py develop --install-dir $@

trailing-spaces:
	find $(MODULE) -name "*.py" -exec perl -pi -e 's/[ \t]*$$//' {} \;

code-analysis:
	flake8 $(MODULE) | grep -v __init__ | grep -v external
	pylint -E -i y $(MODULE)/ # -d E1103,E0611,E1101

update-changelog:
	@echo ".. This file is auto-converted from CHANGELOG.md (make update-changelog) -- do not edit\n\nChange log\n**********" > docs/source/changelog.rst
	pandoc -t rst CHANGELOG.md >> docs/source/changelog.rst

release-pypi: update-changelog
	# better safe than sorry
	test ! -e dist
	python setup.py sdist
	python setup.py bdist_wheel --universal
	twine upload dist/*
