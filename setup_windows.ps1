# Wan2.2 - local setup for Windows (PowerShell)
#
# Usage (from the folder where you want Wan2.2, e.g. D:\LUMEVE\warn2.0):
#   powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
#   powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1 -Model TI2V-5B
#
# Requirements: NVIDIA GPU + recent driver, Python 3.10-3.12, Git.
# flash-attn is NOT required: Wan falls back to PyTorch SDPA attention.

param(
    [ValidateSet("TI2V-5B", "T2V-A14B", "I2V-A14B", "S2V-14B", "Animate-14B", "none")]
    [string]$Model = "TI2V-5B",
    [string]$CudaIndex = "https://download.pytorch.org/whl/cu128"
)

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

Write-Host "==> Checking Python" -ForegroundColor Cyan
$py = (Get-Command py -ErrorAction SilentlyContinue)
if ($py) { $python = "py -3" } else { $python = "python" }
Invoke-Expression "$python --version"

if (-not (Test-Path ".venv")) {
    Write-Host "==> Creating virtual environment .venv" -ForegroundColor Cyan
    Invoke-Expression "$python -m venv .venv"
}
$venvPy = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"

Write-Host "==> Upgrading pip" -ForegroundColor Cyan
& $venvPy -m pip install --upgrade pip setuptools wheel

Write-Host "==> Installing PyTorch with CUDA ($CudaIndex)" -ForegroundColor Cyan
& $venvPy -m pip install torch torchvision torchaudio --index-url $CudaIndex

Write-Host "==> Installing Wan2.2 requirements (without flash_attn)" -ForegroundColor Cyan
$reqs = Get-Content requirements.txt | Where-Object {
    $_ -notmatch '^\s*flash_attn' -and $_ -notmatch '^\s*torch' -and $_.Trim() -ne ''
}
$tmpReq = Join-Path $env:TEMP "wan_requirements_win.txt"
$reqs | Set-Content $tmpReq
& $venvPy -m pip install -r $tmpReq
& $venvPy -m pip install "huggingface_hub[cli]"

Write-Host "==> Verifying CUDA" -ForegroundColor Cyan
& $venvPy -c "import torch; print('torch', torch.__version__, '| CUDA available:', torch.cuda.is_available()); print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'NO GPU DETECTED')"

if ($Model -ne "none") {
    Write-Host "==> Downloading Wan2.2-$Model weights (large download)" -ForegroundColor Cyan
    & $venvPy -c "from huggingface_hub import snapshot_download; snapshot_download('Wan-AI/Wan2.2-$Model', local_dir='Wan2.2-$Model')"
}

Write-Host ""
Write-Host "Done. Example run (TI2V-5B, fits a 24GB GPU):" -ForegroundColor Green
Write-Host '  .\.venv\Scripts\python.exe generate.py --task ti2v-5B --size 1280*704 --ckpt_dir .\Wan2.2-TI2V-5B --offload_model True --convert_model_dtype --t5_cpu --prompt "Two anthropomorphic cats in comfy boxing gear fight on a spotlighted stage."'
