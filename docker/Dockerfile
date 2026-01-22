FROM solr:9.9

COPY --chown=$SOLR_USER:$SOLR_USER security.json /opt/solr/security.json
COPY --chown=$SOLR_USER:$SOLR_USER ci-start.sh /opt/solr/server/scripts/ci-start.sh
COPY --chown=$SOLR_USER:$SOLR_USER lando-start.sh /opt/solr/server/scripts/lando-start.sh

ENV BASE_URL="https://raw.githubusercontent.com/pulibrary/princeton_ansible/main/roles/solr9cloud/files"
ENV JTS_URL="$BASE_URL/jts-core-1.15.1.jar"
ENV CJK_URL="$BASE_URL/CJKFilterUtils-v4.0.jar"
ENV UMICH_URL="$BASE_URL/lucene-umich-solr-filters-2.0-solr-9.0.0.jar"
ENV NASHORN_URL="$BASE_URL/nashorn-core-15.4.jar"
ENV ASM_1_URL="$BASE_URL/asm-7.3.1.jar"
ENV ASM_2_URL="$BASE_URL/asm-commons-7.3.1.jar"
ENV ASM_3_URL="$BASE_URL/asm-tree-7.3.1.jar"
ENV ASM_4_URL="$BASE_URL/asm-util-7.3.1.jar"

ENV ANALYSIS_EXTRAS_PATH="/opt/solr/modules/analysis-extras/lib"
ENV SOLR_ANALYSIS_EXTRAS_PATH="$ANALYSIS_EXTRAS_PATH/solr-analysis-extras-9.9.0.jar"
ENV ICU4J_PATH="$ANALYSIS_EXTRAS_PATH/icu4j-74.2.jar"
ENV LUCENE_ICU_PATH="$ANALYSIS_EXTRAS_PATH/lucene-analysis-icu-9.12.2.jar"

ENV EXTRAS_BASE_PATH="/opt/solr/lib"
ENV CJK_PATH="$EXTRAS_BASE_PATH/CJKFilterUtils-v4.0.jar"
ENV UMICH_PATH="$EXTRAS_BASE_PATH/lucene-umich-solr-filters-2.0-solr-9.0.0.jar"
ENV WEBAPP_BASE_PATH="/opt/solr/server/solr-webapp/webapp/WEB-INF/lib"
ENV JTS_PATH="$WEBAPP_BASE_PATH/jts-core-1.15.1.jar"
ENV SOLR_ANALYSIS_EXTRAS_PATH_DEST="$EXTRAS_BASE_PATH/solr-analysis-extras-9.9.0.jar"
ENV ICU4J_PATH_DEST="$EXTRAS_BASE_PATH/icu4j-74.2.jar"
ENV LUCENE_ICU_PATH_DEST="$EXTRAS_BASE_PATH/lucene-analysis-icu-9.12.2.jar"

USER root
RUN wget $CJK_URL -O $CJK_PATH
RUN wget $UMICH_URL -O $UMICH_PATH
RUN wget $JTS_URL -O $JTS_PATH
RUN wget $NASHORN_URL -P $EXTRAS_BASE_PATH
RUN wget $ASM_1_URL -P $EXTRAS_BASE_PATH
RUN wget $ASM_2_URL -P $EXTRAS_BASE_PATH
RUN wget $ASM_3_URL -P $EXTRAS_BASE_PATH
RUN wget $ASM_4_URL -P $EXTRAS_BASE_PATH
RUN cp $SOLR_ANALYSIS_EXTRAS_PATH $SOLR_ANALYSIS_EXTRAS_PATH_DEST
RUN cp $ICU4J_PATH $ICU4J_PATH_DEST
RUN cp $LUCENE_ICU_PATH $LUCENE_ICU_PATH_DEST
USER $SOLR_USER
