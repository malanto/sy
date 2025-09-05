FROM node:lts-alpine3.19

# Arguments
ARG APP_HOME=/home/node/app

# Install system dependencies
RUN apk add gcompat tini git jq curl

# Ensure proper handling of kernel signals
ENTRYPOINT [ "tini", "--" ]

# Create app directory
WORKDIR ${APP_HOME}

# Set NODE_ENV to production
ENV NODE_ENV=production

# Install app dependencies
# COPY package*.json post-install.js ./
RUN git clone https://github.com/SillyTavern/SillyTavern.git -b release .
RUN \
  echo "*** Install npm packages ***" && \
  npm install && npm cache clean --force

# Bundle app source
# COPY . ./

ADD docker-entrypoint.sh docker-entrypoint.sh
ADD config.yaml config.yaml

RUN \
  echo "*** Install npm packages ***" && \
  npm i --no-audit --no-fund --loglevel=error --no-progress --omit=dev && npm cache clean --force

# Copy default chats, characters and user avatars to <folder>.default folder
RUN \
  rm -rf docker && \
  rm -rf data && \
  ln -s history data && \
  mkdir "config" || true

# Cleanup unnecessary files
RUN chmod -R 777 ${APP_HOME}

EXPOSE 8080

CMD [ "./docker-entrypoint.sh" ]

USER 10014
