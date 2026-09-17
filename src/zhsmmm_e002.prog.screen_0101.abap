
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE docking_and_split_container.

  MODULE main_alv.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD gs_head-matnr MODULE value_selection.
