CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calcluateBookingID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calcluateBookingID.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calcluateBookingID.
    DATA max_booking_id TYPE /dmo/booking_id.
    DATA update TYPE TABLE FOR UPDATE ZI_RAP_Travel_fw\\Booking.

    " Read all travels for the requested bookings.
    " If multiple bookings of the same travel are requested, the travel is returned only once
    READ ENTITIES OF ZI_RAP_Travel_fw IN LOCAL MODE
      ENTITY Booking BY \_Travel
        FIELDS ( TravelUUID )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    " Process all affected Travels. Read respective bookings, determine the max-id and update the bookings without ID.
    LOOP AT travels INTO DATA(travel).
      READ ENTITIES OF ZI_RAP_Travel_fw IN LOCAL MODE
        ENTITY Travel BY \_Booking
          FIELDS ( BookingID )
        WITH VALUE #( ( %tky = travel-%tky ) )
        RESULT DATA(bookings).

      " Find max used BookingID in all bookings of this travel
      max_booking_id = '0000'.
      LOOP AT bookings INTO DATA(booking).
        IF booking-BookingID >= max_booking_id.
          max_booking_id = booking-BookingID.
        ENDIF.
      ENDLOOP.

      " Provide a booking ID for all bookings that have none
      LOOP AT bookings INTO booking WHERE BookingID IS INITIAL.
        max_booking_id += 10.
        APPEND VALUE #( %tky = booking-%tky
                        BookingID = max_booking_id
                        ) TO update.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculateTotalPrice.
    " Read all travels for the requested bookings.
    " If multiple bookings of the same travel are requested, the travel is returned only once.
    READ ENTITIES OF ZI_RAP_Travel_fw IN LOCAL MODE
    ENTITY Booking BY \_Travel
      FIELDS ( TravelUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      FAILED DATA(read_failed).

    " Trigger calculation of the total price
    MODIFY ENTITIES OF ZI_RAP_Travel_fw IN LOCAL MODE
    ENTITY Travel
      EXECUTE recalcTotalPrice
      FROM CORRESPONDING #( travels )
    REPORTED DATA(execute_reported).

    reported = CORRESPONDING #( DEEP execute_reported ).
  ENDMETHOD.

ENDCLASS.
