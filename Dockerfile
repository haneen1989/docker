FROM ubuntu:20.04

# This looks bad, but its the password Azure Kudu uses to access debugging things in the image
# See: https://docs.microsoft.com/en-us/azure/app-service/tutorial-custom-container
ENV SSH_PASSWD "root:Docker!"


ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# tzdata expect you to pick you location during install. We set it here to automate the install
ENV TZ=Europe/Dublin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update \
    && apt upgrade -y \
    && apt install -y --no-install-recommends \
    build-essential \
    vim \
    openssh-server \
    cpanminus \
    apache2 \
    libexpat1-dev \
    libnet-ssleay-perl \
    libdata-yaml-perl \
    libconfig-yaml-perl \
    libssl-dev \
    libipc-run-perl \
    libbio-perl-perl \
    libbio-db-ncbihelper-perl \
    libdbd-pg-perl \
	&& echo "$SSH_PASSWD" | chpasswd \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm install Catalyst::Devel
RUN cpanm install Catalyst::Plugin::SubRequest
RUN cpanm install Catalyst::Model::DBIC::Schema
RUN cpanm install Catalyst::View::Mason
RUN cpanm install Catalyst::DispatchType::Regex
RUN cpanm install Catalyst::Helper::Model::CDBI
RUN cpanm install Catalyst::Controller::REST
RUN cpanm install XML::Parser
RUN cpanm install XML::Twig
RUN cpanm install XML::DOM
RUN cpanm install Log::Log4perl
RUN cpanm install DateTime
RUN cpanm install Class::DBI::SQLite
RUN cpanm install Bio::SeqIO
RUN cpanm install Bio::Cluster::SequenceFamily
RUN cpanm install Bio::Variation::SNP
RUN cpanm install IO::Socket::SSL
RUN cpanm install Bio::SeqIO::entrezgene
RUN cpanm install LWP::Protocol::https
RUN cpanm install Bio::ASN1::EntrezGene
RUN cpanm install Bio::ASN1::Sequence
RUN cpanm install Bio::Perl
RUN cpanm install DateTime::Format::Pg
RUN cpanm install Statistics::Lite

ADD docker_files/sshd_config /etc/ssh/
ADD docker_files/init.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/init.sh

RUN mkdir /tmp/mason
ADD *.mas /tmp/mason/

ADD GeneDesigner /opt/GeneDesigner
WORKDIR /opt/GeneDesigner

RUN chown -R root:root /opt/GeneDesigner \
    && chown -R root:root /usr/local/bin/ \
    && chown -R root:root /etc/ssh/

EXPOSE 80 3000
ENTRYPOINT ["init.sh"]
