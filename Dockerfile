FROM python:3.11

WORKDIR /app

COPY requirements.txt /app
COPY myproject /app

RUN apt-get update && \
	pip install -r requirements.txt && \
	cd myproject
	
	
ENTRYPOINT ["python3"]
CMD ["manage.py", "runserver", "0.0.0.0:8000"]


