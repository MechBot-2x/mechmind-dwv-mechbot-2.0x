import os\nimport hvac\nclient = hvac.Client(url=os.getenv("VAULT_URL"))
