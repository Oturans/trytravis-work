gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--boot-disk-type=pd-ssd \
--image-project=infra-270920 \
--image-family=reddit-full \
--zone europe-west1-d \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure