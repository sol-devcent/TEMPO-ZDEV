
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP AT gt_listd INTO listd
                   WITH CONTROL tc_bdc02.
    MODULE get_lines.
  ENDLOOP.

PROCESS AFTER INPUT.
  LOOP AT gt_listd.
    CHAIN.
      FIELD listd-matnr.
      FIELD listd-maktx.
      FIELD listd-status.
      FIELD listd-labst4.
      FIELD listd-labst5.
      MODULE modify_lines.
    ENDCHAIN.
  ENDLOOP.

  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.
  FIELD bdch-list MODULE material_list.
