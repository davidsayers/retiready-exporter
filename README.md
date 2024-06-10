# retiready-exporter

I wish I had not needed to create this repo but Retiready has no graphs which allowed me track how my pension was doing.

This repo allows people to run a simple webapp which publishes metrics which can be scraped by [Prometheus](https://prometheus.io/) and then displayed through [Grafana](https://grafana.com/).

## Prerequisites

1. Login credentials for [https://retiready.co.uk/public/sign-in.html](https://retiready.co.uk/public/sign-in.html)
2. An API key for [https://2captcha.com](https://2captcha.com/). I wish this was not needed but I am not aware of any developer API key access for Retiready.
3. [Docker](https://www.docker.com/)
3. An instance of Grafana & Prometheus. Here are some options for running your own:
	* [On a Raspberry Pi](https://grafana.com/tutorials/install-grafana-on-raspberry-pi/)
	* [AWS Prometheus](https://aws.amazon.com/prometheus/). Be careful to stay within the free tier limits.
	* [Grafana Cloud](https://grafana.com/products/cloud/). Only has 14 days free retention.

## How to Run

1. Create an env file for credentials `cp .env.example .env`
2. Add Retiready + 2captcha credentials to `.env`
3. Run with Docker:
```
docker run -p 9292:9292 --restart always -d --env-file .env --name retiready-exporter retiready-exporter
```

### Running locally

The `docker-compose.yaml` in this repo will run an instance of Grafana, Prometheus and the retiready-exporter.

After setting up your `.env` you only need to run the following:

```
docker-compose run -P grafana
```

You will then be able to see your metrics at [http://localhost:3000/dashboards](http://localhost:3000/dashboards)