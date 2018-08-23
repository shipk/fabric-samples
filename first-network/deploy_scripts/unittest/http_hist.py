import requests
import json
r = requests.get('http://localhost:3000/api/queries/ContractHistByID?agr_id=id_20')
res = r.json()
print(json.dumps(res, indent = 4))


