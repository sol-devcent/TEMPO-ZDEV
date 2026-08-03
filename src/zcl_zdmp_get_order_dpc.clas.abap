class ZCL_ZDMP_GET_ORDER_DPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_DATA
  abstract
  create public .

public section.

  interfaces /IWBEP/IF_SB_DPC_COMM_SERVICES .
  interfaces /IWBEP/IF_SB_GEN_DPC_INJECTION .

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~UPDATE_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~DELETE_ENTITY
    redefinition .
protected section.

  data mo_injection type ref to /IWBEP/IF_SB_GEN_DPC_INJECTION .

  methods OPERATIONTYPESET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_OPERATIONTYPE
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONTYPESET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATIONTYPE
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPRCONFSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPRCONF
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPRCONFSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPRCONFSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPRCONF
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPRCONFSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_OPRCONF
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPRCONFSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPRCONF
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ORDERSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_ORDER
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ORDERSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ORDERSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_ORDER
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ORDERSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_ORDER
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ORDERSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_ORDER
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WADAHSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_WADAH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WADAHSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WADAHSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_WADAH
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WADAHSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_WADAH
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WADAHSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_WADAH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WEIGHINGACTSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_WEIGHINGACT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WEIGHINGACTSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WEIGHINGACTSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_WEIGHINGACT
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WEIGHINGACTSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_WEIGHINGACT
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods WEIGHINGACTSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_WEIGHINGACT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONTYPESET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATIONTYPE
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods LOCATIONSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_LOCATION
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods LOCATIONSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods LOCATIONSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_LOCATION
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods LOCATIONSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_LOCATION
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods LOCATIONSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_LOCATION
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods MATERIALSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_MATERIAL
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods MATERIALSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods MATERIALSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_MATERIAL
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods MATERIALSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_MATERIAL
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods MATERIALSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_MATERIAL
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONDESCSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATIONDESC
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONDESCSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONDESCSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATIONDESC
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONDESCSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_OPERATIONDESC
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONDESCSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATIONDESC
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATION
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATION
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_ZDMP_GET_ORDER_MPC=>TT_OPERATION
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATION
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONTYPESET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_ZDMP_GET_ORDER_MPC=>TS_OPERATIONTYPE
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods OPERATIONTYPESET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .

  methods CHECK_SUBSCRIPTION_AUTHORITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZDMP_GET_ORDER_DPC IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_ENTITY.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_CRT_ENTITY_BASE
*&* This class has been generated on 08.01.2025 15:10:52 in client 800
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZDMP_GET_ORDER_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA operationtypeset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_operationtype.
 DATA operationdescset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_operationdesc.
 DATA materialset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_material.
 DATA wadahset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_wadah.
 DATA oprconfset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_oprconf.
 DATA weighingactset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_weighingact.
 DATA operationset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_operation.
 DATA locationset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_location.
 DATA orderset_create_entity TYPE zcl_zdmp_get_order_mpc=>ts_order.
 DATA lv_entityset_name TYPE string.

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationTypeSet
*-------------------------------------------------------------------------*
     WHEN 'OperationTypeSet'.
*     Call the entity set generated method
    operationtypeset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = operationtypeset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = operationtypeset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  OperationDescSet
*-------------------------------------------------------------------------*
     WHEN 'OperationDescSet'.
*     Call the entity set generated method
    operationdescset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = operationdescset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = operationdescset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  MaterialSet
*-------------------------------------------------------------------------*
     WHEN 'MaterialSet'.
*     Call the entity set generated method
    materialset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = materialset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = materialset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  wadahSet
*-------------------------------------------------------------------------*
     WHEN 'wadahSet'.
*     Call the entity set generated method
    wadahset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = wadahset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = wadahset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  OprConfSet
*-------------------------------------------------------------------------*
     WHEN 'OprConfSet'.
*     Call the entity set generated method
    oprconfset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = oprconfset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = oprconfset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  WeighingActSet
*-------------------------------------------------------------------------*
     WHEN 'WeighingActSet'.
*     Call the entity set generated method
    weighingactset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = weighingactset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = weighingactset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  OperationSet
*-------------------------------------------------------------------------*
     WHEN 'OperationSet'.
*     Call the entity set generated method
    operationset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = operationset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = operationset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  LocationSet
*-------------------------------------------------------------------------*
     WHEN 'LocationSet'.
*     Call the entity set generated method
    locationset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = locationset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = locationset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  OrderSet
*-------------------------------------------------------------------------*
     WHEN 'OrderSet'.
*     Call the entity set generated method
    orderset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = orderset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = orderset_create_entity
      CHANGING
        cr_data = er_entity
   ).

  when others.
    super->/iwbep/if_mgw_appl_srv_runtime~create_entity(
       EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         io_data_provider   = io_data_provider
         it_key_tab = it_key_tab
         it_navigation_path = it_navigation_path
      IMPORTING
        er_entity = er_entity
  ).
ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~DELETE_ENTITY.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_DEL_ENTITY_BASE
*&* This class has been generated on 08.01.2025 15:10:52 in client 800
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZDMP_GET_ORDER_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA lv_entityset_name TYPE string.

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationSet
*-------------------------------------------------------------------------*
      when 'OperationSet'.
*     Call the entity set generated method
     operationset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  OperationTypeSet
*-------------------------------------------------------------------------*
      when 'OperationTypeSet'.
*     Call the entity set generated method
     operationtypeset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  MaterialSet
*-------------------------------------------------------------------------*
      when 'MaterialSet'.
*     Call the entity set generated method
     materialset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  WeighingActSet
*-------------------------------------------------------------------------*
      when 'WeighingActSet'.
*     Call the entity set generated method
     weighingactset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  LocationSet
*-------------------------------------------------------------------------*
      when 'LocationSet'.
*     Call the entity set generated method
     locationset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  OperationDescSet
*-------------------------------------------------------------------------*
      when 'OperationDescSet'.
*     Call the entity set generated method
     operationdescset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  OrderSet
*-------------------------------------------------------------------------*
      when 'OrderSet'.
*     Call the entity set generated method
     orderset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  OprConfSet
*-------------------------------------------------------------------------*
      when 'OprConfSet'.
*     Call the entity set generated method
     oprconfset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  wadahSet
*-------------------------------------------------------------------------*
      when 'wadahSet'.
*     Call the entity set generated method
     wadahset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

   when others.
     super->/iwbep/if_mgw_appl_srv_runtime~delete_entity(
        EXPORTING
          iv_entity_name = iv_entity_name
          iv_entity_set_name = iv_entity_set_name
          iv_source_name = iv_source_name
          it_key_tab = it_key_tab
          it_navigation_path = it_navigation_path
 ).
 ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY.
*&-----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_GETENTITY_BASE
*&* This class has been generated  on 08.01.2025 15:10:52 in client 800
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZDMP_GET_ORDER_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA wadahset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_wadah.
 DATA locationset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_location.
 DATA materialset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_material.
 DATA oprconfset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_oprconf.
 DATA operationtypeset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_operationtype.
 DATA orderset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_order.
 DATA weighingactset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_weighingact.
 DATA operationset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_operation.
 DATA operationdescset_get_entity TYPE zcl_zdmp_get_order_mpc=>ts_operationdesc.
 DATA lv_entityset_name TYPE string.
 DATA lr_entity TYPE REF TO data.       "#EC NEEDED

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  wadahSet
*-------------------------------------------------------------------------*
      WHEN 'wadahSet'.
*     Call the entity set generated method
          wadahset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = wadahset_get_entity
                         es_response_context = es_response_context
          ).

        IF wadahset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = wadahset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  LocationSet
*-------------------------------------------------------------------------*
      WHEN 'LocationSet'.
*     Call the entity set generated method
          locationset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = locationset_get_entity
                         es_response_context = es_response_context
          ).

        IF locationset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = locationset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  MaterialSet
*-------------------------------------------------------------------------*
      WHEN 'MaterialSet'.
*     Call the entity set generated method
          materialset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = materialset_get_entity
                         es_response_context = es_response_context
          ).

        IF materialset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = materialset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OprConfSet
*-------------------------------------------------------------------------*
      WHEN 'OprConfSet'.
*     Call the entity set generated method
          oprconfset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = oprconfset_get_entity
                         es_response_context = es_response_context
          ).

        IF oprconfset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = oprconfset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationTypeSet
*-------------------------------------------------------------------------*
      WHEN 'OperationTypeSet'.
*     Call the entity set generated method
          operationtypeset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = operationtypeset_get_entity
                         es_response_context = es_response_context
          ).

        IF operationtypeset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = operationtypeset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OrderSet
*-------------------------------------------------------------------------*
      WHEN 'OrderSet'.
*     Call the entity set generated method
          orderset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = orderset_get_entity
                         es_response_context = es_response_context
          ).

        IF orderset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = orderset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  WeighingActSet
*-------------------------------------------------------------------------*
      WHEN 'WeighingActSet'.
*     Call the entity set generated method
          weighingactset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = weighingactset_get_entity
                         es_response_context = es_response_context
          ).

        IF weighingactset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = weighingactset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationSet
*-------------------------------------------------------------------------*
      WHEN 'OperationSet'.
*     Call the entity set generated method
          operationset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = operationset_get_entity
                         es_response_context = es_response_context
          ).

        IF operationset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = operationset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationDescSet
*-------------------------------------------------------------------------*
      WHEN 'OperationDescSet'.
*     Call the entity set generated method
          operationdescset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = operationdescset_get_entity
                         es_response_context = es_response_context
          ).

        IF operationdescset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = operationdescset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.

      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~get_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
          IMPORTING
            er_entity = er_entity
    ).
 ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TMP_ENTITYSET_BASE
*&* This class has been generated on 08.01.2025 15:10:52 in client 800
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZDMP_GET_ORDER_DPC_EXT
*&-----------------------------------------------------------------------------------------------*
 DATA operationdescset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_operationdesc.
 DATA orderset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_order.
 DATA operationtypeset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_operationtype.
 DATA materialset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_material.
 DATA locationset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_location.
 DATA wadahset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_wadah.
 DATA oprconfset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_oprconf.
 DATA operationset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_operation.
 DATA weighingactset_get_entityset TYPE zcl_zdmp_get_order_mpc=>tt_weighingact.
 DATA lv_entityset_name TYPE string.

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationDescSet
*-------------------------------------------------------------------------*
   WHEN 'OperationDescSet'.
*     Call the entity set generated method
      operationdescset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = operationdescset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = operationdescset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  OrderSet
*-------------------------------------------------------------------------*
   WHEN 'OrderSet'.
*     Call the entity set generated method
      orderset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = orderset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = orderset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  OperationTypeSet
*-------------------------------------------------------------------------*
   WHEN 'OperationTypeSet'.
*     Call the entity set generated method
      operationtypeset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = operationtypeset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = operationtypeset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  MaterialSet
*-------------------------------------------------------------------------*
   WHEN 'MaterialSet'.
*     Call the entity set generated method
      materialset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = materialset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = materialset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  LocationSet
*-------------------------------------------------------------------------*
   WHEN 'LocationSet'.
*     Call the entity set generated method
      locationset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = locationset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = locationset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  wadahSet
*-------------------------------------------------------------------------*
   WHEN 'wadahSet'.
*     Call the entity set generated method
      wadahset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = wadahset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = wadahset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  OprConfSet
*-------------------------------------------------------------------------*
   WHEN 'OprConfSet'.
*     Call the entity set generated method
      oprconfset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = oprconfset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = oprconfset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  OperationSet
*-------------------------------------------------------------------------*
   WHEN 'OperationSet'.
*     Call the entity set generated method
      operationset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = operationset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = operationset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  WeighingActSet
*-------------------------------------------------------------------------*
   WHEN 'WeighingActSet'.
*     Call the entity set generated method
      weighingactset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = weighingactset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = weighingactset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

    WHEN OTHERS.
      super->/iwbep/if_mgw_appl_srv_runtime~get_entityset(
        EXPORTING
          iv_entity_name = iv_entity_name
          iv_entity_set_name = iv_entity_set_name
          iv_source_name = iv_source_name
          it_filter_select_options = it_filter_select_options
          it_order = it_order
          is_paging = is_paging
          it_navigation_path = it_navigation_path
          it_key_tab = it_key_tab
          iv_filter_string = iv_filter_string
          iv_search_string = iv_search_string
          io_tech_request_context = io_tech_request_context
       IMPORTING
         er_entityset = er_entityset ).
 ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~UPDATE_ENTITY.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_UPD_ENTITY_BASE
*&* This class has been generated on 08.01.2025 15:10:52 in client 800
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZDMP_GET_ORDER_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA locationset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_location.
 DATA operationdescset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_operationdesc.
 DATA operationtypeset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_operationtype.
 DATA materialset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_material.
 DATA wadahset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_wadah.
 DATA oprconfset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_oprconf.
 DATA weighingactset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_weighingact.
 DATA operationset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_operation.
 DATA orderset_update_entity TYPE zcl_zdmp_get_order_mpc=>ts_order.
 DATA lv_entityset_name TYPE string.
 DATA lr_entity TYPE REF TO data. "#EC NEEDED

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  LocationSet
*-------------------------------------------------------------------------*
      WHEN 'LocationSet'.
*     Call the entity set generated method
          locationset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = locationset_update_entity
          ).
       IF locationset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = locationset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationDescSet
*-------------------------------------------------------------------------*
      WHEN 'OperationDescSet'.
*     Call the entity set generated method
          operationdescset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = operationdescset_update_entity
          ).
       IF operationdescset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = operationdescset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationTypeSet
*-------------------------------------------------------------------------*
      WHEN 'OperationTypeSet'.
*     Call the entity set generated method
          operationtypeset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = operationtypeset_update_entity
          ).
       IF operationtypeset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = operationtypeset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  MaterialSet
*-------------------------------------------------------------------------*
      WHEN 'MaterialSet'.
*     Call the entity set generated method
          materialset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = materialset_update_entity
          ).
       IF materialset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = materialset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  wadahSet
*-------------------------------------------------------------------------*
      WHEN 'wadahSet'.
*     Call the entity set generated method
          wadahset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = wadahset_update_entity
          ).
       IF wadahset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = wadahset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OprConfSet
*-------------------------------------------------------------------------*
      WHEN 'OprConfSet'.
*     Call the entity set generated method
          oprconfset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = oprconfset_update_entity
          ).
       IF oprconfset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = oprconfset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  WeighingActSet
*-------------------------------------------------------------------------*
      WHEN 'WeighingActSet'.
*     Call the entity set generated method
          weighingactset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = weighingactset_update_entity
          ).
       IF weighingactset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = weighingactset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OperationSet
*-------------------------------------------------------------------------*
      WHEN 'OperationSet'.
*     Call the entity set generated method
          operationset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = operationset_update_entity
          ).
       IF operationset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = operationset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  OrderSet
*-------------------------------------------------------------------------*
      WHEN 'OrderSet'.
*     Call the entity set generated method
          orderset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = orderset_update_entity
          ).
       IF orderset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = orderset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~update_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             io_data_provider   = io_data_provider
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
          IMPORTING
            er_entity = er_entity
    ).
 ENDCASE.
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~COMMIT_WORK.
* Call RFC commit work functionality
DATA lt_message      TYPE bapiret2. "#EC NEEDED
DATA lv_message_text TYPE BAPI_MSG.
DATA lo_logger       TYPE REF TO /iwbep/cl_cos_logger.
DATA lv_subrc        TYPE syst-subrc.

lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).

  IF iv_rfc_dest IS INITIAL OR iv_rfc_dest EQ 'NONE'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
      wait   = abap_true
    IMPORTING
      return = lt_message.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      DESTINATION iv_rfc_dest
    EXPORTING
      wait                  = abap_true
    IMPORTING
      return                = lt_message
    EXCEPTIONS
      communication_failure = 1000 MESSAGE lv_message_text
      system_failure        = 1001 MESSAGE lv_message_text
      OTHERS                = 1002.

  IF sy-subrc <> 0.
    lv_subrc = sy-subrc.
    /iwbep/cl_sb_gen_dpc_rt_util=>rfc_exception_handling(
        EXPORTING
          iv_subrc            = lv_subrc
          iv_exp_message_text = lv_message_text
          io_logger           = lo_logger ).
  ENDIF.
  ENDIF.
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~GET_GENERATION_STRATEGY.
* Get generation strategy
  rv_generation_strategy = '1'.
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~LOG_MESSAGE.
* Log message in the application log
DATA lo_logger TYPE REF TO /iwbep/cl_cos_logger.
DATA lv_text TYPE /iwbep/sup_msg_longtext.

  MESSAGE ID iv_msg_id TYPE iv_msg_type NUMBER iv_msg_number
    WITH iv_msg_v1 iv_msg_v2 iv_msg_v3 iv_msg_v4 INTO lv_text.

  lo_logger = mo_context->get_logger( ).
  lo_logger->log_message(
    EXPORTING
     iv_msg_type   = iv_msg_type
     iv_msg_id     = iv_msg_id
     iv_msg_number = iv_msg_number
     iv_msg_text   = lv_text
     iv_msg_v1     = iv_msg_v1
     iv_msg_v2     = iv_msg_v2
     iv_msg_v3     = iv_msg_v3
     iv_msg_v4     = iv_msg_v4
     iv_agent      = 'DPC' ).
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~RFC_EXCEPTION_HANDLING.
* RFC call exception handling
DATA lo_logger  TYPE REF TO /iwbep/cl_cos_logger.

lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).

/iwbep/cl_sb_gen_dpc_rt_util=>rfc_exception_handling(
  EXPORTING
    iv_subrc            = iv_subrc
    iv_exp_message_text = iv_exp_message_text
    io_logger           = lo_logger ).
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~RFC_SAVE_LOG.
  DATA lo_logger  TYPE REF TO /iwbep/cl_cos_logger.
  DATA lo_message_container TYPE REF TO /iwbep/if_message_container.

  lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).
  lo_message_container = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

  " Save the RFC call log in the application log
  /iwbep/cl_sb_gen_dpc_rt_util=>rfc_save_log(
    EXPORTING
      is_return            = is_return
      iv_entity_type       = iv_entity_type
      it_return            = it_return
      it_key_tab           = it_key_tab
      io_logger            = lo_logger
      io_message_container = lo_message_container ).
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~SET_INJECTION.
* Unit test injection
  IF io_unit IS BOUND.
    mo_injection = io_unit.
  ELSE.
    mo_injection = me.
  ENDIF.
  endmethod.


  method CHECK_SUBSCRIPTION_AUTHORITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'CHECK_SUBSCRIPTION_AUTHORITY'.
  endmethod.


  method LOCATIONSET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'LOCATIONSET_CREATE_ENTITY'.
  endmethod.


  method LOCATIONSET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'LOCATIONSET_DELETE_ENTITY'.
  endmethod.


  method LOCATIONSET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'LOCATIONSET_GET_ENTITY'.
  endmethod.


  method LOCATIONSET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'LOCATIONSET_GET_ENTITYSET'.
  endmethod.


  method LOCATIONSET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'LOCATIONSET_UPDATE_ENTITY'.
  endmethod.


  method MATERIALSET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'MATERIALSET_CREATE_ENTITY'.
  endmethod.


  method MATERIALSET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'MATERIALSET_DELETE_ENTITY'.
  endmethod.


  method MATERIALSET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'MATERIALSET_GET_ENTITY'.
  endmethod.


  method MATERIALSET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'MATERIALSET_GET_ENTITYSET'.
  endmethod.


  method MATERIALSET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'MATERIALSET_UPDATE_ENTITY'.
  endmethod.


  method OPERATIONDESCSET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONDESCSET_CREATE_ENTITY'.
  endmethod.


  method OPERATIONDESCSET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONDESCSET_DELETE_ENTITY'.
  endmethod.


  method OPERATIONDESCSET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONDESCSET_GET_ENTITY'.
  endmethod.


  method OPERATIONDESCSET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONDESCSET_GET_ENTITYSET'.
  endmethod.


  method OPERATIONDESCSET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONDESCSET_UPDATE_ENTITY'.
  endmethod.


  method OPERATIONSET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONSET_CREATE_ENTITY'.
  endmethod.


  method OPERATIONSET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONSET_DELETE_ENTITY'.
  endmethod.


  method OPERATIONSET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONSET_GET_ENTITY'.
  endmethod.


  method OPERATIONSET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONSET_GET_ENTITYSET'.
  endmethod.


  method OPERATIONSET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONSET_UPDATE_ENTITY'.
  endmethod.


  method OPERATIONTYPESET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONTYPESET_CREATE_ENTITY'.
  endmethod.


  method OPERATIONTYPESET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONTYPESET_DELETE_ENTITY'.
  endmethod.


  method OPERATIONTYPESET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONTYPESET_GET_ENTITY'.
  endmethod.


  method OPERATIONTYPESET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONTYPESET_GET_ENTITYSET'.
  endmethod.


  method OPERATIONTYPESET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPERATIONTYPESET_UPDATE_ENTITY'.
  endmethod.


  method OPRCONFSET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPRCONFSET_CREATE_ENTITY'.
  endmethod.


  method OPRCONFSET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPRCONFSET_DELETE_ENTITY'.
  endmethod.


  method OPRCONFSET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPRCONFSET_GET_ENTITY'.
  endmethod.


  method OPRCONFSET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPRCONFSET_GET_ENTITYSET'.
  endmethod.


  method OPRCONFSET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'OPRCONFSET_UPDATE_ENTITY'.
  endmethod.


  method ORDERSET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'ORDERSET_CREATE_ENTITY'.
  endmethod.


  method ORDERSET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'ORDERSET_DELETE_ENTITY'.
  endmethod.


  method ORDERSET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'ORDERSET_GET_ENTITY'.
  endmethod.


  method ORDERSET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'ORDERSET_GET_ENTITYSET'.
  endmethod.


  method ORDERSET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'ORDERSET_UPDATE_ENTITY'.
  endmethod.


  method WADAHSET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WADAHSET_CREATE_ENTITY'.
  endmethod.


  method WADAHSET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WADAHSET_DELETE_ENTITY'.
  endmethod.


  method WADAHSET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WADAHSET_GET_ENTITY'.
  endmethod.


  method WADAHSET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WADAHSET_GET_ENTITYSET'.
  endmethod.


  method WADAHSET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WADAHSET_UPDATE_ENTITY'.
  endmethod.


  method WEIGHINGACTSET_CREATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WEIGHINGACTSET_CREATE_ENTITY'.
  endmethod.


  method WEIGHINGACTSET_DELETE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WEIGHINGACTSET_DELETE_ENTITY'.
  endmethod.


  method WEIGHINGACTSET_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WEIGHINGACTSET_GET_ENTITY'.
  endmethod.


  method WEIGHINGACTSET_GET_ENTITYSET.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WEIGHINGACTSET_GET_ENTITYSET'.
  endmethod.


  method WEIGHINGACTSET_UPDATE_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'WEIGHINGACTSET_UPDATE_ENTITY'.
  endmethod.
ENDCLASS.
