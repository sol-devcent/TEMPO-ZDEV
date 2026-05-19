
PROCESS BEFORE OUTPUT.
  MODULE status_9004.
  MODULE tap_display.
  LOOP WITH CONTROL manhk.
    MODULE fill_table_control_manhk.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL manhk.
    MODULE read_table_control_manhk.
  ENDLOOP.
  MODULE validasi_field.
  MODULE user_command_9004.

PROCESS ON VALUE-REQUEST.

  FIELD gs_add-jbiaya MODULE vr_jbiaya.
  FIELD gs_add-schnl MODULE vr_subchnl.
  FIELD gs_add-kvgr4 MODULE vr_kvgr4.
  FIELD gs_add-kunnr MODULE vr_kunnr.
  FIELD gs_add-jbreak1 MODULE vr_jbreak1.
  FIELD gs_add-jbreak2 MODULE vr_jbreak2.
  FIELD gs_add-jbreak3 MODULE vr_jbreak3.
  FIELD gs_add-jbreak4 MODULE vr_jbreak4.
  FIELD gs_add-jbreak5 MODULE vr_jbreak5.
