FTN5K=2a81daa0
NUM_THREAD=20
axel -H "Cookie:ptisp=edu; FTN5K=$FTN5K" -n $NUM_THREAD -o /mnt/sda5  $1
