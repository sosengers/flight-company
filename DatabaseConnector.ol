include "console.iol"
include "database.iol"
include "runtime.iol"
include "time.iol"
include "semaphore_utils.iol"

include "FlightCompanyInterface.iol"

execution { concurrent }

inputPort FlightCompanyInput {
    Location: "local"
    Protocol: sodep
    Interfaces: FlightCompanyInterface
}

init {
    // Loading environment variables.
    getenv@Runtime( "PG_USER" )( PG_USER )
    getenv@Runtime( "PG_PASSWORD" )( PG_PASSWORD )
    getenv@Runtime( "PG_DATABASE" )( PG_DATABASE )

    if ( PG_USER instanceof void || PG_PASSWORD instanceof void || PG_DATABASE instanceof void )  {
        println@Console( "Not all environment variables are set." )();
        callExit@Runtime()()
    }

    install(
        InvalidDriver => {
            println@Console("Invalid driver.")();
            callExit@Runtime()()
        },
        ConnectionError => {
            println@Console("Connection error.")();
            callExit@Runtime()()
        },
        DriverClassNotFound => {
            println@Console("Driver class not found.")();
            callExit@Runtime()()
        }
    )
    
    // Generating connection data and connecting to the PostegreSQL database
    with ( connectionInfo ) {
        .username = PG_USER;
        .password = PG_PASSWORD;
        .host = "?";
        .database = PG_DATABASE;
        .driver = "postgresql"
    }
    
    connect@Database(connectionInfo)();

    // Creating the table if it does not exist
    scope (createTable) {
        install(
            SQLException => println@Console("flights table already exists in database " + PG_DATABASE)()
        );

        update@Database(
            "CREATE TABLE flights(" +
            "flight_id varchar(10)," + // ID of the flight
            "departure_airport_code varchar(3)," + // Airport from which the flight departs from
            "arrival_airport_code varchar(3)," + // Airport to which the flight arrives to
            "cost double precision," + // Cost of the flight
            "departure_datetime timestamp with time zone," + // Time of departure of the flight from the departure airport
            "arrival_datetime timestamp with time zone," + // Time of arrival of the flight to the arrival airport
            "sold_tickets integer," + // Simple counter of how many tickets were sold for this flight for the departure_datetime
            "insertion_date date," + // When the flight was inserted into the database
            "PRIMARY KEY (flight_id, departure_datetime)" +
            ")"
        )( createTableResult )
    }
}

main {
    [ buyFlights( buyFlightsRequest )( buyFlightsResponse ) {
        acquire@SemaphoreUtils( { .name = "buyFlights" } )( acquired )
        scope( update ) {
            install(
                SQLException => println@Console("Could not update the flight counter.")()
            );

            query@Database(
                "SELECT sold_tickets FROM flights WHERE flight_id = :id AND departure_datetime = :date" {
                    .id = buyFlightsRequest.flight_id,
                    .date = buyFlightsRequest.departure_datetime
                }
            )( selectResult );

            println@Console("SELECT result's rows (#): " + #selectResult.row)()

            if( #selectResult.row == 1) {
                tickets = selectResult.row[0] + 1;

                update@Database(
                    "UPDATE flights SET sold_tickets = :tickets WHERE flight_id = :id AND departure_datetime = :date" {
                        .id = buyFlightsRequest.flight_id,
                        .date = buyFlightsRequest.departure_datetime,
                        .tickets = tickets
                    }
                )( updateResult );

                println@Console("UPDATE result: " + updateResult)()
            } else {
                throw (Fault500, { 
                    .description = "Flight with flight_id = " + buyFlightsRequest.flight_id + " and departure_datetime = " + buyFlightsRequest.departure_datetime + " was not found."
                })
            }
        }
        release@SemaphoreUtils( { .name = "buyFlights" })( released )
    }]

    [ getFlightOffers( getFlightOffersRequest )( getFlightOffersResponse ) {
        scope( update ) {
            install(
                SQLException => println@Console("Could not retrieve flights.")()
            );

            getCurrentDateTime@Time( { .format = "yyyy-MM-dd" } )( currentDate )

            query@Database(
                "SELECT * FROM flights WHERE insertion_date = :current" {
                    .current = currentDate
                }
            )( selectResult );

            println@Console("SELECT result's rows (#): " + #selectResult.row)();

            for(i = 0, i < #selectResult.row, i++) {
                currentRow -> selectResult.row[i];
                with(getFlightOffersResponse) {
                    .flights[i].flight_id = currentRow.flight_id;
                    .flights[i].departure_airport_code = currentRow.departure_airport_code;
                    .flights[i].arrival_airport_code = currentRow.arrival_airport_code;
                    .flights[i].cost = currentRow.cost;
                    .flights[i].departure_datetime = currentRow.departure_datetime;
                    .flights[i].arrival_datetime = currentRow.arrival_datetime
                }
            }
        }
    }]
}