#!/bin/sh
CWD=$PWD
export SONAR_TOKEN=$(cat SONAR_TOKEN)
# Run Tests
cd services/demo-api
# python3 -m pytest --cov=src --cov-report=xml --junitxml=tests.xml tests
docker build --target export-test-results --output type=local,dest=reports .
sed -i'.bak' -e 's/\/app\/src/services\/demo-api\/src/g' reports/coverage.xml
cd $CWD

# Run 
sonar-scanner \
  -Dsonar.organization=phclark \
  -Dsonar.projectKey=phclark_k8s-demo \
  -Dsonar.sources=src \
  -Dsonar.tests=tests \
  -Dsonar.python.coverage.reportPaths=**/coverage.xml \
  -Dsonar.python.xunit.reportPath=**/tests.xml \
  -Dsonar.host.url=https://sonarcloud.io