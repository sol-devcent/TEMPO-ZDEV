
PROCESS BEFORE OUTPUT.
  MODULE pbo_100.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'T_CONTROL'
  MODULE t_control_change_tc_attr.
*&SPWIZARD: MODULE T_CONTROL_CHANGE_COL_ATTR.
  LOOP AT   gt_itab
       INTO gs_itab
       WITH CONTROL t_control
       CURSOR t_control-current_line.
    MODULE t_control_get_lines.
*&SPWIZARD:   MODULE T_CONTROL_CHANGE_FIELD_ATTR
  ENDLOOP.

* MODULE STATUS_0100.
*
PROCESS AFTER INPUT.
  MODULE pai_100.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'T_CONTROL'
  LOOP AT gt_itab.
    CHAIN.
      FIELD gs_itab-vrtnr.
      FIELD gs_itab-cname.
      FIELD gs_itab-ansvh.
      FIELD gs_itab-kunn2.
      FIELD gs_itab-jml_bil.
      FIELD gs_itab-jml_kerja.
      FIELD gs_itab-jml_eff_call.
      FIELD gs_itab-jml_unvisit.
      FIELD gs_itab-jml_no_call.
    ENDCHAIN.
  ENDLOOP.
  MODULE t_control_user_command.
*&SPWIZARD: MODULE T_CONTROL_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE T_CONTROL_CHANGE_COL_ATTR.

* MODULE USER_COMMAND_0100.
