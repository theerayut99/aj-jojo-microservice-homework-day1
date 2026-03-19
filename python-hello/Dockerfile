FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV HOST=0.0.0.0
ENV PORT=8000
ENV LOG_LEVEL=info

EXPOSE 8000

STOPSIGNAL SIGTERM

CMD uvicorn main:app --host $HOST --port $PORT --log-level $LOG_LEVEL
