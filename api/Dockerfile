FROM python:3.10-slim

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Installer les dépendances Python
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste de l'application
COPY . /app
WORKDIR /app

# Commande de lancement
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
