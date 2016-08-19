# ustwo Diversity dashboard

[diversity.ustwo.com](http://diversity.ustwo.com)

(Anything below this line comes from the great team at Buffer, developers of the Dashboard, which here at ustwo we are using to share our own data)

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

To get the IP of your docker container (with boot2docker):

```
boot2docker ip
```

The application will run on port 3838 by default.

### Deployment (using Amazon Elastic Beanstalk)

Included is a ``Dockerrun.aws.json`` file. Create a new Elastic Beanstalk application [from a Docker container](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.html).
Once it's up and running you can create a .zip file of the source directory and upload it to AWS.
