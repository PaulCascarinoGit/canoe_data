# Utilise l'image officielle Python
FROM python:3.10

# Définit le répertoire de travail
WORKDIR /app

# Copie les fichiers de dépendances
COPY requirements.txt .

# Installe les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copie le code de l'application
COPY app/ /app/app

# Expose le port de l'API
EXPOSE 8000

# Commande pour lancer l'application FastAPI
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
