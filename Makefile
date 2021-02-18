AWS_ACCOUNT_ID ?= 1234
AWS_REGION ?= eu-north-1
ECR_REGISTRY_ALIAS ?= f8u6t4e3
APPS = yelb-ui yelb-appserver yelb-db yelb-redis

build-%: $(APPS)
	@cd $* && \
	pwd && \
	docker build -t $* .

tag-%: $(APPS)
	@cd $* && \
	docker tag $* public.ecr.aws/$(ECR_REGISTRY_ALIAS)/$* 

ecrpublic-get-login:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws

ecrpublic-create-repo-%: $(APPS)
	PAGER=cat
	@aws --region us-east-1 ecr-public create-repository --repository-name $* --output text || exit 0

ecrpublic-push-%: $(APPS)
	@docker push public.ecr.aws/$(ECR_REGISTRY_ALIAS)/$*

build: $(addprefix build-,$(APPS))
tag: $(addprefix tag-,$(APPS))
ecrpublic-create-repo: $(addprefix ecrpublic-create-repo-,$(APPS))
ecrpublic-push: $(addprefix ecrpublic-push-,$(APPS))

.PHONY: build tag ecrpublic-get-login ecrpublic-create-repo ecrpublic-push

all: build tag ecrpublic-get-login ecrpublic-create-repo ecrpublic-push
