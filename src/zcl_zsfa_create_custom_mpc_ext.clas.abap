class ZCL_ZSFA_CREATE_CUSTOM_MPC_EXT definition
  public
  inheriting from ZCL_ZSFA_CREATE_CUSTOM_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZSFA_CREATE_CUSTOM_MPC_EXT IMPLEMENTATION.


  METHOD define.
    super->define(  ).
    DATA model_feature TYPE /iwbep/if_mgw_appl_types=>ty_s_model_features.
    model_feature-use_strict_decimal_check  = abap_true.  "use_strict_function_param_chk
    model->set_model_features( model_feature ).
  ENDMETHOD.
ENDCLASS.
