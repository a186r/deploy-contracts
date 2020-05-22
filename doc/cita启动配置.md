```
docker run -d -p 127.0.0.1:1337:1337 -p 127.0.0.1:4000:4000 -v "`pwd`":/opt/cita-run cita/cita-release:20.2.0-sm2-sm3 /bin/bash -c 'cita setup test-chain/0 && cita start test-chain/0 && sleep infinity'

docker run -d -p 127.0.0.1:1338:1338 -p 127.0.0.1:4001:4001 -v "`pwd`":/opt/cita-run cita/cita-release:20.2.0-sm2-sm3 /bin/bash -c 'cita setup test-chain/1 && cita start test-chain/1 && sleep infinity'
```