
PROCESS BEFORE OUTPUT.

  MODULE m_status_9020.

  FIELD d_netwr MODULE m_initiate_netwr.
  FIELD d_kzwi1 MODULE m_initiate_kzwi1.

PROCESS AFTER INPUT.

  MODULE m_exit AT EXIT-COMMAND.

  FIELD kna1-kunnr MODULE m_display_detail_cust AT CURSOR-SELECTION.
  FIELD s911-ebeln MODULE m_display_detail_po AT CURSOR-SELECTION.
  FIELD s911-belnr MODULE m_display_detail_doc AT CURSOR-SELECTION.

  MODULE m_user_command_9020.
