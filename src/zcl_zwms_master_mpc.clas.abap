class ZCL_ZWMS_MASTER_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  types:
    begin of TS_FGET_STOCKMATERIAL,
        PLANT type C length 4,
        MATERIAL_NUMBER type C length 18,
        STORAGE_TYPE type C length 3,
        WAREHOUSE type C length 3,
    end of TS_FGET_STOCKMATERIAL .
  types:
   begin of ts_text_element,
      artifact_name  type c length 40,       " technical name
      artifact_type  type c length 4,
      parent_artifact_name type c length 40, " technical name
      parent_artifact_type type c length 4,
      text_symbol    type textpoolky,
   end of ts_text_element .
  types:
         tt_text_elements type standard table of ts_text_element with key text_symbol .
  types:
    begin of TS_FGET_MATERIAL,
        WAREHOUSE type C length 3,
    end of TS_FGET_MATERIAL .
  types:
    begin of TS_FGET_BATCH,
        MATERIAL_NUMBER type C length 18,
    end of TS_FGET_BATCH .
  types:
    begin of TS_FGET_UOM,
        MATERIAL_NUMBER type C length 18,
    end of TS_FGET_UOM .
  types:
    begin of TS_FGET_STOCKBIN,
        WAREHOUSE type C length 3,
        PLANT type C length 4,
        STORAGE_TYPE type C length 3,
        STORAGE_BIN type C length 10,
    end of TS_FGET_STOCKBIN .
  types:
    begin of TS_FGET_UOM1,
        MATERIAL_NUMBER type C length 18,
    end of TS_FGET_UOM1 .
  types:
  begin of TS_MATERIAL,
     MATERIAL_NUMBER type C length 18,
     MATERIAL_DESCRIPTION type C length 40,
     UOM_SATUAN type C length 3,
     UOM_TENGAH type C length 3,
     UOM_CARTON type C length 3,
     UOM_PALLET type C length 3,
     CONVERSION_TENGAH type C length 3,
     CONVERSION_CARTON type C length 5,
     CONVERSION_PALLET type C length 5,
     BATCH_MANAGEMENT type FLAG,
     BARCODE_SATUAN type C length 18,
     BARCODE_TENGAH type C length 18,
     BARCODE_CARTON type C length 18,
     BARCODE_PALLET type C length 18,
     MATERIAL_TYPE type C length 4,
     PLANT type C length 4,
     WAREHOUSE type C length 3,
     VMSTA type C length 2,
  end of TS_MATERIAL .
  types:
TT_MATERIAL type standard table of TS_MATERIAL .
  types:
  begin of TS_BATCH,
     MATERIAL_NUMBER type C length 18,
     PLANT type C length 4,
     BATCH type C length 10,
     EXPIRED_DATE type C length 8,
     CREATE_DATE type C length 8,
     GR_DATE type C length 8,
     UOM type C length 10,
     CONVERSION_CARTON type C length 15,
     UOM_PACKING type C length 3,
  end of TS_BATCH .
  types:
TT_BATCH type standard table of TS_BATCH .
  types:
     TS_UOM_BARCODE type ZWMS_UOM .
  types:
TT_UOM_BARCODE type standard table of TS_UOM_BARCODE .
  types:
  begin of TS_STOCK,
     WAREHOUSE type C length 3,
     PLANT type C length 4,
     STORAGE_TYPE type C length 3,
     STORAGE_BIN type C length 10,
     MATERIAL_NUMBER type C length 18,
     MATERIAL_DESCRIPTION type C length 40,
     BATCH type C length 18,
     UOM type C length 3,
     QUANTITY type C length 15,
     CONVERSION_CARTON type C length 15,
     SHELF_LIFE_EXPIRATION type C length 10,
     GR_DATE type C length 10,
     STOCK_CATEGORY type C length 1,
     PICK_QUANTITY type C length 15,
     QUANTITY_TO_REMOVE type C length 15,
     UOM_PACKING type C length 3,
  end of TS_STOCK .
  types:
TT_STOCK type standard table of TS_STOCK .
  types:
  begin of TS_UOM,
     UNIT_MEASURE type C length 3,
     UOM_CONVERSI type C length 7,
  end of TS_UOM .
  types:
TT_UOM type standard table of TS_UOM .

  constants GC_BATCH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'batch' ##NO_TEXT.
  constants GC_MATERIAL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'material' ##NO_TEXT.
  constants GC_STOCK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'stock' ##NO_TEXT.
  constants GC_UOM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'uom' ##NO_TEXT.
  constants GC_UOM_BARCODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'uom_barcode' ##NO_TEXT.

  methods LOAD_TEXT_ELEMENTS
  final
    returning
      value(RT_TEXT_ELEMENTS) type TT_TEXT_ELEMENTS
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .
protected section.
private section.

  constants GC_INCL_NAME type STRING value 'ZCL_ZWMS_MASTER_MPC===========CP' ##NO_TEXT.

  methods DEFINE_MATERIAL
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_BATCH
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_UOM_BARCODE
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_STOCK
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_UOM
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_ACTIONS
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
ENDCLASS.



CLASS ZCL_ZWMS_MASTER_MPC IMPLEMENTATION.


  method DEFINE.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*

model->set_schema_namespace( 'ZWMS_MASTER_SRV' ).

define_material( ).
define_batch( ).
define_uom_barcode( ).
define_stock( ).
define_uom( ).
define_actions( ).
  endmethod.


  method DEFINE_ACTIONS.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


data:
lo_action         type ref to /iwbep/if_mgw_odata_action,                 "#EC NEEDED
lo_parameter      type ref to /iwbep/if_mgw_odata_parameter.              "#EC NEEDED

***********************************************************************************************************************************
*   ACTION - fget_stockmaterial
***********************************************************************************************************************************

lo_action = model->create_action( 'fget_stockmaterial' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'stock' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'stock' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'plant'    iv_abap_fieldname = 'PLANT' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'material_number'    iv_abap_fieldname = 'MATERIAL_NUMBER' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'storage_type'    iv_abap_fieldname = 'STORAGE_TYPE' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'warehouse'    iv_abap_fieldname = 'WAREHOUSE' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_FGET_STOCKMATERIAL' ). "#EC NOTEXT
***********************************************************************************************************************************
*   ACTION - fget_material
***********************************************************************************************************************************

lo_action = model->create_action( 'fget_material' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'material' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'material' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'warehouse'    iv_abap_fieldname = 'WAREHOUSE' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_FGET_MATERIAL' ). "#EC NOTEXT
***********************************************************************************************************************************
*   ACTION - fget_batch
***********************************************************************************************************************************

lo_action = model->create_action( 'fget_batch' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'batch' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'batch' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'material_number'    iv_abap_fieldname = 'MATERIAL_NUMBER' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_FGET_BATCH' ). "#EC NOTEXT
***********************************************************************************************************************************
*   ACTION - fget_uom
***********************************************************************************************************************************

lo_action = model->create_action( 'fget_uom' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'uom_barcode' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'uom_barcode' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'material_number'    iv_abap_fieldname = 'MATERIAL_NUMBER' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_FGET_UOM' ). "#EC NOTEXT
***********************************************************************************************************************************
*   ACTION - fget_stockbin
***********************************************************************************************************************************

lo_action = model->create_action( 'fget_stockbin' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'stock' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'stock' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'warehouse'    iv_abap_fieldname = 'WAREHOUSE' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'plant'    iv_abap_fieldname = 'PLANT' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'storage_type'    iv_abap_fieldname = 'STORAGE_TYPE' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'storage_bin'    iv_abap_fieldname = 'STORAGE_BIN' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 10 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_FGET_STOCKBIN' ). "#EC NOTEXT
***********************************************************************************************************************************
*   ACTION - fget_uom1
***********************************************************************************************************************************

lo_action = model->create_action( 'fget_uom1' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'uom' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'uom' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'material_number'    iv_abap_fieldname = 'MATERIAL_NUMBER' ). "#EC NOTEXT
lo_parameter->set_label_from_text_element( iv_text_element_symbol = '021' iv_text_element_container = gc_incl_name ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_FGET_UOM1' ). "#EC NOTEXT
  endmethod.


  method DEFINE_BATCH.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  data:
        lo_annotation     type ref to /iwbep/if_mgw_odata_annotation,                "#EC NEEDED
        lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ,                "#EC NEEDED
        lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type,                "#EC NEEDED
        lo_property       type ref to /iwbep/if_mgw_odata_property,                  "#EC NEEDED
        lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set.                "#EC NEEDED

***********************************************************************************************************************************
*   ENTITY - batch
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'batch' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'material_number' iv_abap_fieldname = 'MATERIAL_NUMBER' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '016' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'plant' iv_abap_fieldname = 'PLANT' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '017' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'batch_number' iv_abap_fieldname = 'BATCH' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '018' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 10 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'expired_date' iv_abap_fieldname = 'EXPIRED_DATE' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '012' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 8 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'create_date' iv_abap_fieldname = 'CREATE_DATE' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '013' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 8 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'gr_date' iv_abap_fieldname = 'GR_DATE' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 8 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom' iv_abap_fieldname = 'UOM' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 10 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'conversion_carton' iv_abap_fieldname = 'CONVERSION_CARTON' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 15 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_packing' iv_abap_fieldname = 'UOM_PACKING' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).

lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_BATCH' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'batchSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_true ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).
  endmethod.


  method DEFINE_MATERIAL.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  data:
        lo_annotation     type ref to /iwbep/if_mgw_odata_annotation,                "#EC NEEDED
        lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ,                "#EC NEEDED
        lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type,                "#EC NEEDED
        lo_property       type ref to /iwbep/if_mgw_odata_property,                  "#EC NEEDED
        lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set.                "#EC NEEDED

***********************************************************************************************************************************
*   ENTITY - material
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'material' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'material_number' iv_abap_fieldname = 'MATERIAL_NUMBER' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '001' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'material_description' iv_abap_fieldname = 'MATERIAL_DESCRIPTION' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '002' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 40 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_satuan' iv_abap_fieldname = 'UOM_SATUAN' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '003' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_tengah' iv_abap_fieldname = 'UOM_TENGAH' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_carton' iv_abap_fieldname = 'UOM_CARTON' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '004' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_pallet' iv_abap_fieldname = 'UOM_PALLET' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'conversion_tengah' iv_abap_fieldname = 'CONVERSION_TENGAH' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'conversion_carton' iv_abap_fieldname = 'CONVERSION_CARTON' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '005' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 5 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'conversion_pallet' iv_abap_fieldname = 'CONVERSION_PALLET' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '006' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 5 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'batch_management' iv_abap_fieldname = 'BATCH_MANAGEMENT' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '007' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_boolean( ).
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'barcode_satuan' iv_abap_fieldname = 'BARCODE_SATUAN' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '008' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'barcode_tengah' iv_abap_fieldname = 'BARCODE_TENGAH' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'barcode_carton' iv_abap_fieldname = 'BARCODE_CARTON' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'barcode_pallet' iv_abap_fieldname = 'BARCODE_PALLET' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'material_type' iv_abap_fieldname = 'MATERIAL_TYPE' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '009' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'plant' iv_abap_fieldname = 'PLANT' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '010' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'warehouse' iv_abap_fieldname = 'WAREHOUSE' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '011' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).

lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_MATERIAL' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'materialSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_true ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).
  endmethod.


  method DEFINE_STOCK.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  data:
        lo_annotation     type ref to /iwbep/if_mgw_odata_annotation,                "#EC NEEDED
        lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ,                "#EC NEEDED
        lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type,                "#EC NEEDED
        lo_property       type ref to /iwbep/if_mgw_odata_property,                  "#EC NEEDED
        lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set.                "#EC NEEDED

***********************************************************************************************************************************
*   ENTITY - stock
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'stock' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'warehouse' iv_abap_fieldname = 'WAREHOUSE' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'plant' iv_abap_fieldname = 'PLANT' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'storage_type' iv_abap_fieldname = 'STORAGE_TYPE' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'storage_bin' iv_abap_fieldname = 'STORAGE_BIN' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 10 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'material_number' iv_abap_fieldname = 'MATERIAL_NUMBER' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'material_description' iv_abap_fieldname = 'MATERIAL_DESCRIPTION' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 40 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'batch' iv_abap_fieldname = 'BATCH' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom' iv_abap_fieldname = 'UOM' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'quantity' iv_abap_fieldname = 'QUANTITY' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 15 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'conversion_carton' iv_abap_fieldname = 'CONVERSION_CARTON' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 15 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'shelf_life_expiration' iv_abap_fieldname = 'SHELF_LIFE_EXPIRATION' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 10 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'gr_date' iv_abap_fieldname = 'GR_DATE' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 10 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'stock_category' iv_abap_fieldname = 'STOCK_CATEGORY' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 1 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'pickqty' iv_abap_fieldname = 'PICK_QUANTITY' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 15 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'quantity_to_remove' iv_abap_fieldname = 'QUANTITY_TO_REMOVE' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 15 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_packing' iv_abap_fieldname = 'UOM_PACKING' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).

lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_STOCK' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'stockSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_false ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).
  endmethod.


  method DEFINE_UOM.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  data:
        lo_annotation     type ref to /iwbep/if_mgw_odata_annotation,                "#EC NEEDED
        lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ,                "#EC NEEDED
        lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type,                "#EC NEEDED
        lo_property       type ref to /iwbep/if_mgw_odata_property,                  "#EC NEEDED
        lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set.                "#EC NEEDED

***********************************************************************************************************************************
*   ENTITY - uom
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'uom' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'unit_measure' iv_abap_fieldname = 'UNIT_MEASURE' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '020' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_conversi' iv_abap_fieldname = 'UOM_CONVERSI' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '022' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 7 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).

lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZWMS_MASTER_MPC=>TS_UOM' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'uomSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_false ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).
  endmethod.


  method DEFINE_UOM_BARCODE.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  data:
        lo_annotation     type ref to /iwbep/if_mgw_odata_annotation,                "#EC NEEDED
        lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ,                "#EC NEEDED
        lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type,                "#EC NEEDED
        lo_property       type ref to /iwbep/if_mgw_odata_property,                  "#EC NEEDED
        lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set.                "#EC NEEDED

***********************************************************************************************************************************
*   ENTITY - uom_barcode
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'uom_barcode' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'plant' iv_abap_fieldname = 'PLANT' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'material_number' iv_abap_fieldname = 'MATERIAL_NUMBER' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_conversion_exit( 'MATN1' ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'material_description' iv_abap_fieldname = 'MATERIAL_DESCRIPTION' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 40 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'batch_management' iv_abap_fieldname = 'BATCH_MANAGEMENT' ). "#EC NOTEXT
lo_property->set_type_edm_boolean( ).
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_satuan' iv_abap_fieldname = 'UOM_SATUAN' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_conversion_exit( 'CUNIT' ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_alternative' iv_abap_fieldname = 'UOM_ALTERNATIVE' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 3 ). "#EC NOTEXT
lo_property->set_conversion_exit( 'CUNIT' ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_number_conversi' iv_abap_fieldname = 'UOM_NUMBER_CONVERSI' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '014' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 7 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'uom_conversi' iv_abap_fieldname = 'UOM_CONVERSI' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '015' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 7 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'barcode' iv_abap_fieldname = 'BARCODE' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 18 ). "#EC NOTEXT
lo_property->set_conversion_exit( 'EAN11' ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'main_ean' iv_abap_fieldname = 'MAIN_EAN' ). "#EC NOTEXT
lo_property->set_type_edm_boolean( ).
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'ean_category' iv_abap_fieldname = 'EAN_CATEGORY' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '019' iv_text_element_container = gc_incl_name ).  "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 2 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).

lo_entity_type->bind_structure( iv_structure_name   = 'ZWMS_UOM'
                                iv_bind_conversions = 'X' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'uom_barcodeSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_true ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).
  endmethod.


  method GET_LAST_MODIFIED.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  CONSTANTS: lc_gen_date_time TYPE timestamp VALUE '20250826092628'.                  "#EC NOTEXT
  rv_last_modified = super->get_last_modified( ).
  IF rv_last_modified LT lc_gen_date_time.
    rv_last_modified = lc_gen_date_time.
  ENDIF.
  endmethod.


  method LOAD_TEXT_ELEMENTS.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


DATA:
     ls_text_element TYPE ts_text_element.                                 "#EC NEEDED


clear ls_text_element.
ls_text_element-artifact_name          = 'material_number'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '001'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'material_description'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '002'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'uom_satuan'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '003'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'uom_carton'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '004'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'conversion_carton'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '005'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'conversion_pallet'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '006'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'batch_management'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '007'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'barcode_satuan'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '008'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'material_type'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '009'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'plant'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '010'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'warehouse'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'material'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '011'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.


clear ls_text_element.
ls_text_element-artifact_name          = 'material_number'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'batch'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '016'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'plant'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'batch'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '017'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'batch_number'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'batch'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '018'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'expired_date'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'batch'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '012'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'create_date'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'batch'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '013'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.


clear ls_text_element.
ls_text_element-artifact_name          = 'uom_number_conversi'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'uom_barcode'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '014'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'uom_conversi'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'uom_barcode'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '015'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'ean_category'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'uom_barcode'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '019'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.


clear ls_text_element.
ls_text_element-artifact_name          = 'unit_measure'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'uom'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '020'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
clear ls_text_element.
ls_text_element-artifact_name          = 'uom_conversi'.                 "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'uom'.                            "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                                       "#EC NOTEXT
ls_text_element-text_symbol            = '022'.              "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.


clear ls_text_element.
ls_text_element-artifact_name          = 'material_number'.                               "#EC NOTEXT
ls_text_element-artifact_type          = 'FIPA'.                                                "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'FIMP'.                                                "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'fget_uom1'.                                      "#EC NOTEXT
ls_text_element-text_symbol            = '021'.                            "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
  endmethod.
ENDCLASS.
