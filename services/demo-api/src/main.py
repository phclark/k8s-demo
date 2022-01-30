from typing import Optional
from fastapi import FastAPI, Response
import os
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()


Instrumentator().instrument(app).expose(app)

@app.get("/")
def demo_endpoint(response: Response):
    response.headers["X-VERSION"] = os.environ.get('VERSION', 'default')
    return {
        "message": "Automate all the things!",
        "timestamp": 1529729125
    }

@app.get("/healthz")
def demo_endpoint(response: Response):
    response.headers["X-VERSION"] = os.environ.get('VERSION', 'default')
    return "OK"