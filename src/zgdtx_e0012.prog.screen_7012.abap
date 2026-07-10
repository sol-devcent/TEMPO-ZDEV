
PROCESS BEFORE OUTPUT.

  MODULE cab_status_7012.


PROCESS AFTER INPUT.
  CHAIN.
    FIELD : tn_tx04-masatx.

    MODULE cab_7012i_check_period ON CHAIN-REQUEST.
  ENDCHAIN.

  MODULE cab_user_command_7012e.

