# Prepared by Saeid Amiri
FROM rocker/shiny:latest

RUN apt-get update && apt-get install -y libcurl4-gnutls-dev \
    libssl-dev libopenblas-dev && update-alternatives --config libblas.so.3-$(arch)-linux-gnu

RUN R -e 'install.packages(c(\
              "shiny", "shinydashboard","DT","rlang", "ggplot2", "plotly", "remotes",\
              "tidyverse", "RColorBrewer", "stringr","reshape2","dplyr","shinyalert", "faq"\
            )\
          )'

RUN R -e 'remotes::install_github("nvelden/NGLVieweR")'

COPY ./MTSvieweR /srv/shiny-server/

CMD ["/usr/bin/shiny-server"]
