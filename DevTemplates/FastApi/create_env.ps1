#!/usr/bin/env pwsh

set-strictmode -version latest

param (
    [string]$ProjectName
)

if (-not $ProjectName) {
    Write-Host "Usage: ./script.ps1 -ProjectName <project_name>" -ForegroundColor Red
    exit 1
}

function Create-Readme {
    param (
        [string]$Name
    )

    "# $Name" | Out-File -FilePath "README.md" -Encoding UTF8 -ErrorAction Stop
}

function Create-Venv {
    if (Test-Path -Path "venv") {
        Write-Host "Virtual environment already exists. Skipping creation." -ForegroundColor Yellow
    } else {
        python3 -m venv venv -ErrorAction Stop
    }
}

function Install-BasicDeps {
    Write-Host "Activating virtual environment..."

    if ($env:OS -match "Windows") {
        & "./venv/Scripts/activate" -ErrorAction Stop
    } else {
        . ./venv/bin/activate
    }

    Write-Host "Verifying pip environment..."

    $VenvDir = (Resolve-Path -Path "./venv").Path
    $PythonPath = & python -c "import sys; print(sys.executable)"

    Write-Host "Python Path: $PythonPath"
    Write-Host "Virtual Environment Directory: $VenvDir"

    if ($PythonPath -notmatch [regex]::Escape($VenvDir)) {
        Write-Host "Python is not using the virtual environment. Aborting." -ForegroundColor Red
        deactivate
        exit 1
    }

    Write-Host "Installing dependencies..."

    pip install alembic fastapi pydantic pydantic-settings uvicorn python-jose SQLAlchemy -ErrorAction Stop

    Setup-Alembic -Name $ProjectName

    Write-Host "Freezing dependencies to requirements.txt..."
    pip freeze | Out-File -FilePath "requirements.txt" -Encoding UTF8 -ErrorAction Stop

    Write-Host "Deactivating virtual environment..."
    deactivate
}

function Create-Gitignore {
    $GitignoreContent = @"
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*\$py.class

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py.cover
.hypothesis/
.pytest_cache/
cover/

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Local env files
.env.local
.env.*.local
.env
.env.*.local

# Editor directories and files
.idea
.vscode
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/
"@

    $GitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8 -ErrorAction Stop
}

function Create-Dotenv {
    @"
DEBUG=True
SECRET_KEY=YOUR_SECRET_KEY
DATABASE_URL=sqlite:///./app.db

# Optional
# DATABASE_URL=postgresql://user:password@localhost/dbname
"@ | Out-File -FilePath ".env" -Encoding UTF8 -ErrorAction Stop
}

function Setup-Alembic {
    param (
        [string]$Name
    )

    $DbManager = "$Name`_migration"
    Write-Host "Setting up Alembic..."
    alembic init $DbManager -ErrorAction Stop
}

function Create-AppGateway {
    @"
#!/usr/bin/env python3
from server import create_app
import uvicorn

app = create_app()

if __name__ == '__main__':
    config = uvicorn.Config("app", port=5000, log_level='info')
    server = uvicorn.Server(config)
    server.run()
"@ | Out-File -FilePath "app.py" -Encoding UTF8 -ErrorAction Stop
}

function Main {
    Write-Host "Creating README.md..."
    Create-Readme -Name $ProjectName

    Write-Host "Setting up virtual environment..."
    Create-Venv

    Write-Host "Installing basic dependencies..."
    Install-BasicDeps

    Write-Host "Creating .gitignore..."
    Create-Gitignore

    Write-Host "Creating .env..."
    Create-Dotenv

    Write-Host "Creating app gateway..."
    Create-AppGateway

    Write-Host "Environment setup complete for $ProjectName." -ForegroundColor Green
}

Main
