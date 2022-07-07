
REQ_STAMP = lambda_function/.venv/.req_stamp
PYTHON = lambda_function/.venv/bin/python
VENV = lambda_function/.venv
PKG_DIR = lambda_dist_pkg/
RUNTIME = python3.8

clean:
	@rm -rf $(VENV)
	@rm -rf $(PKG_DIR)
	@rm -rf lambda.zip
	@find . -name "*.pyc" -delete
	@find . -name "*.pyo" -delete
	@find . -name .coverage -delete

virtualenv: $(PYTHON)

$(PYTHON):
	@python -m venv $(VENV)
	@$(VENV)/bin/pip install --upgrade pip

$(REQ_STAMP): lambda_function/requirements.txt # install all module requirements
	@$(VENV)/bin/pip install -Ur lambda_function/requirements.txt
	@rm -rf $(PKG_DIR)
	@mkdir -p $(PKG_DIR)
	@cp -r lambda_function/.venv/lib/$(RUNTIME)/site-packages/ $(PKG_DIR)
	@rm -f lambda.zip
	@cd $(PKG_DIR); zip -r ../lambda.zip . -x "*.DS_Store*" "*.git" "build*" "Makefile" "requirements.txt" 
	@touch $(REQ_STAMP)

init: virtualenv $(REQ_STAMP)

data: init
	@$(VENV)/bin/python kinesis_producer.py

lambda: init
	@cd lambda_function; zip -r ../lambda.zip . -x "*.DS_Store*" "*.git" "build*" "Makefile" "requirements.txt" "*.venv*" 

deploy: lambda
	@cd infra; terraform apply --auto-approve

destroy:
	@cd infra; terraform destroy --auto-approve

default: lambda

.PHONY: lambda deploy destroy init