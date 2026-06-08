
PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  MODULE sort.
  LOOP AT extract WITH CONTROL
   tctrl_zfkwiout CURSOR nextline.
    MODULE liste_show_liste.
    MODULE change_locking.
    MODULE validasi_cell.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zfkwiout-bukrs .
      FIELD zfkwiout-vkbur .
      FIELD zfkwiout-kunnr .
      FIELD zfkwiout-zsts .
      FIELD zfkwiout-status .
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zfkwiout-bukrs .
      FIELD zfkwiout-vkbur .
      FIELD zfkwiout-kunnr .
      MODULE user_entry.
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
