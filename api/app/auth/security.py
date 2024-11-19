from fastapi import HTTPException, Security
from fastapi.security import OAuth2PasswordBearer
from jose import jwt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
KEYCLOAK_PUBLIC_KEY = "your-public-key"  # Replace dynamically

async def jwt_required(token: str = Security(oauth2_scheme)):
    try:
        jwt.decode(token, KEYCLOAK_PUBLIC_KEY, algorithms=["RS256"])
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
