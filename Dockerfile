FROM jupyter/all-spark-notebook

LABEL maintainer="Ogi Stancevic <ognjen.stancevic@westpac.com.au>"

USER root

RUN conda install --quiet --yes\
	-c damianavila82 rise && \
	conda clean -tipsy && \
	fix-permissions $CONDA_DIR && \
	fix-permissions /home/$NB_USER

RUN conda install --quiet --yes\
		-c conda-forge \
		jupyter_contrib_nbextensions \
		rpy2 \
    saspy \
		sas_kernel && \
		conda clean -tipsy && \
		fix-permissions $CONDA_DIR && \
		fix-permissions /home/$NB_USER

#RUN jupyter labextension install @jupyterlab/latex
RUN pip install jupyterlab_latex  \
		pandas_profiling \
		sql_magic\
		brunel && \
    rm -rf /home/$NB_USER/.local && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install jupyterlab extensions here
RUN jupyter labextension install @jupyterlab/toc

RUN pip install jupyterlab_templates
RUN jupyter labextension install jupyterlab_templates
RUN jupyter serverextension enable --py jupyterlab_templates


USER root

RUN apt-get update
RUN apt-get install -y gdebi-core openssh-client sshfs libcairo2-dev unixodbc-dev
RUN rm -rf /var/cache/apt/*

# Install rstudio server
RUN wget --no-check-certificate https://download2.rstudio.org/rstudio-server-1.1.453-amd64.deb
RUN gdebi -n rstudio-server-1.1.453-amd64.deb
RUN rm rstudio-server-1.1.453-amd64.deb
RUN echo "rsession-which-r=/opt/conda/bin/R" >> /etc/rstudio/rserver.conf



EXPOSE 8787

#setup R configs
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN echo ".libPaths('/opt/conda/lib/R/library')" >> ~/.Rprofile
RUN Rscript -e "install.packages('tidyverse')"
RUN Rscript -e "install.packages('sparklyr')"
RUN Rscript -e "install.packages('expm')"
RUN Rscript -e "install.packages('remotes')"
RUN Rscript -e "install.packages('fs')"
RUN Rscript -e "install.packages(c('highr', 'markdown', 'caTools', 'knitr', 'rmarkdown'))"
RUN Rscript -e "install.packages('reshape2')"
RUN Rscript -e "install.packages(c('curl'))"
RUN Rscript -e "install.packages('feather')"
RUN Rscript -e "install.packages('Hmisc')"
RUN Rscript -e "install.packages('RcppRoll')"
RUN Rscript -e "install.packages('fs')"
#RUN Rscript -e "install.packages('getPass')"
RUN Rscript -e "install.packages('gdtools')"
RUN Rscript -e "install.packages('flextable')"
RUN Rscript -e "install.packages('ggplot2')"
RUN Rscript -e "install.packages('fansi')"
RUN Rscript -e "install.packages('mgcv')"
RUN Rscript -e "install.packages('pillar')"
RUN Rscript -e "install.packages('Rcpp')"
RUN Rscript -e "install.packages('rlang')"
RUN Rscript -e "install.packages('reticulate')"

# Enable Jupyter extensions here
RUN jupyter nbextension enable codefolding/main
RUN jupyter nbextension enable latex_envs/latex_envs
RUN jupyter nbextension enable collapsible_headings/main
RUN jupyter nbextension enable snippets/main
RUN jupyter nbextension enable toc2/main
RUN jupyter nbextension enable varInspector/main
RUN jupyter nbextension enable highlighter/highlighter
RUN jupyter nbextension enable hide_input/main
RUN jupyter nbextension enable python-markdown/main
RUN jupyter nbextension enable spellchecker/main
RUN jupyter nbextension enable hide_input_all/main
RUN jupyter nbextension enable scratchpad/main
RUN jupyter nbextension enable execute_time/ExecuteTime
RUN jupyter nbextension enable export_embedded/main
RUN jupyter nbextension enable tree-filter/index

RUN pip install jupyter_dashboards
RUN jupyter dashboards quick-setup --sys-prefix

RUN pip install qgrid \
	tqdm \
	colorama && \
    rm -rf /home/$NB_USER/.local 


RUN fix-permissions $CONDA_DIR && \
		fix-permissions /home/$NB_USER


USER $NB_UID
