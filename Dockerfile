FROM python:3.8-slim

COPY entypoint.sh /entypoint.sh

ENTRYPOINT ["entrypoint.sh"]
