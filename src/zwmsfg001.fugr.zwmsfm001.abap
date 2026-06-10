FUNCTION zwmsfm001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROCESS) TYPE  CHAR30
*"     VALUE(PI_LGNUM) TYPE  LTAK-LGNUM
*"     VALUE(PI_TANUM) TYPE  LTAK-TANUM
*"  TABLES
*"      PT_LTAK STRUCTURE  LTAK
*"      PT_LTAP STRUCTURE  LTAP
*"      PT_LTAP_CONF STRUCTURE  LTAP_CONF
*"----------------------------------------------------------------------
  DATA : ls_ltap      TYPE ltap,
         ls_ltap_conf TYPE ltap_conf.

  SELECT *
    FROM ltak
    INTO CORRESPONDING FIELDS OF TABLE pt_ltak
    WHERE lgnum = pi_lgnum
      AND tanum = pi_tanum
    ORDER BY PRIMARY KEY.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE pt_ltap
    WHERE lgnum = pi_lgnum
      AND tanum = pi_tanum
    ORDER BY PRIMARY KEY.

  CASE pi_process.
    WHEN 'PUTAWAY'.
      LOOP AT pt_ltap INTO ls_ltap.
        ls_ltap_conf-tanum   = ls_ltap-tanum.
        ls_ltap_conf-tapos   = ls_ltap-tapos.
        ls_ltap_conf-squit   = 'X'.
"        ls_ltap_conf-BESTQ   = ls_ltap-BESTQ.
        APPEND ls_ltap_conf TO pt_ltap_conf.
        CLEAR ls_ltap_conf.
      ENDLOOP.
  ENDCASE.




ENDFUNCTION.
