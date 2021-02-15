type buyFlightsError:void {
  .description[1,1]:string
}

type buyFlightsRequest:void {
  .flight_requests[0,*]:void {
    .date[1,1]:string
    .flight_id[1,1]:string
  }
}

type buyFlightsResponse:void

type getFlightOffersError:void {
  .description[1,1]:string
}

type getFlightOffersRequest:void

type getFlightOffersResponse:void {
  .flights[1,*]:void {
    .arrival_datetime[1,1]:string
    .cost[1,1]:double
    .departure_airport_code[1,1]:string
    .arrival_airport_code[1,1]:string
    .flight_id[1,1]:string
    .departure_datetime[1,1]:string
  }
}

interface FlightCompanyInputInterface {
RequestResponse:
  buyFlights( buyFlightsRequest )( buyFlightsResponse ) throws Fault500(buyFlightsError)  Fault400(buyFlightsError)  ,
  getFlightOffers( getFlightOffersRequest )( getFlightOffersResponse ) throws Fault500(getFlightOffersError)  Fault400(getFlightOffersError)  
}



outputPort FlightCompanyInput {
  Protocol:sodep
  Location:"local"
  Interfaces:FlightCompanyInputInterface
}


embedded { Jolie: "FlightCompany2.ol" in FlightCompanyInput }
