build:
	docker build -t lloydpick/dump1090 .

run:
	docker run -it --rm lloydpick/dump1090

buildx:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 -t lloydpick/dump1090 .

deploy:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 -t lloydpick/dump1090 --push .

.PHONY: buildx
