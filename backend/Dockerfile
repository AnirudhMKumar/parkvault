# Use the official Python image
FROM python:3.10-slim

# Set the working directory to /code
WORKDIR /code

# Copy the requirements file to the working directory
COPY ./requirements.txt /code/requirements.txt

# Install the necessary packages. We use --no-cache-dir to keep the image small.
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Create a directory to cache EasyOCR models so it doesn't download on every boot
ENV EASYOCR_MODULE_PATH=/code/.EasyOCR
RUN mkdir -p /code/.EasyOCR

# Copy the actual API code
COPY . /code

# Expose the standard Hugging Face port
EXPOSE 7860

# Run the Uvicorn server on the port expected by Hugging Face Spaces (7860)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
