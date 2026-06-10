FUNCTION zwmfm008.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROCE) TYPE  CHAR30 OPTIONAL
*"     VALUE(PI_TKNUM) TYPE  TKNUM OPTIONAL
*"     VALUE(PI_LGNUM) TYPE  LGNUM OPTIONAL
*"     VALUE(PI_TANUM) TYPE  TANUM OPTIONAL
*"  EXPORTING
*"     VALUE(PE_TYPE) TYPE  CHAR1
*"     VALUE(PE_MESS) TYPE  ZCHARA220
*"----------------------------------------------------------------------
  DATA : ls_vttk TYPE vttk,
         ls_ltak TYPE ltak,
         ls_likp TYPE likp.

  IF pi_tknum IS NOT INITIAL.
    SELECT SINGLE *
      FROM vttk
      INTO CORRESPONDING FIELDS OF ls_vttk
      WHERE tknum = pi_tknum.
    IF sy-subrc = 0.
      pe_type    = 'S'.
      pe_mess    = 'Shipment exist'.
    ELSE.
      pe_type    = 'E'.
      pe_mess    = 'Shipment tidak ditemukan'.
    ENDIF.
  ENDIF.

  IF pi_tanum IS NOT INITIAL.
    SELECT SINGLE *
      FROM ltak
      INTO CORRESPONDING FIELDS OF ls_ltak
      WHERE lgnum = pi_lgnum
        AND tanum = pi_tanum.

    IF ls_ltak-kquit IS INITIAL.
      CASE pi_proce.
        WHEN 'CHECK_AKHIR'.
          pe_type   = 'E'.
          pe_mess   = 'Please confirm TO'.
        WHEN OTHERS.
          pe_type   = 'S'.
          pe_mess   = 'Please confirm TO'.
      ENDCASE.
    ELSE.
      CASE pi_proce.
        WHEN 'CHECK_AKHIR'.
          SELECT SINGLE *
            FROM likp
            INTO CORRESPONDING FIELDS OF ls_likp
            WHERE vbeln = ls_ltak-vbeln.
          IF sy-subrc = 0.
            IF ls_likp-wadat_ist = '00000000'.
              pe_type   = 'E'.
              pe_mess   = 'DN belum PGI'.
            ELSE.
              pe_type   = 'S'.
              pe_mess   = 'TO Akhir bulan'.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          pe_type   = 'E'.
          pe_mess   = 'TO already confirmed'.
      ENDCASE.
    ENDIF.
  ENDIF.



ENDFUNCTION.
