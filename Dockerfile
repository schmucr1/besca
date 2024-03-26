# Use JupyterLab as the base image
FROM jupyter/base-notebook:latest

# Set the working directory in the container
WORKDIR /usr/src/app

# Install any needed packages specified in requirements.txt
COPY environment.yml ./
RUN pip install --no-cache-dir -r environment.yml

# Make port 8888 available to the world outside this container
EXPOSE 8888

# Run JupyterLab
CMD ["jupyter", "lab", "--ip='*'", "--port=8888", "--no-browser", "--allow-root"]
