# build
docker build . -t erd
# pdf作成
docker run -i erd < sample.er > out.pdf
