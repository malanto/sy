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

# Env
# 是否远程获取下面的参数 是个链接，返回一个json；执行完后关闭这个链接即可保密
# 返回内容:
#  {
#    "reverse_proxy": "https://onekey.xxx.top/v1",
#    "proxy_password": "sk-ssvJn4VQAk596Lvv3548xxx",
#    "api_key_makersuite": "AIzaSyAm5S9kl22DDNSXmnd4vgxxx",
#    "github_secret": "github_pat_11AIWDQ2A0cLSEdwiwiZNC_10II4TsFExxx",
#    "github_project": "bincooo/history"
#  }
ENV fetch ""
# 代理转发地址
ENV reverse_proxy ""
# 代理转发token
ENV proxy_password ""
# gemini token
ENV api_key_makersuite ""
# github 项目访问凭证token
ENV github_secret ""
# github 项目名称
ENV github_project ""

# Install app dependencies
# COPY package*.json post-install.js ./
RUN git clone https://github.com/SillyTavern/SillyTavern.git -b release .
RUN \
  echo "*** Install npm packages ***" && \
  npm install && npm cache clean --force

# Bundle app source
# COPY . ./

ADD launch.sh launch.sh
ADD config.yaml ./config/config.yaml
RUN curl -JLO  https://github.com/bincooo/SillyTavern-Docker/releases/download/v1.0.0/git-batch
RUN chmod +x launch.sh && chmod +x git-batch && ./git-batch -h

RUN \
  echo "*** Install npm packages ***" && \
  npm i --no-audit --no-fund --loglevel=error --no-progress --omit=dev && npm cache clean --force

# Copy default chats, characters and user avatars to <folder>.default folder
RUN \
  rm -rf data && \
  ln -s history data && \
  mkdir "config" || true

# Cleanup unnecessary files
RUN chmod -R 777 ${APP_HOME}

EXPOSE 8080

CMD [ "./docker-entrypoint.sh" ]

USER 10014
