# Dashboard v 1.0.1, 2022/03/24
# Developers: Andrew Bayne (andrew.bayne@mail.mcgill.ca), Jing Dong (jing.dong2@mail.mcgill.ca), and Saeid Amiri (saeid.amiri@mcgill.ca)

# install.packages("devtools")
# devtools::install_github("tidyverse/magrittr")
# install.packages("scales")
# install.packages("tidyverse")


library(shiny)
library(shinydashboard)
library(DT)
library(rlang)
#library(data.table)
library(ggplot2)
library(plotly)
library(tidyverse)
library(NGLVieweR)
library(RColorBrewer)
#library(faq)
library(stringr)
library(reshape2)
#library(msaR)
library(dplyr)
library(shinyalert)

###FAQ###
faqdf2 <- data.frame(
  question = c("Q: Where can I find a description of the column headers and various scoring metrics?",
               "Q: How do I use the custom variant upload function?",
               "Q: Where are the structures from?", 
               "Q: Where is the rest of the proteome?", 
               "Q: Where are you getting the variants from? Which reference genome are you using?", 
               "Q: What version of gnomAD are you using?", 
               "Q: Where are your N-terminomics cleavage sites derived from?",
               "Q: Why are the structures of long proteins (>2700 a.a.) truncated?",
               "Q: How are cleavage site positions defined?",
               "Q: What are some limitations of the database?", 
               "Q: I found a bug or want one of my proteins added, who do I contact?"

  ),
  
  answer = c("<p><br><a href='https://docs.google.com/spreadsheets/d/1xNsZieSOqM90I60KZLYKxMXNV2sb3N_9/edit?usp=sharing&ouid=106761529439770616938&rtpof=true&sd=true'>A description of the metrics used in our mutation lists (derived from dbNSFP v4.2) can be found by clicking here.</a> </p> More details on the outputs of the prediction algorithms and other resources can be found below: <br> <a href='https://sites.google.com/site/jpopgen/dbNSFP'> dbNSFP </a> <br> <a href='https://alphafold.ebi.ac.uk/'> AlphaFold </a> <br> <a href='http://mitf.cbrc.jp/MitoFates/usage.html'> MitoFates </a> <br> <a href='https://services.healthtech.dtu.dk/service.php?TargetP-2.0'> TargetP 2.0 </a> <br> <a href='https://tppred3.biocomp.unibo.it/tppred3'> TPpred 3.0 </a> <br> <a href='http://busca.biocomp.unibo.it/deepmito/'> DeepMito </a>",
             "<a href = 'userguide.pdf'> This function is described in our user guide. If you wish to upload multiple CSV files in one session, we recommend that you reload the site each time. The most common upload errors come from mismatched Uniprot IDs (ie. MTSviewer does not contain your protein of interest) or incorrectly formatted HGVsp_VEP cells</a>",
             "Structures are taken from AlphaFold, using the human proteome from 21 July 2021. We will update our viewer with the latest AlphaFold updates as they come out.",
             "In this version of MTSviewer, we are only taking proteins from the <a href='https://www.broadinstitute.org/mitocarta/mitocarta30-inventory-mammalian-mitochondrial-proteins-and-pathways'>MitoCarta 3.0</a> for human proteins, and 901 high-confidence yeast mitochondrial proteins via <a href='https://www.sciencedirect.com/science/article/pii/S2211124717308112'>Morgernstern et al. 2017</a>. In later versions, we hope to expand this viewer to the entire human proteome, as cytosolic proteins can also contain iMTS's worth studying.",
             "Variants are parsed by Uniprot ID through the dbNSFP v4.2a. All genomic coordinates correspond to GRCH38/hg38.",
             "v3.1, derived from dbNSFP v4.2a", 
             "Currently they are derived from <a href='https://topfind.clip.msl.ubc.ca/'> TopFIND 4.1.</a>",
             "A: This is a known consequence of the AlphaFold database -- all proteins that are longer than 2700 a.a. are truncated into overlapping 1400 a.a. segments. In MTSviewer, we only display the first 1400 a.a. segment. Users should proceed with caution when interpreting variants and structural consequences in these cases.",
             "All cleavage sites on the iMTS plot are given by a single a.a. number, which corresponds to the amino acid that is C-terminal to the cleaved peptide bond. For example, '5' implies that the cleavage site is between a.a. 5 and 6 (ie. 12345|6789). For TopFIND N-terminomics sites (TopFINDnt), we have converted their a.a. numbering to match this format on the iMTS plot. The equivalent cleavage sites in the plaintext TopFIND tables are reported as originally indicated by their peptide idenficiation numbering (ie. iMTS plot cleavage site + 1).",
             "The current version of MTSviewer features the inherent limitation that N-terminal MTS's within AlphaFold predictions are typically low confidence and are depicted as unstructured. In the future, structural determination of human MTS's in complexes with TOM/TIM and/or MPP will enable us to model N-MTS's more accurately, and could be integrated as a scoring metric or docking module into later versions of MTSviewer",
             "Please direct all inquiries to our <a href='mailto:mtsviewer.docs@gmail.com'>e-mail address</a>."
          
             
  )
)

load("./Outputs/MTSViewer.RData")
