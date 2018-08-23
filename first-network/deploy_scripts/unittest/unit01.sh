echo '==============================================================='
echo 'Fill the ledger with three contracts id_8 id_18 id_20'
./http_fill.sh
echo
echo '==============================================================='
echo 'Get contract id_20'
./http_get.sh
echo
echo '==============================================================='
echo 'Update contract id_20, put json value in text_item1'
./http_update_20.sh
echo
echo '==============================================================='
echo 'Get contract id_20'
python ./http_req.py
echo
echo '==============================================================='
echo 'Remove contract id_20'
./http_remove_20.sh
echo
echo '==============================================================='
echo 'Get the history for id_20'
python ./http_hist.py


