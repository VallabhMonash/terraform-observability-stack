from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import random

app = FastAPI()

# Metrics
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["endpoint"]
)

REQUEST_LATENCY = Histogram(
    "http_request_latency_seconds",
    "Request latency in seconds",
    ["endpoint"]
)

@app.get("/health")
def health():
    REQUEST_COUNT.labels(endpoint="/health").inc()
    return {"status": "ok"}

@app.get("/work")
def do_work():
    endpoint = "/work"
    REQUEST_COUNT.labels(endpoint=endpoint).inc()

    start_time = time.time()
    time.sleep(random.uniform(0.05, 0.3))  # simulate processing
    REQUEST_LATENCY.labels(endpoint=endpoint).observe(time.time() - start_time)

    return {"result": "processed"}

@app.get("/metrics")
def metrics():
    data = generate_latest()
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)

