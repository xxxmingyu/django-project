# alpine 3.19 버전의 리눅스를 구축하는데, 파이썬 버전은 3.11로 설치된 이미지를 불러와줘
# alpine - 경량화된 리눅스 버전 => 가볍다 => 빌드가 계속 반복이 되는데, 이미지가 무거우면 업무가 느려짐 - 여기에 파이썬 3.11이 설치된 버전
FROM python:3.11-alpine3.19

LABEL maintainer='xxxmingyu'

#파이썬에서 0:1 = False:True임
#컨테이너에 찍히는 로그를 볼 수 있도록 허용하기 위함
#도커 컨테이너에서 어떤 일이 벌어지고 있는지 실시간으로 볼 수 있음 (컨테이너 관리가 편해짐)
ENV PYTHONUNBUFFERED 1

#tmp에 넣는 이유 : 컨테이너를 최대한 경량상태로 유지하기 위함
#tmp 폴더는 빌드 완료 후 삭제 예정
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

#django 포트 : 8000
WORKDIR /app
EXPOSE 8000

ARG DEV=false

#venv를 불러와라 (-m : 불러옴) - /py라는 이름으로
#&& \ : 엔터를 쳐라
#컨테이너에 가상환경을 만들고, pip 업그레이드 후 인스톨까지 한다
#django-user 계정을 추가해서 접속 (루트계정으로 하면 안됨)
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    if [$DEV = 'true']; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"
USER django-user

#Django - Docker - Github Actions(CI/CD) 연동까지 한거임