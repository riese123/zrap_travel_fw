CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF travel_status,
        open      TYPE c LENGTH 1 VALUE 'O', "Open
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        cancelled TYPE c LENGTH 1 VALUE 'X', "Cancelled
      END OF travel_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS recalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~recalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setInitialStatus.

    METHODS calculateTravelID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~calculateTravelID.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD acceptTravel.
    " Set the new overall status
    MODIFY ENTITIES OF zi_rap_travel_FW IN LOCAL MODE
     ENTITY Travel
       UPDATE
         FIELDS ( TravelStatus )
         WITH VALUE #( FOR key IN keys
                       (  %tky         = key-%tky
                          TravelStatus = travel_status-accepted ) )

    FAILED   failed
    REPORTED reported.

    " Fill the response table
    READ ENTITIES OF zi_rap_travel_FW IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels
                        ( %tky   = travel-%tky
                          %param = travel ) ).
  ENDMETHOD.

  METHOD recalcTotalPrice.

  ENDMETHOD.

  METHOD rejectTravel.
    " Set the new overall status
    MODIFY ENTITIES OF ZI_RAP_Travel_fw IN LOCAL MODE
      ENTITY Travel
        UPDATE
          FIELDS ( TravelStatus )
          WITH VALUE #( FOR key IN keys
                        ( %tky         = key-%tky
                          TravelStatus = travel_status-cancelled ) )

  FAILED   failed
  REPORTED reported.

    " Fill the response table
    READ ENTITIES OF zi_rap_travel_fw IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels
                          ( %tky = travel-%tky
                            %param = travel ) ).
  ENDMETHOD.

  METHOD calculateTotalPrice.
  ENDMETHOD.

  METHOD setInitialStatus.
  ENDMETHOD.

  METHOD calculateTravelID.
  ENDMETHOD.

  METHOD validateAgency.
    " Read relevant travel instance data
    READ ENTITIES OF zi_rap_travel_fw IN LOCAL MODE
      ENTITY Travel
        FIELDS ( AgencyID ) WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DATA agencies TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    " Optimization of DB select: extract distinct non-initial agency IDs
    agencies = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING agency_id = AgencyID EXCEPT * ).
    DELETE agencies WHERE agency_id IS INITIAL.

    IF agencies IS NOT INITIAL.
      " CHeck if agency ID exist
      SELECT FROM /dmo/agency FIELDS agency_id
        FOR ALL ENTRIES IN @agencies
        WHERE agency_id = @agencies-agency_id
        INTO TABLE @DATA(agencies_db).
    ENDIF.

    " Raise msg for non existing and initial agencyID
    LOOP AT travels INTO DATA(travel).
      " Clear status messages that might exist
      APPEND VALUE #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_AGENCY' )
        TO reported-travel.

      IF travel-AgencyID IS INITIAL OR NOT line_exists( agencies_db[ agency_id = travel-AgencyID ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_AGENCY'
                        %msg        = NEW zcm_rap_fw(
                                            severity = if_abap_behv_message=>severity-error
                                            textid   = zcm_rap_fw=>agency_unknown
                                            agencyid = travel-AgencyID )
                        %element-AgencyID = if_abap_behv=>mk-on )
        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.
    " Read relevant  travel instance data
    READ ENTITIES OF zi_rap_travel_fw IN LOCAL MODE
      ENTITY Travel
        FIELDS ( CustomerID ) WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    " Optimization of DB select: extract distinct non-initial customer IDs
    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.
    IF customers IS NOT INITIAL.
      " Check if customer ID exists
      SELECT FROM /dmo/customer FIELDS customer_id
        FOR ALL ENTRIES IN @customers
        WHERE customer_id = @customers-customer_id
        INTO TABLE @DATA(customers_db).
    ENDIF.

    " Raise msg for non-existing and initial customerID
    LOOP AT travels INTO DATA(travel).
      " Clear state messages that may exist
      APPEND VALUE #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_CUSTOMER' )
        TO reported-travel.

      IF travel-CustomerID IS INITIAL OR NOT line_exists( customers_db[ customer_id = travel-CustomerID ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg        = NEW zcm_rap_fw(
                                            severity    = if_abap_behv_message=>severity-error
                                            textid      = zcm_rap_fw=>customer_unknown
                                            customerid = travel-CustomerID )
                        %element-CustomerID = if_abap_behv=>mk-on )
          TO reported-travel.
        ENDIF.
      ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

ENDCLASS.
