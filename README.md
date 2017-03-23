# Buffer's (Old) Diversity dashboard

# DEPRECATED

This project has been deprecated by Buffer's new [diversity dashboard](http://diversity.buffer.com/) and is thus not supported by Buffer anymore. No new development or bugfixes will be taking place. Feel free to fork this project if you're up for making improvements!

*What gets measured gets managed*

Built using R and [Shiny](http://shiny.rstudio.com/), this a dashboard showing realtime diversity data for applicants who apply to work at Buffer as well as the Buffer team.

All data is collected through an anonymous, voluntary survey that applicants and team members submit.

At Buffer we care deeply about building diverse teams. The Diversity Dashboard is our attempt to gain a deeper understanding of the diversity of our teams and people who apply to work at Buffer, as well as tracking how this changes over time.

In the spirit of transparency, we want share this data with the world, as well as the code.

If you are interested in creating a similar Dashboard for your own company, feel free to use the source code provided.

## Setup

This project is designed to run within a Docker, and is currently deployed as an [Elastic Beanstalk](https://aws.amazon.com/documentation/elastic-beanstalk/) Application.

### Development environment

For running locally, we use [docker-compose](https://docs.docker.com/compose/). Make sure you have [Docker](https://docs.docker.com/installation/mac/) and [docker-compose](https://docs.docker.com/compose/install/) installed, and then run:

```
docker-compose up -d
```

To get the IP of your docker container (with Docker Machine):

```
docker-machine ip
```

The application will run on port 3838 by default.

### Deployment (using Amazon Elastic Beanstalk)

Included is a ``Dockerrun.aws.json`` file. Create a new Elastic Beanstalk application [from a Docker container](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.html).
Once it's up and running you can create a .zip file of the source directory and upload it to AWS.

