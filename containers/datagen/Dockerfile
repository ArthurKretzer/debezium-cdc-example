FROM python:3.11.5

RUN pip install \
    psycopg2-binary \
    faker \
    ibm_db

WORKDIR /opt/datagen

COPY ./containers/datagen /opt/datagen

CMD [ "python" "./gen-fake-data.py"]