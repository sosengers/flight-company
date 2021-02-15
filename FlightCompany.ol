include "console.iol"
include "string_utils.iol"
include "time.iol"

include "FlightCompanyInterface.iol"

execution{ concurrent }

inputPort FlightCompanyInput {
    Location: "local"
    Protocol: sodep
    Interfaces: FlightCompanyInterface
}

init {
	println@Console("Flight company service started")();
	install (
        Fault400 => throw(Fault400, {description = main.Fault400.description}),
        Fault500 => throw(Fault500, {description = main.Fault500.description})
    )
}

main {
    [ buyFlights( buyFlightsRequest )( buyFlightsResponse ) {
        println@Console( buyFlightsRequest.flight_requests[0].flight_id + " " + buyFlightsRequest.flight_requests[0].date )()
        println@Console( buyFlightsRequest.flight_requests[1].flight_id + " " + buyFlightsRequest.flight_requests[1].date )()
    }]

    [ getFlightOffers( getFlightOffersRequest )( getFlightOffersResponse ) {
        with( getFlightOffersResponse ) {
            .flights[0].flight_id = "1";
            .flights[0].departure_airport_code = "2";
            .flights[0].arrival_airport_code = "3";
            .flights[0].cost = 4.5;
            .flights[0].departure_datetime = "6";
            .flights[0].arrival_datetime = "7"
        }
    }]
}