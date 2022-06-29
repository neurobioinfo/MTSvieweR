fluidPage(
  titlePanel(
    title = 
      tags$a( target = "_blank",
              tags$div(style = "float:right",
                       tags$img(style = "width:150px", src="mcgill.png"),
                       tags$img(style = "width:50px", src="neuro.png")),
              tags$div(style = "float:center",
                       tags$img(style = "width:400px", src="MTSViewer.png")
                       
              )
      ),
    windowTitle = "MTSviewer"
  ), tags$head(tags$style('h3 {font-family: Helvetica; font-weight: Bold;}')), 
  tags$head(tags$style('h1 {font-family: Helvetica; font-weight: Bold;}')),
  tags$head(tags$style('h4 {font-family: Helvetica; font-weight: Bold;}')),
  
  
  
  
  tabsetPanel(
    id = "mainTabsetPanel",
    tabPanel("Home",br(), br(),
             mainPanel(box(
               h4("Welcome to MTSviewer, a database of human and yeast mitochondrial proteins integrating: "),br(),
               "  - MTS and cleavage site predictions", br(), 
               "  - Genetic variants", br(),
               "  - Pathogenicity predictions", br(),
               "  - N-terminomics data", br(),
               "  - Structural visualization using AlphaFold models", br(), br(),
               
               tags$a("Click here for a PDF user guide to teach you how to use MTSviewer and all of its functions!", href="userguide.pdf"), br(),
               
               h4("Using this platform, we have generated a list of disease-linked variants in protein MTS's and their predicted consequences as a resource for their functional characterization. 
               Overall, MTSviewer is a platform that can be used to interrogate MTS mutations and their potential effects on import and proteolysis across the mitochondrial proteome.", br(), br(),
                  "Click on the MTSviewer tab and start interrogating your favorite protein(s)  listed in the dropdown menu!", br(), br(), br()), width = 8),
               
               tags$img(style = "width:800px", src="GA.png"),
               tags$div(style="line-height:25%;", br())
               
             )
             
    ),
    
    tabPanel("MTSviewer",
             sidebarLayout(
               sidebarPanel(tags$head(
                 tags$style(HTML("
      .selectize-input { font-size: 11px; line-height: 11px;} 
                 .selectize-dropdown { font-size: 13px; line-height: 13px; }
                 .form-group, .selectize-control {margin-bottom:-0px;max-height: 100px !important;}
                 .box-body {
          padding-bottom: 0px;
      }
    "))
               ),
               
               selectInput("Organism","Organism", c("Human", "Yeast")),
               
               
               selectizeInput('Genes',' Choose Genes', 
                              choices = na.omit(unique(gene_index[,"Genes"]))), width=2,
               selectInput("database", "Database", c("ClinVar", "GnomAD")),
               selectInput("colouring", "Colouring", c("iMTS","AlphaFold")),
               selectInput("type", "Type", c("cartoon","ball+stick", "backbone")),
               selectInput("Variant", "Show Variants?", c("Pathogenic", "Benign", "Uncertain"), multiple = TRUE),
               fileInput("variant_upload", "Upload Variants", 
                         multiple = FALSE, 
                         accept = c(".csv")
               ), 
               
               a(href="samplefile.csv", "Sample Variant File (see FAQ)", download=NA, target="_blank")
               #downloadLink("samplefile.csv","Sample Variant File (see FAQ)")
               
               ),
               
               mainPanel(div(
                 width = 40,
                 
                 fluidRow(h1(textOutput("genetitle")), textOutput("flag"), tags$head(tags$style("#flag{color: red;font-size: 20px;font-style: italic;}")),
                          h4(textOutput("genedescription")),
                          
                          column(11, title = "structure", NGLVieweROutput("structure")),
                          
                          column(1, imageOutput("legend")), div(style = "display:inline-block; float:right", actionButton("NGLView", "Reset View"))),
                 
                 #fluidRow(h3("iMLP curves"), 
                 fluidRow(a(href="http://imlp.bio.uni-kl.de/", h3("iMLP curves")), 
                          title = "Plot_text",plotlyOutput('plotxy2'), verbatimTextOutput("click")),hr(),
                 
                 h3("Sequence"), uiOutput("AAseq"),hr(),
                 
                 fluidRow(h3("Mutation List"), column(DT::dataTableOutput('mutations'), width = 12)),hr(),
                 
                 fluidRow(
                   h5(downloadButton('downloadData', 'Download')), h3("Cleavage Site Predictions"), br(), a(href="http://mitf.cbrc.jp/MitoFates/cgi-bin/top.cgi", h4("MitoFates")), column(DT::dataTableOutput('MitoFates'), width = 12), br(), a(href="https://services.healthtech.dtu.dk/service.php?TargetP-2.0", h4("TargetP")), column(dataTableOutput('TargetP'), width = 12), br(),  a(href="https://tppred3.biocomp.unibo.it/welcome/default/index", h4("TPPred3")), column(DT::dataTableOutput('TPPred3'),width = 12),  solidHeader = T, status = 'warning'), 
                 hr(),
                 
                 fluidRow(a(href="https://topfind.clip.msl.ubc.ca/", h3("TopFind")), column(h5(DT::dataTableOutput('TopFind')), width=12))),hr(),
                 
                 fluidRow(a(href="http://busca.biocomp.unibo.it/deepmito/", h3("DeepMito")), column(h5(DT::dataTableOutput('DeepMito')), width = 12),hr(),
                          
                 ),class = "span25",tags$div(style="line-height:100%;", hr())))
             
             
    ),
    
    tabPanel("Human MTS mutations", 
             
             fluidRow(title = "All mutations", DT::dataTableOutput('all_mutations'))
             
    ),
    
    tabPanel("FAQ", 
             
             fluidRow(title = "Questions", faq::faq(data=faqdf2, elementId = "faq", faqtitle = "Frequently Asked Questions"))),
    
    tabPanel("Contact us", 
             
             mainPanel(br(), h4("To report bugs, comments, or to submit custom proteins to be added to MTSviewer, please e-mail: "), a(href="mailto:mtsviewer.docs@gmail.com", h5("mtsviewer.docs@gmail.com")),h5("If you are requesting specific proteins to be added to MTSViewer, please attach a FASTA file of interest."))),
    
    
    tabPanel("How to cite us", 
             mainPanel(br(), h4("When using MTSviewer please cite: "), h5("MTSviewer: a database to visualize mitochondrial targeting sequences, cleavage sites, and mutations on protein structures
Andrew N. Bayne, Jing Dong, Saeid Amiri, Sali M.K. Farhan, Jean-Francois Trempe
bioRxiv 2021.11.25.470064;doi: https://doi.org/10.1101/2021.11.25.470064")))
  )
)


