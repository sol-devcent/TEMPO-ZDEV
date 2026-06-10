
PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_ztkmsddt002 CURSOR nextline.
    MODULE liste_show_liste.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD ztkmsddt002-prctr .
      FIELD ztkmsddt002-lifnr .
      FIELD ztkmsddt002-percen .
      FIELD ztkmsddt002-ktext .
      FIELD ztkmsddt002-ltext .
      FIELD ztkmsddt002-name1 .
      MODULE set_update_flag ON CHAIN-REQUEST.
      MODULE table_modify.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD ztkmsddt002-prctr .
      FIELD ztkmsddt002-lifnr .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
