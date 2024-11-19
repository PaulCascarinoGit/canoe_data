from dotenv import load_dotenv
import os

load_dotenv()

KEYCLOAK_URL = os.getenv("KEYCLOAK_URL")
KEYCLOAK_REALM = os.getenv("KEYCLOAK_REALM")
KEYCLOAK_CLIENT_ID = os.getenv("KEYCLOAK_CLIENT_ID")
KEYCLOAK_CLIENT_SECRET = os.getenv("KEYCLOAK_CLIENT_SECRET")

def get_keycloak_public_key():
    url = f"{KEYCLOAK_URL}/realms/{KEYCLOAK_REALM}"
    response = requests.get(url)
    response.raise_for_status()
    return response.json()["public_key"]
