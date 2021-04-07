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

outputPort DbConnector {
    Interfaces: FlightCompanyInterface
}

embedded {
    Jolie:
        "DatabaseConnector.ol" in DbConnector
}

init {
	println@Console("[FlightCompany] Flight company service started")();
	install (
        Fault400 => throw(Fault400, {description = main.Fault400.description}),
        Fault500 => throw(Fault500, {description = main.Fault500.description})
    )
}

main {
    [ buyFlights( buyFlightsRequest )( buyFlightsResponse ) {
        println@Console("Received request to buy a flight")()
        buyFlights@DbConnector(buyFlightsRequest)(buyFlightsResponse)
    }]

    [ getFlightOffers( getFlightOffersRequest )( getFlightOffersResponse ) {
        getFlightOffers@DbConnector(getFlightOffersRequest)(getFlightOffersResponse)
    }]
}
