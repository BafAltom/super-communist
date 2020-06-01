del gen_love /Q

mkdir gen_love
mkdir gen_love\lib
mkdir gen_love\res

copy res\* gen_love\res
copy lib\* gen_love\lib

cd src
moonc -t ../gen_love *.moon
cd ..

cd gen_love

love .
