class ZCL_ZHGWM_MOBILE_MPC_EXT definition
  public
  inheriting from ZCL_ZHGWM_MOBILE_MPC
  create public .

public section.

  types:
    BEGIN OF ts_postrepl_entity ,
        username         TYPE c LENGTH 12,
        warehouse_number TYPE c LENGTH 3,
        to_number        TYPE c LENGTH 20,
        process_status   TYPE c LENGTH 10,
        type             TYPE c LENGTH 1,
        message          TYPE c LENGTH 220,
        nav_postreplsys  TYPE STANDARD TABLE OF ts_postreplitem_sys WITH DEFAULT KEY,
      END OF ts_postrepl_entity .
  types:
    BEGIN OF ts_replenish_entity ,
        username         TYPE c LENGTH 12,
        warehouse_number TYPE c LENGTH 3,
        to_number        TYPE c LENGTH 20,
        type             TYPE c LENGTH 1,
        message          TYPE c LENGTH 220,
        nav_replenishsys TYPE STANDARD TABLE OF ts_replenishitem_sys WITH DEFAULT KEY,
      END OF ts_replenish_entity .
  types:
    BEGIN OF ts_pidyearly_entity ,
        plant            TYPE c LENGTH 4,
        pid_number       TYPE c LENGTH 10,
        pid_year         TYPE c LENGTH 4,
        storage_location TYPE c LENGTH 4,
        username         TYPE c LENGTH 12,
        code_stcat       TYPE c LENGTH 1,
        printer          TYPE c LENGTH 30,
        type             TYPE c LENGTH 1,
        message          TYPE c LENGTH 220,
        nav_pidyr        TYPE STANDARD TABLE OF ts_piditem_year WITH DEFAULT KEY,
      END OF ts_pidyearly_entity .
  types:
    BEGIN OF ts_pidadhoc_entity ,
        plant            TYPE c LENGTH 4,
        storage_location TYPE c LENGTH 4,
        username         TYPE c LENGTH 12,
        pid_number       TYPE c LENGTH 10,
        code_stcat       TYPE c LENGTH 1,
        type             TYPE c LENGTH 1,
        message          TYPE c LENGTH 220,
        nav_adhoc        TYPE STANDARD TABLE OF ts_piditem WITH DEFAULT KEY,
      END OF ts_pidadhoc_entity .
  types:
    BEGIN OF ts_confirm_entity ,
        warehouse_number     TYPE c LENGTH 3,
        material_number      TYPE c LENGTH 18,
        material_description TYPE c LENGTH 40,
        le_quantity          TYPE c LENGTH 20,
        type                 TYPE c LENGTH 1,
        message              TYPE c LENGTH 220,
        nav_conf             TYPE STANDARD TABLE OF ts_transorder WITH DEFAULT KEY,
      END OF ts_confirm_entity .
  types:
    BEGIN OF ts_putaway_entity ,
        warehouse_number     TYPE c LENGTH 3,
        material_number      TYPE c LENGTH 18,
        material_description TYPE c LENGTH 40,
        le_quantity          TYPE c LENGTH 20,
        type                 TYPE c LENGTH 1,
        message              TYPE c LENGTH 220,
        nav_to               TYPE STANDARD TABLE OF ts_transorder WITH DEFAULT KEY,
      END OF ts_putaway_entity .

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZHGWM_MOBILE_MPC_EXT IMPLEMENTATION.


  METHOD define.
    super->define( ).

    DATA:
      lo_annotation   TYPE REF TO /iwbep/if_mgw_odata_annotation,
      lo_entity_type  TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_complex_type TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
      lo_property     TYPE REF TO /iwbep/if_mgw_odata_property,
      lo_entity_set   TYPE REF TO /iwbep/if_mgw_odata_entity_set.

    lo_entity_type = model->get_entity_type( iv_entity_name = 'postputaway_fg' ).
    lo_entity_type->bind_structure(
    iv_structure_name  = 'ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_PUTAWAY_ENTITY' ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'confputaway_fg' ).
    lo_entity_type->bind_structure(
    iv_structure_name  = 'ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_CONFIRM_ENTITY' ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'postpid_adhoc' ).
    lo_entity_type->bind_structure(
    iv_structure_name  = 'ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_PIDADHOC_ENTITY' ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'replenish_sys' ).
    lo_entity_type->bind_structure(
    iv_structure_name  = 'ZCL_ZHGWM_MOBILE_MPC_EXT=>TS_REPLENISH_ENTITY' ).
  ENDMETHOD.
ENDCLASS.
