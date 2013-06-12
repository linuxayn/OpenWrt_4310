local CFG_DIR="/var/etc/radvd-conf"
if [ ! -d $CFG_DIR ];
then
	mkdir $CFG_DIR
fi
for i in $(ls ${CFG_DIR});
do
	cat $CFG_DIR/$i >>/var/etc/radvd.conf
done
