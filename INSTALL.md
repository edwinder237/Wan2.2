# Installation Guide

## Install with pip

```bash
pip install .
pip install .[dev]  # Installe aussi les outils de dev
```

## Install with Poetry

Ensure you have [Poetry](https://python-poetry.org/docs/#installation) installed on your system.

To install all dependencies:

```bash
poetry install
```

### Handling `flash-attn` Installation Issues

If `flash-attn` fails due to **PEP 517 build issues**, you can try one of the following fixes.

#### No-Build-Isolation Installation (Recommended)
```bash
poetry run pip install --upgrade pip setuptools wheel
poetry run pip install flash-attn --no-build-isolation
poetry install
```

#### Install from Git (Alternative)
```bash
poetry run pip install git+https://github.com/Dao-AILab/flash-attention.git
```

---

### Running the Model

Once the installation is complete, you can run **Wan2.2** using:

```bash
poetry run python generate.py --task t2v-A14B --size '1280*720' --ckpt_dir ./Wan2.2-T2V-A14B --prompt "Two anthropomorphic cats in comfy boxing gear and bright gloves fight intensely on a spotlighted stage."
```

#### Test
```bash
bash tests/test.sh
```

#### Format
```bash
black .
isort .
```

---

## Windows (local build)

`flash-attn` has no official Windows wheels, so on Windows Wan2.2 automatically falls
back to PyTorch's `scaled_dot_product_attention`. You don't need to install flash-attn.

Prerequisites: NVIDIA GPU with a recent driver, Python 3.10–3.12, Git.

```powershell
cd D:\path\to\your\folder
git clone https://github.com/edwinder237/Wan2.2.git
cd Wan2.2
powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1 -Model TI2V-5B
```

The script creates `.venv`, installs CUDA PyTorch and the requirements (without
flash-attn), checks the GPU, and downloads the chosen weights
(`TI2V-5B`, `T2V-A14B`, `I2V-A14B`, `S2V-14B`, `Animate-14B`, or `none`).
Use `-CudaIndex https://download.pytorch.org/whl/cu126` if your driver is older.

Run (TI2V-5B fits a single 24 GB GPU):

```powershell
.\.venv\Scripts\python.exe generate.py --task ti2v-5B --size 1280*704 --ckpt_dir .\Wan2.2-TI2V-5B --offload_model True --convert_model_dtype --t5_cpu --prompt "Two anthropomorphic cats in comfy boxing gear fight on a spotlighted stage."
```

The A14B models need ~80 GB of VRAM even with offloading. On consumer GPUs, use TI2V-5B.
