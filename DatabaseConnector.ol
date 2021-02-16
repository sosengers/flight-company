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
    getenv@Runtime( "POSTGRES_USER" )( PG_USER )
    getenv@Runtime( "POSTGRES_PASSWORD" )( PG_PASSWORD )
    getenv@Runtime( "POSTGRES_DB" )( PG_DATABASE )
    getenv@Runtime( "POSTGRES_HOST" )( PG_HOST )

    if ( PG_USER instanceof void || PG_PASSWORD instanceof void || PG_DATABASE instanceof void || PG_HOST instanceof void)  {
        println@Console( "[DatabaseConnector] Not all environment variables are set." )();
        halt@Runtime()()
    }

    install(
        InvalidDriver => {
            println@Console("[DatabaseConnector] Invalid driver.")();
            halt@Runtime()()
        },
        ConnectionError => {
            println@Console("[DatabaseConnector] Connection error.")()
            halt@Runtime()()
        },
        DriverClassNotFound => {
            println@Console("[DatabaseConnector] Driver class not found.")();
            halt@Runtime()()
        }
    )
    
    // Generating connection data and connecting to the PostegreSQL database
    with ( connectionInfo ) {
        .username = PG_USER;
        .password = PG_PASSWORD;
        .host = PG_HOST;
        .database = PG_DATABASE;
        .driver = "postgresql"
    }
    
    connect@Database(connectionInfo)();

    // Creating the table if it does not exist
    scope (createTable) {
        install(
            SQLException => println@Console("[DatabaseConnector] flights table already exists in database " + PG_DATABASE)()
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
                SQLException => println@Console("[DatabaseConnector] Could not update the flight counter.")()
            );

            query@Database(
                "SELECT sold_tickets FROM flights WHERE flight_id = :id AND departure_datetime = :date" {
                    .id = buyFlightsRequest.flight_id,
                    .date = buyFlightsRequest.departure_datetime
                }
            )( selectResult );

            println@Console("[DatabaseConnector] SELECT result's rows (#): " + #selectResult.row)()

            if( #selectResult.row == 1) {
                tickets = selectResult.row[0] + 1;

                update@Database(
                    "UPDATE flights SET sold_tickets = :tickets WHERE flight_id = :id AND departure_datetime = :date" {
                        .id = buyFlightsRequest.flight_id,
                        .date = buyFlightsRequest.departure_datetime,
                        .tickets = tickets
                    }
                )( updateResult );

                println@Console("[DatabaseConnector] UPDATE result: " + updateResult)()
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
                SQLException => println@Console("[DatabaseConnector] Could not retrieve flights.")()
            );

            getCurrentDateTime@Time( { .format = "yyyy-MM-dd" } )( currentDate )
            println@Console(currentDate)()
            query@Database(
                "SELECT * FROM flights WHERE insertion_date = '"+ currentDate  +"';"
//                "SELECT * FROM flights WHERE insertion_date = ':current'" {
//                    .current = currentDate
//                }
            )( selectResult );

            println@Console("[DatabaseConnector] SELECT result's rows (#): " + #selectResult.row)();

            for(i = 0, i < #selectResult.row, i++) {
                currentRow -> selectResult.row[i];
                with(getFlightOffersResponse) {
                    .flights._[i].flight_id = currentRow.flight_id;
                    .flights._[i].departure_airport_code = currentRow.departure_airport_code;
                    .flights._[i].arrival_airport_code = currentRow.arrival_airport_code;
                    .flights._[i].cost = currentRow.cost;
                    .flights._[i].departure_datetime = currentRow.departure_datetime;
                    .flights._[i].arrival_datetime = currentRow.arrival_datetime
                }
            }
        }
    }]
}
