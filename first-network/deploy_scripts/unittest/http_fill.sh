set +e
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d @agreement_8.json 'http://localhost:3000/api/insertContract'
echo
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d @agreement_18.json 'http://localhost:3000/api/insertContract'
echo
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d @agreement_20.json 'http://localhost:3000/api/insertContract'
echo
