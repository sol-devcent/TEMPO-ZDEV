*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0012I01                                           *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7000e INPUT.

  DATA ld_lock_subrc LIKE sy-subrc.

  CASE okcode.
    WHEN 'BACK' OR 'CANC'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      SET SCREEN 0.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      SET SCREEN 0.
      LEAVE PROGRAM.
  ENDCASE.
  CLEAR: okcode.

ENDMODULE.                 " USER_COMMAND_7000  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7000 INPUT.
  CASE okcode.
    WHEN 'EXEC'.
      PERFORM f_closing.
*      PERFORM f_fill_comp_2itab.
*      CALL SCREEN 2000.
    WHEN 'BACK' OR 'CANC'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
  CLEAR: okcode.

ENDMODULE.                 " USER_COMMAND_7000  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7011 INPUT.

ENDMODULE.                 " USER_COMMAND_7011  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7011E  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7011e INPUT.

*  DATA ld_lock_subrc LIKE sy-subrc.

  CASE okcode.
    WHEN 'BACK' OR 'CANC'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      SET SCREEN 0.
      LEAVE PROGRAM.
    WHEN 'CREA'.
      PERFORM f_cab_7011_update_tx04.
  ENDCASE.
  CLEAR: okcode.

ENDMODULE.                 " USER_COMMAND_7011E  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7012E  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE cab_user_command_7012e INPUT.

*  DATA ld_lock_subrc LIKE sy-subrc.

  CASE okcode.
    WHEN 'BACK' OR 'CANC'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      SET SCREEN 0.
      LEAVE PROGRAM.
    WHEN 'EXEC'.
      PERFORM f_check_run.
      PERFORM f_cab_7012_update_tx04.
    WHEN 'CRET'.
      PERFORM f_cab_7012_create_tx04.
  ENDCASE.
  CLEAR: okcode.

ENDMODULE.                 " USER_COMMAND_7012E  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7021E  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7021e INPUT.

*  DATA ld_lock_subrc LIKE sy-subrc.

  CASE okcode.
    WHEN 'BACK' OR 'CANC'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      SET SCREEN 0.
      LEAVE PROGRAM.
    WHEN 'CREA'.
*-----create new tax period for gsber pusat
*     and all gsber belongs to pusat
      PERFORM f_check_run.

      PERFORM f_pusat_7021_update_tx04.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR: okcode.

ENDMODULE.                 " USER_COMMAND_7021E  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7022E  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7022e INPUT.

*  DATA ld_lock_subrc LIKE sy-subrc.

  CASE okcode.
    WHEN 'BACK' OR 'CANC'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      SET SCREEN 0.
      LEAVE PROGRAM.
    WHEN 'EXEC'.
      PERFORM f_check_run.

      IF    ts_tx04_masat = c_status_close.
        MESSAGE i000(zab) WITH text-i06.
      ELSE.
        PERFORM f_pusat_7022_update_tx04.
      ENDIF.
  ENDCASE.
  CLEAR: okcode.

ENDMODULE.                 " USER_COMMAND_7022E  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7024E  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7024e INPUT.
* SEE 'AT USER-COMMAND EVENT'

ENDMODULE.                 " USER_COMMAND_7024E  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7031E  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7031e INPUT.

*  DATA ld_lock_subrc LIKE sy-subrc.

  CASE okcode.
    WHEN 'BACK' OR 'CANC'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      SET SCREEN 0.
      LEAVE PROGRAM.
    WHEN 'EXEC'.
*      PERFORM f_7012_update_tx04.
  ENDCASE.
  CLEAR: okcode.

ENDMODULE.                 " USER_COMMAND_7031E  INPUT

*&---------------------------------------------------------------------*
*&      Module  M7012I_CHECK_PERIOD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE cab_7012i_check_period INPUT.
  DATA ld_lena TYPE i.
  DATA ld_lenn TYPE i.
  DATA ld_seli TYPE i.
  DATA ld_masa LIKE sy-datum.
  DATA ld_masn LIKE sy-datum.

  CHECK NOT tn_tx04-masatx IS INITIAL.
  ld_masa = p_masa.
  ld_masn = tn_tx04-masatx.
  SHIFT : ld_masa LEFT DELETING LEADING '0',
          ld_masn LEFT DELETING LEADING '0'.

  ld_lena = strlen( ld_masa ).
  ld_lenn = strlen( ld_masn ).
  ld_seli = tn_tx04-masatx - p_masa.

  IF ld_lenn LT 6.
    MESSAGE e000(zab) WITH text-m01.
  ENDIF.

  IF ( tn_tx04-masatx+4(2) GT 12 OR tn_tx04-masatx+4(2) LT 1 ).

    MESSAGE e000(zab) WITH text-m01.
  ENDIF.

  IF NOT ( ld_seli EQ 1 OR ld_seli EQ 91 ).
    MESSAGE e000(zab) WITH text-m02.
  ENDIF.

  CHECK tn_tx04-masatx LE p_masa.
  MESSAGE e000(zab) WITH text-i05.

  CLEAR :ld_lena,
  ld_lenn,
  ld_seli,
  ld_masa,
  ld_masn.

ENDMODULE.                 " M7012I_CHECK_PERIOD  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7032E  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7032e INPUT.

*  DATA ld_lock_subrc LIKE sy-subrc.

  CASE okcode.
    WHEN 'BACK' OR 'CANC'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
***added by Rahmadi
      CLEAR ld_lock_subrc.
      PERFORM f_release_tax_period CHANGING ld_lock_subrc.
      CHECK ld_lock_subrc = 0.
***end of addition
      SET SCREEN 0.
      LEAVE PROGRAM.
    WHEN 'EXEC' OR 'SIMU'.
      IF okcode EQ 'EXEC'.
        PERFORM f_check_run.
        CLEAR d_simu.
      ELSE.
        d_simu = 'X'.
      ENDIF.
      PERFORM f_nas_7032_update_tx04.
  ENDCASE.
  CLEAR: okcode,d_simu.
ENDMODULE.                 " USER_COMMAND_7032E  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7022I  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7022i INPUT.
  DATA ld_7022_answer.

  CLEAR ld_7022_answer.


  CHECK t_tx04s-sel EQ 'X'.
  CHECK okcode EQ 'OPEN'.

  PERFORM f_confirm2continue USING text-ph1 text-p11 text-pb1
                                  CHANGING ld_7022_answer.

  CHECK ld_7022_answer EQ '1'.

  PERFORM f_pusat_7022_openbranch_tx04.

  CLEAR ld_7022_answer.
ENDMODULE.                 " USER_COMMAND_7022I  INPUT
