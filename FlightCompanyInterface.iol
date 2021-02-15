type buyFlightsRequest: void {
    .flight_requests*: void {
        .flight_id: string
        .date: string
    }
}

type buyFlightsResponse: void {

}

type buyFlightsError: void {
	.description: string
}

type getFlightOffersRequest: void {

}

type getFlightOffersResponse: void {
    .flights*: void {
        .flight_id: string
        .departure_airport_code: string
        .arrival_airport_code: string
        .cost: double
        .departure_datetime: string
        .arrival_datetime: string
    }
}

type getFlightOffersError: void {
	.description: string
}

interface FlightCompanyInterface {
RequestResponse:
    buyFlights( buyFlightsRequest )( buyFlightsResponse ) throws Fault400( buyFlightsError ) Fault500 ( buyFlightsError ),
    getFlightOffers( getFlightOffersRequest )( getFlightOffersResponse ) throws Fault400( getFlightOffersError ) Fault500 ( getFlightOffersError )
}