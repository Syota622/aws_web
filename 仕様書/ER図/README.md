# build
docker build . -t erd
# pdf作成
docker run -i erd < roadmaphub.er > er.pdf
