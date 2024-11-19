library(shiny)
library(httr)
library(jsonlite)
library(DBI)
library(RPostgres)

# Charger la configuration client
client_secrets <- fromJSON("config/client_secrets.json")
client_id <- client_secrets$web$client_id
client_secret <- client_secrets$web$client_secret
token_uri <- client_secrets$web$token_uri
userinfo_uri <- client_secrets$web$userinfo_uri



# Connexion à la base de données PostgreSQL
con <- tryCatch({
  dbConnect(RPostgres::Postgres(), 
            host = "postgres", 
            port = 5432, 
            user = "shiny_user", 
            password = "shiny_password", 
            dbname = "shiny_db")
}, error = function(e) {
  NULL  # Si la connexion échoue, retourner NULL
})

# Vérification de la connexion
if (is.null(con)) {
  print("Erreur de connexion à la base de données.")
  output$error_message <- renderText({
    "Erreur de connexion à la base de données PostgreSQL."
  })
} else {
  print("Connexion à la base de données réussie.")
}

# UI de la page de connexion
login_ui <- fluidPage(
  titlePanel("Page de Connexion Shiny"),
  
  # Formulaire de connexion
  textInput("username", "Nom d'utilisateur", ""),
  passwordInput("password", "Mot de passe", ""),
  actionButton("login", "Se connecter"),
  
  # Messages d'erreur
  textOutput("error_message")
)

# UI de la page de tableau de bord
dashboard_ui <- fluidPage(
  titlePanel("Tableau de bord"),
  h3("Connexion réussie !"),
  textOutput("user_info")  # Afficher le nom de l'utilisateur connecté
)

# Serveur
server <- function(input, output, session) {
  
  # Variable réactive pour suivre l'état de connexion
  user_authenticated <- reactiveVal(FALSE)
  
  # Afficher l'UI appropriée en fonction de l'authentification
  output$ui <- renderUI({
    if (user_authenticated()) {
      dashboard_ui  # Afficher le tableau de bord après la connexion réussie
    } else {
      login_ui  # Afficher le formulaire de connexion
    }
  })
  
  # Observer l'action de connexion
  observeEvent(input$login, {
    # Authentification avec Keycloak via username et password
    res <- POST(
      token_uri,
      body = list(
        grant_type = "password",
        username = input$username,
        password = input$password,
        client_id = client_id,
        client_secret = client_secret,
        scope = "openid"  # Ajout du scope "openid"
      ),
      encode = "form"
    )
    
    if (http_error(res)) {
      output$error_message <- renderText({
        paste("Erreur de connexion:", content(res, "text"))
      })
    } else {
      token <- content(res, "parsed")
      
      # Vérifier l'existence du token
      if (is.null(token$access_token)) {
        output$error_message <- renderText("Erreur de connexion: Aucun token d'accès retourné.")
        return()
      }
      
      # Récupérer les informations utilisateur
      userinfo_res <- GET(
        userinfo_uri,
        add_headers(Authorization = paste("Bearer", token$access_token))
      )
      
      if (http_error(userinfo_res)) {
        output$error_message <- renderText({
          paste("Erreur lors de la récupération des informations utilisateur:", content(userinfo_res, "text"))
        })
      } else {
        userinfo <- content(userinfo_res, "parsed")
        
        # Sauvegarder les informations utilisateur dans la session
        output$user_info <- renderText({
          paste("Bienvenue,", userinfo$name)
        })
        
        username <- as.character(input$username)
        name <- as.character(userinfo$name)
        
        # Vérifier si l'utilisateur existe déjà dans la base de données
        user_exists <- dbGetQuery(con, 
                                  "SELECT COUNT(*) FROM users WHERE username = $1", 
                                  params = list(username))

       
        if (user_exists == 0) { 

          print("L'utilisateur n'existe pas encore.")
          # Insérer l'utilisateur dans la base de données si l'utilisateur n'existe pas
          dbExecute(con, 
                    "INSERT INTO users (username, name, jetons) 
                    VALUES ($1, $2, $3)", 
                    params = list(username, "name", 0))


          output$user_info <- renderText({
            paste("Utilisateur ajouté:", username)
          })
        } else {
          print("L'utilisateur existe ?")
          # Incrémenter les jetons si l'utilisateur existe déjà
          dbExecute(con, 
                    "UPDATE users SET jetons = jetons + 1 WHERE username = $1", 
                    params = list(username))
          
          output$user_info <- renderText({
            paste("Utilisateur déjà connecté:", user_exists, username, "Jetons:", user_exists$`COUNT(*)`)
          })
        }
        
        # Mettre à jour l'état de l'authentification
        user_authenticated(TRUE)
      }
    }
  })
}

# Lancer l'application
shinyApp(ui = uiOutput("ui"), server = server)