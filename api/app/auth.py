from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import requests
import os

# URL du serveur Keycloak et configuration du client
KEYCLOAK_SERVER_URL = os.getenv("KEYCLOAK_SERVER_URL", "http://localhost:8080")
REALM_NAME = os.getenv("REALM_NAME", "myrealm")
CLIENT_ID = os.getenv("CLIENT_ID", "fastapi-client")
CLIENT_SECRET = os.getenv("CLIENT_SECRET", "client_secret_here")  # Remplace par ton secret client Keycloak

# OAuth2 pour extraire le token
oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{KEYCLOAK_SERVER_URL}/realms/{REALM_NAME}/protocol/openid-connect/token")

def get_keycloak_user_info(token: str):
    """Fonction pour récupérer les informations de l'utilisateur depuis Keycloak."""
    try:
        # Vérification du token avec l'endpoint /userinfo de Keycloak
        response = requests.get(
            f"{KEYCLOAK_SERVER_URL}/realms/{REALM_NAME}/protocol/openid-connect/userinfo",
            headers={"Authorization": f"Bearer {token}"}
        )
        response.raise_for_status()  # Levée d'exception si erreur HTTP
        return response.json()  # Renvoie les informations utilisateur
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token invalide ou expiré") from e

async def get_current_user(token: str = Depends(oauth2_scheme)):
    """Fonction pour récupérer l'utilisateur actuel en validant le token avec Keycloak."""
    return get_keycloak_user_info(token)
