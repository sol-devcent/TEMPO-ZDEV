
PROCESS BEFORE OUTPUT.
  MODULE status_0500.
  LOOP WITH CONTROL tc_zmmattnt.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.
  LOOP WITH CONTROL tc_zmmattnt.
    CHAIN.
      FIELD gt_zmmattnt-mark.
      FIELD gt_zmmattnt-zhier.
      FIELD gt_zmmattnt-zlvl.
      FIELD gt_zmmattnt-zdesc.

      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command_0500.
