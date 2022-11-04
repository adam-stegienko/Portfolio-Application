FROM alpine:3.15 AS builder
WORKDIR /src/app/
COPY ./src/ .
RUN apk add --no-cache curl
RUN apk add --no-cache python3
RUN curl https://bootstrap.pypa.io/pip/3.6/get-pip.py --output get-pip.py
RUN python3 get-pip.py
RUN pip install -r ./requirements.txt
RUN python3 -m ensurepip
ENTRYPOINT ["./app.py"]