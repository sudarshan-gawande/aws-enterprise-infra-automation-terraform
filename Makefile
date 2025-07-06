.PHONY: init plan apply destroy lint docker-build docker-push

init:
	terraform -chdir=terraform init

plan:
	terraform -chdir=terraform plan

apply:
	terraform -chdir=terraform apply -auto-approve

destroy:
	terraform -chdir=terraform destroy -auto-approve

lint:
	terraform -chdir=terraform fmt -recursive
	terraform -chdir=terraform validate

docker-build:
	docker build -t $(DOCKERHUB_USERNAME)/infra-app:latest -f ./app/Dockerfile.prod ./app

docker-push:
	docker push $(DOCKERHUB_USERNAME)/infra-app:latest
