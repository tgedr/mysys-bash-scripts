#!/usr/bin/env bash

if [ -z "$this_folder" ]; then
  this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
  fi
fi

. "$this_folder/common.inc"

usage()
{
        cat <<EOM
        usage:
        $(basename $0) <PROJECT_NAME>
            creates a python 3 proj
EOM
        exit 1
}

[ -z "$1" ] && { usage; }

PROJECT_NAME="$1"
shift

python3 -V
if [ ! "$?" -eq "0" ] ; then err "please install python 3.*" && exit 1; fi

_pwd=$(pwd)

if [ ! -d "$PROJECT_NAME" ]; then
  mkdir "$PROJECT_NAME"
fi

cd "$PROJECT_NAME"

mkdir src
mkdir test

if [ ! -f ".gitignore" ]; then
cat > .gitignore <<____HERE
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
*.manifest
*.spec
pip-log.txt
pip-delete-this-directory.txt
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/
*.mo
*.pot
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
instance/
.webassets-cache
.scrapy
docs/_build/
.pybuilder/
target/
.ipynb_checkpoints
profile_default/
ipython_config.py
__pypackages__/
celerybeat-schedule
celerybeat.pid
*.sage.py
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.spyderproject
.spyproject
.ropeproject
/site
.mypy_cache/
.dmypy.json
dmypy.json
.pyre/
.pytype/
cython_debug/
.idea/
.secrets
test-results.xml
____HERE
fi

if [ ! -f "LICENSE" ]; then
cat > LICENSE <<____HERE
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
____HERE
fi

cat > pyproject.toml <<____HERE
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[tool.black]
line-length = 120

[tool.pytest.ini_options]
log_cli = true
log_cli_level = "INFO"
log_cli_format = "%(asctime)s [%(levelname)8s] %(message)s (%(filename)s:%(lineno)s)"
log_cli_date_format = "%Y-%m-%d %H:%M:%S"
____HERE

cat > requirements.txt <<____HERE
pytest
____HERE

cat > setup.cfg <<____HERE
[metadata]
name = $PROJECT_NAME
version = 0.0.0
author = ...
author_email = ...
url = ...
description = This package provides ...
long_description = file: README.md
long_description_content_type = text/markdown
license = Unlicense
license_files = LICENSE
classifiers =
    Programming Language :: Python :: 3
    Programming Language :: Python :: 3.7

[options]
include_package_data = True
package_dir =
    =src
packages=find_namespace:
install_requires =
    pytest
[options.packages.find]
where=src
____HERE

cat > MANIFEST.in <<____HERE
#include test/resources/*.json
____HERE

/usr/local/bin/python3.7 -m venv .env && source ./.env/bin/activate
python -m pip install --upgrade pip setuptools wheel pytest build twine artifacts-keyring keyring bump2version pipreqs
python -m pip install astroid==2.5.2 pycodestyle==2.7.0 pyflakes==2.3.0 isort black autoflake pytest-cov

cd "$_pwd"