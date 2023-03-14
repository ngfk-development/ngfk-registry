FROM verdaccio/verdaccio:5

USER root
RUN npm install --global verdaccio-github-oauth-ui@^6.0.1 verdaccio-google-cloud@^10.2.0

USER $VERDACCIO_USER_UID
COPY assets /verdaccio/assets
COPY config.yml /verdaccio/conf/config.yaml
