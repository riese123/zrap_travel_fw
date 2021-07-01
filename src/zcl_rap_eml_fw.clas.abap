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
    READ ENTITIES OF zi_rap_travel_fw
      ENTITY  Travel
        FROM VALUE #( ( TravelUUID = '7687AD305163869117000E02C76E016B' ) )
        RESULT DATA(travels).

    out->write( travels ).
  ENDMETHOD.

ENDCLASS.
