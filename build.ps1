# Build script for Tzar UI

$ErrorActionPreference = "Stop"

Write-Host "Building Tzar UI..."

# Ensure dist folder exists
if (-not (Test-Path -Path "dist")) {
    New-Item -ItemType Directory -Path "dist" | Out-Null
}

# Generate Rojo sourcemap for darklua bundling  
Write-Host "Generating sourcemap..."
rojo sourcemap default.project.json -o .sourcemap.json

# Run Darklua to process and bundle
Write-Host "Running Darklua..."
darklua process src/init.luau dist/bundle.lua --config darklua.json

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful! Output at dist/bundle.lua"
} else {
    Write-Host "Build failed."
    exit 1
}
