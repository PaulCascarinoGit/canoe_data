library(shiny)
library(httr)

# UI pour l'interface de connexion
ui <- fluidPage(
  titlePanel("Connexion Keycloak"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("username", "Nom d'utilisateur"),
      passwordInput("password", "Mot de passe"),
      actionButton("login_button", "Se connecter"),
      textOutput("error_message")
    ),
    
    mainPanel(
      h3("Bienvenue dans l'application Shiny")
    )
  )
)

# Serveur de l'application Shiny
server <- function(input, output, session) {
  
  # Fonction pour envoyer les informations de connexion à FastAPI
  observeEvent(input$login_button, {
    username <- input$username
    password <- input$password
    
    # Vérifiez si l'utilisateur a fourni un nom d'utilisateur et un mot de passe
    if (username == "" || password == "") {
      output$error_message <- renderText("Veuillez entrer un nom d'utilisateur et un mot de passe.")
      return(NULL)
    }
    
    # Requête POST vers FastAPI pour obtenir un token via Keycloak
    url <- "http://fastapi_service:8000/login"  # URL de votre API FastAPI

    print(paste(url, username, password))
    response <- POST(url, body = list(username = username, password = password), encode = "form")

    print(content(response, as = "text"))
    
    if (status_code(response) == 200) {
      # Si la connexion est réussie et que nous obtenons un token
      content_data <- content(response)
      token <- content_data$access_token
      
      # Vous pouvez utiliser ce token pour des appels API protégés, par exemple
      output$error_message <- renderText(paste("Connexion réussie! Token : ", token))
      
    } else {
      # Si la connexion échoue
      output$error_message <- renderText("Erreur d'authentification, veuillez vérifier vos identifiants.")
    }
  })
}

# Lancer l'application Shiny
shinyApp(ui = ui, server = server)
