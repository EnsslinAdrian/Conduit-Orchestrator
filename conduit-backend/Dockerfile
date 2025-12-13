FROM python:3.5-slim as build
WORKDIR /app
COPY . /app/

RUN pip install --no-cache-dir -r requirements.txt && \
    chmod +x /app/entrypoint.sh


FROM python:3.5-slim as runtime
WORKDIR /app
COPY --from=build /app /app
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000
ENTRYPOINT [ "/app/entrypoint.sh" ]