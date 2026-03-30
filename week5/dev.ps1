<#
.SYNOPSIS
    Dev workflow for Week 5 FastAPI project.
.EXAMPLE
    .\dev.ps1 install     # install all dev tools
    .\dev.ps1 run         # start the server
    .\dev.ps1 test        # run tests
    .\dev.ps1 test-cov    # run tests with coverage
    .\dev.ps1 lint        # lint with ruff
    .\dev.ps1 format      # auto-format with black + ruff
#>
param(
    [Parameter(Position = 0)]
    [ValidateSet("run", "test", "test-cov", "lint", "format", "install")]
    [string]$Task
)

$Root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$Venv   = "$Root\venv\Scripts"
$Python = "$Venv\python.exe"
$Pip    = "$Venv\pip.exe"
$Pytest = "$Venv\pytest.exe"

# Make imports resolve from the week5 root (e.g. "backend.app.main")
$env:PYTHONPATH = $Root

function Show-Help {
    Write-Host ""
    Write-Host "Usage: .\dev.ps1 <task>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Tasks:"
    Write-Host "  install     Install missing dev tools into the venv"
    Write-Host "  run         Start dev server at http://127.0.0.1:8000"
    Write-Host "  test        Run all tests"
    Write-Host "  test-cov    Run tests with line coverage report"
    Write-Host "  lint        Check code style with ruff"
    Write-Host "  format      Auto-format with black, then fix with ruff"
    Write-Host ""
}

switch ($Task) {

    "install" {
        Write-Host "> Installing dev dependencies into venv..." -ForegroundColor Cyan
        & $Pip install --upgrade pip
        & $Pip install "uvicorn[standard]" pytest-cov ruff black
    }

    "run" {
        Write-Host "> Starting dev server - http://127.0.0.1:8000" -ForegroundColor Cyan
        Write-Host "  Press Ctrl+C to stop." -ForegroundColor DarkGray
        & $Python -m uvicorn backend.app.main:app --reload --host 127.0.0.1 --port 8000
    }

    "test" {
        Write-Host "> Running tests..." -ForegroundColor Cyan
        & $Pytest -v backend/tests
    }

    "test-cov" {
        Write-Host "> Running tests with coverage..." -ForegroundColor Cyan
        & $Pytest -v --cov=backend/app --cov-report=term-missing backend/tests
    }

    "lint" {
        Write-Host "> Linting with ruff..." -ForegroundColor Cyan
        & $Python -m ruff check backend/
    }

    "format" {
        Write-Host "> Formatting with black..." -ForegroundColor Cyan
        & $Python -m black backend/
        Write-Host "> Fixing lint issues with ruff..." -ForegroundColor Cyan
        & $Python -m ruff check backend/ --fix
    }

    default { Show-Help }
}
