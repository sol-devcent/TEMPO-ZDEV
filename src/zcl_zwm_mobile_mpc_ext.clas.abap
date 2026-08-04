CLASS zcl_zwm_mobile_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zwm_mobile_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_login_entity,
        username         TYPE c LENGTH 12,
        password         TYPE c LENGTH 40,
        warehouse_number TYPE c LENGTH 3,
        plant            TYPE c LENGTH 4,
        mmenu            TYPE c LENGTH 5000,
        type             TYPE c LENGTH 1,
        message          TYPE c LENGTH 220,
        nav_login        TYPE STANDARD TABLE OF ts_menu WITH DEFAULT KEY,
      END OF ts_login_entity .

    METHODS define
        REDEFINITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZWM_MOBILE_MPC_EXT IMPLEMENTATION.


  method DEFINE.
    super->define( ).

    DATA:
      lo_annotation   TYPE REF TO /iwbep/if_mgw_odata_annotation,
      lo_entity_type  TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_complex_type TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
      lo_property     TYPE REF TO /iwbep/if_mgw_odata_property,
      lo_entity_set   TYPE REF TO /iwbep/if_mgw_odata_entity_set.

    lo_entity_type = model->get_entity_type( iv_entity_name = 'login' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZWM_MOBILE_MPC_EXT=>TS_LOGIN_ENTITY' ).

  endmethod.
ENDCLASS.
