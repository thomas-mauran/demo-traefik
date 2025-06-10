## Terraform config

### Api deployment module
This module deploys the foobar API.

The goal is to be able to deploy the API with a single command, using the `terraform apply` command in each of our regional clusters.

### Load balancer deployment module
This module deploys the load balancer for the API.
The goal is to be have in front of our 2 regional clusters a load balancer that will route the traffic to the API pods in the regional clusters.

Initially the loadbalancer was using the geoip2 middleware to add the country code to the request header, but this was removed because right now it seems like the middleware headers are added after the request is routed by traefik in the ingress route. This means we add a country code to the header after traefik already decided which service to route the request to.

To fix this we need to have the geoip information sooner this is done by a cloudflare proxy that will add the country code to the request header before it reaches the load balancer.

It was very interesting though to learn how to install traefik plugins and use middlewares.

In local development the loadbalancer use a round robin strategy to route the traffic to the 2 regional clusters.

To check this round robin we can do the following command:

```bash
curl -k -v https://api.lb 2>&1 | grep 'Host:'
```

We see the alternation of the 2 regional clusters in the output.

![alt text](./assets/roundrobin.png "Round Robin")