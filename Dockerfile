# Use JupyterLab as the base image
FROM jupyter/base-notebook:python-3.9

LABEL author="Roland Schmucki" \
      description="besca docker image" \
      maintainer="roland.schmucki@roche.com"

# Set the working directory in the container
WORKDIR /usr/src/app

# Install system dependencies required for building certain Python packages
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential gcc git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the "workbooks" folder from the repository to the desired path in the image
COPY workbooks /opt/besca/workbooks

# Set the appropriate permissions for the copied folder
RUN chown -R $NB_UID:$NB_GID /opt/besca/workbooks

# Switch back to the notebook user
USER $NB_UID

ARG PIP_NO_CACHE_DIR=1

COPY environment.yml /tmp/

RUN mamba env update -n besca -f /tmp/environment.yml --prune && \
    mamba install -n besca -c conda-forge ipykernel && \
    conda run -n besca python -m ipykernel install --user --name besca --display-name "Python 3" && \
    conda clean --all -f -y

# Set "besca" as the default kernel
USER root
RUN echo "c.MultiKernelManager.default_kernel_name = 'besca'" >> /etc/jupyter/jupyter_notebook_config.py
USER $NB_UID

# Change permissions for path in order to be able to download test data sets
RUN mkdir -p /opt/conda/envs/besca/lib/python3.9/site-packages/besca/datasets \
    && chmod -R 777 /opt/conda/envs/besca/lib/python3.9/site-packages/besca/datasets

# Make port 8888 available to the world outside this container
EXPOSE 8888

# Run JupyterLab
CMD ["jupyter", "lab", "--ip='*'", "--port=8888", "--no-browser", "--allow-root"]
