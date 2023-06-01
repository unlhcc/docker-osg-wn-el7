FROM opensciencegrid/osg-wn:3.6-el7

# Required
# --------
# - cmsRun fails without stdint.h (from glibc-headers)
#   Tested CMSSW_7_4_5_patch1
#
# Other
# -----
# - ETF calls /usr/bin/lsb_release (from redhat-lsb-core)
# - sssd-client for LDAP lookups through the host
# - SAM tests expect cvmfs utilities and python3
# - gcc is required by GLOW jobs (builds matplotlib)
#
# CMSSW dependencies
# ------------------
# Required software is listed under slc7_amd64_platformSeeds at
# http://cmsrep.cern.ch/cgi-bin/cmspkg/driver/cms/slc7_amd64_gcc820

RUN yum -y install cvmfs \
                   gcc \
                   glibc-headers \
                   openssh-clients \
                   osg-wn-client \
                   python3 \
                   redhat-lsb-core \
                   sssd-client && \
    yum -y install glibc coreutils bash tcsh zsh perl tcl tk readline openssl \
                   ncurses e2fsprogs krb5-libs freetype ncurses-libs perl-libs \
                   perl-ExtUtils-Embed fontconfig compat-libstdc++-33 libidn \
                   libX11 libXmu libSM libICE libXcursor libXext libXrandr \
                   libXft mesa-libGLU mesa-libGL e2fsprogs-libs libXi \
                   libXinerama libXft-devel libXrender libXpm libcom_err \
                   perl-Test-Harness perl-Carp perl-constant perl-PathTools \
                   perl-Data-Dumper perl-Digest-MD5 perl-Exporter \
                   perl-File-Path perl-File-Temp perl-Getopt-Long perl-Socket \
                   perl-Text-ParseWords perl-Time-Local libX11-devel \
                   libXpm-devel libXext-devel mesa-libGLU-devel perl-Switch \
                   perl-Storable perl-Env perl-Thread-Queue perl-Encode nspr \
                   nss nss-util file file-libs readline zlib popt bzip2 \
                   bzip2-libs && \
    yum clean all && \
    rm -rf /var/cache/yum

# Create condor user and group
RUN groupadd -r condor && \
    useradd -r -g condor -d /var/lib/condor -s /sbin/nologin condor

# Sync singularity version
RUN yum -y distro-sync --enablerepo=epel-testing singularity && \
    yum clean all && \
    rm -rf /var/cache/yum

# Disable overlay and privileged mode
RUN perl -pi -e 's/^enable overlay =.*/enable overlay = no/g' /etc/singularity/singularity.conf && \
    perl -pi -e 's/^allow setuid =.*/allow setuid = no/g'     /etc/singularity/singularity.conf

# yum update
RUN yum update -y && \
    yum clean all && \
    rm -rf /var/cache/yum
