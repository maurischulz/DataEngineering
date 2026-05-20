
# Base image: Jupyter + PySpark (Spark 3.x, Python 3.x, Jupyter notebook/lab)
FROM jupyter/pyspark-notebook:latest

# Conda environment name and Python version
ARG conda_env=vscode_pyspark
ARG py_ver=3.11

# Create isolated conda environment with core kernel support
RUN mamba create --yes -p "${CONDA_DIR}/envs/${conda_env}" python=${py_ver} ipython ipykernel && \
    mamba clean --all -f -y

# Register the environment as a Jupyter kernel
RUN "${CONDA_DIR}/envs/${conda_env}/bin/python" -m ipykernel install --user --name="${conda_env}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install full data engineering / data science stack
RUN "${CONDA_DIR}/envs/${conda_env}/bin/pip" install \
    # --- Spark & big data ---
    pyspark \
    delta-spark \
    pyarrow \
    fastparquet \
    # --- DataFrames ---
    pandas \
    polars \
    numpy \
    scipy \
    # --- Machine Learning ---
    scikit-learn \
    # --- Visualization ---
    matplotlib \
    seaborn \
    plotly \
    # --- Databases & SQL ---
    sqlalchemy \
    # --- Data quality ---
    great-expectations \
    pydantic \
    # --- File formats ---
    openpyxl \
    xlrd \
    --no-cache-dir

# Activate the environment by default in new shells
RUN echo "conda activate ${conda_env}" >> "${HOME}/.bashrc"
