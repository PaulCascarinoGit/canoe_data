from fastapi import FastAPI, HTTPException, Depends
from app.auth.security import jwt_required

app = FastAPI()

@app.get("/secure-endpoint", dependencies=[Depends(jwt_required)])
async def secure_endpoint():
    return {"message": "You have accessed a secure endpoint!"}

@app.exception_handler(Exception)
async def http_error_handler(request, exc):
    if isinstance(exc, HTTPException):
        return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})
    return JSONResponse(status_code=500, content={"detail": "Internal Server Error"})
