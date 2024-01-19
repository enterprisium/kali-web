# Use the official Ubuntu 20.04 image as a parent image
FROM ubuntu:20.04

# Set the working directory
WORKDIR /tmp

# Set frontend to noninteractive
ARG DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git wget curl tar docker.io docker-compose expect ffmpeg tzdata

# Download the necessary files
RUN curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.14.0.3a7abb.tar.gz
RUN curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_service_images_amd64_1.14.0.3a7abb.tar.gz
RUN curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_workspace_images_amd64_1.14.0.3a7abb.tar.gz

# Extract the tar file
RUN tar -xf kasm_release_1.14.0.3a7abb.tar.gz

# Create an expect script
RUN echo '#!/usr/bin/expect\n\
set timeout -1\n\
spawn bash kasm_release/install.sh --offline-workspaces /tmp/kasm_release_workspace_images_amd64_1.14.0.3a7abb.tar.gz --offline-service /tmp/kasm_release_service_images_amd64_1.14.0.3a7abb.tar.gz\n\
expect "I have read and accept End User License Agreement (y/n)?"\n\
send -- "y\r"\n\
expect "Do you want to create a swap partition on this system (y/n)?"\n\
send -- "n\r"\n\
expect eof' > /tmp/expect_script

# Make the script executable
RUN chmod +x /tmp/expect_script

# Run the expect script
RUN /tmp/expect_script

# Expose port 443
EXPOSE 443
