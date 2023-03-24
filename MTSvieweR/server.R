
shinyServer(function(input, output,session) {


  
  uniprot <- reactiveValues()
  observeEvent(input$Genes,{
    req(input$Genes)
    filtered <- gene_index[gene_index["Organism"]== input$Organism,]
    uniprot$a <- filtered[filtered["Genes"]==input$Genes, 'Uniprot']
  })

  
  XYCG_data <- reactiveValues(c=XYC_HY)
  XYCG_data$g <- XYG_HY
  
  
  
  
  observeEvent(input$Organism, {
    updateSelectizeInput(session, "Genes", choice = na.omit(unique(gene_index[gene_index[,"Organism"]== input$Organism,"Genes"])))

  })
  
 
  
  observeEvent(input$variant_upload,{
    
    ###Merge User upload to clinvar 
    tryCatch({
      user_var <- read.csv2(input$variant_upload$datapath, sep = ",")
      user_var[,"label"] <- apply(user_var, 1, Checkaa)
      
      user_data = merge(user_var, XY_HY1, by = c("Uniprot", "amino.acid"))
      user_data = rename(user_data, c("iMTS.value" = "value"))
      XYCG_data$c <- dplyr::bind_rows(XYC_HY, user_data)
      XYCG_data$g <- dplyr::bind_rows(XYG_HY, user_data)
      
      updateSelectInput(session, "Variant", 
                        choices = c("Pathogenic", "Benign", "Uncertain", "User"))
      
    },
    error = function(cond) {
      shinyalert("Error: Failed to read csv. Please ensure that the correct header names are used and amino acid changes are reported using the following format: p.Leu23Arg")
    })
    
  })
  
  Checkaa <- function(x){
    
    transcript <- gene_index[gene_index["Uniprot"]==x["Uniprot"],"aa"] 
    
    
    if (AA_library[AA_library["Let3"]==str_sub(x["HGVSp_VEP"],3,5), "Let1"] != str_sub(transcript,x["amino.acid"], x["amino.acid"])){
      return("Mismatch")
    }
    else{
      return("User")
    }
  }
  
  
  
  
  ###Title of Module###
  
  output$genetitle <- renderText({
    paste(gene_index[gene_index[,"Uniprot"]==uniprot$a, "ID"])
  })
  
  output$genedescription <- renderText({
    paste(gene_index[gene_index[,"Uniprot"]==uniprot$a, "IMPI"])
  })
  
  
  
  output$AAseq <- renderUI({
    sequence()
  })
  
  HL_aa <- reactiveVal(1)
  
  observeEvent(clk(), {
    HL_aa(clk()[,'x'])
  })
  
  
  
  
  sequence = reactive({



    aa_seq = strsplit(gene_index[gene_index[,"Uniprot"]==uniprot$a, "aa"], "")[[1]]

    seqoutput = "<div style= 'font-family: Courier New'>"

    count = 0

    for (x in aa_seq) {

      if (count %% 70 == 0){
        seqoutput = paste(seqoutput, "</br><br>", sep="")
      }

      if (count %% 10 == 0 && count == 0){
        #seqoutput = paste(seqoutput,"   ", toString(count+1),"   ", sep="   ")
        seqoutput = paste(seqoutput,"&nbsp;&nbsp;&nbsp;&nbsp;", toString(count+1),"&nbsp;", sep="")
      }


      if (count %% 10 == 0 && count < 100 && count > 9){
        #seqoutput = paste(seqoutput,"   ", toString(count+1),"   ", sep="   ")
        seqoutput = paste(seqoutput,"&nbsp;&nbsp;&nbsp;", toString(count+1),"&nbsp;", sep="")
      }

      if (count %% 10 == 0 && count < 1000 && count > 99){
        #seqoutput = paste(seqoutput,"   ", toString(count+1),"   ", sep="   ")
        seqoutput = paste(seqoutput,"&nbsp;&nbsp;", toString(count+1),"&nbsp;", sep="")
      }


      if (count %% 10 == 0 && count > 999){
        #seqoutput = paste(seqoutput,"   ", toString(count+1),"   ", sep="   ")
        seqoutput = paste(seqoutput,"&nbsp;", toString(count+1),"&nbsp;", sep="")
      }


      if (count==HL_aa()-1){
        seqoutput = paste(seqoutput,"<span style = 'background-color: yellow; color: black'><strong>",x,"</strong></span>", sep="")
        count = count + 1
      }

      else {
        seqoutput = paste(seqoutput,x, sep="")
        count = count + 1
      }

    }

    seqoutput = paste0(seqoutput, "</div>")
    sequence <- HTML(seqoutput)


  })

  
  ###All mutations page###
  output$all_mutations = DT::renderDataTable({
    DT::datatable(XYC_HY, options = list(order = list(3,'desc'), pageLength = 1000))
  })
  
  ###MTS counting page###
  output$MTScounting = DT::renderDataTable({
    DT::datatable(MTScounting, options = list(order = list(6,'desc'), pageLength = 1000))
  })
  
  ###Alpha fold or iMTS legend###
  output$legend <- renderImage({
    list(src = paste("./WWW/", toString(structure_legend()), sep=""),
         width = 252.4,
         height = 356.4)
    
  }, deleteFile=FALSE)
  
  
  ###index to determine the viewer for Plotly###
  
  datalen = reactive({
    len <- gene_index[gene_index[,"Uniprot"]==uniprot$a,]
    datalen = len[,"Length"]
  })
  
  
  ###XY curves to plot on plotly###
  dataXY = reactive({
    XY0<-XY_HY1[XY_HY1[,1]==uniprot$a,]
    dataXY=XY0
    
  })

  
  ### XYCG to plot clinvar or GnomAD mutations onto plotly###
  
  dataXYCG = reactive({
  
    if (input$database == "ClinVar"){
      XYCG0<-XYCG_data$c[XYCG_data$c[,"Uniprot"]==uniprot$a,]
      dataXYCG=XYCG0[!is.na(XYCG0[,"iMTS.value"]),]
    }
    
    else{
      XYCG0<-XYCG_data$g[XYCG_data$g[,"Uniprot"]==uniprot$a,]
      dataXYCG=XYCG0[!is.na(XYCG0[,"iMTS.value"]),]
    }
    
  })
  
  ###Cleavage values####

  cleavagetable = reactive({
    cleavagetable = cleavagesites[cleavagesites["Uniprot"]== uniprot$a,]
    
  }
  )
  
  ### Reactive functions to plot mutations onto NGL Viewer Structure ###
  
  Pathogenic = reactive({
    req(input$Variant)
    if (input$database == "ClinVar") {
      uncert <- XYCG_data$c
    }
    else{
      uncert <- XYCG_data$g
    }
    placeholder1<-uncert[uncert[,"Uniprot"]==uniprot$a,]
    placeholder2=placeholder1[!is.na(placeholder1[,3]),]
    x <- ""
    for (n in 1:nrow(placeholder2)){
      aa <- placeholder2[n, "amino.acid"]
      clinsig <- placeholder2[n,"label"]
      
      
      if(toString(clinsig)=="Pathogenic"){
        
        x = paste(x, " or ", aa, sep = "")
      }
    }

    if(("Pathogenic" %in% input$Variant)&(x!="")){
        Pathogenic=x
      }
    else{
      Pathogenic = 0
    }
    
  })
  
  
  Benign = reactive({
    req(input$Variant)
    if (input$database == "ClinVar") {
      uncert <- XYCG_data$c
    }
    else{
      uncert <- XYCG_data$g
    }
    placeholder1<-uncert[uncert[,"Uniprot"]==uniprot$a,]
    placeholder2=placeholder1[!is.na(placeholder1[,3]),]
    
    x <- ""
    for (n in 1:nrow(placeholder2)){
      aa <- placeholder2[n, "amino.acid"]
      clinsig <- placeholder2[n,"label"]
      
      if(toString(clinsig)=="Benign"){
        x = paste(x, " or ", aa, sep = "")
      }
    }
    
    if(("Benign" %in% input$Variant)&(x!="")){
      Benign=x
    }
    else{
      Benign = 0
    }
  })
  
  Uncertain = reactive({
    req(input$Variant)
    if (input$database == "ClinVar") {
      uncert <- XYCG_data$c
    }
    else{
      uncert <- XYCG_data$g
    }
    placeholder1<-uncert[uncert[,"Uniprot"]==uniprot$a,]
    placeholder2=placeholder1[!is.na(placeholder1[,3]),]
    
    x <- ""
    for (n in 1:nrow(placeholder2)){
      aa <- placeholder2[n, "amino.acid"]
      clinsig <- placeholder2[n,"label"]
      
      if(toString(clinsig)=="Uncertain"){
        
        x = paste(x, " or ", aa, sep = "")
      }
    }
    if(("Uncertain" %in% input$Variant)&(x!="")){
      Uncertain=x
    }
    else{
      Uncertain = 0
    }
  })
  
  
  
  User = reactive({
    req(input$Variant)
    if (input$database == "ClinVar") {
      uncert <- XYCG_data$c
    }
    else{
      uncert <- XYCG_data$g
    }
    placeholder1<-uncert[uncert[,"Uniprot"]==uniprot$a,]

    x <- ""
    for (n in 1:nrow(placeholder1)){
      aa <- placeholder1[n, "amino.acid"]
      clinsig <- placeholder1[n,"label"]
      
      
      if(toString(clinsig)=="User"){
        
        x = paste(x, " or ", aa, sep = "")
      }
    }
    if(("User" %in% input$Variant)&(x!="")){
      User=x
    }
    else{
      User = 0
    }
  })
  
  
  
  ###Displaying AlphaFold or iMTS scores###
  
  structure_file = reactive({
    
    if (input$colouring == "AlphaFold"){
      structure_file<-"PDB_original/"
    }
    
    else {
      structure_file<-"PDB_extracted/"
      
    }
  })
  
  structure_col = reactive({
    
    if (input$colouring == "AlphaFold"){
      structure_col<-"RdYlBu"
    }
    
    else {
      structure_col<-"Blues"
      
    }
  })
  
  structure_dom = reactive({
    
    if (input$colouring == "AlphaFold"){
      structure_dom<-""
    }
    
    else {
      structure_dom<-"0,6"
      
    }
  })
  
  
  structure_legend = reactive({
    
    if (input$colouring == "AlphaFold"){
      structure_legend<-"AFconfidence.png"
    }
    
    else {
      structure_legend<-"iMTS_Final.png"
      
    }
  })

  
  datamutations = reactive({
    if (input$database == "ClinVar"){
      datamutations <- XYCG_data$c[XYCG_data$c[,"Uniprot"]==uniprot$a,]
    }
    
    else{
      datamutations <- XYCG_data$g[XYCG_data$g[,"Uniprot"]==uniprot$a,]
    }
    
  })
  
  output$TPPred3 = DT::renderDataTable({
    DT::datatable(TPPred_HY[TPPred_HY[,"Uniprot"]==uniprot$a,], options = list(scrollX = TRUE, searching = FALSE, paging = FALSE))
    
  })
  
  output$MitoFates = DT::renderDataTable({
    DT::datatable(MitoFates_HY[MitoFates_HY[,"Uniprot"]==uniprot$a,], options = list(scrollX = TRUE, searching = FALSE, paging = FALSE))
  })
  
  output$mutations = DT::renderDataTable({
    DT::datatable(datamutations(), options = list(order = list(3, 'asc'), scrollX = TRUE))
  })
  

  output$TopFind = DT::renderDataTable({
    DT::datatable(TopFind_HY[TopFind_HY[,"Uniprot"]==uniprot$a,], options = list(scrollX = TRUE, searching = FALSE, paging = FALSE))
  })


  output$TargetP = DT::renderDataTable({
    DT::datatable(TargetP_HY[TargetP_HY[,"Uniprot"]==uniprot$a,], options = list(scrollX = TRUE, searching = FALSE, paging = FALSE))
  })
  
  
  output$DeepMito = DT::renderDataTable({
    DT::datatable(DeepMito_HY[DeepMito_HY[,"Uniprot"]==uniprot$a,], options = list(scrollX = TRUE, searching = FALSE, paging = FALSE))
  })
  
  ###Download button###
  output$downloadData <- downloadHandler(
    filename = function() {
      paste('data-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(datamutations(), con)
    }
  )
  
  output$samplefile <- downloadHandler(
    filename = function() {
      paste('samplefile.csv', sep='')
    },
    content = function(con) {
      write.csv(sample, con)
    }
  )
  
  
  ################ Plot 2
  output$plotxy2 = renderPlotly({
    
    pp<-ggplot(dataXY(), aes(y=dataXY()[,"value"], x=dataXY()[,"amino.acid"]))+
      geom_line()+
      suppressWarnings(geom_point(data=dataXYCG(),aes(x=dataXYCG()[,"amino.acid"], y=dataXYCG()[,"iMTS.value"], color= label, text=sprintf("Protein.Change: %s<br>NT.Change: %s", dataXYCG()[,"HGVSp_VEP"], dataXYCG()[,"HGVSc_VEP"])), show.legend = FALSE))+
      scale_color_manual(values = c("Benign" = "green4", "Pathogenic" = "red", "Uncertain" = "black", "User" = "purple", "TPPred3" = "blue", "MEROPS" = "red", "MitoFates" = "green", "TargetP" = "orange", "TopFINDnt" = "black", "No Cleavages" = "gray"))+
      xlab("Amino Acid Number")+
      coord_cartesian(xlim = c(1,as.integer(datalen())), ylim = c(-2,6))+
      scale_x_continuous(breaks = seq(0, datalen(), by = 10), minor_breaks = seq(0, datalen(), by = 1))+
      theme(axis.text.x = element_text(angle=90, size=8))+
      ylab("iMTS Score")+
      
      geom_vline(aes(xintercept = Position, color = Source, text=sprintf("Source: %s<br>Position: %s", cleavagetable()[,"Source"], cleavagetable()[,"Position"])), linetype= "dashed", cleavagetable(), show.legend = FALSE)

    ggplotly(pp,tooltip="text")
  })
  
  ####### NGLViewer ##########
  output$structure <- renderNGLVieweR({
    NGLVieweR(paste("./PDBs/",toString(structure_file()),toString(uniprot$a),".pdb", sep = "")) %>%
      addRepresentation(input$type,
                        param = list(
                          name = "cartoon", colorScheme = "bfactor", colorScale = toString(structure_col()), colorDomain = structure_dom())
      ) %>%
      
      stageParameters(backgroundColor = "white") %>%
      setQuality("high") %>%
      setFocus(0) %>%
      selectionParameters(5, "residue")
  })

  
  ####Reset View#### 
  observeEvent(input$NGLView, {
    NGLVieweR_proxy("structure")%>%
      updateZoomMove(
        center = "*",
        zoom = "*",
        z_offSet = 0, 
        duration = 1000
      )
    
  })
  
  
  ListentoMutants <- reactive({
    list(input$Variant, input$database)
  })
  
  observeEvent(ListentoMutants(),{
    NGLVieweR_proxy("structure") %>% removeSelection("clinvar")
    NGLVieweR_proxy("structure") %>% removeSelection("benign")
    NGLVieweR_proxy("structure") %>% removeSelection("uncertain")
    NGLVieweR_proxy("structure") %>% removeSelection("user")
    
    NGLVieweR_proxy("structure") %>%
    
        
      addSelection("ball+stick",
                   param = list(
                     name = "clinvar",
                     color = "red",
                     probeRadius = 0.01,
                     labelType = "res",
                     sele = Pathogenic())
      )%>%
      addSelection("ball+stick",
                   param = list(
                     name = "benign",
                     color = "green",
                     probeRadius = 0.01,
                     labelType = "res",
                     sele = Benign())
      )%>%
      
      addSelection("ball+stick",
                   param = list(
                     name = "user",
                     color = "purple",
                     probeRadius = 0.01,
                     labelType = "res",
                     sele = User())
      )%>%
      
      
      addSelection("ball+stick",
                   param = list(
                     name = "uncertain",
                     color = "black",
                     probeRadius = 0.01,
                     labelType = "res",
                     sele = Uncertain())
      )
    
  })
  
  #Save click selections
  sele <- reactiveValues()
  
  observe({
    sele$aa <-
      str_extract(input$structure_selection, "(?<=[\\[])(.*?)(?=\\])")
    sele$aa_bond <-
      str_extract(input$structure_selection, "(?<=[\\]])(.*?)(?=[:space:])")
    sele$resiChain <-
      str_extract(input$structure_selection, "(?<=[]])(.*?)(?=[.])")
    sele$resi <-
      str_extract(input$structure_selection, "(?<=[]])(.*?)(?=[:])")
    sele$fileName <-
      str_extract(input$structure_selection, "(?<=[(])(.*?)(?=[.])")
  })
  
  output$selection = renderPrint({
    #Full selection
    print(input$structure_selection)
    #Amino Acid
    print(sele$aa)
    #Bond
    print(sele$aa_bond)
    #Residue number + ChainNAme
    print(sele$resiChain)
    #Residue number
    print(sele$resi)
    #PDB name
    print(sele$fileName)
    #SelAround
    print(input$structure_selAround)
  })
  
  observeEvent(input$structure_selAround, {
    NGLVieweR_proxy("structure") %>% removeSelection("selAround")
    NGLVieweR_proxy("structure") %>% removeSelection("selected")
    
    
    NGLVieweR_proxy("structure") %>%
      addSelection(
        "ball+stick",
        param =
          list(
            name = "selAround",
            sele = input$structure_selAround
            #colorValue = "yellow"
          )
      )%>%
      
      
      addSelection("ball+stick",
                   param = list(
                     name = "selected",
                     sele = sele$resi,
                     colorValue = "orange"
                   )
                   
      ) 
    
  })
  
  observeEvent(sele$resiChain, {
    #Remove any selections
    NGLVieweR_proxy("structure") %>% removeSelection("label")
    NGLVieweR_proxy("structure") %>% removeSelection("contact")
    NGLVieweR_proxy("structure") %>% removeSelection("selected")
    
    #Add label and contacts
    NGLVieweR_proxy("structure") %>%
      
      addSelection("ball+stick",
                   param = list(
                     name = "selected",
                     sele = sele$resi,
                     colorValue = "orange"
                   )
                   
      ) %>%
      
      addSelection(
        "label",
        param = list(
          name = "label",
          sele = sele$resiChain,
          labelType = "format",
          labelFormat = "[%(resname)s]%(resno)s",
          # or enter custom text
          labelGrouping = "residue",
          # or "atom" (eg. sele = "20:A.CB")
          color = "black",
          xOffset = 1,
          fixedSize = TRUE,
          radiusType = 1,
          radiusSize = 1.5
        )
      ) %>%
      addSelection(
        "contact",
        param = list(
          name = "contact",
          sele = "*",
          #Select all residues
          filterSele =
            list(sele$resiChain, # Show bonds between selected residue
                 "*"),
          # and all other residues
          labelVisible = TRUE,
          labelFixedSize = FALSE,
          labelUnit = "angstrom",
          # "", "angstrom", "nm"
          labelSize = 2
        )
      )
  })
  
  ###Communication between plotly and ngl###
  
  clk = reactive({
    
    clk <- event_data("plotly_click")
  })
  
  observeEvent(clk(), {
    
    #Remove any selection
    NGLVieweR_proxy("structure") %>% removeSelection("label")
    NGLVieweR_proxy("structure") %>% removeSelection("contact")
    NGLVieweR_proxy("structure") %>% removeSelection("selected")
    NGLVieweR_proxy("structure") %>% removeSelection("selAround")
    
    #Add label and contacts
    NGLVieweR_proxy("structure") %>%
      
      addSelection("ball+stick",
                   param = list(
                     name = "selected",
                     sele = toString(clk()[,'x']),
                     colorValue = "orange"
                   )
                   
      ) %>%
      
      addSelection("label",
                   param = list(
                     name = "label",
                     sele = toString(clk()[,'x']),
                     labelType = "format",
                     labelFormat = "[%(resname)s]%(resno)s", # or enter custom text
                     labelGrouping = "residue", # or "atom" (eg. sele = "20:A.CB")
                     color = "black",
                     xOffset = 1,
                     fixedSize = TRUE,
                     radiusType = 1,
                     radiusSize = 1.5
                   )
                   
      ) %>%
      
      addSelection("contact",
                   param = list(
                     name = "contact",
                     sele = "*", #Select all residues
                     filterSele =
                       list(toString(clk()[,'x']), # Show bonds between selected residue
                            "*"),      # and all other residues
                     labelVisible = TRUE,
                     labelFixedSize = FALSE,
                     labelUnit = "angstrom", # "", "angstrom", "nm"
                     labelSize = 2
      
                   )
      )%>%
      
      
      updateZoomMove(
        center = toString(clk()[,'x']),
        zoom = toString(clk()[,'x']),
        duration = 0
      )
  })
  
  


  
})



