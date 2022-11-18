FROM ubuntu:22.04

WORKDIR /src/app/

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install python3.10
RUN curl https://bootstrap.pypa.io/pip/3.6/get-pip.py --output get-pip.py
RUN python3 get-pip.py

RUN apt-get update \
 && apt-get install unixodbc -y \
 && apt-get install unixodbc-dev -y \
 && apt-get install freetds-dev -y \
 && apt-get install freetds-bin -y \
 && apt-get install tdsodbc -y \
 && apt-get install --reinstall build-essential -y

RUN echo "[FreeTDS]\n\
Description = FreeTDS Driver\n\
Driver = /usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so\n\
Setup = /usr/lib/x86_64-linux-gnu/odbc/libtdsS.so" >> /etc/odbcinst.ini

COPY api/ .
RUN pip install -r requirements.txt

ENV FLASK_DEBUG production
EXPOSE 5000

CMD ["gunicorn", "-b", ":5000", "api:app"]