import requests
import json
r = requests.get('http://127.0.0.1:3000/api/Contract/id_20')
res = r.json()
print(json.dumps(res, indent = 4))

if "text_item1" in res.keys():
    print("\nParsed text_item1:")
    ti1 = json.loads(res["text_item1"])
    print(json.dumps(ti1, indent=10))


