FROM jupyter/pyspark-notebook

LABEL maintainer="Ogi Stancevic <ognjen.stancevic@westpac.com.au>"

USER root

# RSpark config
ENV R_LIBS_USER $SPARK_HOME/R/lib
RUN fix-permissions $R_LIBS_USER

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# R packages
RUN conda install --quiet --yes \
    'r-base=3.6.2' \
    'r-ggplot2=3.2*' \
    'r-irkernel=1.1*' \
    'r-rcurl=1.98*' \
    'r-sparklyr=1.1*' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Apache Toree kernel
RUN pip install --no-cache-dir \
    https://dist.apache.org/repos/dist/release/incubator/toree/0.3.0-incubating/toree-pip/toree-0.3.0.tar.gz \
    && \
    jupyter toree install --sys-prefix && \
    rm -rf /home/$NB_USER/.local && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# Extra Installation for model risk team
RUN conda config --add channels conda-forge &&\
	conda config --add channels r &&\
    conda update --yes --all &&\
	conda clean -a -y

RUN conda install -y nodejs
RUN jupyter labextension install --no-build @jupyterlab/toc && \
 jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager && \
 jupyter labextension install --no-build @jupyterlab/hub-extension && \
 jupyter lab build

USER root

# Teradata pre-requisites
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
    gdebi-core \
    openssh-client \
    sshfs \
    tzdata \
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
RUN pip install jupyter_contrib_nbextensions \
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
	pyodbc \
	python-docx


RUN pip install jupyterlab_templates &&\
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
