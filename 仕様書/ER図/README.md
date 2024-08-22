# build
docker build . -t erd
# pdf作成
docker run --rm -i erd < roadmaphub.er > er.pdf
