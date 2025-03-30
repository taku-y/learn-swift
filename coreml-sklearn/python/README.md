# CoreML Sample Project

This directory contains Python scripts for generating CoreML models used in the SwiftUI application.

## Prerequisites

- macOS (for CoreML support)
- [pyenv](https://github.com/pyenv/pyenv) for Python version management
- Git

## Environment Setup

1. Install Python using pyenv:
```bash
# Install Python 3.8 or later
pyenv install 3.8.13

# Set local Python version for this project
pyenv local 3.8.13
```

2. Create and activate a virtual environment:
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# .\venv\Scripts\activate
```

3. Install dependencies:
```bash
# Install project dependencies from pyproject.toml
# This will install coremltools, numpy, and scikit-learn
pip install -e .
```

## Usage

1. Generate the CoreML model:
```bash
python create_model.py
```

This will create a `SimpleClassifier.mlmodel` file in the current directory.

2. Add the generated model to your Xcode project:
   - Drag and drop the `SimpleClassifier.mlmodel` file into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Add the model to your target

## Project Structure

- `create_model.py`: Script to generate the CoreML model
- `pyproject.toml`: Project dependencies and metadata
- `.gitignore`: Git ignore rules for Python projects

## Notes

- The generated CoreML model is not tracked in Git (see `.gitignore`)
- Make sure to regenerate the model if you make changes to the training data or model architecture
- The model requires macOS for both generation and usage 