from fastapi import FastAPI, HTTPException, Depends, Form
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from .auth import get_current_user
import requests

app = FastAPI()

# Récupère les informations de connexion à la base de données depuis les variables d'environnement
DATABASE_URL = os.getenv("DATABASE_URL")

# Connexion à la base de données PostgreSQL
def get_db_connection():
    try:
        conn = psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)
        return conn
    except Exception as e:
        print("Erreur de connexion à la base de données:", e)
        return None

# Modèle Pydantic pour les données utilisateur
class User(BaseModel):
    username: str
    email: str

@app.get("/")
def read_root():
    return {"message": "Bienvenue sur l'API FastAPI"}

@app.get("/protected-route/")
async def protected_route(current_user: dict = Depends(get_current_user)):
    """Route protégée nécessitant une authentification via Keycloak"""
    return {"message": "C'est une route protégée", "user": current_user}

@app.post("/users/")
def create_user(user: User):
    """Créer un utilisateur dans la base de données"""
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Impossible de se connecter à la base de données")
    
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO users (username, email) VALUES (%s, %s) RETURNING id",
            (user.username, user.email),
        )
        user_id = cursor.fetchone()["id"]
        conn.commit()
        return {"id": user_id, "username": user.username, "email": user.email}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Erreur lors de la création de l'utilisateur: {str(e)}")
    finally:
        cursor.close()
        conn.close()


@app.post("/login")
async def login(username: str = Form(...), password: str = Form(...)):
    KEYCLOAK_SERVER_URL = os.getenv("KEYCLOAK_SERVER_URL", "http://localhost:8080")
    REALM_NAME = os.getenv("REALM_NAME", "myrealm")
    CLIENT_ID = os.getenv("CLIENT_ID", "fastapi-client")
    CLIENT_SECRET = os.getenv("CLIENT_SECRET", "fastapi-clientsecret")

    # Faire une requête à Keycloak pour obtenir un token d'accès
    token_url = f"{KEYCLOAK_SERVER_URL}/realms/{REALM_NAME}/protocol/openid-connect/token"
    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "username": username,
        "password": password,
        "grant_type": "password"
    }
    response = requests.post(token_url, data=data)

    if response.status_code == 200:
        token = response.json().get("access_token")
        return {"access_token": token}
    else:
        return {"error": "Échec de l'authentification"}