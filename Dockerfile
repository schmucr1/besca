# Use JupyterLab as the base image
FROM jupyter/base-notebook:python-3.9

LABEL author="Roland Schmucki" \
      description="besca docker image" \
      maintainer="roland.schmucki@roche.com"
      
# Set the working directory in the container
WORKDIR /usr/src/app

# Install system dependencies required for building certain Python packages
# Install system dependencies required for building certain Python packages
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential gcc git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to the notebook user
USER $NB_UID

ARG PIP_NO_CACHE_DIR=1

COPY environment.yml /tmp/

RUN mamba env update -n besca -f /tmp/environment.yml --prune && \
    conda clean --all -f -y

# Make port 8888 available to the world outside this container
EXPOSE 8888

# Run JupyterLab
CMD ["jupyter", "lab", "--ip='*'", "--port=8888", "--no-browser", "--allow-root"]
