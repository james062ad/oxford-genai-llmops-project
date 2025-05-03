from fastapi import FastAPI

app = FastAPI(title="Oxford GenAI LLMOps Project")

@app.get("/")
async def root():
    return {"message": "Hello, Oxford GenAI LLMOps!"}
