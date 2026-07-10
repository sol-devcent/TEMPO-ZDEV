
PROCESS BEFORE OUTPUT.

  MODULE status_7022.

  LOOP AT t_tx04s WITH CONTROL sp_dt7022s CURSOR
                   sp_dt7022s-current_line.

  ENDLOOP.

  LOOP AT t_tx04b WITH CONTROL sp_dt7022b CURSOR
                   sp_dt7022b-current_line.

  ENDLOOP.

PROCESS AFTER INPUT.
  LOOP AT t_tx04s.
  MODULE user_command_7022i.

  ENDLOOP.


  LOOP AT t_tx04b.
  ENDLOOP.

  CHAIN.
    FIELD : tn_tx04-masatx.

*    MODULE m7012i_check_period ON CHAIN-REQUEST.
    MODULE cab_7012i_check_period ON CHAIN-REQUEST.

  ENDCHAIN.

  MODULE user_command_7022e.




