
PROCESS BEFORE OUTPUT.

  MODULE status_0500.
* PBO FLOW LOGIC FOR TABLECONTROL 'TC_0500'
  MODULE tc_0500_init.
* MODULE TC_0500_CHANGE_TC_ATTR.
* MODULE TC_0500_CHANGE_COL_ATTR.
  LOOP AT   g_tc_0500_itab
       INTO g_tc_0500_wa
       WITH CONTROL tc_0500
       CURSOR tc_0500-current_line.
*   MODULE TC_0500_CHANGE_FIELD_ATTR
    MODULE tc_0500_move.

    MODULE tc_0500_get_lines.
  ENDLOOP.

*
PROCESS AFTER INPUT.
* PAI FLOW LOGIC FOR TABLECONTROL 'TC_0500'
  LOOP AT g_tc_0500_itab.
    CHAIN.
      FIELD zfod-vkbur.
      FIELD zfod-zfoid.
      FIELD zfod-kunnr.
      FIELD zfod-name1.
      FIELD zfod-zuonr.
      FIELD zfod-xref2.
      FIELD zfod-budat.
      FIELD zfod-zfbdt.
      FIELD zfod-gidat.
      FIELD zfod-giro.
      FIELD zfod-bill.
      FIELD zfod-faktur.
      FIELD zfod-status.
      FIELD zfod-text.
      FIELD zfod-text2.
      FIELD zfod-waers.
      FIELD zfod-zclos.

      MODULE tc_0500_modify ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.

  MODULE tc_0500_user_command.
* MODULE TC_0500_CHANGE_TC_ATTR.
* MODULE TC_0500_CHANGE_COL_ATTR.

  MODULE user_command_0500.
