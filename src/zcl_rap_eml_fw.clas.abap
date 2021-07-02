CLASS zcl_rap_eml_fw DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_rap_eml_fw IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    "step 1 - READ
*    READ ENTITIES OF zi_rap_travel_fw
*      ENTITY  Travel
*        FROM VALUE #( ( TravelUUID = '7687AD305163869117000E02C76E016B' ) ) "Travel_ID 00000002
*        RESULT DATA(travels).
*
*    out->write( travels ).

    "step 2 - READ with Fields
*    READ ENTITIES OF zi_rap_travel_fw
*      ENTITY  Travel
*        FIELDS ( AgencyID CustomerID )
*        WITH VALUE #( ( TravelUUID = '7687AD305163869117000E02C76E016B' ) ) "Travel_ID 00000002
*        RESULT DATA(travels).
*
*    out->write( travels ).

    "step 3 - READ with All Fields
*    READ ENTITIES OF ZI_RAP_TRAVEL_FW
*      ENTITY travel
*        ALL FIELDS WITH VALUE #( ( TravelUUID = '7687AD305163869117000E02C76E016B' ) )
*        RESULT DATA(travels).
*
*    out->write( travels ).

    "step 4 - READ By Association
*    READ ENTITIES OF ZI_RAP_Travel_FW
*      ENTITY travel BY \_Booking
*        ALL FIELDS WITH VALUE #( ( TravelUUID = '7687AD305163869117000E02C76E016B' ) )
*      RESULT DATA(bookings).
*
*      out->write( bookings ).

    "step 5 - unsuccessful READ
*    READ ENTITIES OF zi_rap_travel_fw
*    ENTITY travel
*      ALL FIELDS WITH VALUE #( ( TravelUUID = '7687AD305163869117000E02C76E0169' ) )
*    RESULT DATA(travels)
*    FAILED DATA(failed)
*    REPORTED DATA(reported).
*
*    out->write( travels ).
*    out->write( failed ).
*    out->write( reported ).

    "step 6 - MODIFY Update
*    MODIFY ENTITIES OF zi_rap_travel_fw
*      ENTITY travel
*        UPDATE
*          SET FIELDS WITH VALUE
*           #( ( TravelUUID = '7687AD305163869117000E02C76E016B'
*                Description = 'I like RAP@openSAP'  ) )
*
*    FAILED DATA(failed)
*    REPORTED DATA(reported).
*
*    out->write( 'Update done' ).
*
*    "step 6b - Commit Entities
*    COMMIT ENTITIES
*      RESPONSE OF zi_rap_travel_fw
*      FAILED DATA(failed_commit)
*      REPORTED DATA(reported_commit).

    "step 7 - MODIFY create
*    MODIFY ENTITIES OF zi_rap_travel_fw
*      ENTITY travel
*        CREATE
*          SET FIELDS WITH VALUE
*            #( ( %cid = 'MyContentID_1'
*                 AgencyID = '70012'
*                 CustomerID = '14'
*                 BeginDate = cl_abap_context_info=>get_system_date(  )
*                 EndDate = cl_abap_context_info=>get_system_date(  ) + 10
*                 Description = 'I like RAP@openSAP' ) )
*
*      MAPPED DATA(mapped)
*      FAILED DATA(failed)
*      REPORTED DATA(reported).
*
*    out->write( mapped-travel ).
*
*    COMMIT ENTITIES
*      RESPONSE OF ZI_RAP_Travel_FW
*      FAILED DATA(failed_commit)
*      REPORTED DATA(reported_commit).
*
*    out->write( 'Create done' ).

    "step 8 - MODIFY Delete
    MODIFY ENTITIES OF zi_rap_travel_fw
      ENTITY travel
        DELETE FROM
          VALUE
            #( ( TravelUUID = '02A9119FFAE41EEBB6E05F156B079DD6' ) )

       FAILED DATA(failed)
       REPORTED DATA(reported).

    COMMIT ENTITIES
      RESPONSE OF zi_rap_travel_fw
      FAILED DATA(failed_commit)
      REPORTED DATA(reported_commit).

    out->write( 'Delete done' ).
  ENDMETHOD.

ENDCLASS.
