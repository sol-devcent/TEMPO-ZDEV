class ZCL_ZDMP_GET_MATERIAL_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  types:
    begin of TS_FIMP_PLANT,
        WERKS type C length 4,
    end of TS_FIMP_PLANT .
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
    begin of TS_FIMP_MATERIAL,
        WERKS type C length 4,
    end of TS_FIMP_MATERIAL .
  types:
    begin of TS_FIMP_USER,
        ZTITLE type C length 30,
        ZNRP type C length 30,
    end of TS_FIMP_USER .
  types:
    begin of TS_FIMP_VOLUME,
        WERKS type C length 4,
    end of TS_FIMP_VOLUME .
  types:
  begin of TS_ENT_PLANT,
     WERKS type C length 4,
     NAME1 type C length 30,
  end of TS_ENT_PLANT .
  types:
TT_ENT_PLANT type standard table of TS_ENT_PLANT .
  types:
  begin of TS_ENT_MATERIAL,
     WERKS type C length 4,
     MATNR type C length 18,
     MAKTX type C length 40,
     FEVOR type C length 3,
  end of TS_ENT_MATERIAL .
  types:
TT_ENT_MATERIAL type standard table of TS_ENT_MATERIAL .
  types:
  begin of TS_ENT_USER,
     ZNRP type C length 30,
     ZTITLETX type C length 30,
     WERKS type C length 4,
  end of TS_ENT_USER .
  types:
TT_ENT_USER type standard table of TS_ENT_USER .
  types:
  begin of TS_ENT_VOLUME,
     WERKS type C length 4,
     POSNR type C length 6,
     VOLUM type P length 5 decimals 0,
     VOLEH type C length 3,
  end of TS_ENT_VOLUME .
  types:
TT_ENT_VOLUME type standard table of TS_ENT_VOLUME .

  constants GC_ENT_MATERIAL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Ent_Material' ##NO_TEXT.
  constants GC_ENT_PLANT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Ent_Plant' ##NO_TEXT.
  constants GC_ENT_USER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Ent_User' ##NO_TEXT.
  constants GC_ENT_VOLUME type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Ent_Volume' ##NO_TEXT.

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

  methods DEFINE_ENT_PLANT
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_ENT_MATERIAL
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_ENT_USER
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_ENT_VOLUME
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods DEFINE_ACTIONS
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
ENDCLASS.



CLASS ZCL_ZDMP_GET_MATERIAL_MPC IMPLEMENTATION.


  method DEFINE.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*

model->set_schema_namespace( 'ZDMP_GET_MATERIAL_SRV' ).

define_ent_plant( ).
define_ent_material( ).
define_ent_user( ).
define_ent_volume( ).
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
*   ACTION - FImp_Plant
***********************************************************************************************************************************

lo_action = model->create_action( 'FImp_Plant' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'Ent_Plant' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'Ent_Plant' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'Plant'    iv_abap_fieldname = 'WERKS' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZDMP_GET_MATERIAL_MPC=>TS_FIMP_PLANT' ). "#EC NOTEXT
***********************************************************************************************************************************
*   ACTION - FImp_Material
***********************************************************************************************************************************

lo_action = model->create_action( 'FImp_Material' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'Ent_Material' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'Ent_Material' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'Plant'    iv_abap_fieldname = 'WERKS' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZDMP_GET_MATERIAL_MPC=>TS_FIMP_MATERIAL' ). "#EC NOTEXT
***********************************************************************************************************************************
*   ACTION - FImp_User
***********************************************************************************************************************************

lo_action = model->create_action( 'FImp_User' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'Ent_User' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'Ent_User' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'Title'    iv_abap_fieldname = 'ZTITLE' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 30 ). "#EC NOTEXT
lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'Nrp'    iv_abap_fieldname = 'ZNRP' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 30 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZDMP_GET_MATERIAL_MPC=>TS_FIMP_USER' ). "#EC NOTEXT
***********************************************************************************************************************************
*   ACTION - FImp_Volume
***********************************************************************************************************************************

lo_action = model->create_action( 'FImp_Volume' ).  "#EC NOTEXT
*Set return entity type
lo_action->set_return_entity_type( 'Ent_Volume' ). "#EC NOTEXT
*Set HTTP method GET or POST
lo_action->set_http_method( 'GET' ). "#EC NOTEXT
*Set the action for entity
lo_action->set_action_for( 'Ent_Volume' ).        "#EC NOTEXT
* Set return type multiplicity
lo_action->set_return_multiplicity( 'M' ). "#EC NOTEXT
***********************************************************************************************************************************
* Parameters
***********************************************************************************************************************************

lo_parameter = lo_action->create_input_parameter( iv_parameter_name = 'Plant'    iv_abap_fieldname = 'WERKS' ). "#EC NOTEXT
lo_parameter->/iwbep/if_mgw_odata_property~set_type_edm_string( ).
lo_parameter->set_maxlength( iv_max_length = 4 ). "#EC NOTEXT
lo_action->bind_input_structure( iv_structure_name  = 'ZCL_ZDMP_GET_MATERIAL_MPC=>TS_FIMP_VOLUME' ). "#EC NOTEXT
  endmethod.


  method DEFINE_ENT_MATERIAL.
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
*   ENTITY - Ent_Material
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'Ent_Material' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'Plant' iv_abap_fieldname = 'WERKS' ). "#EC NOTEXT
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
lo_property = lo_entity_type->create_property( iv_property_name = 'Material' iv_abap_fieldname = 'MATNR' ). "#EC NOTEXT
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
lo_property = lo_entity_type->create_property( iv_property_name = 'Material_Desc' iv_abap_fieldname = 'MAKTX' ). "#EC NOTEXT
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
lo_property = lo_entity_type->create_property( iv_property_name = 'ProductiSupervisor' iv_abap_fieldname = 'FEVOR' ). "#EC NOTEXT
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

lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZDMP_GET_MATERIAL_MPC=>TS_ENT_MATERIAL' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'Ent_MaterialSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_false ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).
  endmethod.


  method DEFINE_ENT_PLANT.
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
*   ENTITY - Ent_Plant
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'Ent_Plant' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'Plant' iv_abap_fieldname = 'WERKS' ). "#EC NOTEXT
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
lo_property = lo_entity_type->create_property( iv_property_name = 'Plant_Desc' iv_abap_fieldname = 'NAME1' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 30 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).

lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZDMP_GET_MATERIAL_MPC=>TS_ENT_PLANT' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'Ent_PlantSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_false ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).
  endmethod.


  method DEFINE_ENT_USER.
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
*   ENTITY - Ent_User
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'Ent_User' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'Nrp' iv_abap_fieldname = 'ZNRP' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 30 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'Title' iv_abap_fieldname = 'ZTITLETX' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 30 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'Werks' iv_abap_fieldname = 'WERKS' ). "#EC NOTEXT
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

lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZDMP_GET_MATERIAL_MPC=>TS_ENT_USER' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'Ent_UserSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_false ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).
  endmethod.


  method DEFINE_ENT_VOLUME.
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
*   ENTITY - Ent_Volume
***********************************************************************************************************************************

lo_entity_type = model->create_entity_type( iv_entity_type_name = 'Ent_Volume' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'Plant' iv_abap_fieldname = 'WERKS' ). "#EC NOTEXT
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
lo_property = lo_entity_type->create_property( iv_property_name = 'Item' iv_abap_fieldname = 'POSNR' ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 6 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'Volume' iv_abap_fieldname = 'VOLUM' ). "#EC NOTEXT
lo_property->set_type_edm_decimal( ).
lo_property->set_maxlength( iv_max_length = 9 ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add(
      EXPORTING
        iv_key      = 'unicode'
        iv_value    = 'false' ).
lo_property = lo_entity_type->create_property( iv_property_name = 'Unit' iv_abap_fieldname = 'VOLEH' ). "#EC NOTEXT
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

lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZDMP_GET_MATERIAL_MPC=>TS_ENT_VOLUME' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_set = lo_entity_type->create_entity_set( 'Ent_VolumeSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_false ).
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


  CONSTANTS: lc_gen_date_time TYPE timestamp VALUE '20251016090223'.                  "#EC NOTEXT
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
  endmethod.
ENDCLASS.
