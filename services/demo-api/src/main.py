from typing import Optional
from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()



Instrumentator().instrument(app).expose(app)

@app.get("/")
def demo_endpoint():
    return {
        "message": "Automate all the things!",
        "timestamp": 1529729125
    }
