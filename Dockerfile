FROM python:3.11
RUN apt-get update && apt-get install -y curl
RUN curl -O "https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2024-A.tar.gz"
