FROM python:3.9-slim-buster as base

USER root
ENV FLUENTD_HOST "fluentd"
ENV FLUENTD_PORT "24224"
ENV FLASK_APP "cd4ml/app.py"
ENV FLASK_ENV "production"
ENV MLFLOW_TRACKING_URL "http://mlflow:5000"

RUN mkdir -p /usr/src/app/cd4ml/
WORKDIR /usr/src/app/cd4ml/

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

FROM base as model
EXPOSE 5005
CMD flask run --host=0.0.0.0 --port 5005

FROM base as mlflow
COPY requirements.mlflow.txt requirements.txt
RUN pip install -r requirements.mlflow.txt
EXPOSE 5000
ENV MLFLOW_S3_ENDPOINT_URL ${MLFLOW_S3_ENDPOINT_URL}
ENV AWS_ACCESS_KEY_ID ${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY ${AWS_SECRET_ACCESS_KEY}
ENTRYPOINT mlflow server -h 0.0.0.0 -p 5000 --default-artifact-root s3://cd4ml-ml-flow-bucket/ --backend-store-uri /mnt/mlflow