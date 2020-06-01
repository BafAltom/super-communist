del gen_love /Q

mkdir gen_love
mkdir gen_love\lib
mkdir gen_love\res

copy src\*.moon gen_love
copy res\* gen_love\res
copy lib\* gen_love\lib

moonc gen_love

cd gen_love

love .
