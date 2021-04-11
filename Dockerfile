FROM jolielang/jolie

RUN mkdir flightCompany
WORKDIR flightCompany

RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.18.jar -O /usr/lib/jolie/lib/jdbc-postgresql.jar

COPY FlightCompany.ol ./
COPY FlightCompanyInterface.iol ./
COPY DatabaseConnector.ol ./
COPY rest_template.json ./

EXPOSE 8080

CMD ["jolier", "FlightCompany.ol", "FlightCompanyInput", "localhost:8080"]
