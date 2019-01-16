FROM jupyter/pyspark-notebook

LABEL maintainer="Ogi Stancevic <ognjen.stancevic@westpac.com.au>"

RUN conda update --yes --all

RUN jupyter labextension install --no-build @jupyterlab/toc && \ 
 jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager && \
 jupyter labextension install --no-build jupyterlab_bokeh && \
 jupyter labextension install --no-build @jupyterlab/hub-extension && \
 pip install nbdime && \
 jupyter lab build

USER root

# RSpark config
ENV R_LIBS_USER $SPARK_HOME/R/lib
RUN fix-permissions $R_LIBS_USER

RUN dpkg --add-architecture i386 && \
 	apt-get update && sudo apt-get -y upgrade && \
	apt-get install -y --no-install-recommends \
	lib32gcc1 \
	lib32stdc++6 \
	libcurl4-gnutls-dev:i386 

# Teradata, R and Octave pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc \
    gdebi-core \ 
    openssh-client \ 
    sshfs \
    libcairo2-dev \
    unixodbc-dev  \
    less \
    gnuplot \
    libnetcdf-dev \
    octave \ 
    zlib1g-dev \
    libssl-dev \ 
    libssh2-1-dev \ 
    build-essential make \
    liboctave-dev  \
    gnuplot-x11 \
    libopenblas-base \ 
    libatlas3-base \
    ghostscript pstoedit  \
    libcurl4-openssl-dev \
    libapparmor1 \
    libedit2 \
    libc6 \
    psmisc \
    lsb-release \
    rrdtool && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



# R and essential R packages
RUN conda install --yes \  
	mro-base 
RUN conda install --yes \
	r-irkernel \
	r-tidyverse 


#setup R configs
RUN echo ".libPaths('/opt/conda/lib/R/library')" >> ~/.Rprofile

# Install additional R packages here
COPY install_packages.R /tmp/install_packages.R 
RUN R --no-save </tmp/install_packages.R 


RUN conda install -c conda-forge \
	jupyter_contrib_nbextensions \
	rpy2 \
	altair \
	tzlocal \
	saspy \
	sas_kernel \ 
	colorama \
	feather-format \
	pyarrow \
	pandas-profiling \
	python-docx \
	octave_kernel && \
	conda clean -tipsy && \
        rm -rf /home/$NB_USER/.local && \
	fix-permissions $CONDA_DIR && \
	fix-permissions /home/$NB_USER

RUN pip install jupyterlab_templates\
	jira \
	sql_magic && \
  jupyter labextension install jupyterlab_templates && \
  jupyter serverextension enable --py jupyterlab_templates

# Install rstudio server
RUN wget https://download2.rstudio.org/rstudio-server-1.1.463-amd64.deb && \
	gdebi -n rstudio-server-1.1.463-amd64.deb && \
	rm rstudio-server-1.1.463-amd64.deb  && \
	echo "rsession-which-r=/opt/conda/bin/R" >> /etc/rstudio/rserver.conf


WORKDIR /tmp

EXPOSE 8787


USER $NB_UID
WORKDIR /home/$NB_USER

#RUN octave --no-gui --eval "pkg install -verbose -forge -auto netcdf" && \
# octave --no-gui --eval "pkg install -verbose -forge -auto io" && \
# octave --no-gui --eval "pkg install -verbose -forge -auto statistics"

#setup R configs
RUN echo ".libPaths('/opt/conda/lib/R/library')" >> ~/.Rprofile



# Enable Jupyter extensions here
RUN jupyter nbextension enable collapsible_headings/main && \
 jupyter nbextension enable snippets/main && \
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

