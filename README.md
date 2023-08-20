# Log Client

ធ្វើការកំណត់ Configure ដើម្បីឲ្យដំណើរការ logs-client នឹងរុញទិន្នន័យទៅកាន់ server ត្រឹមត្រូវមួយ

## install pm2 module

```bash
pm2 install kh71-nodejs/logs-client
```

## Configure

```bash
pm2 set logs-client:ServerName name
pm2 set logs-client:SecretToken objectID
pm2 set logs-client:SocketProtocol wss/ws
pm2 set logs-client:SocketServer portal.kh71.com
```

## Uninstall

```bash
pm2 uninstall kh71-nodejs/logs-client
```
