# Markdown Web Example: AWS EC2 Configuration

## How to Use

1. Create a _.env_ file in git root, included with

```
AWS_ACCESS_KEY_ID=my_key_id
AWS_SECRET_ACCESS_KEY=my_key
```

2. Pull Docker images.
```sh
docker-compose pull
```

3. Run first container, then wait 1 minute.
```sh
docker-compose up -d aws
```

4. Run second container.
```sh
docker-compose up -d web
```

## Access Page

You can change listening port in _docker-compose.yml_. (Default is 80)

Open url http://HOST/ec2/list to access data.
