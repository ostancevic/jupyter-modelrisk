FROM jupyter/pyspark-notebook

LABEL maintainer="Ogi Stancevic <ognjen.stancevic@westpac.com.au>"

RUN conda config --append channels conda-forge &&\
    conda config --append channels r &&\
    conda update --yes --all &&\
	conda clean -a -y

RUN conda install -y nodejs
RUN jupyter labextension install --no-build @jupyterlab/toc && \
 jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager && \
 jupyter labextension install --no-build @jupyterlab/hub-extension && \
 jupyter lab build

USER root

# RSpark config
ENV R_LIBS_USER $SPARK_HOME/R/lib
RUN fix-permissions $R_LIBS_USER


# Teradata pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gdebi-core \
    openssh-client \
    sshfs \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc \
    dpkg \
    cifs-utils \
    vim \
    libcairo2-dev \
    unixodbc-dev  \
    lib32stdc++6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/*

RUN rm -rf /opt/conda/var/cache/*

USER $NB_UID

# R packages
# Install additional R packages here
RUN conda install --quiet --yes \
    'r-mro' \
    'r-irkernel=0.8*' \
    'r-rcurl' \ 
	jupyter_contrib_nbextensions \
	rpy2 \
	altair \
	vega \
	jira \
	tzlocal \
	saspy \
	sas_kernel \
	colorama \
	feather-format \
	pyarrow \
	pandas-profiling \
  	qgrid \
  	simplegeneric \
  	tqdm \
	python-docx && \
    conda install -y -c h2oai h2o && \
    conda clean -a -y

RUN pip install jupyterlab_templates\
  jupyter labextension install jupyterlab_templates && \
  jupyter serverextension enable --py jupyterlab_templates

#setup R configs
# Install h2o for R
RUN echo ".libPaths('/opt/conda/lib/R/library')" >> ~/.Rprofile &&\
    echo "local({r <- getOption('repos'); r['CRAN'] <- 'https://mran.microsoft.com/snapshot/2019-01-31'; options(repos = r)})" >> /home/$NB_USER/.Rprofile &&\
   Rscript -e 'install.packages("h2o", repos=(c("http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R")))' && \
   Rscript -e "install.packages('sparklyr')"

EXPOSE 8787

RUN rm -rf /home/$NB_USER/.local
WORKDIR /home/$NB_USER


# Enable Jupyter extensions here
RUN jupyter nbextension enable collapsible_headings/main && \
 jupyter nbextension enable snippets_menu/main && \
 jupyter nbextension enable toc2/main && \
 jupyter nbextension enable varInspector/main && \
 jupyter nbextension enable highlighter/highlighter && \
 jupyter nbextension enable hide_input/main && \
 jupyter nbextension enable python-markdown/main && \
 jupyter nbextension enable spellchecker/main && \
 jupyter nbextension enable hide_input_all/main && \
 jupyter nbextension enable execute_time/ExecuteTime && \
 jupyter nbextension enable export_embedded/main && \
 jupyter nbextension enable tree-filter/index

