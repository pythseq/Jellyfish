#! /bin/sh

cd tests
. ./compat.sh

RLEN=200
MLEN=40
ALL=2000000
UNIQ=1000000
MULT=1000000

$GS -o intersection_all -s 2703731828 -r $RLEN $ALL
$GS -o intersection_uniq -s 2139959797 -r $RLEN $UNIQ
$GS -o intersection_mult -s 3348383312 -r $RLEN $MULT

cat intersection_all.fa intersection_mult.fa intersection_uniq.fa > uniq.fa
cat intersection_mult.fa intersection_all.fa > mult.fa

time $JF intersection --verbose -s 2M -m $MLEN -t 1 uniq.fa mult.fa intersection_all.fa

test "$((($RLEN - $MLEN + 1) * ($ALL / $RLEN)))" = "$(wc -l < intersection)"
test "$((($RLEN - $MLEN + 1) * ($UNIQ / $RLEN)))" = "$(wc -l < uniq_uniq.fa)"
test "0" = "$(wc -l < uniq_mult.fa)"
test "0" = "$(wc -l < uniq_intersection_all.fa)"

# Same specifying memory instead of size and with name collision
mkdir -p extra_dir
ln -sf $(pwd)/mult.fa extra_dir/uniq.fa
time $JF intersection --verbose --mem 8M -i intersection2 -p uniq2_ -m $MLEN -t 1 uniq.fa extra_dir/uniq.fa intersection_all.fa

test "$((($RLEN - $MLEN + 1) * ($ALL / $RLEN)))" = "$(wc -l < intersection2)"
test "$((($RLEN - $MLEN + 1) * ($UNIQ / $RLEN)))" = "$(wc -l < uniq2_uniq.fa)"
test "0" = "$(wc -l < uniq2_1_uniq.fa)"
test "0" = "$(wc -l < uniq2_intersection_all.fa)"

# Same but with canonical mers
time $JF intersection --verbose -C -s 2M -m $MLEN -t 1 -p uniqC_ -i intersectionC uniq.fa mult.fa intersection_all.fa

test "$((($RLEN - $MLEN + 1) * ($ALL / $RLEN)))" = "$(wc -l < intersectionC)"
test "$((($RLEN - $MLEN + 1) * ($UNIQ / $RLEN)))" = "$(wc -l < uniqC_uniq.fa)"
test "0" = "$(wc -l < uniqC_mult.fa)"
test "0" = "$(wc -l < uniqC_intersection_all.fa)"