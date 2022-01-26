from typing import Optional
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def demo_endpoint():
    return {
        "message": "Automate all the things!",
        "timestamp": 1529729125
    }
