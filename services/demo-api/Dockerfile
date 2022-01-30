FROM python:3.9 as build

COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir --upgrade -r /requirements.txt

COPY ./src /app/src/
COPY ./tests /app/tests/
WORKDIR /app

FROM build AS test
RUN pytest --cov=src --cov-report=xml --junitxml=tests.xml tests/

FROM scratch as export-test-results
COPY --from=test /app/*.xml .

FROM build as publish

EXPOSE 8000
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
