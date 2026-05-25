
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfexpense-vbund MODULE value_vbund.
  FIELD gv_ktext MODULE value_ktext.
