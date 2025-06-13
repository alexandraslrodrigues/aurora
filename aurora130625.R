# LIBRARIES ---------------------------------------------------------------------
library(shiny)
library(bslib)
library(bsicons)
library(dplyr)
library(rsconnect)  
library(shinyjs)
library(tools)
library(shinyWidgets)
library(writexl)

# INTERFACE ---------------------------------------------------------------------
## INTRO -------------------------------------------------
# Define UI for application that draws a histogram
ui <- page_navbar(
  useShinyjs(), 
  
  id = "tabs",
  underline = FALSE,
  collapsible = TRUE,
  window_title = "aurora",
  
  title = actionLink("home_link", "aurora"),
  
  theme = bs_theme(
    version = 5,
    # bootswatch = "flatly",
    # primary = "#4e5678",
    primary = "#676971",
    # secondary = "#5bc0de",
    # light = "#f7f7f7",
    # dark = "#333333",
    # success = "#5cb85c",
    # info = "#5bc0de",
    # warning = "#f0ad4e",
    # danger = "#d9534f",
    # color = "#ffffff"
    base_font = font_google("Inter")
  ),
  
  # # Include the favicon in the head of the document
  tags$head(
    tags$link(rel = "icon", type = "image/png", href = "picture_auroraicon.png"),
    tags$style(HTML(
      "#home_link {
      text-decoration: none !important;
      color: #676971;
      font-family: helvetica;
      font-size: 40px;
      font-weight: bold;
      letter-spacing: -3px;
      cursor: pointer;
    }
  ")),
    
    # Google Analytics scripts:
    HTML("
    <!-- Google tag (gtag.js) -->
    <script async src='https://www.googletagmanager.com/gtag/js?id=G-K8VCNK1TLC'></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-K8VCNK1TLC');
    </script>
  ")
  ),
  
  tags$style(HTML("
  /* Right-align the tab titles in pill navigation */
  .nav-pills .nav-link {
    text-align: left !important;
  }
  .nav-pills .nav-item {
    width: 100%;
  }
")),
  
  tags$script(HTML(
    "$(document).on('click', '#home_link', function(){
      $('#tabs a[data-value=\"Home\"]').tab('show');
    });"
  )),
  
  
  nav_panel_hidden(
    "Home",
    
    div(
      class = "d-flex flex-column justify-content-center align-items-center",
      style = "min-height: 80vh;",
      
      tags$div(
        class = "d-flex justify-content-center align-items-center",
        style = "text-align: center;",
        
        # Icon on the left
        tags$img(src = "picture_auroraicon.png", style = "height: 60px; margin-right: 20px;"),
        
        # Title "aurora"
        tags$h1(
          tags$span(HTML("aurora&nbsp;&thinsp;&thinsp;&thinsp;"), style = "font-family: helvetica; font-size: 60px; font-weight: bold; letter-spacing: -3px; margin-right: 40px;")
        )
      ),
      
      tags$div(style = "padding-top: 5px;"),
      
      div(
        class = "welcome-message",
        style = "max-width: 700px; text-align: center;",
        p("clear reports, brighter outcomes"),
      ),
      
      tags$div(style = "padding-top: 30px;"),
      
      actionButton("report",
                   "Create an Aurora Report",
                   width = "400"),
      
      tags$div(style = "padding-top: 15px;"),
      
      actionButton("atrophy_calculator", "Use the Atrophy Calculator",
                   width = "400"),
      
      tags$div(style = "padding-top: 15px;"),
      
      actionButton("movement_calculator", "Use the Movement Calculator",
                   width = "400")
    )
  ),
  
  ## REPORT ------------------------
  nav_panel_hidden ("Report",
                    
                    # Hidden tabsetPanel (no visible headers)
                    tabsetPanel(id = "tabs_report", type = "hidden",
                                
                                
                                ### IDENTIFICATION -------------
                                
                                tabPanel(
                                  title = "Identification",
                                  value = "tab_identification",
                                  card(
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("identification_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;", 
                                          "Identification"
                                        )
                                      )
                                    ),
                                    card_body(
                                      selectInput("input_sex", "Sex of the patient", choices = c("Female", "Male", "NA")),
                                      numericInput("input_age", "Age of the patient", value = 0, min = 0, max = 100, step = 1)
                                    )
                                    
                                    # checkboxGroupInput(
                                    #   "clinical_symptoms",
                                    #   "Clinical symptoms:",
                                    #   choices = c("Dementia", "Movement disorder", "Other/NA")
                                    # )
                                  )
                                ),
                                
                                
                                
                                ### SMALL VESSEL DISEASE -------------------------------------------------
                                
                                #### RECENT SMALL SUBCORTICAL INFARCT -------------
                                
                                tabPanel(
                                  title = "Recent Small Subcortical Infarcts",
                                  value = "tab_recent_small_infarcts",      
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("rsi_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "Recent Small Subcortical Infarcts"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(5,
                                               selectizeInput(
                                                 "recentsmallinfarct", "Select all recent small subcortical infarcts",
                                                 choices = list(
                                                   "Supra-Tentorial" = c(
                                                     "Centrum semiovale - Frontal - Right",
                                                     "Centrum semiovale - Frontal - Left",
                                                     "Centrum semiovale - Parietal - Right",
                                                     "Centrum semiovale - Parietal - Left",
                                                     
                                                     "Corona radiata - Frontal - Right",
                                                     "Corona radiata - Frontal - Left",
                                                     "Corona radiata - Parietal - Right",
                                                     "Corona radiata - Parietal - Left",
                                                     
                                                     "Caudate nucleus - Right",
                                                     "Caudate nucleus - Left",
                                                     
                                                     "External capsule - Right",
                                                     "External capsule - Left",
                                                     
                                                     "Internal capsule - Anterior limb - Right",
                                                     "Internal capsule - Anterior limb - Left",
                                                     "Internal capsule - Genu - Right",
                                                     "Internal capsule - Genu - Left",
                                                     "Internal capsule - Posterior limb - Right",
                                                     "Internal capsule - Posterior limb - Left",
                                                     
                                                     "Lentiform nucleus - Right",
                                                     "Lentiform nucleus - Left",
                                                     
                                                     "Thalamus - Anterior - Right",
                                                     "Thalamus - Anterior - Left",
                                                     "Thalamus - Lateral - Right",
                                                     "Thalamus - Lateral - Left",
                                                     "Thalamus - Medial - Right",
                                                     "Thalamus - Medial - Left",
                                                     "Thalamus - Posterior - Right",
                                                     "Thalamus - Posterior - Left",
                                                     "Cerebral peduncle - Right",
                                                     "Cerebral peduncle - Left"
                                                   ), 
                                                   "Brainstem" = c(
                                                     "Midbrain - Crus cerebri - Right",
                                                     "Midbrain - Crus cerebri - Left",
                                                     "Midbrain - Tegmentum - Right",
                                                     "Midbrain - Tegmentum - Central",
                                                     "Midbrain - Tegmentum - Left",
                                                     "Midbrain - Tectum - Right",
                                                     "Midbrain - Tectum - Midline",
                                                     "Midbrain - Tectum - Left",
                                                     
                                                     "Pons - Basis - Right",
                                                     "Pons - Basis - Midline",
                                                     "Pons - Basis - Left",
                                                     "Pons - Tegmentum - Right",
                                                     "Pons - Tegmentum - Midline",
                                                     "Pons - Tegmentum - Left",
                                                     
                                                     "Medulla - Anterior - Right",
                                                     "Medulla - Anterior - Left",
                                                     "Medulla - Posterior - Right",
                                                     "Medulla - Posterior - Left"
                                                   ),
                                                   "Cerebellum" = c(
                                                     "Cerebellum - Right",
                                                     "Cerebellum - Left"
                                                   )
                                                 ),
                                                 multiple = TRUE,
                                                 options = list(placeholder = 'Search and select recent small subcortical infarcts'),
                                                 width = "90%"
                                               )
                                        ),
                                        column(
                                          width = 7, 
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("Definition")
                                              ),
                                              
                                              tags$img(src = "picture_rsi.png", height = "auto", width = "100%"),
                                              
                                              tags$p(
                                                "An acute infarct in the territory of a single perforating artery, as seen in MR DWI, typically associated with a corresponding focal neurological deficit. ",
                                                "The term small refers to a lesion less than 20 mm in maximum axial diameter (axial plane), though infarcts may appear slightly larger on coronal imaging. ",
                                                "No lower size limit is specified, as DWI allows distinction of very small infarcts from perivascular spaces."
                                              ),
                                              
                                              tags$p("Exclusions - do not classify as small subcortical infarcts:"),
                                              tags$ul(
                                                tags$li("Lesions >20 mm in the basal ganglia/internal capsule due to multiple penetrating arteries (striatocapsular infarcts)."),
                                                tags$li("Anterior choroidal artery infarcts (aetiologically distinct); identified by location (caudate head) and comma shape.")
                                              ),
                                              
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555;",
                                                tags$p(
                                                  "Figure adapted from: Mahammedi, A. et al. (2022). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.3174/ajnr.A7302",
                                                    "Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.",
                                                    target = "_blank"
                                                  ),
                                                  " Licensed under ",
                                                  tags$a(
                                                    href = "http://creativecommons.org/licenses/by/4.0/",
                                                    "CC BY 4.0",
                                                    target = "_blank"
                                                  ),
                                                  "."
                                                ),
                                                tags$p(
                                                  "Text adapted from: Duering, M. et al. (2023). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1016/s1474-4422(23)00131-x",
                                                    "Neuroimaging standards for research into small vessel disease—advances since 2013.",
                                                    target = "_blank"
                                                  ),
                                                  " The Lancet Neurology."
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),             
                                
                                
                                #### LACUNAR INFARCTS -------------------------------------------------    
                                
                                tabPanel(
                                  title = "Lacunes of Presumed Vascular Origin",
                                  value = "tab_svd_lacunes",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("li_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;", 
                                          "Lacunes of Presumed Vascular Origin"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(5,
                                               selectizeInput(
                                                 "lacunar_infarcts","Select all lacunar infarcts",
                                                 choices = list(
                                                   "Supra-Tentorial" = c(
                                                     "Centrum semiovale - Frontal - Right",
                                                     "Centrum semiovale - Frontal - Left",
                                                     "Centrum semiovale - Parietal - Right",
                                                     "Centrum semiovale - Parietal - Left",
                                                     
                                                     "Corona radiata - Frontal - Right",
                                                     "Corona radiata - Frontal - Left",
                                                     "Corona radiata - Parietal - Right",
                                                     "Corona radiata - Parietal - Left",
                                                     
                                                     "Caudate nucleus - Right",
                                                     "Caudate nucleus - Left",
                                                     
                                                     "External capsule - Right",
                                                     "External capsule - Left",
                                                     
                                                     "Internal capsule - Anterior limb - Right",
                                                     "Internal capsule - Anterior limb - Left",
                                                     "Internal capsule - Genu - Right",
                                                     "Internal capsule - Genu - Left",
                                                     "Internal capsule - Posterior limb - Right",
                                                     "Internal capsule - Posterior limb - Left",
                                                     
                                                     "Lentiform nucleus - Right",
                                                     "Lentiform nucleus - Left",
                                                     
                                                     "Thalamus - Anterior - Right",
                                                     "Thalamus - Anterior - Left",
                                                     "Thalamus - Lateral - Right",
                                                     "Thalamus - Lateral - Left",
                                                     "Thalamus - Medial - Right",
                                                     "Thalamus - Medial - Left",
                                                     "Thalamus - Posterior - Right",
                                                     "Thalamus - Posterior - Left",
                                                     "Cerebral peduncle - Right",
                                                     "Cerebral peduncle - Left"
                                                   ),
                                                   "Brainstem" = c(
                                                     "Midbrain - Crus cerebri - Right",
                                                     "Midbrain - Crus cerebri - Left",
                                                     "Midbrain - Tegmentum - Right",
                                                     "Midbrain - Tegmentum - Central",
                                                     "Midbrain - Tegmentum - Left",
                                                     "Midbrain - Tectum - Right",
                                                     "Midbrain - Tectum - Midline",
                                                     "Midbrain - Tectum - Left",
                                                     
                                                     "Pons - Basis - Right",
                                                     "Pons - Basis - Midline",
                                                     "Pons - Basis - Left",
                                                     "Pons - Tegmentum - Right",
                                                     "Pons - Tegmentum - Midline",
                                                     "Pons - Tegmentum - Left",
                                                     
                                                     "Medulla - Anterior - Right",
                                                     "Medulla - Anterior - Left",
                                                     "Medulla - Posterior - Right",
                                                     "Medulla - Posterior - Left"
                                                   ),
                                                   "Cerebellum" = c(
                                                     "Cerebellum - Right",
                                                     "Cerebellum - Left"
                                                   )
                                                 ),
                                                 multiple = TRUE,
                                                 options = list(placeholder = 'Search and select lacunar infarcts'),
                                                 width = "90%"
                                               )
                                        ),
                                        column(
                                          width = 7, 
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("Definition")
                                              ),
                                              
                                              tags$img(src = "picture_li.png", height = "auto", width = "100%"),
                                              
                                              tags$p(
                                                "Lacunes of presumed vascular origin are round or ovoid, fluid-filled cavities in the subcortical region that mirror cerebrospinal fluid signal. They typically measure 3–15 mm, although smaller (<3 mm) cavities may represent recent small subcortical infarcts."
                                              ),
                                              tags$p(
                                                "Differentiation from enlarged perivascular spaces can be challenging, as both can be similar in size and may lack a hyperintense T2 rim. Consider cavity shape, the presence of adjacent perivascular spaces, and signal changes in surrounding tissue to improve specificity."
                                              ),
                                              tags$p(
                                                "Lacunes may arise from small subcortical infarcts, small subcortical haemorrhages, incidental DWI-positive lesions, or represent end-stage cavitation within a white matter hyperintensity."
                                              ),
                                              
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555;",
                                                
                                                tags$p(
                                                  "Figure adapted from: Mahammedi, A. et al. (2022). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.3174/ajnr.A7302",
                                                    "Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.",
                                                    target = "_blank"
                                                  ),
                                                  " Licensed under ",
                                                  tags$a(
                                                    href = "http://creativecommons.org/licenses/by/4.0/",
                                                    "CC BY 4.0",
                                                    target = "_blank"
                                                  ),
                                                  "."
                                                ),
                                                
                                                tags$p(
                                                  "Text adapted from: Duering, M. et al. (2023). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1016/S1474-4422(23)00131-X",
                                                    "Neuroimaging standards for research into small vessel disease—advances since 2013.",
                                                    target = "_blank"
                                                  ),
                                                  " The Lancet Neurology."
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                #### FAZEKAS ------------------------------------------------- 
                                
                                tabPanel(
                                  title = "White Matter Hyperintensities of Presumed Vascular Origin",
                                  value = "fazekas_chk",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("fazekas_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "White Matter Hyperintensities of Presumed Vascular Origin"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(6,
                                               fluidRow(
                                                 column(6,
                                                        card(
                                                          style = "height: 400px; overflow-y: auto;",
                                                          selectInput("periventricular_grade", "Periventricular White Matter", 
                                                                      choices = c("0 = absent", "1 = “caps” or pencil-thin lining", "2 = smooth “halo”", "3 = irregular periventricular signal extending into the deep white matter")),
                                                          conditionalPanel(
                                                            condition = "input.periventricular_grade != '0 = absent'", 
                                                            selectInput("periventricular_distribution", "Predominant Distribution", 
                                                                        choices = c("diffuse", "frontal", "occipital", "temporal", "peri-atrial"))
                                                          ),
                                                          conditionalPanel(
                                                            condition = "input.periventricular_distribution != 'Diffuse' && input.periventricular_grade != '0 = absent'",
                                                            selectInput("periventricular_laterality", "Laterality", 
                                                                        choices = c("bilateral", "right", "left"))
                                                          )
                                                        )
                                                 ),
                                                 column(6,
                                                        card(
                                                          style = "height: 400px; overflow-y: auto;",
                                                          selectInput("deep_white_matter_grade", "Deep White Matter", 
                                                                      choices = c("0 = absent", "1 = punctate foci", "2 = beginning confluence", "3 = large confluent areas")),
                                                          conditionalPanel(
                                                            condition = "input.deep_white_matter_grade != '0 = absent'", 
                                                            selectInput("deep_white_matter_distribution", "Predominant Distribution", 
                                                                        choices = c("diffuse", "centrum semiovale", "corona radiata"))
                                                          ),
                                                          conditionalPanel (
                                                            condition = "input.deep_white_matter_distribution != 'Diffuse' && input.deep_white_matter_grade != '0 = absent'",
                                                            selectInput("deep_white_matter_laterality", "Laterality", 
                                                                        choices = c("bilateral", "right", "left"))
                                                          )
                                                        )
                                                 )
                                               )
                                        ),
                                        column(
                                          width = 6,
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("Fazekas Scale")
                                              ),
                                              
                                              tags$img(src = "picture_fazekas.png", height = "auto", width = "100%"),
                                              
                                              tags$p(
                                                "White matter hyperintensities of presumed vascular origin are characterized by hyperintense lesions on T2 FLAIR and decreased attenuation on CT in the periventricular/deep cerebral white matter, subcortical gray matter, basal ganglia, and brainstem."
                                              ),
                                              
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555;",
                                                
                                                tags$p(
                                                  "Figure adapted from: Mahammedi, A. et al. (2022). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.3174/ajnr.A7302",
                                                    "Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.",
                                                    target = "_blank"
                                                  ),
                                                  " © 2022 by American Journal of Neuroradiology. Open access to non-subscribers at ",
                                                  tags$a(href = "https://www.ajnr.org", "www.ajnr.org", target = "_blank"),
                                                  "."
                                                ),
                                                
                                                tags$p(
                                                  "Scale adapted from: Fazekas, F., Chawluk, J., Alavi, A., Hurtig, H. & Zimmerman, R. (1987). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.2214/ajr.149.2.3",
                                                    "MR signal abnormalities at 1.5 T in Alzheimer’s dementia and normal aging. American Journal of Roentgenology, 149, 351–356.",
                                                    target = "_blank"
                                                  )
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                
                                #### PVS ------------------------------------------
                                
                                tabPanel(
                                  title = "Perivascular Spaces",
                                  value = "pvs_chk",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("pvs_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",  # Text aligned left & centered vertically
                                          "Perivascular Spaces"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(6,
                                               fluidRow(
                                                 column(6,
                                                        selectInput("pvs_centrum_semiovale", "Centra Semiovalia", 
                                                                    choices = c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40"))
                                                 ),
                                                 column(6,
                                                        selectInput("pvs_basal_ganglia", "Basal Ganglia", 
                                                                    choices = c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40"))
                                                 )
                                               ),
                                               fluidRow(
                                                 column(6,
                                                        selectInput("pvs_mesencephalon", "Mesencephalon", 
                                                                    choices = c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40"))
                                                 )
                                               )
                                        ),
                                        column(
                                          width = 6,
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("The Enlarged Perivascular Spaces Scale")
                                              ),
                                              
                                              tags$img(src = "picture_pvs.png", height = "auto", width = "100%"),
                                              tags$img(src = "picture_pvs_2.png", height = "auto", width = "100%"),
                                              
                                              tags$div(
                                                style = "text-align: justify; margin-top: 10px;",
                                                tags$p(
                                                  "Severe perivascular spaces (PVS) are demonstrated in the basal ganglia and centrum semiovale (Figure 1), with additional PVS visible in the midbrain (arrowheads). ",
                                                  "In Figure 2, the spectrum of PVS burden is illustrated: panel (a) shows grade 4 (severe) PVS in the centrum semiovale; panel (b) displays grade 2 involvement in the basal ganglia; and panel (c) highlights grade 1 (mild) PVS in the midbrain, also indicated by arrowheads."
                                                )
                                              ),
                                              
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555; margin-top: 15px;",
                                                tags$p(
                                                  "Adapted from: Potter, G. M., Chappell, F. M., Morris, Z., & Wardlaw, J. M. (2015). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1159/000375153",
                                                    "Cerebrovascular Diseases, 39(4), 224–231.",
                                                    target = "_blank"
                                                  ),
                                                  " Licensed under ",
                                                  tags$a(
                                                    href = "https://creativecommons.org/licenses/by/3.0/",
                                                    "CC BY 3.0",
                                                    target = "_blank"
                                                  ),
                                                  "."
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                
                                #### MICROBLEEDS ------------------------------------------------- 
                                
                                tabPanel(
                                  title = "Microbleeds",
                                  value = "microbleeds_chk",
                                  card(
                                    full_screen = FALSE,
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",
                                        tags$div(
                                          style = "flex: none; width: 35px;",
                                          input_switch("mb_switch", label = NULL, value = TRUE)
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",
                                          "Microbleeds"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;",
                                      fluidRow(
                                        column(7,
                                               fluidRow(
                                                 tags$style(HTML("
        .definite-columns {
  background-color: #ffffff; /* Pure white */
}

.possible-columns {
  background-color: rgba(85, 51, 86, 0.05); /* Soft tint of #553356 */
}
              ")),
                                                 column(4, ""),
                                                 column(4, tags$h5("Definite"), align = "center", class = "definite-columns"),
                                                 column(4, tags$h5("Possible"), align = "center", class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, ""),
                                                 column(2, "Right", align = "center", class = "definite-columns"),
                                                 column(2, "Left", align = "center", class = "definite-columns"),
                                                 column(2, "Right", align = "center", class = "possible-columns"),
                                                 column(2, "Left", align = "center", class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Brainstem", style = "background-color: rgba(161, 203, 149, 0.1);"),
                                                 column(2, numericInput("brainstem_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("brainstem_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("brainstem_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("brainstem_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Cerebellum", style = "background-color: rgba(161, 203, 149, 0.1);"),
                                                 column(2, numericInput("cerebellum_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("cerebellum_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("cerebellum_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("cerebellum_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Basal Ganglia", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("basal_ganglia_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("basal_ganglia_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("basal_ganglia_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("basal_ganglia_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Thalamus", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("thalamus_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("thalamus_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("thalamus_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("thalamus_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Internal Capsule", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("internal_capsule_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("internal_capsule_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("internal_capsule_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("internal_capsule_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "External Capsule", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("external_capsule_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("external_capsule_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("external_capsule_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("external_capsule_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Corpus Callosum", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("corpus_callosum_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("corpus_callosum_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("corpus_callosum_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("corpus_callosum_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Deep/PV White Matter*", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("deep_pvwhite_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("deep_pvwhite_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("deep_pvwhite_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("deep_pvwhite_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Frontal", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("frontal_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("frontal_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("frontal_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("frontal_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Parietal", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("parietal_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("parietal_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("parietal_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("parietal_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Temporal", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("temporal_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("temporal_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("temporal_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2,numericInput("temporal_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Occipital", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("occipital_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("occipital_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("occipital_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("occipital_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Insula", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("insula_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("insula_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("insula_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("insula_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               )
                                        ),
                                        column(5,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Microbleed Anatomical Rating Scale (MARS)")
                                                   ),
                                                   
                                                   tags$p(
                                                     "Cerebral microbleeds are small, chronic brain hemorrhages visible as focal, round, hypointense lesions on T2*-GRE or SWI sequences, reflecting hemosiderin deposits due to vascular leakage. The Microbleed Anatomical Rating Scale (MARS) provides a standardized approach for categorizing microbleeds by anatomical location and imaging characteristics."
                                                   ),
                                                   
                                                   tags$ul(
                                                     tags$li("Lobar: cortical and subcortical regions, including subcortical U-fibers."),
                                                     tags$li("Deep: basal ganglia, thalamus, internal capsule, external capsule, corpus callosum, and deep/periventricular white matter (within approximately 10 mm of the lateral ventricles)."),
                                                     tags$li("Infratentorial: brainstem and cerebellum.")
                                                   ),
                                                   
                                                   tags$p("Imaging classification (GRE T2*-weighted):"),
                                                   tags$ul(
                                                     tags$li("Definite microbleeds: small (2–10 mm), round or circular, well-defined hypointense lesions."),
                                                     tags$li("Possible microbleeds: less well-defined, less hypointense, or not strictly rounded.")
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555;",
                                                     tags$p(
                                                       "Adapted from: Gregoire, S. M. et al. (2009). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1212/WNL.0b013e3181c34a7d",
                                                         "The Microbleed Anatomical Rating Scale (MARS). Neurology, 73, 1759–1766.",
                                                         target = "_blank"
                                                       )
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                #### SUPERFICIAL SIDEROSIS ----------------------------------
                                
                                tabPanel(
                                  title = "Superficial Siderosis",
                                  value = "superficial_siderosis_chk",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("css_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "Superficial Siderosis"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(6,
                                               selectizeInput(
                                                 "superficial_siderosis_right",
                                                 "Right Hemisphere",
                                                 choices = list(
                                                   "0: none" = 0,
                                                   "1: 1 sulcus or up to 3 immediately adjacent sulci with cSS" = 1,
                                                   "2: 2 or more nonadjacent sulci or more than 3 adjacent sulci with cSS" = 2
                                                 ), width = "100%"
                                               ),
                                               selectizeInput(
                                                 "superficial_siderosis_left",
                                                 "Left Hemisphere",
                                                 choices = list(
                                                   "0: none" = 0,
                                                   "1: 1 sulcus or up to 3 immediately adjacent sulci with cSS" = 1,
                                                   "2: 2 or more nonadjacent sulci or more than 3 adjacent sulci with cSS" = 2
                                                 ), width = "100%"
                                               )
                                        ),
                                        column(
                                          width = 6,
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("Cortical Superficial Siderosis Multifocality Rating Scale")
                                              ),
                                              
                                              tags$img(src = "picture_ss.png", height = "auto", width = "100%"),
                                              
                                              tags$p(
                                                "Cortical superficial siderosis (cSS) is identified as a well-defined, homogeneous, curvilinear hypointense signal (black) on T2*-GRE or SWI, following the outer surface of the cerebral cortex within the subarachnoid space. Do not score cSS if it is contiguous or anatomically connected to lobar intracerebral hemorrhage (ICH). To be considered separate, cSS must be ≥3 sulci away, or ≥2 sulci away on multiple axial levels without clear superficial communication."
                                              ),
                                              
                                              tags$ul(
                                                tags$li("cSS score (each hemisphere): 0 = no cSS, 1 = 1 sulcus or ≤3 adjacent sulci and 2 = ≥2 non-adjacent or >3 adjacent sulci."),
                                                tags$li("cSS total score (right + left): 0 = no cSS, 1 = mild/unifocal and ≥2 = severe/multifocal.")
                                              ),
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555;",
                                                
                                                tags$p(
                                                  "Picture adapted from: Andersen, N. H., Blauenfeldt, R. A., Mikkelsen, R. & Simonsen, C. Z. (2023). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1186/s12883-023-03300-9",
                                                    "Preceding symptoms and temporal development of cortical superficial siderosis in cerebral amyloid angiopathy: a case report. BMC Neurology, 23, 252.",
                                                    target = "_blank"
                                                  ),
                                                  " Licensed under ",
                                                  tags$a(
                                                    href = "http://creativecommons.org/licenses/by/4.0/",
                                                    "CC BY 4.0",
                                                    target = "_blank"
                                                  ),
                                                  "."
                                                ),
                                                
                                                tags$p(
                                                  "Scale cSS adapted from: Charidimou, A. et al. (2017). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1212/WNL.0000000000004665",
                                                    "Cortical superficial siderosis multifocality in cerebral amyloid angiopathy. Neurology, 89, 2128–2135.",
                                                    target = "_blank"
                                                  )
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                ### ATROPHY SCALES -------------------------------------------------
                                #### Global Cortical Atrophy Scale (GCA) -------
                                tabPanel(
                                  title = "Global Atrophy",
                                  value = "tab_gca_report",
                                  card(
                                    full_screen = FALSE,  # Only the main content card should be fullscreen
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("gca_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "Global Atrophy"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        # Left column for the form inputs
                                        column(7, 
                                               fluidRow(
                                                 column(4, ""),
                                                 column(4, tags$h5("Right", align = "center")),
                                                 column(4, tags$h5("Left", align = "center"))
                                               ),
                                               tags$h5("Sulci"),
                                               fluidRow(
                                                 column(4, "Frontal"),
                                                 column(4, selectInput("frontal_sulci_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("frontal_sulci_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Parieto-occipital"),
                                                 column(4, selectInput("parietal_sulci_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("parietal_sulci_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Temporal"),
                                                 column(4, selectInput("temporal_sulci_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("temporal_sulci_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               tags$h5("Ventricles"),
                                               fluidRow(
                                                 column(4, "Frontal"),
                                                 column(4, selectInput("frontal_ventricles_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("frontal_ventricles_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Parieto-occipital"),
                                                 column(4, selectInput("parietal_ventricles_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("parietal_ventricles_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Temporal"),
                                                 column(4, selectInput("temporal_ventricles_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("temporal_ventricles_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Third Ventricle"),
                                                 column(4, selectInput("third_ventricle_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, "")
                                               ),
                                               tags$br()
                                        ),
                                        # Right column for the sidebar with image and text (expanded width)
                                        column(5, 
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Global Cortical Atrophy Scale (GCA)")
                                                   ),
                                                   
                                                   tags$img(src = "picture_gca.png", width = "100%", height = "auto"),
                                                   
                                                   tags$p(
                                                     "GCA scale 0: no atrophy; 1: mild atrophy – enlargement of sulci; 2: moderate atrophy – volume loss of gyri; 3: severe atrophy – “knife-blade” atrophy."
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555;",
                                                     
                                                     tags$p(
                                                       "Figure adapted from: Furtner, J. & Prayer, D. (2021). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1007/s10354-021-00825-x",
                                                         "Neuroimaging in dementia. Wien Med Wochenschr, 171, 274–281.",
                                                         target = "_blank"
                                                       ),
                                                       " Licensed under ",
                                                       tags$a(
                                                         href = "http://creativecommons.org/licenses/by/4.0/",
                                                         "CC BY 4.0",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     ),
                                                     
                                                     tags$p(
                                                       "GCA scale adapted from: Pasquier, F. et al. (2008). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1159/000117270",
                                                         "Inter- and Intraobserver Reproducibility of Cerebral Atrophy Assessment on MRI Scans with Hemispheric Infarcts. European Neurology, 36, 268–272.",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                
                                #### MTA -------------
                                tabPanel(
                                  title = "Medial Temporal Atrophy",
                                  value = "tab_mta_report",
                                  card(
                                    full_screen = FALSE,
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",
                                        tags$div(
                                          style = "flex: none; width: 35px;",  
                                          input_switch("mta_switch", label = NULL, value = TRUE)
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;", 
                                          "Medial Temporal Atrophy"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;",
                                      fluidRow(
                                        column(6,
                                               selectInput("mta_right_report", 
                                                           "Right Hemisphere", 
                                                           choices = c(
                                                             "0: no CSF is visible around the hippocampus",
                                                             "1: choroid fissure is slightly widened",
                                                             "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
                                                             "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
                                                             "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost"
                                                           ), width = "90%" ),
                                               selectInput("mta_left_report",
                                                           "Left Hemisphere", 
                                                           choices = c(
                                                             "0: no CSF is visible around the hippocampus",
                                                             "1: choroid fissure is slightly widened",
                                                             "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
                                                             "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
                                                             "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost"
                                                           ), width = "90%" )
                                        ),
                                        column(6,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Medial Temporal Lobe Atrophy Score (MTA)")
                                                   ),
                                                   
                                                   tags$img(src = "picture_mta.png", height = "auto", width = "100%"),
                                                   
                                                   tags$p("Medial Temporal Lobe Atrophy (MTA) score in coronal T1-weighted MRI. The score is based on qualitative evaluation of the widening of the choroid fissure, enlargement of the temporal horn, and atrophy of the hippocampus."),
                                                   
                                                   tags$ul(
                                                     tags$li("0: no CSF is visible around the hippocampus"),
                                                     tags$li("1: choroid fissure is slightly widened"),
                                                     tags$li("2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height"),
                                                     tags$li("3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height"),
                                                     tags$li("4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost")
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555;",
                                                     
                                                     tags$p(
                                                       "Figure adapted from: Håkansson, C. et al. (2022). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1007/s00330-021-08177-1",
                                                         "Inter-modality assessment of medial temporal lobe atrophy in a non-demented population: application of a visual rating scale template across radiologists with varying clinical experience. Eur Radiol, 32, 1127–1134.",
                                                         target = "_blank"
                                                       ),
                                                       " Licensed under ",
                                                       tags$a(
                                                         href = "http://creativecommons.org/licenses/by/4.0/",
                                                         "CC BY 4.0",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     ),
                                                     
                                                     tags$p(
                                                       "MTA scale adapted from: Scheltens, P., Launer, L., Barkhof, F. et al. (1995). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1007/BF00868807",
                                                         "Visual assessment of medial temporal lobe atrophy on magnetic resonance imaging: Interobserver reliability. Journal of Neurology, 242(9), 557–560.",
                                                         target = "_blank"
                                                       )
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                #### ERICA -------------
                                tabPanel(
                                  title = "Entorhinal Atrophy",
                                  value = "tab_erica_report",
                                  card(
                                    full_screen = FALSE,
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",
                                        tags$div(
                                          style = "flex: none; width: 35px;",
                                          input_switch("erica_switch", label = NULL, value = TRUE) # The switch, aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;", 
                                          "Entorhinal Atrophy"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;",
                                      fluidRow(
                                        column(6,
                                               selectInput("erica_right_report", label = "Right Hemisphere", choices = c(
                                                 "0: normal volume of the entorhinal cortex and parahippocampal gyrus",
                                                 "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
                                                 "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
                                                 "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium"
                                               ), width = "90%" ),
                                               selectInput("erica_left_report", label = "Left Hemisphere", choices = c(
                                                 "0: normal volume of the entorhinal cortex and parahippocampal gyrus",
                                                 "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
                                                 "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
                                                 "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium"
                                               ), width = "90%" )
                                        ),
                                        column(6,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Entorhinal Cortical Atrophy Score (ERICA)")
                                                   ),
                                                   
                                                   tags$img(src = "picture_erica1.png", height = "auto", width = "100%"),
                                                   
                                                   tags$p(
                                                     "Orientation: coronal sections aligned to the brainstem with a section thickness of 1 mm."
                                                   ),
                                                   
                                                   tags$ul(
                                                     tags$li("0: normal volume of the entorhinal cortex and parahippocampal gyrus."),
                                                     tags$li("1: mild atrophy with widening of the collateral sulcus."),
                                                     tags$li("2: moderate atrophy with detachment of the entorhinal cortex from the cerebellar tentorium (the 'tentorial cleft sign')."),
                                                     tags$li("3: pronounced atrophy of the parahippocampal gyrus and a wide cleft between entorhinal cortex and the cerebellar tentorium.")
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555;",
                                                     
                                                     tags$p(
                                                       "Figure adapted from: Roberge, X., Brisson, M. & Laforce, R. J. (2023). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1017/cjn.2021.253",
                                                         "Specificity of Entorhinal Atrophy MRI Scale in Predicting Alzheimer’s Disease Conversion. Canadian Journal of Neurological Sciences, 50, 112–114.",
                                                         target = "_blank"
                                                       ),
                                                       " Licensed under ",
                                                       tags$a(
                                                         href = "http://creativecommons.org/licenses/by/4.0/",
                                                         "CC BY 4.0",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     ),
                                                     
                                                     tags$p(
                                                       "Scale adapted from: Enkirch, S. J. et al. (2018). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1148/radiol.2018171888",
                                                         "The ERICA Score: An MR Imaging–based Visual Scoring System for the Assessment of Entorhinal Cortex Atrophy in Alzheimer Disease. Radiology, 288, 226–333.",
                                                         target = "_blank"
                                                       )
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                #### PCA -------------
                                tabPanel(
                                  title = "Posterior Parietal Atrophy",
                                  value = "tab_pca_report",
                                  card(
                                    full_screen = FALSE,  # Only the main content card should be fullscreen
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("pca_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "Posterior Parietal Atrophy"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(6,
                                               selectInput("pca_right_report", "Right Hemisphere", choices = c(
                                                 "0: closed sulci; no gyral atrophy",
                                                 "1: mild sulcal widening; mild gyral atrophy",
                                                 "2: substantial sulcal widening; substantial gyral atrophy",
                                                 "3: marked sulcal widening; knife-blade gyral atrophy"
                                               ), width = "90%" ),
                                               selectInput("pca_left_report", "Left Hemisphere", choices = c(
                                                 "0: closed sulci; no gyral atrophy",
                                                 "1: mild sulcal widening; mild gyral atrophy",
                                                 "2: substantial sulcal widening; substantial gyral atrophy",
                                                 "3: marked sulcal widening; knife-blade gyral atrophy"
                                               ), width = "90%" )
                                        ),
                                        column(6,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   ## Header with icon and title
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Koedam Score")
                                                   ),
                                                   
                                                   ## Image
                                                   tags$img(src = "picture_pca.png", height = "auto", width = "100%"),
                                                   
                                                   ## Single-block description
                                                   tags$div(
                                                     style = "text-align: justify; margin-top: 10px;",
                                                     tags$p(
                                                       "On sagittal images, assess the posterior cingulate sulcus and parieto-occipital sulcus, and check for atrophy of the precuneus. On axial and coronal images, evaluate the widening of the posterior cingulate sulcus and look for sulcal dilatation in the parietal lobes. Atrophy should be rated on a scale from 0 to 3: 0 = no atrophy, 1 = mild, 2 = moderate, and 3 = severe."
                                                     )
                                                   ),
                                                   
                                                   ## Reference footer
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555; margin-top: 15px;",
                                                     tags$p(
                                                       "Adapted from: Koedam, E. L. G. E. et al. (2011). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1007/s00330-011-2205-4",
                                                         "Visual assessment of posterior atrophy: development of a MRI rating scale. European Radiology, 21, 2618–2625.",
                                                         target = "_blank"
                                                       ),
                                                       " Licensed under ",
                                                       tags$a(
                                                         href = "https://creativecommons.org/licenses/by-nc/2.0/",
                                                         "CC BY-NC",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     )
                                                   )
                                                   
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),     
                                
                                ## SUMMARY SVD SCORE ------
                                
                                tabPanel(
                                  title = "Summary of Small Vessel Disease",
                                  value = "tab_ssvds_report",
                                  card(
                                    full_screen = FALSE,
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",
                                        tags$div(
                                          style = "flex: none; width: 35px;",
                                          input_switch("ssvds_switch", label = NULL, value = TRUE)
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",
                                          "Summary of Small Vessel Disease"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;",
                                      fluidRow(
                                        column(5,
                                               tags$div(
                                                 style = "border: 1px solid #ccc; padding: 15px; margin: 10px 0; border-radius: 5px; background-color: #f9f9f9; font-family: Arial, sans-serif; font-size: 16px; line-height: 1.5;",
                                                 tags$p(
                                                   "Overview of small vessel disease score:",
                                                   style = "margin: 0 0 10px 0;"
                                                 ),
                                                 tags$ul(
                                                   tags$li(
                                                     tags$span(
                                                       style = "display: inline;",
                                                       tags$strong("Lacunar Infarcts: "),
                                                       textOutput("lacunarInfarctsScore", inline = TRUE)
                                                     )
                                                   ),
                                                   tags$li(
                                                     tags$span(
                                                       style = "display: inline;",
                                                       tags$strong("Cerebral Microbleeds: "),
                                                       textOutput("cerebralMicrobleedsScore", inline = TRUE)
                                                     )
                                                   ),
                                                   tags$li(
                                                     tags$span(
                                                       style = "display: inline;",
                                                       tags$strong("Perivascular Spaces: "),
                                                       textOutput("perivascularSpacesScore", inline = TRUE)
                                                     )
                                                   ),
                                                   tags$li(
                                                     tags$span(
                                                       style = "display: inline;",
                                                       tags$strong("White Matter Hyperintensities: "),
                                                       textOutput("whiteMatterHyperintensitiesScore", inline = TRUE)
                                                     )
                                                   )
                                                 )
                                               )
                                        ),
                                        column(7,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Small Vessel Disease Score")
                                                   ),
                                                   
                                                   tags$img(
                                                     src = "picture_ssvds.png",
                                                     width = "100%",
                                                     height = "auto"
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "text-align: justify; margin-top: 10px;",
                                                     tags$p(
                                                       "The total MRI burden of small vessel disease is graded from 0 to 4. Assign one point for each of the following:"
                                                     ),
                                                     tags$ul(
                                                       tags$li("Lacunes: presence of ≥1"),
                                                       tags$li("Cerebral microbleeds: any present"),
                                                       tags$li("Perivascular spaces: moderate to severe (grade 2–4) in the basal ganglia"),
                                                       tags$li("White matter hyperintensities (WMH): deep WMH (Fazekas 2–3) or irregular periventricular WMH extending into deep white matter (Fazekas 3)")
                                                     )
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555; margin-top: 15px;",
                                                     tags$p(
                                                       "Adapted from: Staals, J., Makin, S. D. J., Doubal, F. N., Dennis, M. S. & Wardlaw, J. M. (2014). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1212/WNL.0000000000000837",
                                                         "Stroke subtype, vascular risk factors, and total MRI brain small-vessel disease burden. Neurology, 83, 1228–1234.",
                                                         target = "_blank"
                                                       )
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                # ### MOVEMENT SUB NIGRA -------------------------------------------------
                                # tabPanel(
                                #   title = "Substantia Nigra",
                                #   value = "tab_substantia_nigra",
                                #   fluidRow(
                                #     column(6, 
                                #            tags$h5("Loss of T1 signal intensity, area or simmetry"),
                                #            fluidRow(
                                #              column(6, selectInput("t1_hyperintensity_right", "Right", choices = c("yes", "no", "not sure"))),
                                #              column(6, selectInput("t1_hyperintensity_left", "Left", choices = c("yes", "no", "not sure")))
                                #            ),
                                #            tags$h5("Loss of SWI hyperintensity"),
                                #            tags$h6("(loss of 'swallow tail sign')"),
                                #            fluidRow(
                                #              column(6, selectInput("swi_hyperintensity_right", "Right", choices = c("yes", "no", "not sure"))),
                                #              column(6, selectInput("swi_hyperintensity_left", "Left", choices = c("yes", "no", "not sure")))
                                #            )
                                #     ),
                                #     column(6,
                                #            img(src = "picture_mest1swi.png", width = "100%"),
                                #            tags$h6("Normal appearance of the substantia nigra on T1-NM and SWI. It should be evaluated in three consecutive slices."),
                                #            img(src = "picture_t1eg.png", width = "100%"),
                                #            tags$h6(tags$a(href = "https://doi.org/10.3389/fneur.2020.00665", "doi: 10.3389/fneur.2020.00665", target = "_blank")),
                                #            img(src = "picture_swieg.png", width = "100%"),
                                #            tags$h6(tags$a(href = "https://doi.org/10.3389/fneur.2020.00665", "doi: 10.3389/fneur.2020.00665", target = "_blank")),
                                #     )
                                #   )
                                # ),
                                # 
                                # ### MOVEMENT CALCULATOR -------------------------------------------------
                                # tabPanel(
                                #   title = HTML('Movement <i class="fa-solid fa-calculator"></i>'),
                                #   value = "tab_movement_calculator",
                                #   
                                #   page_fluid(
                                #     fluidRow(
                                #       column(6,
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_midbrain_report",
                                #                  "Midbrain surface area (mm²)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 1000,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_area_mes_pon_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_pons",
                                #                  "Pons surface area (mm²)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 1000,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_area_mes_pon_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_scp_report",
                                #                  "Width of superior cerebellar peduncles (mm)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 1000,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_scp_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_mcp_report",
                                #                  "Width of middle cerebellar peduncles (mm)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 1000,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_mcp_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_v3_report",
                                #                  "Width of the third ventricle V3 (mm)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 100,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_v3_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_fh_report",
                                #                  "Width of the frontal horn (mm)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 100,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_fh_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                column(12, 
                                #                       fluidRow(
                                #                         actionButton("calculate_midbrain_pons_ratio_report", "Calculate Midbrain/Pons Ratio"),
                                #                         style = "margin-bottom: 10px;"
                                #                       ),
                                #                       fluidRow(
                                #                         actionButton("calculate_mrpi_1_report", "Calculate MRPI"),
                                #                         style = "margin-bottom: 10px;"
                                #                       ),
                                #                       fluidRow(
                                #                         actionButton("calculate_mrpi_2_report", "Calculate MRPI 2.0")
                                #                       )
                                #                )
                                #              ),
                                #              tags$h4(textOutput("calculation_result_report"))
                                #       ),
                                #       
                                #       
                                #       column(6,
                                #              
                                #              # imageOutput("help_image_report")
                                #              uiOutput("help_image_report")
                                #       )
                                #     )
                                #   )
                                # ),
                                
                                
                                ### GENERATE REPORT-----     
                                tabPanel(
                                  title = "Aurora Report",
                                  value = "tab_report",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: space-between; width: 100%;",
                                        tags$div(
                                          style = "font-weight: 900; font-size: 20px; color: #333;",
                                          "Aurora Report"
                                        ),
                                        tags$div(
                                          style = "margin-left: auto; width: 220px;",
                                          selectInput("lang", label = NULL, 
                                                      choices = c("English", "Português (Portugal)"), 
                                                      selected = "English", 
                                                      width = "100%")
                                        ),
                                        tags$div(
                                          style = "display: inline-block;",
                                          downloadButton(
                                            "downloadData", 
                                            "Export to Excel", 
                                            style = "height: 37px; padding: 6px 12px; font-size: 16px; margin-left: 5px; vertical-align: middle;"
                                          )
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 580px; overflow-y: auto;", 
                                      fluidRow(
                                        column(12,
                                               tags$div(style = "margin-top: 30px; font-size: 16px;",  
                                                        uiOutput("final_report"),
                                                        tags$br()
                                               )
                                        )
                                      )
                                    )
                                  )
                                )
                    ),
                    
                    # Navigation Panel (Buttons + Floating Dropdown)
                    fixedPanel(
                      bottom = 0,
                      left = 0,
                      right = 0,
                      style = "background-color: white; z-index: 1000; position: fixed;",  # Adjust z-index and ensure position is set
                      div(
                        style = "display: flex; justify-content: space-between; align-items: center; padding: 10px;",
                        # Previous Button
                        actionButton("prev_report", "Previous", class = "btn btn-primary"),
                        # Dropdown between buttons
                        div(
                          selectInput("tab_selector", NULL,  # No label for compactness
                                      choices = list(
                                        "Identification" = "tab_identification",
                                        "Recent Small Subcortical Infarcts" = "tab_recent_small_infarcts",
                                        "Lacunes" = "tab_svd_lacunes",
                                        "White Matter Hyperintensities" = "fazekas_chk",
                                        "Perivascular Spaces" = "pvs_chk",
                                        "Microbleeds" = "microbleeds_chk",
                                        "Superficial Siderosis" = "superficial_siderosis_chk",
                                        "Global Atrophy" = "tab_gca_report",
                                        "Medial Temporal Atrophy" = "tab_mta_report",
                                        "Entorhinal Atrophy" = "tab_erica_report",
                                        "Posterior Parietal Atrophy" = "tab_pca_report",
                                        "Summary of Small Vessel Disease" = "tab_ssvds_report",
                                        "Aurora Report" = "tab_report"
                                      ),
                                      selectize = FALSE, width = "300px", 
                          ),
                          style="background-color: white;"  # Ensure div containing selectInput has a white background
                        ),
                        # Next Button
                        actionButton("next_report", "Next", class = "btn btn-primary")
                      )
                    )
  ),
  
  ## Atrophy Calculator -----
  
  nav_panel_hidden(
    "Atrophy Calculator",
    
    navset_pill_list(
      
      #### GCA -------------
      nav_panel(
        title = "Global Atrophy Scale (GCA)",
        value = "tab_gca_singlecalc",
        page_fluid(
          fluidRow(
            column(6,
                   fluidRow(
                     column(4, ""),
                     column(4, tags$h5("Right", align = "center")),
                     column(4, tags$h5("Left", align = "center"))
                   ),
                   tags$h5("Sulci"),
                   fluidRow(
                     column(4, "Frontal"),
                     column(4, selectInput("frontal_sulci_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("frontal_sulci_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Parieto-occipital"),
                     column(4, selectInput("parietal_sulci_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("parietal_sulci_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Temporal"),
                     column(4, selectInput("temporal_sulci_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("temporal_sulci_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   tags$h5("Ventricles"),
                   fluidRow(
                     column(4, "Frontal"),
                     column(4, selectInput("frontal_ventricles_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("frontal_ventricles_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Parieto-occipital"),
                     column(4, selectInput("parietal_ventricles_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("parietal_ventricles_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Temporal"),
                     column(4, selectInput("temporal_ventricles_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("temporal_ventricles_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Third Ventricle"),
                     column(4, selectInput("third_ventricle_singlecalc", "", choices = c(0, 1, 2, 3))),
                     column(4, "")
                   ),
                   actionButton("calculate_gca_singlecalc", "Calculate"),
                   textOutput("gca_score_singlecalc"),
                   tags$br()
            ),
            column(6,
                   img(src = "picture_gca.png", width = "100%"),
                   tags$div(style = "text-align: justify;",
                            tags$h6("GCA scale 0: no atrophy; 1: mild atrophy: enlargement of sulci; 2: moderate atrophy: volume loss of gyri; 3: severe atrophy: “knife blade” atrophy.")
                   ),
                   tags$h6(
                     "Figure adapted from: Furtner, J. & Prayer, D. (2021). ",
                     tags$a(href = "https://doi.org/10.1007/s10354-021-00825-x", "Neuroimaging in dementia. Wien Med Wochenschr, 171, 274–281.", target = "_blank"),
                     " Licensed under ",
                     tags$a(href = "http://creativecommons.org/licenses/by/4.0/", "CC BY 4.0", target = "_blank"),
                     "."
                   ),
                   tags$h6(
                     "GCA scale adapted from: Pasquier, F. et al. (2008). ",
                     tags$a(href = "https://doi.org/10.1159/000117270", "Inter- and Intraobserver Reproducibility of Cerebral Atrophy Assessment on MRI Scans with Hemispheric Infarcts. European Neurology, 36, 268–272.", target = "_blank")
                   )
            )
          )
        )
      ),
      #### MTA -------------
      nav_panel(
        title = "Medial Temporal Lobe Atrophy Score (MTA)",
        value = "tab_mta_calc",
        page_fluid(
          fluidRow(
            column(6,
                   selectInput("mta_right_calc", 
                               "Right hemisphere", 
                               choices = c(
                                 "0: no CSF is visible around the hippocampus",
                                 "1: choroid fissure is slightly widened",
                                 "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
                                 "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
                                 "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost"
                               ),
                               width = "500px"),
                   selectInput("mta_left_calc",
                               "Left hemisphere", 
                               choices = c(
                                 "0: no CSF is visible around the hippocampus",
                                 "1: choroid fissure is slightly widened",
                                 "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
                                 "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
                                 "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost"
                               ),
                               width = "500px"),
                   actionButton("calculate_mta_calc", "Calculate"),
                   uiOutput("mta_result_output_calc")
            ),
            column(6,
                   img(src = "picture_mta.png", width = "100%"),
                   tags$div(style = "text-align: justify;",
                            tags$h6("Medial Temporal Lobe Atrophy (MTA) score in coronal T1w MRI. 
                             The score is based on qualitative evaluation of the widening of the choroid fissure, enlargement of the temporal horn and atrophy of the hippocampus.
                             Ranges from 0 (no atrophy) to 4 (severe atrophy).")),
                   tags$h6(
                     "Figure adapted from: Håkansson, C. et al. (2022). ",
                     tags$a(href = "https://doi.org/10.1007/s00330-021-08177-1", "Inter-modality assessment of medial temporal lobe atrophy in a non-demented population: application of a visual rating scale template across radiologists with varying clinical experience. Eur Radiol, 32, 1127–1134.", target = "_blank"),
                     " Licensed under ",
                     tags$a(href = "http://creativecommons.org/licenses/by/4.0/", "CC BY 4.0", target = "_blank"),
                     "."
                   ),
                   tags$h6(
                     "MTA scale adapted from: Scheltens, P., Launer, L., Barkhof, F. et al. (1995). ",
                     tags$a(href = "https://doi.org/10.1007/BF00868807", "Visual assessment of medial temporal lobe atrophy on magnetic resonance imaging: Interobserver reliability. Journal of Neurology, 242(9), 557–560.", target = "_blank")
                   )
            )
          )
        )
      ),
      
      #### ERICA -------------
      erica_calc_ui <- nav_panel(
        title = "Entorhinal Cortical Atrophy Score (ERICA)",
        value = "tab_erica_singlecalc",
        page_fluid(
          fluidRow(
            column(6,
                   selectInput("erica_right_singlecalc", "Right hemisphere", choices = c(
                     "0: normal volume of the entorhinal cortex and parahippocampal gyrus",
                     "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
                     "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
                     "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium"
                   )),
                   selectInput("erica_left_singlecalc", "Left hemisphere", choices = c(
                     "0: normal volume of the entorhinal cortex and parahippocampal gyrus",
                     "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
                     "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
                     "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium"
                   )),
                   actionButton("calculate_erica", "Calculate"),
                   uiOutput("erica_result_output")  
            ),
            column(6,
                   img(src = "picture_erica1.png", width = "100%"),
                   tags$div(style = "text-align: justify", 
                            tags$h6("Orientation: coronal sections aligned to the brainstem with a section thickness of 1 mm."),
                            tags$h6("0: normal volume of the entorhinal cortex and parahippocampal gyrus."),
                            tags$h6("1: mild atrophy with widening of the collateral sulcus."),
                            tags$h6("2: moderate atrophy with detachment of the entorhinal cortex from the cerebellar tentorium (the 'tentorial cleft sign')."),
                            tags$h6("3: pronounced atrophy of the parahippocampal gyrus and a wide cleft between entorhinal cortex and the cerebellar tentorium."),
                   ),
                   tags$h6(
                     "Figure adapted from: Roberge, X., Brisson, M. & Laforce, R. J. (2023). ",
                     tags$a(href = "https://doi.org/10.1017/cjn.2021.253", "Specificity of Entorhinal Atrophy MRI Scale in Predicting Alzheimer’s Disease Conversion. Canadian Journal of Neurological Sciences, 50, 112–114.", target = "_blank"),
                     " Licensed under ",
                     tags$a(href = "http://creativecommons.org/licenses/by/4.0/", "CC BY 4.0", target = "_blank"),
                     "."
                   ),
                   tags$h6(
                     "Scale adapted from: Enkirch, S. J. et al. (2018). ",
                     tags$a(href = "https://doi.org/10.1148/radiol.2018171888", "The ERICA Score: An MR Imaging–based Visual Scoring System for the Assessment of Entorhinal Cortex Atrophy in Alzheimer Disease. Radiology, 288, 226–333.", target = "_blank")
                   )
            )
          )
        )
      ),
      
      #### PCA -------------
      nav_panel(
        title = "Posterior parietal atrophy (Koedam) score",
        value = "tab_pca_singlecalc",
        page_fluid(
          fluidRow(
            column(6,
                   selectInput("pca_right_singlecalc", "Right hemisphere", choices = c(
                     "0: closed sulci; no gyral atrophy",
                     "1: mild sulcal widening; mild gyral atrophy",
                     "2: substantial sulcal widening; substantial gyral atrophy",
                     "3: marked sulcal widening; knife-blade gyral atrophy"
                   )),
                   selectInput("pca_left_singlecalc", "Left hemisphere", choices = c(
                     "0: closed sulci; no gyral atrophy",
                     "1: mild sulcal widening; mild gyral atrophy",
                     "2: substantial sulcal widening; substantial gyral atrophy",
                     "3: marked sulcal widening; knife-blade gyral atrophy"
                   )),
                   actionButton("pca_calculate", "Calculate"),
                   uiOutput("pca_result_output")  
            ),
            column(6,
                   img(src = "picture_pca.png", width = "100%"),
                   tags$div(style = "text-align: justify", 
                            tags$h6("Sagittal: evaluate the widening of the posterior cingulate sulcus and parieto-occipital sulcus, and assess atrophy of the precuneus."),
                            tags$h6("Axial: evaluate the widening of the posterior cingulate sulcus and sulcal dilatation in the parietal lobes."),
                            tags$h6("Coronal: evaluate the widening of the posterior cingulate sulcus and sulcal dilatation in the parietal lobes."),
                            tags$h6("Rating: 0 = no atrophy, 1 = mild atrophy, 2 = moderate atrophy, 3 = severe atrophy.")
                   ),
                   tags$h6(
                     "Adapted from: Koedam, E. L. G. E. et al. (2011). ",
                     tags$a(href = "https://doi.org/10.1007/s00330-011-2205-4", "Visual assessment of posterior atrophy: development of a MRI rating scale. European Radiology, 21, 2618–2625.", target = "_blank"),
                     " Licensed under ",
                     tags$a(href = "https://creativecommons.org/licenses/by-nc/2.0/", "CC BY-NC", target = "_blank"),
                     "."
                   )
            )
          )
        )
      ),
      widths = c(2, 10)
    )
    
    
  ),
  
  ## Movement Calculator -----   
  
  nav_panel_hidden(
    "Movement Calculator",
    
    page_fluid(
      fluidRow(
        column(6,
               fluidRow(
                 numericInput(
                   "input_midbrain_singlecalc",
                   "Midbrain surface area (mm²)",
                   value = 0,
                   min = 0,
                   max = 1000,
                   step = 0.1
                 ),
                 actionButton("show_image_area_mes_pon_singlecalc", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
               ),
               
               
               fluidRow(
                 numericInput(
                   "input_pons",
                   "Pons surface area (mm²)",
                   value = 0,
                   min = 0,
                   max = 1000,
                   step = 0.1
                 ),
                 actionButton("show_image_area_mes_pon_singlecalc", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
               ),
               
               fluidRow(
                 numericInput(
                   "input_scp_singlecalc",
                   "Width of superior cerebellar peduncles (mm)",
                   value = 0,
                   min = 0,
                   max = 1000,
                   step = 0.1
                 ),
                 actionButton("show_image_scp_singlecalc", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
               ),
               
               fluidRow(
                 numericInput(
                   "input_mcp_singlecalc",
                   "Width of middle cerebellar peduncles (mm)",
                   value = 0,
                   min = 0,
                   max = 1000,
                   step = 0.1
                 ),
                 actionButton("show_image_mcp_singlecalc", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
               ),
               
               fluidRow(
                 numericInput(
                   "input_v3_singlecalc",
                   "Width of the third ventricle V3 (mm)",
                   value = 0,
                   min = 0,
                   max = 100,
                   step = 0.1
                 ),
                 actionButton("show_image_v3_singlecalc", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
               ),
               
               fluidRow(
                 numericInput(
                   "input_fh_singlecalc",
                   "Width of the frontal horn (mm)",
                   value = 0,
                   min = 0,
                   max = 100,
                   step = 0.1
                 ),
                 actionButton("show_image_fh_singlecalc", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
               ),
               
               fluidRow(
                 column(12, 
                        fluidRow(
                          actionButton("calculate_midbrain_pons_ratio_singlecalc", "Calculate Midbrain/Pons Ratio"),
                          style = "margin-bottom: 10px;"
                        ),
                        fluidRow(
                          actionButton("calculate_mrpi_1_singlecalc", "Calculate MRPI"),
                          style = "margin-bottom: 10px;"
                        ),
                        fluidRow(
                          actionButton("calculate_mrpi_2_singlecalc", "Calculate MRPI 2.0")
                        )
                 )
               ),
               tags$h4(textOutput("calculation_result_singlecalc"))
        ),
        
        
        column(6,
               
               # imageOutput("help_image_singlecalc")
               uiOutput("help_image_singlecalc")
        )
      )
    )
    
    
  ),
  
  nav_spacer(), # push nav items to the right
  
  
  ## Help ------- 
  
  nav_panel(
    "Help",
    
    tags$head(tags$style(HTML("
    p, ul, li {
      font-family: Helvetica, sans-serif;
      text-align: justify;
    }
    h4, h5 {
      font-family: Helvetica, sans-serif;
    }
    .license {
      font-size: 12px;
      margin-top: 30px;
      font-family: Helvetica, sans-serif;
      text-align: center;
      color: #555;
    }
  "))),
    
    HTML("
    <h4>Frequently Asked Questions (FAQ)</h4>
    
    <p><strong>Can I use Aurora on my phone or tablet?</strong><br />
    Aurora is optimized for desktop browsers. Mobile and tablet support is limited. For the best experience, use recent versions of Chrome, Firefox, or Edge on a desktop or laptop.</p>
    
    <p><strong>Which languages are available?</strong><br />
    The user interface is available in English (US). Generated reports can be exported in English (US) or Portuguese (PT).</p>
    
    <p><strong>What is the Aurora Report?</strong><br />
    The Aurora Report guides you through sections like infarcts, lacunes, and atrophy scores. Each section includes instructions and example images. Aurora follows STRIVE-2 recommendations for small vessel disease reporting. You can optionally enter age and sex for automatic interpretation of the Medial Temporal Atrophy (MTA) scale.</p>
    
    <p><strong>Which calculators are available?</strong><br />
    Atrophy calculators: Global Cortical Atrophy (GCA), Medial Temporal Atrophy (MTA), Entorhinal Cortex Atrophy (ERICA), and Posterior/Parietal Atrophy (Koedam scale). Movement disorder calculators: Morphometric measurements of midbrain, pons, cerebral peduncle, and ventricles, with visual guides for correct technique. Calculators can be used individually, without completing all report steps.</p>
    
    <p><strong>Can I export my data from Aurora?</strong><br />
    Yes. You can export all entered data using the Excel export button in the Aurora Report section, for research, audit, or documentation purposes.</p>
    
    <p><strong>Where can I find references and further reading?</strong><br />
    Most sections and scales in Aurora include direct links to validation studies and clinical guidelines.</p>
    
    <p><strong>Are the scales and calculators validated?</strong><br />
    Yes. All calculators and reporting tools are based on published, peer-reviewed scales with references provided in the app.</p>
    
    <p><strong></strong><br />
    
    <h4>Feedback</h4>
    <p>Your feedback is important to us. Help improve Aurora by emailing your suggestions or comments to: <a href='mailto:aurora.shinyapps@gmail.com'>aurora.shinyapps@gmail.com</a>.</p>
    
    <div class='license'>
      Aurora © 2024 is licensed under 
      <a href='https://creativecommons.org/licenses/by-nc-sa/4.0/' target='_blank'>
        Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
      </a>.
    </div>
  ")
  ),
  
  ## About ----- 
  
  nav_panel(
    "About",
    
    tags$head(tags$style(HTML("
    p {
      font-family: Helvetica, sans-serif;
      text-align: justify;
    }
    h4, h5 {
      font-family: Helvetica, sans-serif;
    }
    .license {
      font-size: 12px;
      margin-top: 30px;
      font-family: Helvetica, sans-serif;
      text-align: center;
      color: #555;
    }
  "))),
    
    HTML("
    <p>Aurora is a free web-based open-access application developed using R software. It is designed to assist neuroradiologists reporting. Aurora will help you with consulting, inputting results, and calculating scales and scores in dementia and movement disorders. It provides checklists for systematic structured reporting and includes visual guides and references.</p>
    
    <p><strong>Alexandra Rodrigues, MD</strong><br />
    <em>Neuroradiology resident, web development, scientific research</em><br />
    Neuroradiology department, Hospital de São José, Unidade Local de Saúde São José, Lisboa, Portugal<br />
    Neuroradiology Unit, Hospital Central do Funchal, Funchal, Portugal - SESARAM<br />
    NOVA Medical School, Universidade Nova de Lisboa, Lisbon, Portugal</p>

    <p><strong>Gonçalo Gama Lobo, MD</strong><br />
    <em>Neuroradiologist, scientific consultant</em><br />
    Neuroradiology department, Hospital de São José, Unidade Local de Saúde São José, Lisboa, Portugal<br />
    NOVA Medical School, Universidade Nova de Lisboa, Lisbon, Portugal</p>

    <p><strong>Tiago Machado, MD</strong><br />
    <em>Clinical pharmacologist, web development consultant</em><br />
    Laboratory of Clinical Pharmacology and Therapeutics, Faculdade de Medicina, Universidade de Lisboa, Lisbon, Portugal</p>

    <p><strong>Daniela Jardim Pereira, MD, PhD</strong><br />
    <em>Neuroradiologist, scientific consultant</em><br />
    Neurorradiology Functional Unit, Imaging Department, Unidade Local de Saúde de Coimbra, Coimbra, Portugal<br />
    Faculty of Medicine, University of Coimbra, Coimbra, Portugal<br />
    Coimbra Institute for Biomedical Imaging and Translational Research (CIBIT), University of Coimbra, Coimbra, Portugal</p>

    <div class='license'>
      Aurora © 2024 is licensed under 
      <a href='https://creativecommons.org/licenses/by-nc-sa/4.0/' target='_blank'>
        Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
      </a>.
    </div>
  ")
  )
  
  
  # nav_item(
  #   input_dark_mode(id = "dark_mode", mode = "light")
  # )
  
)
# Define server 
server <- function(input, output, session) {
  
  
  ## Home buttons -----
  # observe the action button that jumps to report tab
  observeEvent(input$report, {
    
    nav_select(
      id = "tabs",
      selected = "Report")
    
  })
  
  # observe the action button that jumps to atrophy calculator tab
  observeEvent(input$atrophy_calculator, {
    
    nav_select(
      id = "tabs",
      selected = "Atrophy Calculator")
    
  })
  
  # observe the action button that jumps to movement calculator tab
  observeEvent(input$movement_calculator, {
    
    nav_select(
      id = "tabs",
      selected = "Movement Calculator")
    
  })
  
  ## Reactive values --------------------------
  
  image_movement <- reactiveVal(NULL)
  
  reportData <- reactiveValues()
  
  ## Atrophy calculator ----------------------
  ### Calculate GCA Score in single calculator -----------------------------
  
  observeEvent(input$calculate_gca_singlecalc, {
    
    # Reactive expression to calculate GCA score and generate interpretation for Single Calculator
    gca_interpretation_singlecalc <- reactive({
      sulci_values_singlecalc <- c(
        as.numeric(input$frontal_sulci_right_singlecalc),
        as.numeric(input$frontal_sulci_left_singlecalc),
        as.numeric(input$parietal_sulci_right_singlecalc),
        as.numeric(input$parietal_sulci_left_singlecalc),
        as.numeric(input$temporal_sulci_right_singlecalc),
        as.numeric(input$temporal_sulci_left_singlecalc)
      )
      
      ventricles_values_singlecalc <- c(
        as.numeric(input$frontal_ventricles_right_singlecalc),
        as.numeric(input$frontal_ventricles_left_singlecalc),
        as.numeric(input$parietal_ventricles_right_singlecalc),
        as.numeric(input$parietal_ventricles_left_singlecalc),
        as.numeric(input$temporal_ventricles_right_singlecalc),
        as.numeric(input$temporal_ventricles_left_singlecalc),
        as.numeric(input$third_ventricle_singlecalc)
      )
      
      gca_score_singlecalc <- sum(sulci_values_singlecalc, ventricles_values_singlecalc, na.rm = TRUE)
      
      format_value_summary <- function(name, right_value, left_value) {
        parts <- c()
        if (right_value > 0) parts <- c(parts, paste("right:", right_value))
        if (left_value > 0) parts <- c(parts, paste("left:", left_value))
        if (length(parts) > 0) return(paste(name, " (", paste(parts, collapse = "; "), ")", sep = ""))
        else return(NULL)
      }
      
      sulci_summary_singlecalc <- c(
        format_value_summary("frontal", sulci_values_singlecalc[1], sulci_values_singlecalc[2]),
        format_value_summary("parieto-occipital", sulci_values_singlecalc[3], sulci_values_singlecalc[4]),
        format_value_summary("temporal", sulci_values_singlecalc[5], sulci_values_singlecalc[6])
      )
      
      ventricles_summary_singlecalc <- c(
        format_value_summary("frontal", ventricles_values_singlecalc[1], ventricles_values_singlecalc[2]),
        format_value_summary("parieto-occipital", ventricles_values_singlecalc[3], ventricles_values_singlecalc[4]),
        format_value_summary("temporal", ventricles_values_singlecalc[5], ventricles_values_singlecalc[6])
      )
      
      if (ventricles_values_singlecalc[7] > 0) {
        ventricles_summary_singlecalc <- c(ventricles_summary_singlecalc, paste("third ventricle:", ventricles_values_singlecalc[7]))
      }
      
      sulci_summary_singlecalc <- paste(na.omit(sulci_summary_singlecalc), collapse = ", ")
      ventricles_summary_singlecalc <- paste(na.omit(ventricles_summary_singlecalc), collapse = ", ")
      
      summary_text_singlecalc <- paste0(
        "Global cortical atrophy (GCA) score = ", gca_score_singlecalc, ". ",
        ifelse(sulci_summary_singlecalc != "", paste0("Sulci: ", sulci_summary_singlecalc, ". "), ""),
        ifelse(ventricles_summary_singlecalc != "", paste0("Ventricles: ", ventricles_summary_singlecalc, "."), "")
      )
      
      return(summary_text_singlecalc)
    })
    
    output$gca_score_singlecalc <- renderText({
      gca_interpretation_singlecalc()
    })
  })
  
  ### Calculate MTA score for Single Calculator --------------------
  
  observeEvent(input$calculate_mta_calc, {
    
    # Parse input values and convert to numeric values
    mta_right <- as.numeric(substr(input$mta_right_calc, 1, 1))
    mta_left <- as.numeric(substr(input$mta_left_calc, 1, 1))
    
    # Check if the conversion to numeric resulted in NAs
    if (is.na(mta_right) | is.na(mta_left)) {
      print("Could not convert inputs to numeric.")
      return()
    }
    
    # Initialize result variable
    result_text <- ""
    
    if (mta_right == mta_left) {
      result_text <- paste("Medial temporal atrophy (MTA) score =", mta_right, "bilaterally.")
    } else {
      greater_side <- ifelse(mta_right > mta_left, "right", "left")
      lesser_side <- ifelse(mta_right > mta_left, "left", "right")
      
      result_text <- paste("Medial temporal atrophy (MTA) score =", max(mta_right, mta_left), 
                           "on the", greater_side, "and", min(mta_right, mta_left), 
                           "on the", lesser_side, "side.")
    }
    
    # Render result and MTA guidelines only after button is clicked
    output$mta_result_output_calc <- renderUI({
      tagList(
        # Display MTA result
        h6(result_text),
        
        # Adding Paragraph
        p(""),
        
        # Display MTA guideline
        tags$h6("MTA interpretation:"),
        tags$ul(
          tags$li("<75 years: ≥2 suggests abnormal findings"),
          tags$li("≥75 years: ≥3 suggests abnormal findings")
        )
      )
    })
  })
  
  ### Calculate ERICA -----------
  
  observeEvent(input$calculate_erica, {
    erica_left <- as.numeric(substr(input$erica_left_singlecalc, 1, 1))
    erica_right <- as.numeric(substr(input$erica_right_singlecalc, 1, 1))
    # Initialize result_text variable
    result_text <- ""
    
    # Check if scores are equal
    if (erica_right == erica_left) {
      result_text <- paste("Entorhinal cortical atrophy (ERICA) score =", erica_left, "bilaterally.")
    } else {
      # Determine the side with the greater score and the side with the lesser score
      greater_side <- ifelse(erica_right > erica_left, "right", "left")
      lesser_side <- ifelse(erica_right > erica_left, "left", "right")
      greater_score <- max(erica_left, erica_right)
      lesser_score <- min(erica_left, erica_right)
      
      # Construct the result text with the greater side first
      result_text <- paste("Entorhinal cortical atrophy (ERICA) score =", greater_score, "on the", greater_side, 
                           "and", lesser_score, "on the", lesser_side, "side.")
    }
    output$erica_result_output <- renderUI({
      tagList(
        h6(result_text),
        p(""),
        tags$h6("ERICA interpretation:"),
        tags$ul(
          tags$li("≥2 suggests abnormal findings")
        )
      )
    })
  })
  
  ### Calculate PCA ---------------
  
  observeEvent(input$pca_calculate, {
    pca_left <- as.numeric(substr(input$pca_left_singlecalc, 1, 1))
    pca_right <- as.numeric(substr(input$pca_right_singlecalc, 1, 1))
    
    # Initialize result_text variable
    result_text <- ""
    
    # Check if scores are equal
    if (pca_right == pca_left) {
      result_text <- paste("Posterior parietal atrophy (Koedam) score =", pca_left, "bilaterally.")
    } else {
      # Determine the side with the greater score and the side with the lesser score
      greater_side <- ifelse(pca_right > pca_left, "right", "left")
      lesser_side <- ifelse(pca_right < pca_left, "right", "left")
      greater_score <- max(pca_left, pca_right)
      lesser_score <- min(pca_left, pca_right)
      
      # Construct the result text with the greater side first
      result_text <- paste("Posterior parietal atrophy (Koedam) score =", greater_score, "on the", 
                           greater_side, "and", lesser_score, "on the", lesser_side, "side.")
    }
    output$pca_result_output <- renderUI({
      tagList(
        h6(result_text)
      )
    })
  })
  
  
  ## Movement calculator single server --------------------
  
  # output$help_image_singlecalc <- renderUI({
  #   tags$img(src = 'area_mes_pon.png', alt = "area_mes_pon", width = "100%")
  # })
  
  observeEvent(input$show_image_area_mes_pon_singlecalc, {
    image_movement("area_mes_pon.png")
  })
  
  observeEvent(input$show_image_scp_singlecalc, {
    image_movement("picture_scp.png")
  })
  
  observeEvent(input$show_image_mcp_singlecalc, {
    image_movement("picture_mcp.png")
  })
  
  observeEvent(input$show_image_v3_singlecalc, {
    image_movement("picture_3v.png")
  })
  
  observeEvent(input$show_image_fh_singlecalc, {
    image_movement("picture_fh.png")
  })
  
  output$help_image_singlecalc <- renderUI({
    req(image_movement()) 
    tags$img(src = image_movement(), alt = "Dynamic Image", width = "100%")
  })
  
  
  observeEvent(input$calculate_midbrain_pons_ratio_singlecalc, {
    output$calculation_result_singlecalc <- renderText({
      req(input$input_midbrain_singlecalc, input$input_pons)
      ratio <- input$input_midbrain_singlecalc / input$input_pons
      if (is.na(ratio) || !is.finite(ratio)) {
        "Invalid output"
      } else {
        paste("Midbrain/Pons Ratio is", round(ratio, 2))
      }
    })
  })
  
  observeEvent(input$calculate_mrpi_1_singlecalc, {
    output$calculation_result_singlecalc <- renderText({
      req(input$input_midbrain_singlecalc, input$input_pons, input$input_scp_singlecalc, input$input_mcp_singlecalc)
      mrpi <- (input$input_pons / input$input_midbrain_singlecalc) * (input$input_mcp_singlecalc / input$input_scp_singlecalc)
      if (is.na(mrpi) || !is.finite(mrpi)) {
        "Invalid output"
      } else {
        paste("MRPI is", round(mrpi, 2))
      }
    })
  })
  
  observeEvent(input$calculate_mrpi_2_singlecalc, {
    output$calculation_result_singlecalc <- renderText({
      req(input$input_midbrain_singlecalc, input$input_pons, input$input_scp_singlecalc, input$input_mcp_singlecalc, input$input_v3_singlecalc, input$input_fh_singlecalc)
      mrpi2 <- (input$input_pons / input$input_midbrain_singlecalc) * (input$input_mcp_singlecalc / input$input_scp_singlecalc) * (input$input_v3_singlecalc / input$input_fh_singlecalc)
      if (is.na(mrpi2) || !is.finite(mrpi2)) {
        "Invalid output"
      } else {
        paste("MRPI 2.0 is", round(mrpi2, 2))
      }
    })
  })
  
  
  ## Report buttons -------------------
  
  # Dropdown selection -> Switch tab
  observeEvent(input$tab_selector, {
    updateTabsetPanel(session, "tabs_report", selected = input$tab_selector)
  })
  
  observeEvent(input$prev_report, {
    current_tab <- input$tabs_report  # Update to tabs_report
    tab_names <- c("tab_identification", "tab_recent_small_infarcts", "tab_svd_lacunes", "fazekas_chk", 
                   "pvs_chk", "microbleeds_chk", "superficial_siderosis_chk", "tab_gca_report", 
                   "tab_mta_report", "tab_erica_report", "tab_pca_report", "tab_ssvds_report", "tab_report")
    
    current_index <- match(current_tab, tab_names)
    
    if (current_index > 1) {
      new_tab <- tab_names[current_index - 1]
      updateTabsetPanel(session, "tabs_report", selected = new_tab)  # Update to tabs_report
    }
  })
  
  observeEvent(input$next_report, {
    current_tab <- input$tabs_report  # Update to tabs_report
    tab_names <- c("tab_identification", "tab_recent_small_infarcts", "tab_svd_lacunes", "fazekas_chk", 
                   "pvs_chk", "microbleeds_chk", "superficial_siderosis_chk", "tab_gca_report", 
                   "tab_mta_report", "tab_erica_report", "tab_pca_report", "tab_ssvds_report", "tab_report")
    
    current_index <- match(current_tab, tab_names)
    
    if (current_index < length(tab_names)) {
      new_tab <- tab_names[current_index + 1]
      updateTabsetPanel(session, "tabs_report", selected = new_tab)  # Update to tabs_report
    }
  })
  
  # JavaScript for keyboard shortcuts (Left and Right Arrow keys)
  runjs('
    $(document).keydown(function(e) {
      if (e.keyCode == 37) {  // Left arrow
        $("#prev_report").click();
      }
      if (e.keyCode == 39) {  // Right arrow
        $("#next_report").click();
      }
    });
  ')
  
  
  ## Fazekas ---------
  
  fazekas_report_text <- reactive({
    if (!input$fazekas_switch) {
      return("")
    }
    
    # Extract selected values
    periventricular_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$periventricular_grade))
    deep_white_matter_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$deep_white_matter_grade))
    
    # Check if both are 0
    if (periventricular_grade == 0 && deep_white_matter_grade == 0) {
      return("No significant T2-FLAIR hyperintensities of presumed vascular origin identified. Fazekas = 0.")
    }
    
    # Determine the severity
    severity_levels <- c("mild", "moderate", "severe")
    fazekas_value <- max(periventricular_grade, deep_white_matter_grade, na.rm = TRUE)
    
    # Initialize the report text
    report_text <- "T2-FLAIR hypersignal of presumed vascular origin:"
    regions_text <- c()
    
    if (periventricular_grade > 0) {
      severity <- severity_levels[periventricular_grade]
      laterality <- input$periventricular_laterality
      distribution <- input$periventricular_distribution
      distribution_text <- ifelse(distribution == "diffuse", "", distribution)
      laterality_text <- ifelse(laterality == "bilateral", "bilaterally", paste("at", laterality))
      periventricular_text <- paste(severity, "in the periventricular", distribution_text, "white matter", laterality_text)
      periventricular_text <- gsub("\\s+", " ", periventricular_text) # Clean extra spaces
      regions_text <- c(regions_text, periventricular_text)
    }
    
    if (deep_white_matter_grade > 0) {
      severity <- severity_levels[deep_white_matter_grade]
      laterality <- input$deep_white_matter_laterality
      distribution <- input$deep_white_matter_distribution
      if (distribution %in% c("corona radiata", "centrum semiovale")) {
        if (laterality == "bilateral") {
          distribution_text <- paste("in the", distribution, "bilaterally")
        } else {
          distribution_text <- paste("in the", laterality, distribution)
        }
      } else {
        laterality_text <- ifelse(laterality == "bilateral", "bilaterally", paste("at", laterality))
        distribution_text <- paste("in the deep white matter", laterality_text)
      }
      deep_text <- paste(severity, distribution_text)
      deep_text <- gsub("\\s+", " ", deep_text) # Clean extra spaces
      regions_text <- c(regions_text, deep_text)
    }
    
    report_text <- paste(report_text, paste(regions_text, collapse = " and "), ". Fazekas =", fazekas_value, ".", sep = " ")
    report_text <- gsub("\\s+\\.", ".", report_text) # Remove space before the period
    
    return(trimws(report_text))
  })
  
  
  ## Recent subcortical infarcts --------
  
  rsi_report_text <- reactive({
    if (input$rsi_switch && !is.null(input$recentsmallinfarct) && length(input$recentsmallinfarct) > 0) {
      
      format_selected_region <- function(region_string) {
        elements <- unlist(strsplit(region_string, " - "))
        structure <- tolower(elements[1])
        
        if (region_string %in% c("Midbrain - Tegmentum - Right", 
                                 "Midbrain - Tegmentum - Midline", 
                                 "Midbrain - Tegmentum - Left", 
                                 "Midbrain - Tectum - Right", 
                                 "Midbrain - Tectum - Midline", 
                                 "Midbrain - Tectum - Left", 
                                 "Pons - Basis - Right", 
                                 "Pons - Basis - Midline", 
                                 "Pons - Basis - Left", 
                                 "Pons - Tegmentum - Right", 
                                 "Pons - Tegmentum - Midline", 
                                 "Pons - Tegmentum - Left")) {
          # TYPE 2
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, "of the", structure, "at", side)
        } else if (region_string %in% c("Medulla - Anterior - Right", 
                                        "Medulla - Anterior - Left", 
                                        "Medulla - Posterior - Right", 
                                        "Medulla - Posterior - Left")) {
          # TYPE 3
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, structure, "at", side)
        } else if (region_string %in% c("Internal capsule - Anterior limb - Right", 
                                        "Internal capsule - Anterior limb - Left", 
                                        "Internal capsule - Genu - Right", 
                                        "Internal capsule - Genu - Left", 
                                        "Internal capsule - Posterior limb - Right", 
                                        "Internal capsule - Posterior limb - Left")) {
          # TYPE 4
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, "of the", side, structure)
        } else if (region_string %in% c("Midbrain - Crus cerebri - Right", 
                                        "Midbrain - Crus cerebri - Left")) {
          # TYPE 5
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(side, topography, "of the", structure)
        } else if (region_string %in% c("Cerebellum - Right", "Cerebellum - Left")) {
          # TYPE 6 (Cerebellum handling)
          side <- tolower(gsub(" hemisphere", "", elements[2]))
          paste(structure, "at", side)
        } else {
          # TYPE 1 (Default)
          if (length(elements) == 3) {
            side <- tolower(elements[3])
            topo <- tolower(elements[2])
            paste(side, topo, structure)
          } else if (length(elements) == 2) {
            side <- tolower(elements[2])
            paste(side, structure)
          } else {
            tolower(structure)
          }
        }
      }
      
      formatted_regions <- sapply(input$recentsmallinfarct, format_selected_region)
      
      n_regions <- length(formatted_regions)
      
      if (n_regions > 1) {
        region_phrase <- paste(formatted_regions, collapse = ", ")
        separator <- ifelse(n_regions > 2, ", ", " ")
        region_phrase <- gsub(", (?!.*,)", paste(separator, "and "), region_phrase, perl = TRUE)
        final_text <- paste0("Recent small subcortical infarcts in the ", region_phrase, ".")
      } else {
        final_text <- paste0("Recent small subcortical infarct in the ", formatted_regions, ".")
      }
      
      final_text <- paste0(toupper(substr(final_text, 1, 1)), substr(final_text, 2, nchar(final_text)))
      
      return(final_text)
      
    } else {
      return("No recent small subcortical infarcts identified.") # Empty return when off or no selection
    }
  })
  
  ## Lacunar infarcts ------
  
  li_report_text <- reactive({
    if (input$li_switch && !is.null(input$lacunar_infarcts) && length(input$lacunar_infarcts) > 0) {
      
      format_selected_region <- function(region_string) {
        elements <- unlist(strsplit(region_string, " - "))
        structure <- tolower(elements[1])
        
        if (region_string %in% c("Midbrain - Tegmentum - Right", 
                                 "Midbrain - Tegmentum - Midline", 
                                 "Midbrain - Tegmentum - Left", 
                                 "Midbrain - Tectum - Right", 
                                 "Midbrain - Tectum - Midline", 
                                 "Midbrain - Tectum - Left", 
                                 "Pons - Basis - Right", 
                                 "Pons - Basis - Midline", 
                                 "Pons - Basis - Left", 
                                 "Pons - Tegmentum - Right", 
                                 "Pons - Tegmentum - Midline", 
                                 "Pons - Tegmentum - Left")) {
          # TYPE 2
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, "of the", structure, "at", side)
        } else if (region_string %in% c("Medulla - Anterior - Right", 
                                        "Medulla - Anterior - Left", 
                                        "Medulla - Posterior - Right", 
                                        "Medulla - Posterior - Left")) {
          # TYPE 3
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, structure, "at", side)
        } else if (region_string %in% c("Internal capsule - Anterior limb - Right", 
                                        "Internal capsule - Anterior limb - Left", 
                                        "Internal capsule - Genu - Right", 
                                        "Internal capsule - Genu - Left", 
                                        "Internal capsule - Posterior limb - Right", 
                                        "Internal capsule - Posterior limb - Left")) {
          # TYPE 4
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, "of the", side, structure)
        } else if (region_string %in% c("Midbrain - Crus cerebri - Right", 
                                        "Midbrain - Crus cerebri - Left")) {
          # TYPE 5
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(side, topography, "of the", structure)
        } else if (region_string %in% c("Cerebellum - Right", "Cerebellum - Left")) {
          # TYPE 6 (Cerebellum handling)
          side <- tolower(gsub(" hemisphere", "", elements[2]))
          paste(structure, "at", side)
        } else {
          # TYPE 1 (Default)
          if (length(elements) == 3) {
            side <- tolower(elements[3])
            topo <- tolower(elements[2])
            paste(side, topo, structure)
          } else if (length(elements) == 2) {
            side <- tolower(elements[2])
            paste(side, structure)
          } else {
            tolower(structure)
          }
        }
      }
      
      formatted_regions <- sapply(input$lacunar_infarcts, format_selected_region)
      
      n_regions <- length(formatted_regions)
      
      if (n_regions > 1) {
        region_phrase <- paste(formatted_regions, collapse = ", ")
        separator <- ifelse(n_regions > 2, ", ", " ")
        region_phrase <- gsub(", (?!.*,)", paste(separator, "and "), region_phrase, perl = TRUE)
        final_text_li <- paste0("Lacunes of presumed vascular origin in the ", region_phrase, ".")
      } else {
        final_text_li <- paste0("Lacunes of presumed vascular origin in the ", formatted_regions, ".")
      }
      
      final_text_li <- paste0(toupper(substr(final_text_li, 1, 1)), substr(final_text_li, 2, nchar(final_text_li)))
      
      return(final_text_li)
      
    } else {
      return("No lacunes of presumed vascular origin identified.") # Empty return when off or no selection
    }
  })
  
  ## PVS ------------
  
  pvs_report_text <- reactive({
    if (input$pvs_switch) {
      # Define severity scores based on the inputs
      severity_scores <- c(
        which(c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40") == input$pvs_centrum_semiovale) - 1,
        which(c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40") == input$pvs_basal_ganglia) - 1,
        which(c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40") == input$pvs_mesencephalon) - 1
      )
      
      regions <- c("centra semiovalia", "basal ganglia", "mesencephalon")
      severity_data <- data.frame(Region = regions, Score = severity_scores)
      
      relevant_severity_data <- severity_data[severity_data$Score > 0, ]
      
      if (nrow(relevant_severity_data) == 0) {
        return("No perivascular spaces identified.")
      }
      
      relevant_severity_data <- relevant_severity_data[order(-relevant_severity_data$Score), ]
      severity_labels <- c("none", "Mild (1-10)", "Moderate (11-20)", "Frequent (21-40)", "Severe (>40)")
      
      report_parts <- lapply(unique(relevant_severity_data$Score), function(severity) {
        current_regions <- relevant_severity_data$Region[relevant_severity_data$Score == severity]
        severity_label <- severity_labels[severity + 1]
        
        if (length(current_regions) > 1) {
          regions_string <- paste(paste(head(current_regions, -1), collapse=", "), "and", tail(current_regions, 1))
        } else {
          regions_string <- current_regions
        }
        
        if (severity == max(relevant_severity_data$Score)) {
          return(paste0(severity_label, " perivascular spaces in ", regions_string))
        } else {
          return(paste0(tolower(severity_label), " in ", regions_string))
        }
      })
      
      if (length(report_parts) > 1) {
        final_report_text <- paste(paste(head(report_parts, -1), collapse="; "), "; and ", tail(report_parts, 1), sep="")
      } else {
        final_report_text <- report_parts[[1]]
      }
      
      final_report_text <- paste0(toupper(substring(final_report_text, 1, 1)), substring(final_report_text, 2), ".")
      
      return(final_report_text)
    } else {
      return("")
    }
  })
  
  ## Microbleeds --------
  
  observe({
    fields <- c(
      "brainstem_definite_right", "brainstem_definite_left", 
      "brainstem_possible_right", "brainstem_possible_left",
      "cerebellum_definite_right", "cerebellum_definite_left", 
      "cerebellum_possible_right", "cerebellum_possible_left",
      "basal_ganglia_definite_right", "basal_ganglia_definite_left", 
      "basal_ganglia_possible_right", "basal_ganglia_possible_left",
      "thalamus_definite_right", "thalamus_definite_left", 
      "thalamus_possible_right", "thalamus_possible_left",
      "internal_capsule_definite_right", "internal_capsule_definite_left", 
      "internal_capsule_possible_right", "internal_capsule_possible_left",
      "external_capsule_definite_right", "external_capsule_definite_left", 
      "external_capsule_possible_right", "external_capsule_possible_left",
      "corpus_callosum_definite_right", "corpus_callosum_definite_left", 
      "corpus_callosum_possible_right", "corpus_callosum_possible_left",
      "deep_pvwhite_definite_right", "deep_pvwhite_definite_left", 
      "deep_pvwhite_possible_right", "deep_pvwhite_possible_left",
      "frontal_definite_right", "frontal_definite_left", 
      "frontal_possible_right", "frontal_possible_left",
      "parietal_definite_right", "parietal_definite_left", 
      "parietal_possible_right", "parietal_possible_left",
      "temporal_definite_right", "temporal_definite_left", 
      "temporal_possible_right", "temporal_possible_left",
      "occipital_definite_right", "occipital_definite_left", 
      "occipital_possible_right", "occipital_possible_left",
      "insula_definite_right", "insula_definite_left", 
      "insula_possible_right", "insula_possible_left"
    )
    for (id in fields) {
      val <- input[[id]]
      if (is.null(val) || is.na(val) || val == "" || !is.numeric(val)) {
        updateNumericInput(session, id, value = 0)
      }
    }
  })
  
  mb_report_text <- reactive({
    if (input$mb_switch) {
      total_microbleeds <- sum(
        input$brainstem_definite_right, input$brainstem_definite_left,
        input$brainstem_possible_right, input$brainstem_possible_left,
        input$cerebellum_definite_right, input$cerebellum_definite_left,
        input$cerebellum_possible_right, input$cerebellum_possible_left,
        input$basal_ganglia_definite_right, input$basal_ganglia_definite_left,
        input$basal_ganglia_possible_right, input$basal_ganglia_possible_left,
        input$thalamus_definite_right, input$thalamus_definite_left,
        input$thalamus_possible_right, input$thalamus_possible_left,
        input$internal_capsule_definite_right, input$internal_capsule_definite_left,
        input$internal_capsule_possible_right, input$internal_capsule_possible_left,
        input$frontal_definite_right, input$frontal_definite_left,
        input$frontal_possible_right, input$frontal_possible_left,
        input$parietal_definite_right, input$parietal_definite_left,
        input$parietal_possible_right, input$parietal_possible_left,
        input$temporal_definite_right, input$temporal_definite_left,
        input$temporal_possible_right, input$temporal_possible_left,
        input$occipital_definite_right, input$occipital_definite_left,
        input$occipital_possible_right, input$occipital_possible_left,
        input$insula_definite_right, input$insula_definite_left,
        input$insula_possible_right, input$insula_possible_left
      )
      
      if (total_microbleeds == 0) {
        return("No cerebral microbleeds identified.")
      }
      
      summarize_region <- function(region, definite_right, definite_left, possible_right, possible_left) {
        entries <- c()
        if (definite_right > 0 || definite_left > 0) {
          definite_list <- c()
          if (definite_right > 0) definite_list <- c(definite_list, paste(definite_right, "right"))
          if (definite_left > 0) definite_list <- c(definite_list, paste(definite_left, "left"))
          entries <- c(entries, paste(paste(definite_list, collapse = ", "), "definite"))
        }
        if (possible_right > 0 || possible_left > 0) {
          possible_list <- c()
          if (possible_right > 0) possible_list <- c(possible_list, paste(possible_right, "right"))
          if (possible_left > 0) possible_list <- c(possible_list, paste(possible_left, "left"))
          entries <- c(entries, paste(paste(possible_list, collapse = ", "), "possible"))
        }
        if (length(entries) > 0) {
          return(paste0(region, " (", paste(entries, collapse = "; "), ")"))
        }
        return(NULL)
      }
      
      format_section <- function(section) {
        if (length(section) > 1) {
          return(paste(paste(head(section, -1), collapse = "; "), "and", tail(section, 1)))
        } else {
          return(section)
        }
      }
      
      infratentorial <- c(
        summarize_region("brainstem", input$brainstem_definite_right, input$brainstem_definite_left, input$brainstem_possible_right, input$brainstem_possible_left),
        summarize_region("cerebellum", input$cerebellum_definite_right, input$cerebellum_definite_left, input$cerebellum_possible_right, input$cerebellum_possible_left)
      )
      
      deep <- c(
        summarize_region("basal ganglia", input$basal_ganglia_definite_right, input$basal_ganglia_definite_left, input$basal_ganglia_possible_right, input$basal_ganglia_possible_left),
        summarize_region("thalamus", input$thalamus_definite_right, input$thalamus_definite_left, input$thalamus_possible_right, input$thalamus_possible_left),
        summarize_region("internal capsule", input$internal_capsule_definite_right, input$internal_capsule_definite_left, input$internal_capsule_possible_right, input$internal_capsule_possible_left)
      )
      
      lobar <- c(
        summarize_region("frontal", input$frontal_definite_right, input$frontal_definite_left, input$frontal_possible_right, input$frontal_possible_left),
        summarize_region("parietal", input$parietal_definite_right, input$parietal_definite_left, input$parietal_possible_right, input$parietal_possible_left),
        summarize_region("temporal", input$temporal_definite_right, input$temporal_definite_left, input$temporal_possible_right, input$temporal_possible_left),
        summarize_region("occipital", input$occipital_definite_right, input$occipital_definite_left, input$occipital_possible_right, input$occipital_possible_left),
        summarize_region("insula", input$insula_definite_right, input$insula_definite_left, input$insula_possible_right, input$insula_possible_left)
      )
      
      report_details <- c()
      
      if (length(infratentorial) > 0) {
        report_details <- c(report_details, paste("Infratentorial:", format_section(infratentorial)))
      }
      if (length(deep) > 0) {
        report_details <- c(report_details, paste("Deep:", format_section(deep)))
      }
      if (length(lobar) > 0) {
        report_details <- c(report_details, paste("Lobar:", format_section(lobar)))
      }
      
      # Remove any extra spaces before the closing bracket
      formatted_report <- gsub(" +\\.", ".", paste(report_details, collapse = ". "))
      report <- paste0("Number of cerebral microbleeds: ", total_microbleeds, ". [", formatted_report, "].")
      
      return(report)
    } else {
      return("")
    }
  })
  
  
  ## cSS --------
  
  css_report_text <- reactive({
    if (input$css_switch) {
      # Extract numeric value from input
      ss_right <- as.numeric(substr(input$superficial_siderosis_right, 1, 1))
      ss_left <- as.numeric(substr(input$superficial_siderosis_left, 1, 1))
      
      # Calculate total cSS score
      total_css <- ss_right + ss_left
      
      # Generate interpretation based on cSS scores
      if (total_css == 0) {
        report_text <- "No cortical superficial siderosis (cSS) identified."
      } else if (total_css == 1) {
        location <- if (ss_right == 1) {
          "on the right"
        } else {
          "on the left"
        }
        report_text <- paste0("Mild, unifocal cortical superficial siderosis (cSS), score 1 ", location, ". cSS total score = 1.")
      } else {
        location <- if (ss_right == ss_left) {
          paste0("score ", ss_right, " on both hemispheres")
        } else {
          paste0("score ", ss_right, " on the right and ", ss_left, " on the left")
        }
        report_text <- paste0("Severe, multifocal cortical superficial siderosis (cSS), ", location, ". cSS total score = ", total_css, ".")
      }
      
      return(report_text)
    } else {
      return("")  # Return an empty string if the switch is off
    }
  })
  
  ## GCA ------------
  gca_report_text <- reactive({
    if (input$gca_switch) {
      # Collect values directly instead of using reactive() inside reactive()
      sulci_values <- c(
        as.numeric(input$frontal_sulci_right_report),
        as.numeric(input$frontal_sulci_left_report),
        as.numeric(input$parietal_sulci_right_report),
        as.numeric(input$parietal_sulci_left_report),
        as.numeric(input$temporal_sulci_right_report),
        as.numeric(input$temporal_sulci_left_report)
      )
      
      ventricles_values <- c(
        as.numeric(input$frontal_ventricles_right_report),
        as.numeric(input$frontal_ventricles_left_report),
        as.numeric(input$parietal_ventricles_right_report),
        as.numeric(input$parietal_ventricles_left_report),
        as.numeric(input$temporal_ventricles_right_report),
        as.numeric(input$temporal_ventricles_left_report),
        as.numeric(input$third_ventricle_report)
      )
      
      gca_sum_report <- sum(sulci_values, ventricles_values, na.rm = TRUE)
      
      severity_levels <- c("No atrophy", "Mild", "Moderate", "Severe")
      
      sulci_regions <- c("right frontal", "left frontal", "right parieto-occipital",
                         "left parieto-occipital", "right temporal", "left temporal")
      
      ventricles_regions <- c("right frontal", "left frontal", "right parieto-occipital",
                              "left parieto-occipital", "right temporal", "left temporal", "third ventricle")
      
      highest_sulci_regions <- sulci_regions[which(sulci_values == max(sulci_values, na.rm = TRUE))]
      highest_ventricles_regions <- ventricles_regions[which(ventricles_values == max(ventricles_values, na.rm = TRUE))]
      
      # Function to format bilateral regions
      format_regions <- function(regions) {
        unique_regions <- unique(regions)
        bilateral_regions <- c()
        remaining_regions <- c()
        
        for (region in unique_regions) {
          base_region <- sub("^(right|left) ", "", region)
          if (paste("right", base_region) %in% regions && paste("left", base_region) %in% regions) {
            if (!(paste("bilateral", base_region) %in% bilateral_regions)) {
              bilateral_regions <- c(bilateral_regions, paste("bilateral", base_region))
            }
          } else {
            remaining_regions <- c(remaining_regions, region)
          }
        }
        
        final_regions <- c(bilateral_regions, remaining_regions)
        
        if (length(final_regions) == 1) {
          return(final_regions)
        } else if (length(final_regions) == 2) {
          return(paste(final_regions, collapse = " and "))
        } else {
          return(paste(paste(final_regions[-length(final_regions)], collapse = ", "), "and", final_regions[length(final_regions)]))
        }
      }
      
      # Construct sulci text
      max_sulci <- max(sulci_values, na.rm = TRUE)
      severity_index_sulci <- pmin(max_sulci + 1, length(severity_levels)) # Avoid out-of-range index
      
      sulci_text <- if (max_sulci > 0) {
        formatted_sulci <- format_regions(highest_sulci_regions)
        area_word <- ifelse(length(highest_sulci_regions) > 1, "areas", "area")
        paste(severity_levels[severity_index_sulci], "cortical atrophy predominantly in the", formatted_sulci, area_word, ".")
      } else {
        "No cortical atrophy."
      }
      
      # Construct ventricles text
      max_ventricles <- max(ventricles_values, na.rm = TRUE)
      severity_index_ventricles <- pmin(max_ventricles + 1, length(severity_levels)) # Avoid out-of-range index
      
      ventricles_text <- if (max_ventricles > 0) {
        formatted_ventricles <- format_regions(highest_ventricles_regions)
        
        if ("third ventricle" %in% highest_ventricles_regions && length(highest_ventricles_regions) > 1) {
          other_regions <- setdiff(highest_ventricles_regions, "third ventricle")
          area_word <- ifelse(length(other_regions) > 1, "areas", "area")
          formatted_ventricles <- paste(format_regions(other_regions), area_word, "and third ventricle")
        } else if ("third ventricle" %in% highest_ventricles_regions) {
          formatted_ventricles <- "third ventricle"
        } else {
          area_word <- ifelse(length(highest_ventricles_regions) > 1, "areas", "area")
          formatted_ventricles <- paste(formatted_ventricles, area_word)
        }
        
        paste(severity_levels[severity_index_ventricles], "subcortical atrophy predominantly in the", formatted_ventricles, ".")
      } else {
        "No subcortical atrophy."
      }
      
      # Construct the summary part
      format_value_summary <- function(name, right_value, left_value) {
        parts <- c()
        if (right_value > 0) parts <- c(parts, paste("right:", right_value))
        if (left_value > 0) parts <- c(parts, paste("left:", left_value))
        if (length(parts) > 0) return(paste(name, " (", paste(parts, collapse = "; "), ")", sep = ""))
        else return(NULL)
      }
      
      sulci_summary <- c(
        format_value_summary("frontal", sulci_values[1], sulci_values[2]),
        format_value_summary("parieto-occipital", sulci_values[3], sulci_values[4]),
        format_value_summary("temporal", sulci_values[5], sulci_values[6])
      )
      
      ventricles_summary <- c(
        format_value_summary("frontal", ventricles_values[1], ventricles_values[2]),
        format_value_summary("parieto-occipital", ventricles_values[3], ventricles_values[4]),
        format_value_summary("temporal", ventricles_values[5], ventricles_values[6])
      )
      
      if (ventricles_values[7] > 0) {
        ventricles_summary <- c(ventricles_summary, paste("third ventricle:", ventricles_values[7]))
      }
      
      sulci_summary <- paste(na.omit(sulci_summary), collapse = ", ")
      ventricles_summary <- paste(na.omit(ventricles_summary), collapse = ", ")
      
      summary_text <- paste0(
        "Sulci: ", sulci_summary, ". ",
        "Ventricles: ", ventricles_summary, "."
      )
      
      if (sulci_summary == "" && ventricles_summary == "") {
        summary_text <- ""
      }
      
      # Construct the summary part without "Sulci:" if empty
      summary_text_parts <- c()
      if (sulci_summary != "") {
        summary_text_parts <- c(summary_text_parts, paste0("Sulci: ", sulci_summary, "."))
      }
      if (ventricles_summary != "") {
        summary_text_parts <- c(summary_text_parts, paste0("Ventricles: ", ventricles_summary, "."))
      }
      summary_text <- paste(summary_text_parts, collapse = " ")
      
      # Construct final report text
      formatted_gca_text <- paste(
        sulci_text,
        ventricles_text,
        "Global cortical atrophy (GCA) score =", gca_sum_report, ".",
        summary_text
      )
      
      # Remove unnecessary spaces before punctuation
      cleaned_gca_text <- gsub("\\s+(?=\\.)", "", formatted_gca_text, perl = TRUE)
      
      return(cleaned_gca_text)
      
    } else {  
      # If switch is FALSE, return an empty string
      return("")
    }
  })
  
  ## MTA ---------
  
  mta_report_text <- reactive({
    if (input$mta_switch) {
      
      # Extract numeric age
      age <- input$input_age
      
      # Extract numeric MTA scores
      mta_left <- as.numeric(substr(input$mta_left_report, 1, 1))
      mta_right <- as.numeric(substr(input$mta_right_report, 1, 1))
      
      # Define abnormality thresholds
      abnormal_threshold <- ifelse(age < 75, 2, 3)
      
      # Determine if left and right are abnormal
      left_abnormal <- mta_left >= abnormal_threshold
      right_abnormal <- mta_right >= abnormal_threshold
      
      # Generate interpretation based on conditions
      if (left_abnormal && right_abnormal && mta_left == mta_right) {
        report_text <- paste0("Medial Temporal Atrophy (MTA) score: bilateral = ", mta_left, 
                              "; abnormal according to the age-related normative range.")
      } else if (left_abnormal && right_abnormal && mta_left != mta_right) {
        report_text <- paste0("Medial Temporal Atrophy (MTA) score: left = ", mta_left, 
                              " (abnormal) and right = ", mta_right, " (abnormal); according to the age-related normative range.")
      } else if (left_abnormal || right_abnormal) {
        abnormal_side <- ifelse(left_abnormal, "left", "right")
        normal_side <- ifelse(left_abnormal, "right", "left")
        abnormal_value <- ifelse(left_abnormal, mta_left, mta_right)
        normal_value <- ifelse(left_abnormal, mta_right, mta_left)
        report_text <- paste0("Medial Temporal Atrophy (MTA) score: ", abnormal_side, " = ", abnormal_value, 
                              " (abnormal) and ", normal_side, " = ", normal_value, 
                              " (normal); according to the age-related normative range.")
      } else {
        if (mta_left == mta_right) {
          report_text <- paste0("Medial Temporal Atrophy (MTA) score: bilateral = ", mta_left, 
                                "; normal according to the age-related normative range.")
        } else {
          report_text <- paste0("Medial Temporal Atrophy (MTA) score: left = ", mta_left, 
                                " and right = ", mta_right, 
                                "; normal according to the age-related normative range.")
        }
      }
      
      return(report_text)
    } else {
      return("")
    }
  })
  
  
  
  ## ERICA ---------
  erica_report_text <- reactive({
    if (input$erica_switch) {
      # Extract ERICA scores
      erica_left <- as.numeric(substr(input$erica_left_report, 1, 1))
      erica_right <- as.numeric(substr(input$erica_right_report, 1, 1))
      
      # Generate clean interpretation
      if (erica_left >= 2 && erica_right >= 2) {
        if (erica_left == erica_right) {
          report_text <- paste0("Entorhinal Cortical Atrophy (ERICA) score: bilateral = ", erica_left, 
                                " (abnormal); may suggest a neurodegenerative condition rather than subjective cognitive decline.")
        } else {
          report_text <- paste0(
            "Entorhinal Cortical Atrophy (ERICA) score: right = ", erica_right, " (", ifelse(erica_right >= 2, "abnormal", "normal"), ") and ",
            "left = ", erica_left, " (", ifelse(erica_left >= 2, "abnormal", "normal"), "); ",
            "may suggest a neurodegenerative condition rather than subjective cognitive decline."
          )
        }
      } else if (erica_left >= 2 || erica_right >= 2) {
        report_text <- paste0(
          "Entorhinal Cortical Atrophy (ERICA) score: right = ", erica_right, " (", ifelse(erica_right >= 2, "abnormal", "normal"), ") and ",
          "left = ", erica_left, " (", ifelse(erica_left >= 2, "abnormal", "normal"), "); ",
          ifelse(erica_left >= 2, "left", "right"), " may suggest a neurodegenerative condition, while ",
          ifelse(erica_left >= 2, "right", "left"), " does not support neurodegenerative pathology over subjective cognitive decline."
        )
      } else {
        if (erica_left == erica_right) {
          report_text <- paste0("Entorhinal Cortical Atrophy (ERICA) score: bilateral = ", erica_left, 
                                " (normal); do not support neurodegenerative pathology over subjective cognitive decline.")
        } else {
          report_text <- paste0(
            "Entorhinal Cortical Atrophy (ERICA) score: right = ", erica_right, " (normal) and ",
            "left = ", erica_left, " (normal); do not support neurodegenerative pathology over subjective cognitive decline."
          )
        }
      }
      
      return(report_text)
    } else {
      return("")
    }
  })
  
  ## PCA (koedam) ----------
  pca_report_text <- reactive({
    # Check if the PCA section switch is on
    if (input$pca_switch) {  # If switch is TRUE, proceed to generate content
      # Extract the numeric part of the PCA scores
      pca_left <- as.numeric(substr(input$pca_left_report, 1, 1))
      pca_right <- as.numeric(substr(input$pca_right_report, 1, 1))
      
      # Initialize the report text variable
      report_text <- ""
      
      # Check if the PCA scores are the same or different and generate text accordingly
      if (pca_left == pca_right) {
        report_text <- paste0("Posterior parietal atrophy (Koedam) score: ", "bilateral = ", pca_left, ".")
      } else {
        if (pca_left > pca_right) {
          report_text <- paste0("Posterior parietal atrophy (Koedam) score: ", "left = ", pca_left, " and right = ", pca_right, ".")
        } else {
          report_text <- paste0("Posterior parietal atrophy (Koedam) score: ", "right = ", pca_right, " and left = ", pca_left, ".")
        }
      }
      
      return(report_text)
    } else {  # If switch is FALSE, do not generate or return an empty string
      return("")
    }
  })
  
  ## summary svd score ----
  
  lacunar_infarcts_score <- reactive({
    if (!is.null(input$lacunar_infarcts) && length(input$lacunar_infarcts) > 0) {
      return(1)  # 1 point if one or more selected
    } else {
      return(0)  # 0 points if none selected
    }
  })
  
  cerebral_microbleeds_score <- reactive({
    total_microbleeds <- sum(
      input$brainstem_definite_right, input$brainstem_definite_left,
      input$brainstem_possible_right, input$brainstem_possible_left,
      input$cerebellum_definite_right, input$cerebellum_definite_left,
      input$cerebellum_possible_right, input$cerebellum_possible_left,
      input$basal_ganglia_definite_right, input$basal_ganglia_definite_left,
      input$basal_ganglia_possible_right, input$basal_ganglia_possible_left,
      input$thalamus_definite_right, input$thalamus_definite_left,
      input$thalamus_possible_right, input$thalamus_possible_left,
      input$internal_capsule_definite_right, input$internal_capsule_definite_left,
      input$internal_capsule_possible_right, input$internal_capsule_possible_left,
      input$frontal_definite_right, input$frontal_definite_left,
      input$frontal_possible_right, input$frontal_possible_left,
      input$parietal_definite_right, input$parietal_definite_left,
      input$parietal_possible_right, input$parietal_possible_left,
      input$temporal_definite_right, input$temporal_definite_left,
      input$temporal_possible_right, input$temporal_possible_left,
      input$occipital_definite_right, input$occipital_definite_left,
      input$occipital_possible_right, input$occipital_possible_left,
      input$insula_definite_right, input$insula_definite_left,
      input$insula_possible_right, input$insula_possible_left
    )
    
    if (total_microbleeds > 0) {
      return(1)  # 1 point if any microbleeds are present
    } else {
      return(0)  # 0 points if none
    }
  })
  
  perivascular_spaces_score <- reactive({
    severity_map <- c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40")
    selected_severity <- input$pvs_basal_ganglia
    
    if (selected_severity %in% severity_map[3:5]) {
      return(1)  # 1 point if moderate, frequent, or severe
    } else {
      return(0)  # 0 points if none or mild
    }
  })
  
  white_matter_hyperintensities_score <- reactive({
    periventricular_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$periventricular_grade))
    deep_white_matter_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$deep_white_matter_grade))
    
    if (periventricular_grade == 3 || deep_white_matter_grade >= 2) {
      return(1)  # 1 point for the specified conditions
    } else {
      return(0)  # 0 points for other cases
    }
  })
  
  ssvds_report_text <- reactive({
    total_score <- lacunar_infarcts_score() + 
      cerebral_microbleeds_score() + 
      perivascular_spaces_score() + 
      white_matter_hyperintensities_score()
    
    paste0("Summary small vessel disease (SVD) score = ", total_score, 
           ifelse(total_score == 1, " point.", " points."))
  })
  
  
  # Output for summary svd Score
  output$lacunarInfarctsScore <- renderText({
    score <- lacunar_infarcts_score()
    paste(score, ifelse(score == 1, "point", "points"))
  })
  
  output$cerebralMicrobleedsScore <- renderText({
    score <- cerebral_microbleeds_score()
    paste(score, ifelse(score == 1, "point", "points"))
  })
  
  output$perivascularSpacesScore <- renderText({
    score <- perivascular_spaces_score()
    paste(score, ifelse(score == 1, "point", "points"))
  })
  
  output$whiteMatterHyperintensitiesScore <- renderText({
    score <- white_matter_hyperintensities_score()
    paste(score, ifelse(score == 1, "point", "points"))
  })
  
  ## portuguese report -----------
  
  ## pRecent Subcortical Infarcts ---------
  
  rsi_report_text_pt <- reactive({
    if (input$rsi_switch && !is.null(input$recentsmallinfarct) && length(input$recentsmallinfarct) > 0) {
      
      translate_region <- function(region_string) {
        translation_map <- list(
          "Midbrain - Tegmentum - Right" = "tegmento do mesencéfalo à direita",
          "Midbrain - Tegmentum - Midline" = "tegmento do mesencéfalo na linha média",
          "Midbrain - Tegmentum - Left" = "tegmento do mesencéfalo à esquerda",
          "Midbrain - Tectum - Right" = "tecto do mesencéfalo à direita",
          "Midbrain - Tectum - Midline" = "tecto do mesencéfalo na linha média",
          "Midbrain - Tectum - Left" = "tecto do mesencéfalo à esquerda",
          "Pons - Basis - Right" = "base da ponte à direita",
          "Pons - Basis - Midline" = "base da ponte na linha média",
          "Pons - Basis - Left" = "base da ponte à esquerda",
          "Pons - Tegmentum - Right" = "tegmento da ponte à direita",
          "Pons - Tegmentum - Midline" = "tegmento da ponte na linha média",
          "Pons - Tegmentum - Left" = "tegmento da ponte à esquerda",
          "Medulla - Anterior - Right" = "medula anterior à direita",
          "Medulla - Anterior - Left" = "medula anterior à esquerda",
          "Medulla - Posterior - Right" = "medula posterior à direita",
          "Medulla - Posterior - Left" = "medula posterior à esquerda",
          "Internal capsule - Anterior limb - Right" = "braço anterior da cápsula interna à direita",
          "Internal capsule - Anterior limb - Left" = "braço anterior da cápsula interna à esquerda",
          "Internal capsule - Genu - Right" = "joelho da cápsula interna à direita",
          "Internal capsule - Genu - Left" = "joelho da cápsula interna à esquerda",
          "Internal capsule - Posterior limb - Right" = "braço posterior da cápsula interna à direita",
          "Internal capsule - Posterior limb - Left" = "braço posterior da cápsula interna à esquerda",
          "Midbrain - Crus cerebri - Right" = "crus cerebri do mesencéfalo à direita",
          "Midbrain - Crus cerebri - Left" = "crus cerebri do mesencéfalo à esquerda",
          "Cerebellum - Right" = "cerebelo à direita",
          "Cerebellum - Left" = "cerebelo à esquerda",
          "Centrum semiovale - Frontal - Left" = "centro semioval frontal à esquerda",
          "Centrum semiovale - Frontal - Right" = "centro semioval frontal à direita",
          "Centrum semiovale - Parietal - Left" = "centro semioval parietal à esquerda",
          "Centrum semiovale - Parietal - Right" = "centro semioval parietal à direita",
          "Corona radiata - Frontal - Left" = "corona radiata frontal à esquerda",
          "Corona radiata - Frontal - Right" = "corona radiata frontal à direita",
          "Corona radiata - Parietal - Left" = "corona radiata parietal à esquerda",
          "Corona radiata - Parietal - Right" = "corona radiata parietal à direita",
          "Caudate nucleus - Left" = "núcleo caudado à esquerda",
          "Caudate nucleus - Right" = "núcleo caudado à direita",
          "Thalamus - Anterior - Left" = "tálamo anterior à esquerda",
          "Thalamus - Anterior - Right" = "tálamo anterior à direita",
          "Thalamus - Medial - Left" = "tálamo medial à esquerda",
          "Thalamus - Medial - Right" = "tálamo medial à direita",
          "Thalamus - Lateral - Left" = "tálamo lateral à esquerda",
          "Thalamus - Lateral - Right" = "tálamo lateral à direita",
          "Thalamus - Posterior - Left" = "tálamo posterior à esquerda",
          "Thalamus - Posterior - Right" = "tálamo posterior à direita",
          "Lentiform nucleus - Left" = "núcleo lentiforme à esquerda",
          "Lentiform nucleus - Right" = "núcleo lentiforme à direita",
          "Cerebral peduncle - Left" = "pedúnculo cerebral à esquerda",
          "Cerebral peduncle - Right" = "pedúnculo cerebral à direita",
          "Central tegmentum midbrain" = "tegmento central do mesencéfalo",
          "External capsule - Left" = "cápsula externa à esquerda",
          "External capsule - Right" = "cápsula externa à direita"
        )
        translated <- translation_map[[region_string]]
        if (is.null(translated)) {
          print(paste("Missing translation for:", region_string)) # Debugging
        }
        return(translated)
      }
      
      formatted_regions <- lapply(input$recentsmallinfarct, translate_region)
      formatted_regions <- formatted_regions[!sapply(formatted_regions, is.null)] # Remove NULLs
      
      n_regions <- length(formatted_regions)
      
      if (n_regions > 1) {
        region_phrase <- paste(formatted_regions, collapse = ", ")
        region_phrase <- sub(", ([^,]+)$", " e \\1", region_phrase) # Ensures no comma before "e"
        texto_final <- paste0("Pequenos enfartes subcorticais recentes: ", region_phrase, ".")
      } else if (n_regions == 1) {
        texto_final <- paste0("Pequeno enfarte subcortical recente: ", formatted_regions, ".")
      } else {
        texto_final <- "Sem pequenos enfartes subcorticais recentes."
      }
      
      texto_final <- paste0(toupper(substr(texto_final, 1, 1)), substr(texto_final, 2, nchar(texto_final)))
      
      return(texto_final)
      
    } else {
      return("Sem pequenos enfartes subcorticais recentes.")
    }
  })
  
  ## pLi -----
  
  li_report_text_pt <- reactive({
    if (input$li_switch && !is.null(input$lacunar_infarcts) && length(input$lacunar_infarcts) > 0) {
      
      translate_li_region <- function(region_string) {
        translation_map_li <- list(
          "Centrum semiovale - Frontal - Right" = "centro semioval frontal à direita",
          "Centrum semiovale - Frontal - Left" = "centro semioval frontal à esquerda",
          "Centrum semiovale - Parietal - Right" = "centro semioval parietal à direita",
          "Centrum semiovale - Parietal - Left" = "centro semioval parietal à esquerda",
          "Corona radiata - Frontal - Right" = "corona radiata frontal à direita",
          "Corona radiata - Frontal - Left" = "corona radiata frontal à esquerda",
          "Corona radiata - Parietal - Right" = "corona radiata parietal à direita",
          "Corona radiata - Parietal - Left" = "corona radiata parietal à esquerda",
          "Caudate nucleus - Right" = "núcleo caudado à direita",
          "Caudate nucleus - Left" = "núcleo caudado à esquerda",
          "External capsule - Right" = "cápsula externa à direita",
          "External capsule - Left" = "cápsula externa à esquerda",
          "Internal capsule - Anterior limb - Right" = "braço anterior da cápsula interna à direita",
          "Internal capsule - Anterior limb - Left" = "braço anterior da cápsula interna à esquerda",
          "Internal capsule - Genu - Right" = "joelho da cápsula interna à direita",
          "Internal capsule - Genu - Left" = "joelho da cápsula interna à esquerda",
          "Internal capsule - Posterior limb - Right" = "braço posterior da cápsula interna à direita",
          "Internal capsule - Posterior limb - Left" = "braço posterior da cápsula interna à esquerda",
          "Lentiform nucleus - Right" = "núcleo lentiforme à direita",
          "Lentiform nucleus - Left" = "núcleo lentiforme à esquerda",
          "Thalamus - Anterior - Right" = "tálamo anterior à direita",
          "Thalamus - Anterior - Left" = "tálamo anterior à esquerda",
          "Thalamus - Lateral - Right" = "tálamo lateral à direita",
          "Thalamus - Lateral - Left" = "tálamo lateral à esquerda",
          "Thalamus - Medial - Right" = "tálamo medial à direita",
          "Thalamus - Medial - Left" = "tálamo medial à esquerda",
          "Thalamus - Posterior - Right" = "tálamo posterior à direita",
          "Thalamus - Posterior - Left" = "tálamo posterior à esquerda",
          "Cerebral peduncle - Right" = "pedúnculo cerebral à direita",
          "Cerebral peduncle - Left" = "pedúnculo cerebral à esquerda",
          "Midbrain - Crus cerebri - Right" = "crus cerebri do mesencéfalo à direita",
          "Midbrain - Crus cerebri - Left" = "crus cerebri do mesencéfalo à esquerda",
          "Midbrain - Tegmentum - Right" = "tegmento do mesencéfalo à direita",
          "Midbrain - Tegmentum - Central" = "tegmento do mesencéfalo ao centro",
          "Midbrain - Tegmentum - Left" = "tegmento do mesencéfalo à esquerda",
          "Midbrain - Tectum - Right" = "tecto do mesencéfalo à direita",
          "Midbrain - Tectum - Midline" = "tecto do mesencéfalo na linha média",
          "Midbrain - Tectum - Left" = "tecto do mesencéfalo à esquerda",
          "Pons - Basis - Right" = "base da ponte à direita",
          "Pons - Basis - Midline" = "base da ponte na linha média",
          "Pons - Basis - Left" = "base da ponte à esquerda",
          "Pons - Tegmentum - Right" = "tegmento da ponte à direita",
          "Pons - Tegmentum - Midline" = "tegmento da ponte na linha média",
          "Pons - Tegmentum - Left" = "tegmento da ponte à esquerda",
          "Medulla - Anterior - Right" = "medula anterior à direita",
          "Medulla - Anterior - Left" = "medula anterior à esquerda",
          "Medulla - Posterior - Right" = "medula posterior à direita",
          "Medulla - Posterior - Left" = "medula posterior à esquerda",
          "Cerebellum - Right" = "cerebelo à direita",
          "Cerebellum - Left" = "cerebelo à esquerda"
        )
        translated <- translation_map_li[[region_string]]
        return(translated)
      }
      
      regioes_formatadas <- lapply(input$lacunar_infarcts, translate_li_region)
      regioes_formatadas <- regioes_formatadas[!sapply(regioes_formatadas, is.null)] # Remove NULLs
      
      n_regioes <- length(regioes_formatadas)
      
      if (n_regioes > 1) {
        frase_regiao <- paste(regioes_formatadas, collapse = ", ")
        frase_regiao <- sub(", ([^,]+)$", " e \\1", frase_regiao) # Ensures no comma before "e"
        texto_final_li <- paste0("Lacunas de origem vascular presumida em: ", frase_regiao, ".")
      } else if (n_regioes == 1) {
        texto_final_li <- paste0("Lacuna de origem vascular presumida em: ", regioes_formatadas, ".")
      } else {
        texto_final_li <- "Sem lacunas de origem vascular presumida."
      }
      
      texto_final_li <- paste0(toupper(substr(texto_final_li, 1, 1)), substr(texto_final_li, 2, nchar(texto_final_li)))
      
      return(texto_final_li)
      
    } else {
      return("Sem lacunas de origem vascular presumida.")
    }
  })
  
  ## pFazekas ---------
  
  fazekas_report_text_pt <- reactive({
    if (!input$fazekas_switch) {
      return("")
    }
    
    # Extrair valores selecionados
    periventricular_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$periventricular_grade))
    deep_white_matter_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$deep_white_matter_grade))
    
    # Verificar se ambos são 0
    if (periventricular_grade == 0 && deep_white_matter_grade == 0) {
      return("Sem valorizável leucoencefalopatia microangiopática crónica. Fazekas = 0.")
    }
    
    # Determinar a severidade
    severity_levels <- c("leve", "moderado", "marcado")
    fazekas_value <- max(periventricular_grade, deep_white_matter_grade, na.rm = TRUE)
    
    # Inicializar o texto do relatório
    report_text <- "Hipersinal T2-FLAIR de presumível origem microangiopática de predomínio:"
    regions_text <- c()
    
    translate_laterality <- function(laterality) {
      if (laterality == "bilateral") {
        return("bilateral")
      } else if (laterality == "left") {
        return("à esquerda")
      } else if (laterality == "right") {
        return("à direita")
      }
    }
    
    if (periventricular_grade > 0) {
      severity <- severity_levels[periventricular_grade]
      laterality <- translate_laterality(input$periventricular_laterality)
      distribution <- input$periventricular_distribution
      distribution_text <- ifelse(distribution == "diffuse", "", distribution)
      periventricular_text <- paste(severity, "na substância branca periventricular", distribution_text, laterality)
      periventricular_text <- gsub("\\s+", " ", periventricular_text)  # Limpar espaços extras
      regions_text <- c(regions_text, periventricular_text)
    }
    
    if (deep_white_matter_grade > 0) {
      severity <- severity_levels[deep_white_matter_grade]
      laterality <- translate_laterality(input$deep_white_matter_laterality)
      distribution <- input$deep_white_matter_distribution
      if (distribution == "centrum semiovale") {
        distribution_text <- "no centro semiovale"
      } else if (distribution == "corona radiata") {
        distribution_text <- "na coroa radiata"
      } else if (distribution == "diffuse") {
        distribution_text <- "na substância branca profunda"
      } else {
        distribution_text <- ""
      }
      deep_text <- paste(severity, distribution_text, laterality)
      deep_text <- gsub("\\s+", " ", deep_text)  # Limpar espaços extras
      regions_text <- c(regions_text, deep_text)
    }
    
    report_text <- paste0(report_text, " ", paste(regions_text, collapse = " e "), ". Fazekas = ", fazekas_value, ".")
    
    return(trimws(report_text))
  })
  
  ## pPVS ------
  
  pvs_report_text_pt <- reactive({
    if (input$pvs_switch) {
      categories_eng <- c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40")
      categories_pt <- c("nenhum = 0", "ligeiro = 1-10", "moderado = 11-20", "frequente = 21-40", "grave >40")
      
      # Capture inputs
      selected_eng <- c(input$pvs_centrum_semiovale, input$pvs_basal_ganglia, input$pvs_mesencephalon)
      severity_scores <- sapply(selected_eng, function(x) match(x, categories_eng) - 1)
      
      regions <- c("centra semiovalia", "gânglios da base", "mesencéfalo")
      prepositions <- c("nos", "nos", "no")
      severity_data <- data.frame(Região = regions, Pontuação = severity_scores, Preposição = prepositions)
      
      relevant_severity_data <- severity_data[severity_data$Pontuação > 0, ]
      
      if (nrow(relevant_severity_data) == 0) {
        return("Sem valorizável ectasia de espaços perivasculares.")
      }
      
      # Sort by severity level
      relevant_severity_data <- relevant_severity_data[order(-relevant_severity_data$Pontuação), ]
      severity_labels_pt <- c("nenhum", "ligeira", "moderada", "frequente", "marcada")
      
      report_parts <- lapply(unique(relevant_severity_data$Pontuação), function(severity) {
        current_regions <- relevant_severity_data$Região[relevant_severity_data$Pontuação == severity]
        prepositions <- relevant_severity_data$Preposição[relevant_severity_data$Pontuação == severity]
        severity_label <- severity_labels_pt[severity + 1]
        
        regions_with_prepositions <- mapply(function(region, prep) {
          paste(prep, region)
        }, current_regions, prepositions)
        
        regions_string <- if (length(regions_with_prepositions) > 1) {
          paste(paste(head(regions_with_prepositions, -1), collapse=", "), "e", tail(regions_with_prepositions, 1))
        } else {
          regions_with_prepositions
        }
        
        return(paste0(severity_label, " ", regions_string))
      })
      
      final_report_text <- paste("Dilatação de espaços perivasculares:", 
                                 paste(report_parts, collapse=", "))
      
      # Replace last ", " with " e "
      final_report_text <- sub(",([^,]*)$", " e\\1", final_report_text)
      
      final_report_text <- paste0(toupper(substring(final_report_text, 1, 1)), substring(final_report_text, 2), ".")
      
      return(final_report_text)
    } else {
      return("")
    }
  })
  
  ## pmicrobleeds ------
  
  mb_report_text_pt <- reactive({
    if (input$mb_switch) {
      
      total_microbleeds <- sum(
        input$brainstem_definite_right, input$brainstem_definite_left,
        input$brainstem_possible_right, input$brainstem_possible_left,
        input$cerebellum_definite_right, input$cerebellum_definite_left,
        input$cerebellum_possible_right, input$cerebellum_possible_left,
        input$basal_ganglia_definite_right, input$basal_ganglia_definite_left,
        input$basal_ganglia_possible_right, input$basal_ganglia_possible_left,
        input$thalamus_definite_right, input$thalamus_definite_left,
        input$thalamus_possible_right, input$thalamus_possible_left,
        input$internal_capsule_definite_right, input$internal_capsule_definite_left,
        input$internal_capsule_possible_right, input$internal_capsule_possible_left,
        input$frontal_definite_right, input$frontal_definite_left,
        input$frontal_possible_right, input$frontal_possible_left,
        input$parietal_definite_right, input$parietal_definite_left,
        input$parietal_possible_right, input$parietal_possible_left,
        input$temporal_definite_right, input$temporal_definite_left,
        input$temporal_possible_right, input$temporal_possible_left,
        input$occipital_definite_right, input$occipital_definite_left,
        input$occipital_possible_right, input$occipital_possible_left,
        input$insula_definite_right, input$insula_definite_left,
        input$insula_possible_right, input$insula_possible_left
      )
      
      if (total_microbleeds == 0) {
        return("Sem microhemorragias parenquimatosas.")
      }
      
      summarize_region <- function(region, definite_right, definite_left, possible_right, possible_left) {
        entries <- c()
        if (definite_right > 0 || definite_left > 0) {
          definite_list <- c()
          if (definite_right > 0) definite_list <- c(definite_list, paste(definite_right, "direita"))
          if (definite_left > 0) definite_list <- c(definite_list, paste(definite_left, "esquerda"))
          entries <- c(entries, paste(paste(definite_list, collapse = ", "), "definitivas"))
        }
        if (possible_right > 0 || possible_left > 0) {
          possible_list <- c()
          if (possible_right > 0) possible_list <- c(possible_list, paste(possible_right, "direita"))
          if (possible_left > 0) possible_list <- c(possible_list, paste(possible_left, "esquerda"))
          entries <- c(entries, paste(paste(possible_list, collapse = ", "), "possíveis"))
        }
        if (length(entries) > 0) {
          return(paste(region, " (", paste(entries, collapse = "; "), ")", sep = ""))
        }
        return(NULL)
      }
      
      format_section <- function(section) {
        if (length(section) > 1) {
          return(paste(paste(head(section, -1), collapse = ", "), "e", tail(section, 1), sep = " "))
        } else {
          return(section)
        }
      }
      
      infratentorial <- c(
        summarize_region("tronco encefálico", input$brainstem_definite_right, input$brainstem_definite_left, input$brainstem_possible_right, input$brainstem_possible_left),
        summarize_region("cerebelo", input$cerebellum_definite_right, input$cerebellum_definite_left, input$cerebellum_possible_right, input$cerebellum_possible_left)
      )
      
      deep <- c(
        summarize_region("gânglios da base", input$basal_ganglia_definite_right, input$basal_ganglia_definite_left, input$basal_ganglia_possible_right, input$basal_ganglia_possible_left),
        summarize_region("tálamo", input$thalamus_definite_right, input$thalamus_definite_left, input$thalamus_possible_right, input$thalamus_possible_left),
        summarize_region("cápsula interna", input$internal_capsule_definite_right, input$internal_capsule_definite_left, input$internal_capsule_possible_right, input$internal_capsule_possible_left)
      )
      
      lobar <- c(
        summarize_region("frontal", input$frontal_definite_right, input$frontal_definite_left, input$frontal_possible_right, input$frontal_possible_left),
        summarize_region("parietal", input$parietal_definite_right, input$parietal_definite_left, input$parietal_possible_right, input$parietal_possible_left),
        summarize_region("temporal", input$temporal_definite_right, input$temporal_definite_left, input$temporal_possible_right, input$temporal_possible_left),
        summarize_region("occipital", input$occipital_definite_right, input$occipital_definite_left, input$occipital_possible_right, input$occipital_possible_left),
        summarize_region("ínsula", input$insula_definite_right, input$insula_definite_left, input$insula_possible_right, input$insula_possible_left)
      )
      
      report_details <- c()
      
      if (length(infratentorial) > 0) {
        report_details <- c(report_details, paste("Infratentoriais:", format_section(infratentorial)))
      }
      if (length(deep) > 0) {
        report_details <- c(report_details, paste("Profundas:", format_section(deep)))
      }
      if (length(lobar) > 0) {
        report_details <- c(report_details, paste("Lobares:", format_section(lobar)))
      }
      
      formatted_report <- paste(report_details, collapse = ". ")
      return(paste0("Número de micro-hemorragias cerebrais: ", total_microbleeds, ". [", formatted_report, "]."))
    } else {
      return("")
    }
  })
  
  ### pcSS ---------
  
  css_report_text_pt <- reactive({
    if (input$css_switch) {
      # Extrair valor numérico do input
      ss_right <- as.numeric(substr(input$superficial_siderosis_right, 1, 1))
      ss_left <- as.numeric(substr(input$superficial_siderosis_left, 1, 1))
      
      # Calcular pontuação total de cSS
      total_css <- ss_right + ss_left
      
      # Gerar interpretação com base nas pontuações de cSS
      if (total_css == 0) {
        report_text <- "Sem siderose superficial cortical."
      } else if (total_css == 1) {
        location <- if (ss_right == 1) {
          "no hemisfério direito"
        } else {
          "no hemisfério esquerdo"
        }
        report_text <- paste0("Siderose superficial cortical (cSS) ligeira, unifocal, grau 1 ", location, ". cSS total = 1.")
      } else {
        location <- if (ss_right == ss_left) {
          paste0("grau ", ss_right, " em ambos os hemisférios")
        } else {
          paste0("grau ", ss_right, " no hemisfério direito e ", ss_left, " no hemisfério esquerdo")
        }
        report_text <- paste0("Siderose superficial cortical (cSS) marcada, multifocal, ", location, ". cSS total = ", total_css, ".")
      }
      
      return(report_text)
    } else {
      return("")  # Retornar uma string vazia se a chave estiver desligada
    }
  })
  
  ### pGCA -----
  
  # GCA Server Portuguese
  gca_report_text_pt <- reactive({
    if (input$gca_switch) {
      # Capture values
      sulci_values <- c(
        as.numeric(input$frontal_sulci_right_report),
        as.numeric(input$frontal_sulci_left_report),
        as.numeric(input$parietal_sulci_right_report),
        as.numeric(input$parietal_sulci_left_report),
        as.numeric(input$temporal_sulci_right_report),
        as.numeric(input$temporal_sulci_left_report)
      )
      
      ventricles_values <- c(
        as.numeric(input$frontal_ventricles_right_report),
        as.numeric(input$frontal_ventricles_left_report),
        as.numeric(input$parietal_ventricles_right_report),
        as.numeric(input$parietal_ventricles_left_report),
        as.numeric(input$temporal_ventricles_right_report),
        as.numeric(input$temporal_ventricles_left_report),
        as.numeric(input$third_ventricle_report)
      )
      
      gca_sum_report <- sum(sulci_values, ventricles_values, na.rm = TRUE)
      
      severity_levels <- c("Sem atrofia", "Leve", "Moderada", "Marcada")
      
      # Regions for naming
      base_regions <- c("frontal", "parieto-occipital", "temporal")
      sulci_reg_map <- c("frontal direito", "frontal esquerdo", 
                         "parieto-occipital direito", "parieto-occipital esquerdo", 
                         "temporal direito", "temporal esquerdo")
      ventricles_reg_map <- c("frontal direito", "frontal esquerdo", 
                              "parieto-occipital direito", "parieto-occipital esquerdo", 
                              "temporal direito", "temporal esquerdo", "terceiro ventrículo")
      
      # Get max values
      max_sulci <- max(sulci_values, na.rm = TRUE)
      max_ventricles <- max(ventricles_values, na.rm = TRUE)
      severity_index_sulci <- pmin(max_sulci + 1, length(severity_levels))
      severity_index_ventricles <- pmin(max_ventricles + 1, length(severity_levels))
      
      # Helper for region phrasing for "predomínio" sentence
      get_predominant_regions_bilateral <- function(values, max_val, reg_names, add_terceiro=FALSE) {
        regs <- c()
        # Only three bilateral regions (frontal, parieto-occipital, temporal)
        for (i in 1:3) {
          idxR <- 2*(i-1)+1
          idxL <- 2*(i-1)+2
          if (values[idxR]==max_val && values[idxL]==max_val && max_val>0) {
            regs <- c(regs, paste(reg_names[i],"bilateral"))
          } else if (values[idxR]==max_val && values[idxL]!=max_val && max_val>0) {
            regs <- c(regs, paste(reg_names[i],"direito"))
          } else if (values[idxR]!=max_val && values[idxL]==max_val && max_val>0) {
            regs <- c(regs, paste(reg_names[i],"esquerdo"))
          }
        }
        if(add_terceiro && values[7]==max_val && max_val>0) {
          regs <- c(regs, "no terceiro ventrículo")
        }
        regs
      }
      
      # Returns a string of regions joined by commas, handling "e" before the last
      join_regions_for_predom <- function(regions) {
        n <- length(regions)
        if (n==0) return("")
        if (n==1) return(regions[1])
        if (n==2) return(paste(regions, collapse=" e "))
        # more than 2
        paste(paste(regions[1:(n-1)], collapse=", "), "e", regions[n])
      }
      
      # SULCI PHRASE
      if (max_sulci == 0) {
        sulci_text <- "Sem atrofia cortical."
      } else {
        sulci_predom_regs <- get_predominant_regions_bilateral(sulci_values, max_sulci, base_regions, add_terceiro=FALSE)
        sulci_predom <- join_regions_for_predom(sulci_predom_regs)
        sulci_text <- paste0(severity_levels[severity_index_sulci], " atrofia cortical de predomínio ", sulci_predom, ".")
      }
      
      # VENTRICLES PHRASE
      if (max_ventricles == 0) {
        ventricles_text <- "Sem atrofia subcortical."
      } else {
        vent_predom_regs <- get_predominant_regions_bilateral(ventricles_values, max_ventricles, base_regions, add_terceiro=TRUE)
        base_regs_predom <- vent_predom_regs[!grepl("^no terceiro ventrículo$", vent_predom_regs)]
        terceiro_present <- "no terceiro ventrículo" %in% vent_predom_regs
        if (length(base_regs_predom) == 0 && terceiro_present) {
          vent_predom <- "no terceiro ventrículo"
        } else if (length(base_regs_predom) == 1 && terceiro_present) {
          vent_predom <- paste(base_regs_predom, "e no terceiro ventrículo")
        } else if (length(base_regs_predom) > 1 && terceiro_present) {
          vent_predom <- paste(
            paste(base_regs_predom, collapse = ", "),
            "e no terceiro ventrículo"
          )
        } else {
          vent_predom <- join_regions_for_predom(base_regs_predom)
        }
        ventricles_text <- paste0(severity_levels[severity_index_ventricles], " atrofia subcortical de predomínio ", vent_predom, ".")
      }
      
      # -- Summary part, keep same ----
      format_value_summary <- function(name, right_value, left_value) {
        parts <- c()
        if (right_value > 0) parts <- c(parts, paste("direito:", right_value))
        if (left_value > 0) parts <- c(parts, paste("esquerdo:", left_value))
        if (length(parts) > 0) return(paste(name, " (", paste(parts, collapse = "; "), ")", sep = ""))
        else return(NULL)
      }
      
      sulci_summary <- c(
        format_value_summary("frontal", sulci_values[1], sulci_values[2]),
        format_value_summary("parieto-occipital", sulci_values[3], sulci_values[4]),
        format_value_summary("temporal", sulci_values[5], sulci_values[6])
      )
      
      ventricles_summary <- c(
        format_value_summary("frontal", ventricles_values[1], ventricles_values[2]),
        format_value_summary("parieto-occipital", ventricles_values[3], ventricles_values[4]),
        format_value_summary("temporal", ventricles_values[5], ventricles_values[6])
      )
      if (ventricles_values[7] > 0) {
        ventricles_summary <- c(ventricles_summary, paste("terceiro ventrículo:", ventricles_values[7]))
      }
      sulci_summary <- paste(na.omit(sulci_summary), collapse = ", ")
      ventricles_summary <- paste(na.omit(ventricles_summary), collapse = ", ")
      
      summary_text_parts <- c()
      if (sulci_summary != "") {
        summary_text_parts <- c(summary_text_parts, paste0("Sulcos: ", sulci_summary, "."))
      }
      if (ventricles_summary != "") {
        summary_text_parts <- c(summary_text_parts, paste0("Ventrículos: ", ventricles_summary, "."))
      }
      summary_text <- paste(summary_text_parts, collapse = " ")
      
      formatted_gca_text <- paste(
        sulci_text,
        ventricles_text,
        "Global cortical atrophy (GCA) =", gca_sum_report, ".",
        summary_text
      )
      
      # Remove unnecessary spaces before punctuation
      cleaned_gca_text <- gsub("\\s+(?=\\.)", "", formatted_gca_text, perl = TRUE)
      return(cleaned_gca_text)
    } else {
      return("")
    }
  })
  
  ### pMTA ----
  
  mta_report_text_pt <- reactive({
    if (input$mta_switch) {
      
      idade <- input$input_age
      
      mta_esquerda <- as.numeric(substr(input$mta_left_report, 1, 1))
      mta_direita <- as.numeric(substr(input$mta_right_report, 1, 1))
      
      limiar_anormal <- ifelse(idade < 75, 2, 3)
      
      esquerda_anormal <- mta_esquerda >= limiar_anormal
      direita_anormal <- mta_direita >= limiar_anormal
      
      if (esquerda_anormal && direita_anormal && mta_esquerda == mta_direita) {
        texto_relatorio <- paste0(
          "Medial Temporal Atrophy (MTA): bilateral = ", mta_esquerda,
          "; alterado face aos valores de referência para a idade."
        )
      } else if (esquerda_anormal && direita_anormal && mta_esquerda != mta_direita) {
        texto_relatorio <- paste0(
          "Medial Temporal Atrophy (MTA): esquerdo = ", mta_esquerda,
          " e direito = ", mta_direita,
          "; alterados face aos valores de referência para a idade."
        )
      } else if (esquerda_anormal || direita_anormal) {
        lado_anormal <- ifelse(esquerda_anormal, "à esquerda", "à direita")
        lado_normal <- ifelse(esquerda_anormal, "à direita", "à esquerda")
        valor_anormal <- ifelse(esquerda_anormal, mta_esquerda, mta_direita)
        valor_normal <- ifelse(esquerda_anormal, mta_direita, mta_esquerda)
        
        texto_relatorio <- paste0(
          "Medial Temporal Atrophy (MTA): ", lado_anormal, " = ", valor_anormal,
          " e ", lado_normal, " = ", valor_normal,
          "; ", lado_anormal, " alterado e ", lado_normal, " adequado face aos valores de referência para a idade."
        )
      } else {
        if (mta_esquerda == mta_direita) {
          texto_relatorio <- paste0(
            "Medial Temporal Atrophy (MTA): bilateral = ", mta_esquerda,
            "; adequado face aos valores de referência para a idade."
          )
        } else {
          texto_relatorio <- paste0(
            "Medial Temporal Atrophy (MTA): esquerdo = ", mta_esquerda,
            " e direito = ", mta_direita,
            "; adequado face aos valores de referência para a idade."
          )
        }
      }
      
      return(texto_relatorio)
    } else {
      return("")
    }
  })
  
  ### pERICA (Escala de Atrofia Cortical Entorrinal) ---------
  erica_report_text_pt <- reactive({
    if (input$erica_switch) {
      erica_esquerda <- as.numeric(substr(input$erica_left_report, 1, 1))
      erica_direita <- as.numeric(substr(input$erica_right_report, 1, 1))
      
      if (erica_esquerda >= 2 && erica_direita >= 2) {
        if (erica_esquerda == erica_direita) {
          texto_relatorio <- paste0(
            "Entorhinal Cortical Atrophy (ERICA): bilateral = ", erica_esquerda,
            "; pode sugerir patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
          )
        } else {
          texto_relatorio <- paste0(
            "Entorhinal Cortical Atrophy (ERICA): direito = ", erica_direita,
            " e esquerdo = ", erica_esquerda,
            "; pode sugerir patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
          )
        }
      } else if (erica_esquerda >= 2 || erica_direita >= 2) {
        texto_relatorio <- paste0(
          "Entorhinal Cortical Atrophy (ERICA): direito = ", erica_direita,
          " e esquerdo = ", erica_esquerda,
          "; ", ifelse(erica_esquerda >= 2, "à esquerda", "à direita"),
          " pode sugerir patologia neurodegenerativa, enquanto ",
          ifelse(erica_esquerda >= 2, "à direita", "à esquerda"),
          " não apoia patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
        )
      } else {
        if (erica_esquerda == erica_direita) {
          texto_relatorio <- paste0(
            "Entorhinal Cortical Atrophy (ERICA): bilateral = ", erica_esquerda,
            "; não apoia patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
          )
        } else {
          texto_relatorio <- paste0(
            "Entorhinal Cortical Atrophy (ERICA): direito = ", erica_direita,
            " e esquerdo = ", erica_esquerda,
            "; não apoia patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
          )
        }
      }
      
      return(texto_relatorio)
    }
  })
  
  ### PCA (Escala de Atrofia Parietal Posterior - Koedam) ---------
  pca_report_text_pt <- reactive({
    if (input$pca_switch) {
      pca_esquerda <- as.numeric(substr(input$pca_left_report, 1, 1))
      pca_direita <- as.numeric(substr(input$pca_right_report, 1, 1))
      
      texto_relatorio <- ""
      
      if (pca_esquerda == pca_direita) {
        texto_relatorio <- paste0("Posterior parietal atrophy (Koedam): bilateral = ", pca_esquerda, ".")
      } else {
        if (pca_esquerda > pca_direita) {
          texto_relatorio <- paste0("Posterior parietal atrophy (Koedam): esquerdo = ", pca_esquerda, " e direito = ", pca_direita, ".")
        } else {
          texto_relatorio <- paste0("Posterior parietal atrophy (Koedam): direito = ", pca_direita, " e esquerdo = ", pca_esquerda, ".")
        }
      }
      
      return(texto_relatorio)
    } else {
      return("")
    }
  })
  
  ### psSVDs ------
  
  ssvds_report_text_pt <- reactive({
    total_score <- lacunar_infarcts_score() + 
      cerebral_microbleeds_score() + 
      perivascular_spaces_score() + 
      white_matter_hyperintensities_score()
    
    points_text <- ifelse(total_score == 1, "ponto", "pontos")
    
    paste0("Resumo do score da doença de pequenos vasos (SVD) = ", total_score, " ", points_text, ".")
  })
  
  ## final report ------
  
  createStyledBlock <- function(content) {
    return(HTML(paste0(
      '<div style="border: 1px solid #ccc; padding: 15px; margin: 10px 0; border-radius: 5px; background-color: #f9f9f9; font-family: Arial, sans-serif; font-size: 17px; line-height: 2 !important;">',
      content,
      '</div>'
    )))
  }
  
  
  output$final_report <- renderUI({
    lang <- input$lang
    report_content <- NULL
    
    if (lang == "English") {
      if (!is.null(input$rsi_switch) && input$rsi_switch) {
        rsi_content <- rsi_report_text()
        report_content <- ifelse(is.null(report_content), rsi_content, paste(report_content, rsi_content, sep="<br>"))
      }
      if (!is.null(input$li_switch) && input$li_switch) {
        li_content <- li_report_text()
        report_content <- ifelse(is.null(report_content), li_content, paste(report_content, li_content, sep="<br>"))
      }
      if (!is.null(input$fazekas_switch) && input$fazekas_switch) {
        fazekas_content <- fazekas_report_text()
        report_content <- ifelse(is.null(report_content), fazekas_content, paste(report_content, fazekas_content, sep="<br>"))
      }
      if (!is.null(input$pvs_switch) && input$pvs_switch) {
        pvs_content <- pvs_report_text()
        report_content <- ifelse(is.null(report_content), pvs_content, paste(report_content, pvs_content, sep="<br>"))
      }
      if (!is.null(input$mb_switch) && input$mb_switch) {
        mb_content <- mb_report_text()
        report_content <- ifelse(is.null(report_content), mb_content, paste(report_content, mb_content, sep="<br>"))
      }
      if (!is.null(input$css_switch) && input$css_switch) {
        css_content <- css_report_text()
        report_content <- ifelse(is.null(report_content), css_content, paste(report_content, css_content, sep="<br>"))
      }
      if (!is.null(input$gca_switch) && input$gca_switch) {
        gca_content <- gca_report_text()
        report_content <- ifelse(is.null(report_content), gca_content, paste(report_content, gca_content, sep="<br>"))
      }
      if (!is.null(input$mta_switch) && input$mta_switch) {
        mta_content <- mta_report_text()
        report_content <- ifelse(is.null(report_content), mta_content, paste(report_content, mta_content, sep="<br>"))
      }
      if (!is.null(input$erica_switch) && input$erica_switch) {
        erica_content <- erica_report_text()
        report_content <- ifelse(is.null(report_content), erica_content, paste(report_content, erica_content, sep="<br>"))
      }
      if (!is.null(input$pca_switch) && input$pca_switch) {
        pca_content <- pca_report_text()
        report_content <- ifelse(is.null(report_content), pca_content, paste(report_content, pca_content, sep="<br>"))
      }
      if (!is.null(input$ssvds_switch) && input$ssvds_switch) {
        ssvds_content <- ssvds_report_text()
        report_content <- ifelse(is.null(report_content), ssvds_content, paste(report_content, ssvds_content, sep="<br>"))
      }
    } else if (lang == "Português (Portugal)") {
      if (!is.null(input$rsi_switch) && input$rsi_switch) {
        rsi_content <- rsi_report_text_pt()
        report_content <- ifelse(is.null(report_content), rsi_content, paste(report_content, rsi_content, sep="<br>"))
      }
      if (!is.null(input$li_switch) && input$li_switch) {
        li_content <- li_report_text_pt()
        report_content <- ifelse(is.null(report_content), li_content, paste(report_content, li_content, sep="<br>"))
      }
      if (!is.null(input$fazekas_switch) && input$fazekas_switch) {
        fazekas_content <- fazekas_report_text_pt()
        report_content <- ifelse(is.null(report_content), fazekas_content, paste(report_content, fazekas_content, sep="<br>"))
      }
      if (!is.null(input$pvs_switch) && input$pvs_switch) {
        pvs_content <- pvs_report_text_pt()
        report_content <- ifelse(is.null(report_content), pvs_content, paste(report_content, pvs_content, sep="<br>"))
      }
      if (!is.null(input$mb_switch) && input$mb_switch) {
        mb_content <- mb_report_text_pt()
        report_content <- ifelse(is.null(report_content), mb_content, paste(report_content, mb_content, sep="<br>"))
      }
      if (!is.null(input$css_switch) && input$css_switch) {
        css_content <- css_report_text_pt()
        report_content <- ifelse(is.null(report_content), css_content, paste(report_content, css_content, sep="<br>"))
      }
      if (!is.null(input$gca_switch) && input$gca_switch) {
        gca_content <- gca_report_text_pt()
        report_content <- ifelse(is.null(report_content), gca_content, paste(report_content, gca_content, sep="<br>"))
      }
      if (!is.null(input$mta_switch) && input$mta_switch) {
        mta_content <- mta_report_text_pt()
        report_content <- ifelse(is.null(report_content), mta_content, paste(report_content, mta_content, sep="<br>"))
      }
      if (!is.null(input$erica_switch) && input$erica_switch) {
        erica_content <- erica_report_text_pt()
        report_content <- ifelse(is.null(report_content), erica_content, paste(report_content, erica_content, sep="<br>"))
      }
      if (!is.null(input$pca_switch) && input$pca_switch) {
        pca_content <- pca_report_text_pt()
        report_content <- ifelse(is.null(report_content), pca_content, paste(report_content, pca_content, sep="<br>"))
      }
      if (!is.null(input$ssvds_switch) && input$ssvds_switch) {
        ssvds_content <- ssvds_report_text_pt()
        report_content <- ifelse(is.null(report_content), ssvds_content, paste(report_content, ssvds_content, sep="<br>"))
      }
    }
    
    HTML(createStyledBlock(report_content))
  })
  
  ## export to excel -----
  # Reactive expression to gather data
  report_data <- reactive({
    data.frame(
      PatientInfo = data.frame(
        Sex = input$input_sex,
        Age = input$input_age
      ),
      RSI = data.frame(
        RecentSmallInfarcts = paste(input$recentsmallinfarct, collapse = ", ")
      ),
      LI = data.frame(
        LacunarInfarcts = paste(input$lacunar_infarcts, collapse = ", ")
      ),
      Fazekas = data.frame(
        PeriventricularGrade = input$periventricular_grade,
        PeriventricularDistribution = input$periventricular_distribution,
        PeriventricularLaterality = input$periventricular_laterality,
        DeepWhiteMatterGrade = input$deep_white_matter_grade,
        DeepWhiteMatterDistribution = input$deep_white_matter_distribution,
        DeepWhiteMatterLaterality = input$deep_white_matter_laterality
      ),
      PVS = data.frame(
        CentrumSemiovale = input$pvs_centrum_semiovale,
        BasalGanglia = input$pvs_basal_ganglia,
        Mesencephalon = input$pvs_mesencephalon
      ),
      Microbleeds = data.frame(
        BrainstemDefiniteRight = input$brainstem_definite_right,
        BrainstemDefiniteLeft = input$brainstem_definite_left,
        BrainstemPossibleRight = input$brainstem_possible_right,
        BrainstemPossibleLeft = input$brainstem_possible_left,
        CerebellumDefiniteRight = input$cerebellum_definite_right,
        CerebellumDefiniteLeft = input$cerebellum_definite_left,
        CerebellumPossibleRight = input$cerebellum_possible_right,
        CerebellumPossibleLeft = input$cerebellum_possible_left,
        BasalGangliaDefiniteRight = input$basal_ganglia_definite_right,
        BasalGangliaDefiniteLeft = input$basal_ganglia_definite_left,
        BasalGangliaPossibleRight = input$basal_ganglia_possible_right,
        BasalGangliaPossibleLeft = input$basal_ganglia_possible_left,
        ThalamusDefiniteRight = input$thalamus_definite_right,
        ThalamusDefiniteLeft = input$thalamus_definite_left,
        ThalamusPossibleRight = input$thalamus_possible_right,
        ThalamusPossibleLeft = input$thalamus_possible_left,
        InternalCapsuleDefiniteRight = input$internal_capsule_definite_right,
        InternalCapsuleDefiniteLeft = input$internal_capsule_definite_left,
        InternalCapsulePossibleRight = input$internal_capsule_possible_right,
        InternalCapsulePossibleLeft = input$internal_capsule_possible_left,
        ExternalCapsuleDefiniteRight = input$external_capsule_definite_right,
        ExternalCapsuleDefiniteLeft = input$external_capsule_definite_left,
        ExternalCapsulePossibleRight = input$external_capsule_possible_right,
        ExternalCapsulePossibleLeft = input$external_capsule_possible_left,
        CorpusCallosumDefiniteRight = input$corpus_callosum_definite_right,
        CorpusCallosumDefiniteLeft = input$corpus_callosum_definite_left,
        CorpusCallosumPossibleRight = input$corpus_callosum_possible_right,
        CorpusCallosumPossibleLeft = input$corpus_callosum_possible_left,
        DeepPVWhiteDefiniteRight = input$deep_pvwhite_definite_right,
        DeepPVWhiteDefiniteLeft = input$deep_pvwhite_definite_left,
        DeepPVWhitePossibleRight = input$deep_pvwhite_possible_right,
        DeepPVWhitePossibleLeft = input$deep_pvwhite_possible_left,
        FrontalDefiniteRight = input$frontal_definite_right,
        FrontalDefiniteLeft = input$frontal_definite_left,
        FrontalPossibleRight = input$frontal_possible_right,
        FrontalPossibleLeft = input$frontal_possible_left,
        ParietalDefiniteRight = input$parietal_definite_right,
        ParietalDefiniteLeft = input$parietal_definite_left,
        ParietalPossibleRight = input$parietal_possible_right,
        ParietalPossibleLeft = input$parietal_possible_left,
        TemporalDefiniteRight = input$temporal_definite_right,
        TemporalDefiniteLeft = input$temporal_definite_left,
        TemporalPossibleRight = input$temporal_possible_right,
        TemporalPossibleLeft = input$temporal_possible_left,
        OccipitalDefiniteRight = input$occipital_definite_right,
        OccipitalDefiniteLeft = input$occipital_definite_left,
        OccipitalPossibleRight = input$occipital_possible_right,
        OccipitalPossibleLeft = input$occipital_possible_left,
        InsulaDefiniteRight = input$insula_definite_right,
        InsulaDefiniteLeft = input$insula_definite_left,
        InsulaPossibleRight = input$insula_possible_right,
        InsulaPossibleLeft = input$insula_possible_left
      ),
      CSS = data.frame(
        SuperficialSiderosisRight = input$superficial_siderosis_right,
        SuperficialSiderosisLeft = input$superficial_siderosis_left
      ),
      GCA = data.frame(
        FrontalSulciRight = input$frontal_sulci_right_report,
        FrontalSulciLeft = input$frontal_sulci_left_report,
        FrontalVentriclesRight = input$frontal_ventricles_right_report,
        FrontalVentriclesLeft = input$frontal_ventricles_left_report,
        ParietoSulciRight = input$parietal_sulci_right_report,
        ParietoSulciLeft = input$parietal_sulci_left_report,
        ParietoVentriclesRight = input$parietal_ventricles_right_report,
        ParietoVentriclesLeft = input$parietal_ventricles_left_report,
        TemporalSulciRight = input$temporal_sulci_right_report,
        TemporalSulciLeft = input$temporal_sulci_left_report,
        TemporalVentriclesRight = input$temporal_ventricles_right_report,
        TemporalVentriclesLeft = input$temporal_ventricles_left_report,
        ThirdVentricle = input$third_ventricle_report
      ),
      MTA = data.frame(
        MTARight = input$mta_right_report,
        MTALeft = input$mta_left_report
      ),
      ERICA = data.frame(
        ERICARight = input$erica_right_report,
        ERICALeft = input$erica_left_report
      ),
      PCA = data.frame(
        PCARight = input$pca_right_report,
        PCALeft = input$pca_left_report
      ),
      SSVDSummary = data.frame(
        SSVDSReport = ssvds_report_text()
      )
    )
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("aurorareport_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".xlsx", sep = "")
    },
    content = function(file) {
      write_xlsx(report_data(), path = file)
    }
  )
} 

# Run the application 
shinyApp(ui = ui, server = server)