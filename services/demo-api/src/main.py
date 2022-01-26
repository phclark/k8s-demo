from typing import Optional
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    # should fail test 
    
    return {"Hello": "World"}
