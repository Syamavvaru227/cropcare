FROM python:3.11-slim
ARG WITH_ML=false
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements*.txt ./
RUN pip install --no-cache-dir -r requirements.txt && if [ "$WITH_ML" = "true" ]; then pip install --no-cache-dir -r requirements-ml.txt; fi
COPY app ./app
RUN useradd --create-home cropcare && mkdir -p /app/models /app/data && chown -R cropcare:cropcare /app
USER cropcare
ENV DATABASE_URL=sqlite:////app/data/cropcare.db
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--no-proxy-headers"]
