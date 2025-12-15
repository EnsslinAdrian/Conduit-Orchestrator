FROM python:3.5-slim

WORKDIR /app

COPY . /app/

RUN pip install --no-cache-dir -r requirements.txt && \
    chmod +x /app/entrypoint.sh

EXPOSE 8000

ENTRYPOINT [ "/app/entrypoint.sh" ]
