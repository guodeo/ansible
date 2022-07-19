FROM cypress/included:10.3.0 as build
WORKDIR /app
ADD app/package.json .
ADD app/package-lock.json .
ENV HTTP_PROXY=http://dcpwvsqid01.edftrading.com:3128
WORKDIR /app
ADD app/package.json .
ADD app/package-lock.json .
RUN npm ci
COPY app .

FROM build AS testrunner
WORKDIR /app
ENTRYPOINT ["npm", "run", "test:ci"]

FROM build AS e2etestrunner
WORKDIR /app
ENTRYPOINT ["npm", "run", "cypress:ci"]

FROM build AS test
RUN ["npm", "run", "test:ci"]
RUN ["npm", "run", "cypress:ci"]

FROM test AS publish
RUN ["npm", "run", "build"]

FROM nginx:1.23.0
COPY --from=publish /app/dist/app /usr/share/nginx/html
COPY ./nginx/templates/*.* /etc/nginx/templates/
