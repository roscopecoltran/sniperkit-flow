FROM mhart/alpine-node:latest

# docker build -t node-red-alpine --no-cache .
# docker run --rm -p 1880:1880  node-red-alpine

RUN apk add --update --no-cache --no-progress msgpack-c msgpack-c-dev lua-cmsgpack libcrypto1.0 \ 
	&& npm i -g node-red node-red-admin node-red-node-msgpack node-red-dashboard node-red-node-base64 \
				node-red-contrib-composer node-red-contrib-ui \
				node-red-node-instagram \
				node-red-node-google \
				node-red-node-flickr \
				node-red-node-delicious \
				node-red-node-aws \
				node-red-node-openweathermap \
				node-red-auth-github \
				node-red-auth-twitter \
				node-red-node-swagger \
				nanomsg \
				node-red-dashboard \
				node-red-node-watson \
				node-red-node-wordpos \
				node-red-node-badwords \
				node-red-node-random \
				node-red-node-geohash \
				node-red-node-notify \
				node-red-node-exif 

	# node-red-node-mysql node-red-node-mongodb
	# leveldb leveldb-dev \

CMD ["/usr/bin/node-red"]

EXPOSE 1880
