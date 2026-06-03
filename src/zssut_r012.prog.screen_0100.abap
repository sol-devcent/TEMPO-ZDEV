
PROCESS BEFORE OUTPUT.
  MODULE pbo_100.
  MODULE pbo_101.
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

*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'T_CONTROL'
  LOOP AT gt_itab.
    CHAIN.
      FIELD gs_itab-counter.
      FIELD gs_itab-kunn2.
      FIELD gs_itab-kunnr.
      FIELD gs_itab-name1.
      FIELD gs_itab-addrs.
      MODULE t_control_modify ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD gs_itab-mark
      MODULE t_control_mark ON REQUEST.
  ENDLOOP.

  MODULE pai_100.
  MODULE t_control_user_command.

*process on value-request.
*  field gs_itab-kunn2 module f4_kunn2.
*  field gs_itab-kunnr module f4_kunnr.
*  field
*  process on value-request.
*
*&SPWIZARD: MODULE T_CONTROL_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE T_CONTROL_CHANGE_COL_ATTR.

* MODULE USER_COMMAND_0100.
