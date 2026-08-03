class ZCL_ZWMS_MATERIAL_MPC_EXT definition
  public
  inheriting from ZCL_ZWMS_MATERIAL_MPC
  create public .

public section.

   TYPES:
      BEGIN OF ts_deep_entity,
        warehouse    TYPE c LENGTH 3,
        storage_type TYPE c LENGTH 3,
        storage_bin  TYPE c LENGTH 10,
        dcc_number   TYPE c LENGTH 10,
        nav_dcc TYPE TABLE OF ts_dcc_d WITH DEFAULT KEY,
      END OF  ts_deep_entity .

    METHODS define
        REDEFINITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZWMS_MATERIAL_MPC_EXT IMPLEMENTATION.


  method DEFINE.
 DATA:
      lo_annotation   TYPE REF TO /iwbep/if_mgw_odata_annotation,
      lo_entity_type  TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_complex_type TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
      lo_property     TYPE REF TO /iwbep/if_mgw_odata_property,
      lo_entity_set   TYPE REF TO /iwbep/if_mgw_odata_entity_set.

    super->define( ).
    lo_entity_type = model->get_entity_type( iv_entity_name = 'dcc_h' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZWMS_MATERIAL_MPC_EXT=>TS_DEEP_ENTITY' ).
  endmethod.
ENDCLASS.
