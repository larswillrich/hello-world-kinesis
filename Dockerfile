FROM python:buster
COPY ./main.py /app/main.py

ENTRYPOINT python -u /app/main.py