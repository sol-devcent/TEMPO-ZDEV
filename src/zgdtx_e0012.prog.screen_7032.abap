PROCESS BEFORE OUTPUT.

  MODULE status_7032.

  LOOP AT t_tx04s WITH CONTROL sp_dt7022s CURSOR
                   sp_dt7022s-current_line.

  ENDLOOP.

  LOOP AT t_tx04b WITH CONTROL sp_dt7022b CURSOR
                   sp_dt7022b-current_line.

  ENDLOOP.

PROCESS AFTER INPUT.
  LOOP AT t_tx04s.
  ENDLOOP.


  LOOP AT t_tx04b.
  ENDLOOP.

  MODULE user_command_7032e.




