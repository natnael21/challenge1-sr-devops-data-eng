
#!/bin/bash

curl -X POST http://localhost:3000/api/v1/user/repos   -H "Content-Type: application/json"   -u "gitea_admin:admin_password"   -d '{"name": "etl-sandbox", "private": false}'
